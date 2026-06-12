import '../../../point_of_sales/order/models/order.dart' as pos_order;
import 'order_status.dart';

enum OrderWorkspaceSlaTone { neutral, info, success, warning, danger }

class OrderWorkspaceSlaThresholds {
  final Duration freshLimit;
  final Duration watchLimit;
  final Duration staleLimit;

  const OrderWorkspaceSlaThresholds({
    this.freshLimit = const Duration(minutes: 30),
    this.watchLimit = const Duration(hours: 2),
    this.staleLimit = const Duration(hours: 6),
  });
}

class OrderWorkspaceSlaBand {
  final String id;
  final String label;
  final String rangeLabel;
  final String detail;
  final int count;
  final OrderWorkspaceSlaTone tone;

  const OrderWorkspaceSlaBand({
    required this.id,
    required this.label,
    required this.rangeLabel,
    required this.detail,
    required this.count,
    required this.tone,
  });
}

class OrderWorkspaceSlaSummary {
  final int orderCount;
  final int activeOrderCount;
  final int terminalOrderCount;
  final Duration oldestActiveAge;
  final String title;
  final String summary;
  final String badgeLabel;
  final String oldestActiveAgeLabel;
  final OrderWorkspaceSlaTone tone;
  final List<OrderWorkspaceSlaBand> bands;

  const OrderWorkspaceSlaSummary({
    required this.orderCount,
    required this.activeOrderCount,
    required this.terminalOrderCount,
    required this.oldestActiveAge,
    required this.title,
    required this.summary,
    required this.badgeLabel,
    required this.oldestActiveAgeLabel,
    required this.tone,
    required this.bands,
  });

  factory OrderWorkspaceSlaSummary.fromOrders({
    required List<pos_order.Order> orders,
    required DateTime now,
    OrderWorkspaceSlaThresholds thresholds =
        const OrderWorkspaceSlaThresholds(),
  }) {
    final buckets = _SlaBuckets();

    for (final order in orders) {
      if (_isTerminalOrder(order)) {
        buckets.terminalCount += 1;
        continue;
      }

      final age = _orderAge(order.createdAt, now);
      buckets.activeCount += 1;
      buckets.recordAge(age);

      if (age <= thresholds.freshLimit) {
        buckets.freshCount += 1;
      } else if (age <= thresholds.watchLimit) {
        buckets.watchCount += 1;
      } else if (age <= thresholds.staleLimit) {
        buckets.staleCount += 1;
      } else {
        buckets.escalationCount += 1;
      }
    }

    final headline = _headlineFor(buckets);
    final oldestAge = buckets.oldestAge ?? Duration.zero;

    return OrderWorkspaceSlaSummary(
      orderCount: orders.length,
      activeOrderCount: buckets.activeCount,
      terminalOrderCount: buckets.terminalCount,
      oldestActiveAge: oldestAge,
      title: headline.title,
      summary: headline.summary,
      badgeLabel: _activeLabel(buckets.activeCount),
      oldestActiveAgeLabel: _durationLabel(oldestAge),
      tone: headline.tone,
      bands: List.unmodifiable([
        _band(
          id: 'fresh',
          label: 'Fresh',
          rangeLabel: '<= ${_durationLabel(thresholds.freshLimit)}',
          count: buckets.freshCount,
          detail: 'Inside intake target',
          tone: OrderWorkspaceSlaTone.success,
        ),
        _band(
          id: 'watch',
          label: 'Watch',
          rangeLabel:
              '${_durationLabel(thresholds.freshLimit)}-${_durationLabel(thresholds.watchLimit)}',
          count: buckets.watchCount,
          detail: 'Keep fulfillment moving',
          tone: OrderWorkspaceSlaTone.info,
        ),
        _band(
          id: 'stale',
          label: 'Stale',
          rangeLabel:
              '${_durationLabel(thresholds.watchLimit)}-${_durationLabel(thresholds.staleLimit)}',
          count: buckets.staleCount,
          detail: 'Needs same-shift action',
          tone: OrderWorkspaceSlaTone.warning,
        ),
        _band(
          id: 'escalate',
          label: 'Escalate',
          rangeLabel: '> ${_durationLabel(thresholds.staleLimit)}',
          count: buckets.escalationCount,
          detail: 'Manager review recommended',
          tone: OrderWorkspaceSlaTone.danger,
        ),
      ]),
    );
  }
}

({String title, String summary, OrderWorkspaceSlaTone tone}) _headlineFor(
  _SlaBuckets buckets,
) {
  if (buckets.activeCount == 0 && buckets.terminalCount == 0) {
    return (
      title: 'No queue age yet',
      summary: 'Visible orders will be aged once work enters this workspace.',
      tone: OrderWorkspaceSlaTone.neutral,
    );
  }

  if (buckets.activeCount == 0) {
    return (
      title: 'No active aging risk',
      summary:
          'All ${buckets.terminalCount} visible ${_noun(buckets.terminalCount, 'order')} are closed or terminal.',
      tone: OrderWorkspaceSlaTone.success,
    );
  }

  if (buckets.escalationCount > 0) {
    return (
      title: 'Aging queue needs escalation',
      summary:
          '${buckets.escalationCount} active ${_noun(buckets.escalationCount, 'order')} exceeded the long-wait threshold.',
      tone: OrderWorkspaceSlaTone.danger,
    );
  }

  if (buckets.staleCount > 0) {
    return (
      title: 'Stale orders need attention',
      summary:
          '${buckets.staleCount} active ${_noun(buckets.staleCount, 'order')} should be cleared this shift.',
      tone: OrderWorkspaceSlaTone.warning,
    );
  }

  if (buckets.watchCount > 0) {
    return (
      title: 'Queue is warming up',
      summary:
          '${buckets.watchCount} active ${_noun(buckets.watchCount, 'order')} are approaching the stale window.',
      tone: OrderWorkspaceSlaTone.info,
    );
  }

  return (
    title: 'Queue age is fresh',
    summary:
        '${buckets.activeCount} active ${_noun(buckets.activeCount, 'order')} remain inside the intake target.',
    tone: OrderWorkspaceSlaTone.success,
  );
}

OrderWorkspaceSlaBand _band({
  required String id,
  required String label,
  required String rangeLabel,
  required int count,
  required String detail,
  required OrderWorkspaceSlaTone tone,
}) {
  return OrderWorkspaceSlaBand(
    id: id,
    label: label,
    rangeLabel: rangeLabel,
    count: count,
    detail: '$count ${_noun(count, 'order')} | $detail',
    tone: tone,
  );
}

bool _isTerminalOrder(pos_order.Order order) {
  return switch (normalizeOrderStatus(order.status)) {
    'completed' || 'cancelled' => true,
    _ => false,
  };
}

Duration _orderAge(DateTime createdAt, DateTime now) {
  final age = now.difference(createdAt);
  return age.isNegative ? Duration.zero : age;
}

String _activeLabel(int count) {
  return '$count active';
}

String _durationLabel(Duration duration) {
  if (duration.inDays > 0) {
    final hours = duration.inHours.remainder(24);
    if (hours == 0) return '${duration.inDays}d';
    return '${duration.inDays}d ${hours}h';
  }

  if (duration.inHours > 0) {
    final minutes = duration.inMinutes.remainder(60);
    if (minutes == 0) return '${duration.inHours}h';
    return '${duration.inHours}h ${minutes}m';
  }

  return '${duration.inMinutes}m';
}

String _noun(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

class _SlaBuckets {
  int activeCount = 0;
  int terminalCount = 0;
  int freshCount = 0;
  int watchCount = 0;
  int staleCount = 0;
  int escalationCount = 0;
  Duration? oldestAge;

  void recordAge(Duration age) {
    final currentOldest = oldestAge;
    if (currentOldest == null || age > currentOldest) {
      oldestAge = age;
    }
  }
}

import '../../../point_of_sales/order/models/order.dart' as pos_order;
import 'order_attention.dart';
import 'order_fulfillment_promise_policy.dart';
import 'order_status.dart';

export 'order_fulfillment_promise_policy.dart';

enum OrderFulfillmentPromiseTone { neutral, info, success, warning, danger }

class OrderFulfillmentPromiseBand {
  final String id;
  final String label;
  final String detail;
  final int count;
  final OrderFulfillmentPromiseTone tone;

  const OrderFulfillmentPromiseBand({
    required this.id,
    required this.label,
    required this.detail,
    required this.count,
    required this.tone,
  });
}

class OrderFulfillmentPromiseSummary {
  final int orderCount;
  final int activeOrderCount;
  final int terminalOrderCount;
  final int blockedCount;
  final int overTargetCount;
  final int dueSoonCount;
  final int readyHandoffCount;
  final int onTrackCount;
  final Duration? nextPromiseDueIn;
  final String title;
  final String summary;
  final String badgeLabel;
  final String nextPromiseDueLabel;
  final OrderFulfillmentPromiseTone tone;
  final List<OrderFulfillmentPromiseBand> bands;

  const OrderFulfillmentPromiseSummary({
    required this.orderCount,
    required this.activeOrderCount,
    required this.terminalOrderCount,
    required this.blockedCount,
    required this.overTargetCount,
    required this.dueSoonCount,
    required this.readyHandoffCount,
    required this.onTrackCount,
    required this.nextPromiseDueIn,
    required this.title,
    required this.summary,
    required this.badgeLabel,
    required this.nextPromiseDueLabel,
    required this.tone,
    required this.bands,
  });

  factory OrderFulfillmentPromiseSummary.fromOrders({
    required List<pos_order.Order> orders,
    required DateTime now,
    OrderFulfillmentPromisePolicy policy =
        const OrderFulfillmentPromisePolicy(),
  }) {
    final buckets = _PromiseBuckets();

    for (final order in orders) {
      if (_isTerminalOrder(order)) {
        buckets.terminalCount += 1;
        continue;
      }

      buckets.activeCount += 1;

      if (_isPromiseBlocked(order)) {
        buckets.blockedCount += 1;
        continue;
      }

      final target = policy.targetFor(order);
      final deadline = order.createdAt.add(target.duration);
      final remaining = deadline.difference(now);

      if (!deadline.isAfter(now)) {
        buckets.overTargetCount += 1;
        continue;
      }

      buckets.recordNextDue(remaining);

      if (remaining <= policy.warningWindow) {
        buckets.dueSoonCount += 1;
        continue;
      }

      if (normalizeOrderStatus(order.status) == 'ready') {
        buckets.readyHandoffCount += 1;
        continue;
      }

      buckets.onTrackCount += 1;
    }

    final headline = _headlineFor(buckets);

    return OrderFulfillmentPromiseSummary(
      orderCount: orders.length,
      activeOrderCount: buckets.activeCount,
      terminalOrderCount: buckets.terminalCount,
      blockedCount: buckets.blockedCount,
      overTargetCount: buckets.overTargetCount,
      dueSoonCount: buckets.dueSoonCount,
      readyHandoffCount: buckets.readyHandoffCount,
      onTrackCount: buckets.onTrackCount,
      nextPromiseDueIn: buckets.nextDueIn,
      title: headline.title,
      summary: headline.summary,
      badgeLabel: _activeLabel(buckets.activeCount),
      nextPromiseDueLabel: _nextDueLabel(buckets.nextDueIn),
      tone: headline.tone,
      bands: List.unmodifiable([
        _band(
          id: 'blocked',
          label: 'Blocked',
          count: buckets.blockedCount,
          detail: 'Payment, customer, or routing data needed',
          tone: OrderFulfillmentPromiseTone.danger,
        ),
        _band(
          id: 'over_target',
          label: 'Over target',
          count: buckets.overTargetCount,
          detail: 'Past configured fulfillment promise',
          tone: OrderFulfillmentPromiseTone.danger,
        ),
        _band(
          id: 'due_soon',
          label: 'Due soon',
          count: buckets.dueSoonCount,
          detail: 'Inside next ${_durationLabel(policy.warningWindow)}',
          tone: OrderFulfillmentPromiseTone.warning,
        ),
        _band(
          id: 'ready_handoff',
          label: 'Ready handoff',
          count: buckets.readyHandoffCount,
          detail: 'Prepared for pickup, courier, or dispatch',
          tone: OrderFulfillmentPromiseTone.info,
        ),
        _band(
          id: 'on_track',
          label: 'On track',
          count: buckets.onTrackCount,
          detail: 'Within the target fulfillment window',
          tone: OrderFulfillmentPromiseTone.success,
        ),
      ]),
    );
  }
}

({String title, String summary, OrderFulfillmentPromiseTone tone}) _headlineFor(
  _PromiseBuckets buckets,
) {
  if (buckets.activeCount == 0 && buckets.terminalCount == 0) {
    return (
      title: 'No promise pressure yet',
      summary: 'Visible orders will be measured once fulfillment work appears.',
      tone: OrderFulfillmentPromiseTone.neutral,
    );
  }

  if (buckets.activeCount == 0) {
    return (
      title: 'Fulfillment promises are closed',
      summary:
          'All ${buckets.terminalCount} visible ${_noun(buckets.terminalCount, 'order')} are completed or cancelled.',
      tone: OrderFulfillmentPromiseTone.success,
    );
  }

  if (buckets.blockedCount > 0) {
    return (
      title: 'Promise blockers need clearing',
      summary:
          '${buckets.blockedCount} active ${_noun(buckets.blockedCount, 'order')} need payment, customer, or routing data before fulfillment can progress.',
      tone: OrderFulfillmentPromiseTone.danger,
    );
  }

  if (buckets.overTargetCount > 0) {
    return (
      title: 'Fulfillment promises are over target',
      summary:
          '${buckets.overTargetCount} active ${_noun(buckets.overTargetCount, 'order')} exceeded the configured fulfillment promise.',
      tone: OrderFulfillmentPromiseTone.danger,
    );
  }

  if (buckets.dueSoonCount > 0) {
    return (
      title: 'Promise window is tightening',
      summary:
          '${buckets.dueSoonCount} active ${_noun(buckets.dueSoonCount, 'order')} should be moved before the next promise target.',
      tone: OrderFulfillmentPromiseTone.warning,
    );
  }

  if (buckets.readyHandoffCount > 0) {
    return (
      title: 'Ready handoffs are waiting',
      summary:
          '${buckets.readyHandoffCount} ready ${_noun(buckets.readyHandoffCount, 'order')} can move to pickup, courier, or dispatch.',
      tone: OrderFulfillmentPromiseTone.info,
    );
  }

  return (
    title: 'Fulfillment promises are on track',
    summary:
        '${buckets.onTrackCount} active ${_noun(buckets.onTrackCount, 'order')} remain inside their target fulfillment windows.',
    tone: OrderFulfillmentPromiseTone.success,
  );
}

OrderFulfillmentPromiseBand _band({
  required String id,
  required String label,
  required int count,
  required String detail,
  required OrderFulfillmentPromiseTone tone,
}) {
  return OrderFulfillmentPromiseBand(
    id: id,
    label: label,
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

bool _isPromiseBlocked(pos_order.Order order) {
  return !order.isPaid ||
      order.fulfillment == null ||
      ecommerceOrderHasCriticalAttention(order);
}

String _activeLabel(int count) {
  return '$count active';
}

String _nextDueLabel(Duration? remaining) {
  if (remaining == null) return 'No active target';
  return _durationLabel(remaining);
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

class _PromiseBuckets {
  int activeCount = 0;
  int terminalCount = 0;
  int blockedCount = 0;
  int overTargetCount = 0;
  int dueSoonCount = 0;
  int readyHandoffCount = 0;
  int onTrackCount = 0;
  Duration? nextDueIn;

  void recordNextDue(Duration remaining) {
    final current = nextDueIn;
    if (current == null || remaining < current) {
      nextDueIn = remaining;
    }
  }
}

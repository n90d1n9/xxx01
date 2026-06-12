import '../../../point_of_sales/order/models/order.dart' as pos_order;
import 'order_insights.dart';
import 'order_status.dart';
import 'order_workspace_view.dart';

enum OrderWorkspaceBriefingTone { neutral, info, success, warning, danger }

class OrderWorkspaceBriefingCue {
  final String id;
  final String label;
  final String detail;
  final OrderWorkspaceBriefingTone tone;

  const OrderWorkspaceBriefingCue({
    required this.id,
    required this.label,
    required this.detail,
    required this.tone,
  });
}

class OrderWorkspaceBriefing {
  final String title;
  final String summary;
  final String detail;
  final String badgeLabel;
  final OrderWorkspaceBriefingTone tone;
  final List<OrderWorkspaceBriefingCue> cues;

  const OrderWorkspaceBriefing({
    required this.title,
    required this.summary,
    required this.detail,
    required this.badgeLabel,
    required this.tone,
    required this.cues,
  });

  factory OrderWorkspaceBriefing.fromOrders({
    required OrderWorkspaceContext workspace,
    required List<pos_order.Order> orders,
    required int totalOrderCount,
  }) {
    final insights = OrderInsights.fromOrders(orders);
    final unpaidCount = insights.orderCount - insights.paidOrderCount;
    final readyCount =
        orders
            .where((order) => normalizeOrderStatus(order.status) == 'ready')
            .length;
    final topChannel = _firstOrNull(insights.channelBreakdown);
    final topFulfillment = _firstOrNull(insights.fulfillmentBreakdown);

    if (totalOrderCount == 0) {
      return OrderWorkspaceBriefing(
        title: 'Waiting for ecommerce orders',
        summary: 'No ecommerce orders have landed yet.',
        detail:
            'Orders from online checkout, marketplaces, and channel handoff will appear here.',
        badgeLabel: 'No orders',
        tone: OrderWorkspaceBriefingTone.neutral,
        cues: const [
          OrderWorkspaceBriefingCue(
            id: 'watch_intake',
            label: 'Watch intake',
            detail: 'Keep the workspace ready for first-channel orders.',
            tone: OrderWorkspaceBriefingTone.neutral,
          ),
        ],
      );
    }

    if (orders.isEmpty) {
      return OrderWorkspaceBriefing(
        title: '${workspace.label} is clear',
        summary:
            'No orders match this workspace while $totalOrderCount ${_noun(totalOrderCount, 'order')} remain available elsewhere.',
        detail:
            workspace.isPreset
                ? 'Use another workspace or a recommended next move when new work arrives.'
                : 'Broaden the filters or switch back to a preset workspace.',
        badgeLabel: 'Clear',
        tone: OrderWorkspaceBriefingTone.success,
        cues: const [
          OrderWorkspaceBriefingCue(
            id: 'clear_workspace',
            label: 'No matching work',
            detail: 'This queue has no active orders to handle right now.',
            tone: OrderWorkspaceBriefingTone.success,
          ),
        ],
      );
    }

    final cues = <OrderWorkspaceBriefingCue>[];

    if (insights.criticalAttentionOrderCount > 0) {
      cues.add(
        OrderWorkspaceBriefingCue(
          id: 'fix_blockers',
          label: 'Fix blockers',
          detail:
              '${insights.criticalAttentionOrderCount} high-priority ${_noun(insights.criticalAttentionOrderCount, 'order')} need missing data or routing.',
          tone: OrderWorkspaceBriefingTone.danger,
        ),
      );
    }

    if (unpaidCount > 0) {
      cues.add(
        OrderWorkspaceBriefingCue(
          id: 'confirm_payment',
          label: 'Confirm payment',
          detail:
              '$unpaidCount unpaid ${_noun(unpaidCount, 'order')} should be collected or verified before handoff.',
          tone: OrderWorkspaceBriefingTone.warning,
        ),
      );
    }

    if (readyCount > 0) {
      cues.add(
        OrderWorkspaceBriefingCue(
          id: 'handoff_ready',
          label: 'Move handoff',
          detail:
              '$readyCount ready ${_noun(readyCount, 'order')} can move toward pickup, courier, or dispatch.',
          tone: OrderWorkspaceBriefingTone.info,
        ),
      );
    }

    if (insights.externalSettlementCount > 0) {
      cues.add(
        OrderWorkspaceBriefingCue(
          id: 'reconcile_settlement',
          label: 'Reconcile settlement',
          detail:
              '${insights.externalSettlementCount} externally settled ${_noun(insights.externalSettlementCount, 'order')} need channel matching.',
          tone: OrderWorkspaceBriefingTone.info,
        ),
      );
    }

    if (cues.isEmpty) {
      cues.add(
        OrderWorkspaceBriefingCue(
          id: 'keep_flow',
          label: 'Keep flow',
          detail:
              'No active blockers across ${insights.orderCount} ${_noun(insights.orderCount, 'order')}.',
          tone: OrderWorkspaceBriefingTone.success,
        ),
      );
    }

    final headline = _headlineFor(
      insights: insights,
      unpaidCount: unpaidCount,
      readyCount: readyCount,
    );
    final detail = _detailFor(
      workspace: workspace,
      topChannel: topChannel,
      topFulfillment: topFulfillment,
    );

    return OrderWorkspaceBriefing(
      title: headline.title,
      summary: headline.summary,
      detail: detail,
      badgeLabel: ecommerceOrderWorkspaceResultText(insights.orderCount),
      tone: headline.tone,
      cues: List.unmodifiable(cues.take(3)),
    );
  }
}

({String title, String summary, OrderWorkspaceBriefingTone tone}) _headlineFor({
  required OrderInsights insights,
  required int unpaidCount,
  required int readyCount,
}) {
  if (insights.criticalAttentionOrderCount > 0) {
    final count = insights.criticalAttentionOrderCount;
    return (
      title: 'Resolve blockers first',
      summary:
          '$count high-priority ${_noun(count, 'order')} ${_verb(count)} blocking ecommerce fulfillment.',
      tone: OrderWorkspaceBriefingTone.danger,
    );
  }

  if (insights.attentionOrderCount > 0) {
    final count = insights.attentionOrderCount;
    return (
      title: 'Clear active exceptions',
      summary:
          '$count actionable ${_noun(count, 'order')} ${_verb(count)} waiting for operator attention.',
      tone: OrderWorkspaceBriefingTone.warning,
    );
  }

  if (unpaidCount > 0) {
    return (
      title: 'Confirm open payments',
      summary:
          '$unpaidCount unpaid ${_noun(unpaidCount, 'order')} should be settled before closeout.',
      tone: OrderWorkspaceBriefingTone.warning,
    );
  }

  if (readyCount > 0) {
    return (
      title: 'Move ready handoffs',
      summary:
          '$readyCount ready ${_noun(readyCount, 'order')} can move to pickup, courier, or dispatch.',
      tone: OrderWorkspaceBriefingTone.info,
    );
  }

  if (insights.externalSettlementCount > 0) {
    final count = insights.externalSettlementCount;
    return (
      title: 'Reconcile settled channels',
      summary:
          '$count externally settled ${_noun(count, 'order')} ${_verb(count)} ready for finance matching.',
      tone: OrderWorkspaceBriefingTone.info,
    );
  }

  return (
    title: 'Workspace is flowing',
    summary:
        '${insights.orderCount} ${_noun(insights.orderCount, 'order')} are paid and clear of operational blockers.',
    tone: OrderWorkspaceBriefingTone.success,
  );
}

String _detailFor({
  required OrderWorkspaceContext workspace,
  required OrderBreakdown? topChannel,
  required OrderBreakdown? topFulfillment,
}) {
  final focusParts = <String>[];
  if (topChannel != null) {
    focusParts.add(
      '${topChannel.label} leads with ${topChannel.orderCount} ${_noun(topChannel.orderCount, 'order')}',
    );
  }
  if (topFulfillment != null) {
    focusParts.add('${topFulfillment.label} is the main fulfillment path');
  }

  if (focusParts.isEmpty) return workspace.description;
  return '${focusParts.join('; ')}. ${workspace.description}';
}

String _noun(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

String _verb(int count) {
  return count == 1 ? 'is' : 'are';
}

T? _firstOrNull<T>(List<T> values) {
  return values.isEmpty ? null : values.first;
}

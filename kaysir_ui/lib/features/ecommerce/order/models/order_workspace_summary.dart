import '../../../point_of_sales/order/models/order.dart' as pos_order;
import 'order_insights.dart';
import 'order_workspace_view.dart';

enum OrderWorkspaceSignalTone { neutral, info, success, warning, danger }

class OrderWorkspaceSignal {
  final String id;
  final String label;
  final String value;
  final String detail;
  final OrderWorkspaceSignalTone tone;

  const OrderWorkspaceSignal({
    required this.id,
    required this.label,
    required this.value,
    required this.detail,
    required this.tone,
  });
}

class OrderWorkspaceSummary {
  final String workspaceId;
  final String title;
  final String subtitle;
  final List<OrderWorkspaceSignal> signals;

  const OrderWorkspaceSummary({
    required this.workspaceId,
    required this.title,
    required this.subtitle,
    required this.signals,
  });

  factory OrderWorkspaceSummary.fromOrders({
    required OrderWorkspaceContext workspace,
    required List<pos_order.Order> orders,
  }) {
    final insights = OrderInsights.fromOrders(orders);
    final orderCount = insights.orderCount;

    return OrderWorkspaceSummary(
      workspaceId: workspace.id,
      title: '${workspace.label} snapshot',
      subtitle:
          '${ecommerceOrderWorkspaceResultText(orderCount)}, ${workspace.description}',
      signals: [
        _channelSignal(insights),
        _fulfillmentSignal(insights),
        _paymentSignal(insights),
        _attentionSignal(insights),
      ],
    );
  }
}

OrderWorkspaceSignal _channelSignal(OrderInsights insights) {
  final topChannel = _firstOrNull(insights.channelBreakdown);
  final orderCount = insights.orderCount;

  return OrderWorkspaceSignal(
    id: 'top_channel',
    label: 'Top channel',
    value: topChannel?.label ?? 'Unassigned',
    detail:
        topChannel == null
            ? 'No channel data yet'
            : '${topChannel.orderCount} of $orderCount ${_noun(orderCount, 'order')}, ${insights.channelBreakdown.length} ${_noun(insights.channelBreakdown.length, 'channel')}',
    tone:
        topChannel == null
            ? OrderWorkspaceSignalTone.neutral
            : OrderWorkspaceSignalTone.info,
  );
}

OrderWorkspaceSignal _fulfillmentSignal(OrderInsights insights) {
  final topMode = _firstOrNull(insights.fulfillmentBreakdown);
  final orderCount = insights.orderCount;

  return OrderWorkspaceSignal(
    id: 'fulfillment_mix',
    label: 'Fulfillment mix',
    value: topMode?.label ?? 'Unassigned',
    detail:
        topMode == null
            ? 'No fulfillment data yet'
            : '${topMode.orderCount} of $orderCount ${_noun(orderCount, 'order')}, ${insights.fulfillmentBreakdown.length} ${_noun(insights.fulfillmentBreakdown.length, 'mode')}',
    tone:
        topMode == null
            ? OrderWorkspaceSignalTone.neutral
            : OrderWorkspaceSignalTone.info,
  );
}

OrderWorkspaceSignal _paymentSignal(OrderInsights insights) {
  final unpaidCount = insights.orderCount - insights.paidOrderCount;
  final detailParts = <String>[
    if (insights.orderCount == 0)
      'No payment activity'
    else if (unpaidCount == 0)
      'All paid'
    else
      '$unpaidCount unpaid',
    if (insights.externalSettlementCount > 0)
      '${insights.externalSettlementCount} external settlement',
  ];

  return OrderWorkspaceSignal(
    id: 'payment_health',
    label: 'Payment health',
    value: '${insights.paidOrderCount}/${insights.orderCount} paid',
    detail: detailParts.join(', '),
    tone:
        insights.orderCount == 0
            ? OrderWorkspaceSignalTone.neutral
            : unpaidCount > 0
            ? OrderWorkspaceSignalTone.warning
            : insights.externalSettlementCount > 0
            ? OrderWorkspaceSignalTone.info
            : OrderWorkspaceSignalTone.success,
  );
}

OrderWorkspaceSignal _attentionSignal(OrderInsights insights) {
  return OrderWorkspaceSignal(
    id: 'ops_attention',
    label: 'Ops attention',
    value:
        insights.attentionOrderCount == 0
            ? 'Clear'
            : '${insights.attentionOrderCount} ${insights.attentionOrderCount == 1 ? 'needs' : 'need'} review',
    detail:
        insights.orderCount == 0
            ? 'No order activity'
            : insights.criticalAttentionOrderCount > 0
            ? '${insights.criticalAttentionOrderCount} high priority'
            : insights.attentionOrderCount > 0
            ? 'Review recommended'
            : 'No operational blockers',
    tone:
        insights.criticalAttentionOrderCount > 0
            ? OrderWorkspaceSignalTone.danger
            : insights.attentionOrderCount > 0
            ? OrderWorkspaceSignalTone.warning
            : insights.orderCount > 0
            ? OrderWorkspaceSignalTone.success
            : OrderWorkspaceSignalTone.neutral,
  );
}

String _noun(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

T? _firstOrNull<T>(List<T> values) {
  return values.isEmpty ? null : values.first;
}

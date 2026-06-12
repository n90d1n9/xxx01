import '../../../point_of_sales/order/models/order.dart' as pos_order;
import 'order_attention.dart';
import 'order_payment_scope.dart';

class OrderBreakdown {
  final String id;
  final String label;
  final int orderCount;
  final double revenue;

  const OrderBreakdown({
    required this.id,
    required this.label,
    required this.orderCount,
    required this.revenue,
  });
}

class OrderInsights {
  final int orderCount;
  final double revenue;
  final double averageOrderValue;
  final int paidOrderCount;
  final int externalSettlementCount;
  final int attentionOrderCount;
  final int criticalAttentionOrderCount;
  final List<OrderBreakdown> channelBreakdown;
  final List<OrderBreakdown> fulfillmentBreakdown;

  const OrderInsights({
    required this.orderCount,
    required this.revenue,
    required this.averageOrderValue,
    required this.paidOrderCount,
    required this.externalSettlementCount,
    required this.attentionOrderCount,
    required this.criticalAttentionOrderCount,
    required this.channelBreakdown,
    required this.fulfillmentBreakdown,
  });

  factory OrderInsights.fromOrders(List<pos_order.Order> orders) {
    final revenue = orders.fold<double>(0, (sum, order) => sum + order.total);
    final orderCount = orders.length;

    return OrderInsights(
      orderCount: orderCount,
      revenue: revenue,
      averageOrderValue: orderCount == 0 ? 0 : revenue / orderCount,
      paidOrderCount: orders.where((order) => order.isPaid).length,
      externalSettlementCount:
          orders.where(ecommerceOrderUsesExternalSettlement).length,
      attentionOrderCount: orders.where(ecommerceOrderNeedsAttention).length,
      criticalAttentionOrderCount:
          orders.where(ecommerceOrderHasCriticalAttention).length,
      channelBreakdown: _buildBreakdown(
        orders: orders,
        keyFor: (order) => order.fulfillment?.commerceChannelId ?? 'unknown',
        labelFor:
            (order) => order.fulfillment?.commerceChannelLabel ?? 'Unassigned',
      ),
      fulfillmentBreakdown: _buildBreakdown(
        orders: orders,
        keyFor:
            (order) => order.fulfillment?.fulfillmentModeKey ?? 'unassigned',
        labelFor:
            (order) => order.fulfillment?.fulfillmentModeLabel ?? 'Unassigned',
      ),
    );
  }

  static const empty = OrderInsights(
    orderCount: 0,
    revenue: 0,
    averageOrderValue: 0,
    paidOrderCount: 0,
    externalSettlementCount: 0,
    attentionOrderCount: 0,
    criticalAttentionOrderCount: 0,
    channelBreakdown: [],
    fulfillmentBreakdown: [],
  );
}

bool orderUsesExternalSettlement(pos_order.Order order) {
  return ecommerceOrderUsesExternalSettlement(order);
}

List<OrderBreakdown> _buildBreakdown({
  required List<pos_order.Order> orders,
  required String Function(pos_order.Order order) keyFor,
  required String Function(pos_order.Order order) labelFor,
}) {
  final totals = <String, _BreakdownAccumulator>{};

  for (final order in orders) {
    final key = keyFor(order);
    final accumulator = totals.putIfAbsent(
      key,
      () => _BreakdownAccumulator(id: key, label: labelFor(order)),
    );
    accumulator.orderCount += 1;
    accumulator.revenue += order.total;
  }

  final breakdown =
      totals.values
          .map(
            (entry) => OrderBreakdown(
              id: entry.id,
              label: entry.label,
              orderCount: entry.orderCount,
              revenue: entry.revenue,
            ),
          )
          .toList()
        ..sort((a, b) {
          final countComparison = b.orderCount.compareTo(a.orderCount);
          if (countComparison != 0) return countComparison;
          return a.label.compareTo(b.label);
        });

  return List.unmodifiable(breakdown);
}

class _BreakdownAccumulator {
  final String id;
  final String label;
  int orderCount = 0;
  double revenue = 0;

  _BreakdownAccumulator({required this.id, required this.label});
}

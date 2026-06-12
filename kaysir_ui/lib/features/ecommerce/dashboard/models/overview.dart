import '../../order/cart_item.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../../order/models/order_insights.dart';

class Overview {
  final OrderInsights orderInsights;
  final int cartLineCount;
  final int cartUnitCount;
  final double cartTotal;
  final int promisePolicyIssueCount;

  const Overview({
    required this.orderInsights,
    required this.cartLineCount,
    required this.cartUnitCount,
    required this.cartTotal,
    required this.promisePolicyIssueCount,
  });

  factory Overview.fromState({
    required List<pos_order.Order> orders,
    required List<CartItem> cartItems,
    required int promisePolicyIssueCount,
  }) {
    return Overview(
      orderInsights: OrderInsights.fromOrders(orders),
      cartLineCount: cartItems.length,
      cartUnitCount: cartItems.fold<int>(0, (sum, item) => sum + item.quantity),
      cartTotal: cartItems.fold<double>(0, (sum, item) => sum + item.total),
      promisePolicyIssueCount: promisePolicyIssueCount,
    );
  }

  int get operationalAlertCount =>
      orderInsights.attentionOrderCount + promisePolicyIssueCount;

  bool get hasPolicyIssues => promisePolicyIssueCount > 0;

  String get policyHealthLabel =>
      hasPolicyIssues ? '$promisePolicyIssueCount issue(s)' : 'Ready';

  String get cartLabel {
    if (cartLineCount == 0) return 'No active cart';
    return '$cartUnitCount item${cartUnitCount == 1 ? '' : 's'}';
  }
}

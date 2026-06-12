import '../../../point_of_sales/order/models/order.dart' as pos_order;
import 'order_filter.dart';
import 'order_fulfillment_filter.dart';
import 'order_sort.dart';
import 'order_workspace_recommendation.dart';
import 'order_workspace_view.dart';

class OrderWorkspaceSnapshot {
  final DateTime referenceTime;
  final List<pos_order.Order> orders;
  final List<pos_order.Order> filteredOrders;
  final List<pos_order.Order> visibleOrders;
  final List<OrderWorkspaceView> workspaceViews;
  final Map<String, int> workspaceViewCounts;
  final OrderWorkspaceContext workspaceContext;
  final List<OrderWorkspaceRecommendation> workspaceRecommendations;
  final List<OrderFulfillmentOption> fulfillmentModes;
  final List<String> statuses;

  const OrderWorkspaceSnapshot._({
    required this.referenceTime,
    required this.orders,
    required this.filteredOrders,
    required this.visibleOrders,
    required this.workspaceViews,
    required this.workspaceViewCounts,
    required this.workspaceContext,
    required this.workspaceRecommendations,
    required this.fulfillmentModes,
    required this.statuses,
  });

  factory OrderWorkspaceSnapshot.fromOrders({
    required List<pos_order.Order> orders,
    required OrderFilter filter,
    required OrderSortMode sortMode,
    List<OrderWorkspaceView> workspaceViews =
        ecommerceDefaultOrderWorkspaceViews,
    DateTime? now,
    int recommendationLimit = 3,
  }) {
    assert(recommendationLimit >= 0);

    final referenceTime = now ?? DateTime.now();
    final sourceOrders = List<pos_order.Order>.unmodifiable(orders);
    final sourceWorkspaceViews = List<OrderWorkspaceView>.unmodifiable(
      workspaceViews,
    );
    final filteredOrders = filterOrders(
      sourceOrders,
      filter,
      now: referenceTime,
    );
    final visibleOrders = sortOrders(filteredOrders, sortMode);
    final workspaceViewCounts = ecommerceOrderWorkspaceViewCounts(
      sourceOrders,
      sourceWorkspaceViews,
      now: referenceTime,
    );
    final workspaceContext = ecommerceOrderWorkspaceContext(
      views: sourceWorkspaceViews,
      filter: filter,
      sortMode: sortMode,
    );
    final workspaceRecommendations = ecommerceOrderWorkspaceRecommendations(
      activeWorkspace: workspaceContext,
      workspaceViewCounts: workspaceViewCounts,
      limit: recommendationLimit,
    );

    return OrderWorkspaceSnapshot._(
      referenceTime: referenceTime,
      orders: sourceOrders,
      filteredOrders: filteredOrders,
      visibleOrders: visibleOrders,
      workspaceViews: sourceWorkspaceViews,
      workspaceViewCounts: workspaceViewCounts,
      workspaceContext: workspaceContext,
      workspaceRecommendations: workspaceRecommendations,
      fulfillmentModes: ecommerceOrderFulfillmentOptions(sourceOrders),
      statuses: ecommerceOrderStatuses(sourceOrders),
    );
  }

  int get totalOrderCount => orders.length;
  int get filteredOrderCount => filteredOrders.length;
  int get visibleOrderCount => visibleOrders.length;
  bool get hasOrders => orders.isNotEmpty;
  bool get hasFilteredOrders => filteredOrders.isNotEmpty;
  bool get hasVisibleOrders => visibleOrders.isNotEmpty;
}

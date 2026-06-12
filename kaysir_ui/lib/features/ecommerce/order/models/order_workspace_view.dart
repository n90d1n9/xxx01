import '../../../point_of_sales/order/models/order.dart' as pos_order;
import 'order_attention.dart';
import 'order_filter.dart';
import 'order_payment_scope.dart';
import 'order_sort.dart';

class OrderWorkspaceView {
  final String id;
  final String label;
  final String description;
  final OrderFilter filter;
  final OrderSortMode sortMode;

  const OrderWorkspaceView({
    required this.id,
    required this.label,
    required this.description,
    required this.filter,
    required this.sortMode,
  });

  bool matches(OrderFilter activeFilter, OrderSortMode sort) {
    return sort == sortMode && ecommerceOrderFiltersEqual(activeFilter, filter);
  }
}

class OrderWorkspaceContext {
  final String id;
  final String label;
  final String description;
  final bool isPreset;
  final OrderFilter filter;
  final OrderSortMode sortMode;

  const OrderWorkspaceContext({
    required this.id,
    required this.label,
    required this.description,
    required this.isPreset,
    required this.filter,
    required this.sortMode,
  });

  factory OrderWorkspaceContext.fromView(OrderWorkspaceView view) {
    return OrderWorkspaceContext(
      id: view.id,
      label: view.label,
      description: view.description,
      isPreset: true,
      filter: view.filter,
      sortMode: view.sortMode,
    );
  }
}

const ecommerceAllOrdersWorkspaceView = OrderWorkspaceView(
  id: 'all_orders',
  label: 'All orders',
  description: 'Show every ecommerce order with the newest orders first.',
  filter: OrderFilter(),
  sortMode: OrderSortMode.newest,
);

const ecommerceDefaultOrderWorkspaceViews = <OrderWorkspaceView>[
  ecommerceAllOrdersWorkspaceView,
  OrderWorkspaceView(
    id: 'priority_queue',
    label: 'Priority queue',
    description: 'Show high-priority orders before other operational work.',
    filter: OrderFilter(attentionScope: OrderAttentionScope.highPriority),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'action_queue',
    label: 'Action queue',
    description: 'Show actionable orders ordered by operational attention.',
    filter: OrderFilter(attentionScope: OrderAttentionScope.actionable),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'ready_handoff',
    label: 'Ready handoff',
    description: 'Show ready orders waiting for pickup, courier, or dispatch.',
    filter: OrderFilter(status: 'ready'),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'settlement_review',
    label: 'Settlement review',
    description: 'Show externally settled channel orders for reconciliation.',
    filter: OrderFilter(paymentScope: OrderPaymentScope.externalSettlement),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'today_queue',
    label: 'Today queue',
    description: 'Show today orders with attention surfaced first.',
    filter: OrderFilter(timeScope: OrderTimeScope.today),
    sortMode: OrderSortMode.attention,
  ),
];

OrderWorkspaceView? ecommerceActiveOrderWorkspaceView({
  required List<OrderWorkspaceView> views,
  required OrderFilter filter,
  required OrderSortMode sortMode,
}) {
  for (final view in views) {
    if (view.matches(filter, sortMode)) return view;
  }
  return null;
}

OrderWorkspaceView? ecommerceOrderWorkspaceViewById({
  required List<OrderWorkspaceView> views,
  required String viewId,
}) {
  final normalizedViewId = viewId.trim();
  if (normalizedViewId.isEmpty) return null;

  for (final view in views) {
    if (view.id == normalizedViewId) return view;
  }

  return null;
}

OrderWorkspaceContext ecommerceOrderWorkspaceContext({
  required List<OrderWorkspaceView> views,
  required OrderFilter filter,
  required OrderSortMode sortMode,
}) {
  final activeView = ecommerceActiveOrderWorkspaceView(
    views: views,
    filter: filter,
    sortMode: sortMode,
  );
  if (activeView != null) {
    return OrderWorkspaceContext.fromView(activeView);
  }

  return OrderWorkspaceContext(
    id: 'custom_workspace',
    label: 'Custom workspace',
    description: 'Manual filters or sorting are active.',
    isPreset: false,
    filter: filter,
    sortMode: sortMode,
  );
}

String ecommerceOrderWorkspaceResultText(int resultCount) {
  return '$resultCount matching order${resultCount == 1 ? '' : 's'}';
}

String ecommerceOrderWorkspaceEmptyTitle(
  OrderWorkspaceContext context, {
  required bool hasAnyOrders,
}) {
  if (!hasAnyOrders || context.id == ecommerceAllOrdersWorkspaceView.id) {
    return 'No orders yet';
  }

  if (context.isPreset) {
    return 'No ${context.label.toLowerCase()} orders';
  }

  return 'No matching orders';
}

String ecommerceOrderWorkspaceEmptyMessage(
  OrderWorkspaceContext context, {
  required bool hasAnyOrders,
}) {
  if (!hasAnyOrders) {
    return 'Orders created from ecommerce checkout will appear here.';
  }

  if (context.isPreset) {
    return '${context.description} Try another workspace or broaden filters.';
  }

  return 'Try a broader channel, status, or search term.';
}

Map<String, int> ecommerceOrderWorkspaceViewCounts(
  List<pos_order.Order> orders,
  List<OrderWorkspaceView> views, {
  DateTime? now,
}) {
  final referenceTime = now ?? DateTime.now();

  return Map.unmodifiable({
    for (final view in views)
      view.id: filterOrders(orders, view.filter, now: referenceTime).length,
  });
}

bool ecommerceOrderFiltersEqual(OrderFilter left, OrderFilter right) {
  return left.channelId == right.channelId &&
      left.fulfillmentModeKey == right.fulfillmentModeKey &&
      left.status == right.status &&
      left.timeScope == right.timeScope &&
      left.paymentScope == right.paymentScope &&
      left.attentionScope == right.attentionScope &&
      left.query == right.query;
}

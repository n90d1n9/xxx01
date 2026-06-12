import '../../../point_of_sales/order/models/order.dart' as pos_order;
import 'order_attention.dart';
import 'order_fulfillment_filter.dart';
import 'order_payment_scope.dart';

const ecommerceOrderAllChannelsFilter = 'all_channels';
const ecommerceOrderAllStatusesFilter = 'all_statuses';

enum OrderTimeScope { all, today, last7Days, last30Days }

extension OrderTimeScopeLabel on OrderTimeScope {
  String get label {
    return switch (this) {
      OrderTimeScope.all => 'All time',
      OrderTimeScope.today => 'Today',
      OrderTimeScope.last7Days => '7 days',
      OrderTimeScope.last30Days => '30 days',
    };
  }
}

class OrderFilter {
  final String channelId;
  final String fulfillmentModeKey;
  final String status;
  final OrderTimeScope timeScope;
  final OrderPaymentScope paymentScope;
  final OrderAttentionScope attentionScope;
  final String query;

  const OrderFilter({
    this.channelId = ecommerceOrderAllChannelsFilter,
    this.fulfillmentModeKey = ecommerceOrderAllFulfillmentModesFilter,
    this.status = ecommerceOrderAllStatusesFilter,
    this.timeScope = OrderTimeScope.all,
    this.paymentScope = OrderPaymentScope.all,
    this.attentionScope = OrderAttentionScope.all,
    this.query = '',
  });

  bool get hasActiveFilters =>
      channelId != ecommerceOrderAllChannelsFilter ||
      fulfillmentModeKey != ecommerceOrderAllFulfillmentModesFilter ||
      status != ecommerceOrderAllStatusesFilter ||
      timeScope != OrderTimeScope.all ||
      paymentScope != OrderPaymentScope.all ||
      attentionScope != OrderAttentionScope.all ||
      query.trim().isNotEmpty;

  OrderFilter copyWith({
    String? channelId,
    String? fulfillmentModeKey,
    String? status,
    OrderTimeScope? timeScope,
    OrderPaymentScope? paymentScope,
    OrderAttentionScope? attentionScope,
    String? query,
  }) {
    return OrderFilter(
      channelId: channelId ?? this.channelId,
      fulfillmentModeKey: fulfillmentModeKey ?? this.fulfillmentModeKey,
      status: status ?? this.status,
      timeScope: timeScope ?? this.timeScope,
      paymentScope: paymentScope ?? this.paymentScope,
      attentionScope: attentionScope ?? this.attentionScope,
      query: query ?? this.query,
    );
  }

  bool matches(pos_order.Order order, {DateTime? now}) {
    if (channelId != ecommerceOrderAllChannelsFilter &&
        order.fulfillment?.commerceChannelId != channelId) {
      return false;
    }

    if (!matchesOrderFulfillmentMode(order, fulfillmentModeKey)) {
      return false;
    }

    if (status != ecommerceOrderAllStatusesFilter && order.status != status) {
      return false;
    }

    if (!_matchesTimeScope(order.createdAt, timeScope, now ?? DateTime.now())) {
      return false;
    }

    if (!matchesOrderPaymentScope(order, paymentScope)) {
      return false;
    }

    if (!matchesOrderAttentionScope(order, attentionScope)) {
      return false;
    }

    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return _searchableTerms(
      order,
    ).any((term) => term.toLowerCase().contains(normalizedQuery));
  }
}

List<pos_order.Order> filterOrders(
  List<pos_order.Order> orders,
  OrderFilter filter, {
  DateTime? now,
}) {
  final referenceTime = now ?? DateTime.now();
  return List.unmodifiable(
    orders.where((order) => filter.matches(order, now: referenceTime)),
  );
}

List<String> ecommerceOrderStatuses(List<pos_order.Order> orders) {
  final statuses = orders.map((order) => order.status).toSet().toList()..sort();
  return List.unmodifiable(statuses);
}

List<String> _searchableTerms(pos_order.Order order) {
  final customer = order.customer;
  return [
    order.id,
    order.status,
    if (customer != null) ...[customer.name, customer.phone, customer.email],
    if (order.fulfillment != null) ...[
      order.fulfillment!.commerceChannelLabel,
      order.fulfillment!.fulfillmentModeLabel,
      order.fulfillment!.summaryLabel,
      order.fulfillment!.statusLabel,
      order.fulfillment!.destination,
      order.fulfillment!.tableName,
      order.fulfillment!.contactName,
      order.fulfillment!.scheduleLabel,
      order.fulfillment!.note,
    ],
    ...order.payments.map((payment) => payment.method),
    ...order.items.map((item) => item.product.name),
  ].where((term) => term.trim().isNotEmpty).toList(growable: false);
}

bool _matchesTimeScope(
  DateTime createdAt,
  OrderTimeScope timeScope,
  DateTime now,
) {
  if (timeScope == OrderTimeScope.all) return true;

  final normalizedOrderDay = DateTime(
    createdAt.year,
    createdAt.month,
    createdAt.day,
  );
  final today = DateTime(now.year, now.month, now.day);

  final start = switch (timeScope) {
    OrderTimeScope.all => today,
    OrderTimeScope.today => today,
    OrderTimeScope.last7Days => today.subtract(const Duration(days: 6)),
    OrderTimeScope.last30Days => today.subtract(const Duration(days: 29)),
  };
  final end = today.add(const Duration(days: 1));

  return !normalizedOrderDay.isBefore(start) &&
      normalizedOrderDay.isBefore(end);
}

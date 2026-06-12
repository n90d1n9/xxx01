import '../../../point_of_sales/order/models/order.dart' as pos_order;
import 'order_attention.dart';

enum OrderSortMode {
  attention,
  newest,
  oldest,
  highestValue,
  lowestValue,
  channel,
  fulfillment,
  status,
}

extension OrderSortModeLabel on OrderSortMode {
  String get label {
    return switch (this) {
      OrderSortMode.attention => 'Attention',
      OrderSortMode.newest => 'Newest',
      OrderSortMode.oldest => 'Oldest',
      OrderSortMode.highestValue => 'Highest value',
      OrderSortMode.lowestValue => 'Lowest value',
      OrderSortMode.channel => 'Channel',
      OrderSortMode.fulfillment => 'Fulfillment',
      OrderSortMode.status => 'Status',
    };
  }
}

List<pos_order.Order> sortOrders(
  List<pos_order.Order> orders,
  OrderSortMode sortMode,
) {
  final sorted = [...orders];
  sorted.sort((a, b) => _compareOrders(a, b, sortMode));
  return List.unmodifiable(sorted);
}

int _compareOrders(
  pos_order.Order a,
  pos_order.Order b,
  OrderSortMode sortMode,
) {
  return switch (sortMode) {
    OrderSortMode.attention => _compareAttention(
      a,
      b,
    ).ifEqual(_newestFirst(a, b)),
    OrderSortMode.newest => _newestFirst(a, b),
    OrderSortMode.oldest => a.createdAt.compareTo(b.createdAt),
    OrderSortMode.highestValue => _compareDescending(
      a.total,
      b.total,
    ).ifEqual(_newestFirst(a, b)),
    OrderSortMode.lowestValue => a.total
        .compareTo(b.total)
        .ifEqual(_newestFirst(a, b)),
    OrderSortMode.channel => _compareText(
      a.fulfillment?.commerceChannelLabel,
      b.fulfillment?.commerceChannelLabel,
    ).ifEqual(_newestFirst(a, b)),
    OrderSortMode.fulfillment => _compareText(
      a.fulfillment?.fulfillmentModeLabel,
      b.fulfillment?.fulfillmentModeLabel,
    ).ifEqual(_newestFirst(a, b)),
    OrderSortMode.status => _compareText(
      a.status,
      b.status,
    ).ifEqual(_newestFirst(a, b)),
  };
}

int _compareAttention(pos_order.Order a, pos_order.Order b) {
  return _attentionRank(a).compareTo(_attentionRank(b));
}

int _attentionRank(pos_order.Order order) {
  if (ecommerceOrderHasCriticalAttention(order)) return 0;
  if (ecommerceOrderNeedsAttention(order)) return 1;
  if (ecommerceOrderAttentionSignals(order).isNotEmpty) return 2;
  return 3;
}

int _newestFirst(pos_order.Order a, pos_order.Order b) {
  return b.createdAt.compareTo(a.createdAt);
}

int _compareDescending(num a, num b) {
  return b.compareTo(a);
}

int _compareText(String? a, String? b) {
  final left = (a ?? '').trim().toLowerCase();
  final right = (b ?? '').trim().toLowerCase();
  if (left.isEmpty && right.isNotEmpty) return 1;
  if (left.isNotEmpty && right.isEmpty) return -1;
  return left.compareTo(right);
}

extension _StableComparison on int {
  int ifEqual(int fallback) => this == 0 ? fallback : this;
}

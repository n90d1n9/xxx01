import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'order_attention.dart';
import 'order_filter.dart';
import 'order_fulfillment_filter.dart';
import 'order_payment_scope.dart';
import 'order_sort.dart';

enum OrderActiveFilterSummaryType {
  channel,
  fulfillment,
  status,
  time,
  payment,
  attention,
  search,
  sort,
}

class OrderActiveFilterSummaryItem {
  final OrderActiveFilterSummaryType type;
  final String label;
  final String value;

  const OrderActiveFilterSummaryItem({
    required this.type,
    required this.label,
    required this.value,
  });

  String get id => type.name;

  String get displayLabel => '$label: $value';
}

class OrderActiveFilterState {
  final OrderFilter filter;
  final OrderSortMode sortMode;

  const OrderActiveFilterState({required this.filter, required this.sortMode});

  static const defaults = OrderActiveFilterState(
    filter: OrderFilter(),
    sortMode: OrderSortMode.newest,
  );
}

List<OrderActiveFilterSummaryItem> ecommerceOrderActiveFilterSummary({
  required OrderFilter filter,
  required OrderSortMode sortMode,
  List<POSCommerceChannel> channels = const [],
  List<OrderFulfillmentOption> fulfillmentModes = const [],
}) {
  final items = <OrderActiveFilterSummaryItem>[];

  if (filter.channelId != ecommerceOrderAllChannelsFilter) {
    items.add(
      OrderActiveFilterSummaryItem(
        type: OrderActiveFilterSummaryType.channel,
        label: 'Channel',
        value: _channelLabel(filter.channelId, channels),
      ),
    );
  }

  if (filter.fulfillmentModeKey != ecommerceOrderAllFulfillmentModesFilter) {
    items.add(
      OrderActiveFilterSummaryItem(
        type: OrderActiveFilterSummaryType.fulfillment,
        label: 'Fulfillment',
        value: _fulfillmentLabel(filter.fulfillmentModeKey, fulfillmentModes),
      ),
    );
  }

  if (filter.status != ecommerceOrderAllStatusesFilter) {
    items.add(
      OrderActiveFilterSummaryItem(
        type: OrderActiveFilterSummaryType.status,
        label: 'Status',
        value: ecommerceOrderStatusSummaryLabel(filter.status),
      ),
    );
  }

  if (filter.timeScope != OrderTimeScope.all) {
    items.add(
      OrderActiveFilterSummaryItem(
        type: OrderActiveFilterSummaryType.time,
        label: 'Time',
        value: filter.timeScope.label,
      ),
    );
  }

  if (filter.paymentScope != OrderPaymentScope.all) {
    items.add(
      OrderActiveFilterSummaryItem(
        type: OrderActiveFilterSummaryType.payment,
        label: 'Settlement',
        value: filter.paymentScope.label,
      ),
    );
  }

  if (filter.attentionScope != OrderAttentionScope.all) {
    items.add(
      OrderActiveFilterSummaryItem(
        type: OrderActiveFilterSummaryType.attention,
        label: 'Attention',
        value: filter.attentionScope.label,
      ),
    );
  }

  final query = filter.query.trim();
  if (query.isNotEmpty) {
    items.add(
      OrderActiveFilterSummaryItem(
        type: OrderActiveFilterSummaryType.search,
        label: 'Search',
        value: query,
      ),
    );
  }

  if (sortMode != OrderSortMode.newest) {
    items.add(
      OrderActiveFilterSummaryItem(
        type: OrderActiveFilterSummaryType.sort,
        label: 'Sort',
        value: sortMode.label,
      ),
    );
  }

  return List.unmodifiable(items);
}

OrderActiveFilterState ecommerceOrderActiveFilterStateAfterClear({
  required OrderFilter filter,
  required OrderSortMode sortMode,
  required OrderActiveFilterSummaryType type,
}) {
  return switch (type) {
    OrderActiveFilterSummaryType.channel => OrderActiveFilterState(
      filter: filter.copyWith(channelId: ecommerceOrderAllChannelsFilter),
      sortMode: sortMode,
    ),
    OrderActiveFilterSummaryType.fulfillment => OrderActiveFilterState(
      filter: filter.copyWith(
        fulfillmentModeKey: ecommerceOrderAllFulfillmentModesFilter,
      ),
      sortMode: sortMode,
    ),
    OrderActiveFilterSummaryType.status => OrderActiveFilterState(
      filter: filter.copyWith(status: ecommerceOrderAllStatusesFilter),
      sortMode: sortMode,
    ),
    OrderActiveFilterSummaryType.time => OrderActiveFilterState(
      filter: filter.copyWith(timeScope: OrderTimeScope.all),
      sortMode: sortMode,
    ),
    OrderActiveFilterSummaryType.payment => OrderActiveFilterState(
      filter: filter.copyWith(paymentScope: OrderPaymentScope.all),
      sortMode: sortMode,
    ),
    OrderActiveFilterSummaryType.attention => OrderActiveFilterState(
      filter: filter.copyWith(attentionScope: OrderAttentionScope.all),
      sortMode: sortMode,
    ),
    OrderActiveFilterSummaryType.search => OrderActiveFilterState(
      filter: filter.copyWith(query: ''),
      sortMode: sortMode,
    ),
    OrderActiveFilterSummaryType.sort => OrderActiveFilterState(
      filter: filter,
      sortMode: OrderSortMode.newest,
    ),
  };
}

String ecommerceOrderStatusSummaryLabel(String status) {
  final normalizedStatus = status.trim();
  if (normalizedStatus.isEmpty) return 'Unknown';

  return normalizedStatus
      .split(RegExp(r'[_\s-]+'))
      .where((segment) => segment.isNotEmpty)
      .map((segment) => '${segment[0].toUpperCase()}${segment.substring(1)}')
      .join(' ');
}

String _channelLabel(String channelId, List<POSCommerceChannel> channels) {
  for (final channel in channels) {
    if (channel.id == channelId) return channel.label;
  }

  return ecommerceOrderStatusSummaryLabel(channelId);
}

String _fulfillmentLabel(
  String fulfillmentModeKey,
  List<OrderFulfillmentOption> fulfillmentModes,
) {
  for (final mode in fulfillmentModes) {
    if (mode.key == fulfillmentModeKey) return mode.label;
  }

  return ecommerceOrderStatusSummaryLabel(fulfillmentModeKey);
}

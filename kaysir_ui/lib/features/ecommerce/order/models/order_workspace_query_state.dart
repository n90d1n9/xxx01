import 'order_attention.dart';
import 'order_filter.dart';
import 'order_fulfillment_filter.dart';
import 'order_payment_scope.dart';
import 'order_sort.dart';

class OrderWorkspaceQueryState {
  static const channelIdQueryKey = 'order_channel_id';
  static const fulfillmentModeQueryKey = 'order_fulfillment_mode';
  static const statusQueryKey = 'order_status';
  static const timeScopeQueryKey = 'order_time_scope';
  static const paymentScopeQueryKey = 'order_payment_scope';
  static const attentionScopeQueryKey = 'order_attention_scope';
  static const searchQueryKey = 'order_search';
  static const sortModeQueryKey = 'order_sort';

  final OrderFilter filter;
  final OrderSortMode sortMode;

  const OrderWorkspaceQueryState({
    required this.filter,
    required this.sortMode,
  });

  bool get hasCustomState {
    return filter.hasActiveFilters || sortMode != OrderSortMode.newest;
  }

  Map<String, String> toQueryParameters() {
    if (!hasCustomState) return const {};

    final query = filter.query.trim();
    return {
      if (filter.channelId != ecommerceOrderAllChannelsFilter)
        channelIdQueryKey: filter.channelId,
      if (filter.fulfillmentModeKey != ecommerceOrderAllFulfillmentModesFilter)
        fulfillmentModeQueryKey: filter.fulfillmentModeKey,
      if (filter.status != ecommerceOrderAllStatusesFilter)
        statusQueryKey: filter.status,
      if (filter.timeScope != OrderTimeScope.all)
        timeScopeQueryKey: filter.timeScope.name,
      if (filter.paymentScope != OrderPaymentScope.all)
        paymentScopeQueryKey: filter.paymentScope.name,
      if (filter.attentionScope != OrderAttentionScope.all)
        attentionScopeQueryKey: filter.attentionScope.name,
      if (query.isNotEmpty) searchQueryKey: query,
      if (sortMode != OrderSortMode.newest) sortModeQueryKey: sortMode.name,
    };
  }

  String locationForPath(String path) {
    return Uri(
      path: path.trim(),
      queryParameters: toQueryParameters(),
    ).toString();
  }

  static OrderWorkspaceQueryState? fromQueryParameters(
    Map<String, String> queryParameters,
  ) {
    final hasState = _queryKeys.any(queryParameters.containsKey);
    if (!hasState) return null;

    return OrderWorkspaceQueryState(
      filter: OrderFilter(
        channelId:
            _trimmedValue(queryParameters[channelIdQueryKey]) ??
            ecommerceOrderAllChannelsFilter,
        fulfillmentModeKey:
            _trimmedValue(queryParameters[fulfillmentModeQueryKey]) ??
            ecommerceOrderAllFulfillmentModesFilter,
        status:
            _trimmedValue(queryParameters[statusQueryKey]) ??
            ecommerceOrderAllStatusesFilter,
        timeScope: _enumByName(
          OrderTimeScope.values,
          queryParameters[timeScopeQueryKey],
          OrderTimeScope.all,
        ),
        paymentScope: _enumByName(
          OrderPaymentScope.values,
          queryParameters[paymentScopeQueryKey],
          OrderPaymentScope.all,
        ),
        attentionScope: _enumByName(
          OrderAttentionScope.values,
          queryParameters[attentionScopeQueryKey],
          OrderAttentionScope.all,
        ),
        query: _trimmedValue(queryParameters[searchQueryKey]) ?? '',
      ),
      sortMode: _enumByName(
        OrderSortMode.values,
        queryParameters[sortModeQueryKey],
        OrderSortMode.newest,
      ),
    );
  }

  static const _queryKeys = <String>[
    channelIdQueryKey,
    fulfillmentModeQueryKey,
    statusQueryKey,
    timeScopeQueryKey,
    paymentScopeQueryKey,
    attentionScopeQueryKey,
    searchQueryKey,
    sortModeQueryKey,
  ];
}

String? _trimmedValue(String? value) {
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty) return null;

  return normalized;
}

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  final normalizedName = name?.trim() ?? '';
  for (final value in values) {
    if (value.name == normalizedName) return value;
  }

  return fallback;
}

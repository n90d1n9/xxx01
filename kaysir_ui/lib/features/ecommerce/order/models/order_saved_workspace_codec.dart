import 'order_attention.dart';
import 'order_filter.dart';
import 'order_fulfillment_filter.dart';
import 'order_payment_scope.dart';

Map<String, Object?> orderSavedWorkspaceFilterToJson(OrderFilter filter) {
  return {
    'channelId': filter.channelId,
    'fulfillmentModeKey': filter.fulfillmentModeKey,
    'status': filter.status,
    'timeScope': filter.timeScope.name,
    'paymentScope': filter.paymentScope.name,
    'attentionScope': filter.attentionScope.name,
    'query': filter.query,
  };
}

OrderFilter orderSavedWorkspaceFilterFromJson(Map<String, Object?> json) {
  return OrderFilter(
    channelId:
        orderSavedWorkspaceStringOrNull(json['channelId']) ??
        ecommerceOrderAllChannelsFilter,
    fulfillmentModeKey:
        orderSavedWorkspaceStringOrNull(json['fulfillmentModeKey']) ??
        ecommerceOrderAllFulfillmentModesFilter,
    status:
        orderSavedWorkspaceStringOrNull(json['status']) ??
        ecommerceOrderAllStatusesFilter,
    timeScope:
        orderSavedWorkspaceEnumByName(
          OrderTimeScope.values,
          json['timeScope'],
        ) ??
        OrderTimeScope.all,
    paymentScope:
        orderSavedWorkspaceEnumByName(
          OrderPaymentScope.values,
          json['paymentScope'],
        ) ??
        OrderPaymentScope.all,
    attentionScope:
        orderSavedWorkspaceEnumByName(
          OrderAttentionScope.values,
          json['attentionScope'],
        ) ??
        OrderAttentionScope.all,
    query: orderSavedWorkspaceStringOrNull(json['query']) ?? '',
  );
}

T? orderSavedWorkspaceEnumByName<T extends Enum>(
  List<T> values,
  Object? rawName,
) {
  final name = orderSavedWorkspaceStringOrNull(rawName);
  if (name == null) return null;

  for (final value in values) {
    if (value.name == name) return value;
  }

  return null;
}

String? orderSavedWorkspaceStringOrNull(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;

  return text;
}

Map<String, Object?> orderSavedWorkspaceJsonMap(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);

  return const {};
}

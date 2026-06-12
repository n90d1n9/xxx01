import 'order_active_filter_summary.dart';
import 'order_attention.dart';
import 'order_filter.dart';
import 'order_fulfillment_filter.dart';
import 'order_payment_scope.dart';
import 'order_saved_workspace_model.dart';
import 'order_sort.dart';

enum OrderSavedWorkspaceDetailType {
  channel,
  fulfillment,
  status,
  time,
  payment,
  attention,
  search,
  sort,
}

class OrderSavedWorkspaceDetailItem {
  final OrderSavedWorkspaceDetailType type;
  final String label;
  final String value;

  const OrderSavedWorkspaceDetailItem({
    required this.type,
    required this.label,
    required this.value,
  });

  String get id => type.name;
}

List<OrderSavedWorkspaceDetailItem> ecommerceOrderSavedWorkspaceDetailItems(
  OrderSavedWorkspace workspace,
) {
  return List.unmodifiable([
    OrderSavedWorkspaceDetailItem(
      type: OrderSavedWorkspaceDetailType.channel,
      label: 'Channel',
      value: _filterTokenLabel(
        workspace.filter.channelId,
        emptyValue: ecommerceOrderAllChannelsFilter,
        emptyLabel: 'All channels',
      ),
    ),
    OrderSavedWorkspaceDetailItem(
      type: OrderSavedWorkspaceDetailType.fulfillment,
      label: 'Fulfillment',
      value: _filterTokenLabel(
        workspace.filter.fulfillmentModeKey,
        emptyValue: ecommerceOrderAllFulfillmentModesFilter,
        emptyLabel: 'All fulfillment',
      ),
    ),
    OrderSavedWorkspaceDetailItem(
      type: OrderSavedWorkspaceDetailType.status,
      label: 'Status',
      value: _filterTokenLabel(
        workspace.filter.status,
        emptyValue: ecommerceOrderAllStatusesFilter,
        emptyLabel: 'All statuses',
      ),
    ),
    OrderSavedWorkspaceDetailItem(
      type: OrderSavedWorkspaceDetailType.time,
      label: 'Time',
      value: workspace.filter.timeScope.label,
    ),
    OrderSavedWorkspaceDetailItem(
      type: OrderSavedWorkspaceDetailType.payment,
      label: 'Payment',
      value: workspace.filter.paymentScope.label,
    ),
    OrderSavedWorkspaceDetailItem(
      type: OrderSavedWorkspaceDetailType.attention,
      label: 'Attention',
      value: workspace.filter.attentionScope.label,
    ),
    OrderSavedWorkspaceDetailItem(
      type: OrderSavedWorkspaceDetailType.search,
      label: 'Search',
      value:
          workspace.filter.query.trim().isEmpty
              ? 'No search query'
              : workspace.filter.query.trim(),
    ),
    OrderSavedWorkspaceDetailItem(
      type: OrderSavedWorkspaceDetailType.sort,
      label: 'Sort',
      value: workspace.sortMode.label,
    ),
  ]);
}

String _filterTokenLabel(
  String token, {
  required String emptyValue,
  required String emptyLabel,
}) {
  final normalizedToken = token.trim();
  if (normalizedToken.isEmpty || normalizedToken == emptyValue) {
    return emptyLabel;
  }

  return ecommerceOrderStatusSummaryLabel(normalizedToken);
}

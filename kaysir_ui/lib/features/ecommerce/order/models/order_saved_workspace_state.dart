import 'order_active_filter_summary.dart';
import 'order_filter.dart';
import 'order_saved_workspace_identity.dart';
import 'order_saved_workspace_model.dart';
import 'order_sort.dart';

OrderSavedWorkspace ecommerceOrderSavedWorkspaceFromState({
  required OrderFilter filter,
  required OrderSortMode sortMode,
  required List<OrderActiveFilterSummaryItem> summaryItems,
  int index = 1,
}) {
  final visibleItems = orderSavedWorkspaceVisibleSummaryItems(summaryItems);
  final label = orderSavedWorkspaceLabelFromSummary(
    summaryItems: visibleItems,
    index: index,
  );

  return OrderSavedWorkspace(
    id: orderSavedWorkspaceIdForState(filter: filter, sortMode: sortMode),
    label: label,
    description: ecommerceOrderSavedWorkspaceDescriptionFromSummary(
      visibleItems,
    ),
    isDescriptionCustom: false,
    filter: filter,
    sortMode: sortMode,
    isPinned: false,
  );
}

OrderSavedWorkspace ecommerceOrderSavedWorkspaceWithState({
  required OrderSavedWorkspace workspace,
  required OrderFilter filter,
  required OrderSortMode sortMode,
  required List<OrderActiveFilterSummaryItem> summaryItems,
}) {
  final generatedDescription =
      ecommerceOrderSavedWorkspaceDescriptionFromSummary(
        orderSavedWorkspaceVisibleSummaryItems(summaryItems),
      );

  return workspace.copyWith(
    filter: filter,
    sortMode: sortMode,
    description:
        workspace.isDescriptionCustom
            ? workspace.description
            : generatedDescription,
  );
}

List<OrderActiveFilterSummaryType> ecommerceOrderSavedWorkspaceChangedFields({
  required OrderSavedWorkspace workspace,
  required OrderFilter filter,
  required OrderSortMode sortMode,
}) {
  final changedFields = <OrderActiveFilterSummaryType>[];

  if (workspace.filter.channelId != filter.channelId) {
    changedFields.add(OrderActiveFilterSummaryType.channel);
  }
  if (workspace.filter.fulfillmentModeKey != filter.fulfillmentModeKey) {
    changedFields.add(OrderActiveFilterSummaryType.fulfillment);
  }
  if (workspace.filter.status != filter.status) {
    changedFields.add(OrderActiveFilterSummaryType.status);
  }
  if (workspace.filter.timeScope != filter.timeScope) {
    changedFields.add(OrderActiveFilterSummaryType.time);
  }
  if (workspace.filter.paymentScope != filter.paymentScope) {
    changedFields.add(OrderActiveFilterSummaryType.payment);
  }
  if (workspace.filter.attentionScope != filter.attentionScope) {
    changedFields.add(OrderActiveFilterSummaryType.attention);
  }
  if (workspace.filter.query.trim() != filter.query.trim()) {
    changedFields.add(OrderActiveFilterSummaryType.search);
  }
  if (workspace.sortMode != sortMode) {
    changedFields.add(OrderActiveFilterSummaryType.sort);
  }

  return List.unmodifiable(changedFields);
}

String ecommerceOrderSavedWorkspaceChangeSummary({
  required OrderSavedWorkspace workspace,
  required OrderFilter filter,
  required OrderSortMode sortMode,
  int visibleFieldLimit = 3,
}) {
  final changedFields = ecommerceOrderSavedWorkspaceChangedFields(
    workspace: workspace,
    filter: filter,
    sortMode: sortMode,
  );
  if (changedFields.isEmpty) return '';

  final effectiveLimit = visibleFieldLimit < 1 ? 1 : visibleFieldLimit;
  final visibleLabels = changedFields
      .take(effectiveLimit)
      .map(orderSavedWorkspaceChangedFieldLabel)
      .toList(growable: false);
  final remainingCount = changedFields.length - visibleLabels.length;
  final suffix = remainingCount > 0 ? ' +$remainingCount more' : '';

  return 'Changed: ${visibleLabels.join(', ')}$suffix';
}

OrderSavedWorkspace ecommerceOrderSavedWorkspaceWithAutoDescription({
  required OrderSavedWorkspace workspace,
  required List<OrderActiveFilterSummaryItem> summaryItems,
}) {
  return workspace.copyWith(
    description: ecommerceOrderSavedWorkspaceDescriptionFromSummary(
      orderSavedWorkspaceVisibleSummaryItems(summaryItems),
    ),
    isDescriptionCustom: false,
  );
}

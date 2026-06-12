import 'package:kaysir/core/workspace/models/saved_workspace_shortcut.dart';

import 'order_active_filter_summary.dart';
import 'order_filter.dart';
import 'order_sort.dart';

String orderSavedWorkspaceIdForState({
  required OrderFilter filter,
  required OrderSortMode sortMode,
}) {
  final raw = [
    filter.channelId,
    filter.fulfillmentModeKey,
    filter.status,
    filter.timeScope.name,
    filter.paymentScope.name,
    filter.attentionScope.name,
    filter.query.trim(),
    sortMode.name,
  ].join('_');

  final token = workspaceShortcutNormalizedId(raw);
  if (token.isEmpty) return 'saved_workspace';

  return 'saved_$token';
}

String orderSavedWorkspaceLabelFromSummary({
  required List<OrderActiveFilterSummaryItem> summaryItems,
  int index = 1,
}) {
  final visibleItems = orderSavedWorkspaceVisibleSummaryItems(summaryItems);
  if (visibleItems.isEmpty) return 'Saved workspace $index';

  final parts = visibleItems
      .take(2)
      .map((item) => item.value)
      .toList(growable: false);
  return parts.join(' / ');
}

String ecommerceOrderSavedWorkspaceDescriptionFromSummary(
  List<OrderActiveFilterSummaryItem> summaryItems,
) {
  final visibleItems = orderSavedWorkspaceVisibleSummaryItems(summaryItems);
  if (visibleItems.isEmpty) return 'Saved custom order workspace.';

  return visibleItems.map((item) => item.displayLabel).join(' • ');
}

List<OrderActiveFilterSummaryItem> orderSavedWorkspaceVisibleSummaryItems(
  List<OrderActiveFilterSummaryItem> summaryItems,
) {
  return summaryItems
      .where((item) => item.value.trim().isNotEmpty)
      .toList(growable: false);
}

String orderSavedWorkspaceChangedFieldLabel(OrderActiveFilterSummaryType type) {
  return switch (type) {
    OrderActiveFilterSummaryType.channel => 'Channel',
    OrderActiveFilterSummaryType.fulfillment => 'Fulfillment',
    OrderActiveFilterSummaryType.status => 'Status',
    OrderActiveFilterSummaryType.time => 'Time',
    OrderActiveFilterSummaryType.payment => 'Settlement',
    OrderActiveFilterSummaryType.attention => 'Attention',
    OrderActiveFilterSummaryType.search => 'Search',
    OrderActiveFilterSummaryType.sort => 'Sort',
  };
}

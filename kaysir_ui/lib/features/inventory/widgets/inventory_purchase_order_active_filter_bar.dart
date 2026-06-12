import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_active_filter_bar.dart';
import '../models/inventory_purchase_order_workspace.dart';

/// Active search, status, and sort tokens for the purchase-order queue.
class InventoryPurchaseOrderActiveFilterBar extends StatelessWidget {
  const InventoryPurchaseOrderActiveFilterBar({
    super.key,
    required this.query,
    required this.filter,
    required this.sort,
    required this.onQueryCleared,
    required this.onFilterCleared,
    required this.onSortCleared,
    required this.onClearAll,
  });

  final String query;
  final InventoryPurchaseOrderFilter filter;
  final InventoryPurchaseOrderSort sort;
  final VoidCallback onQueryCleared;
  final VoidCallback onFilterCleared;
  final VoidCallback onSortCleared;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim();

    return ActiveFilterBar(
      title: 'Active controls',
      clearAllLabel: 'Reset queue',
      tokens: [
        if (trimmedQuery.isNotEmpty)
          ActiveFilterToken(
            icon: Icons.search_rounded,
            label: 'Search: $trimmedQuery',
            clearTooltip: 'Clear purchase order search',
            onClear: onQueryCleared,
          ),
        if (filter != InventoryPurchaseOrderFilter.all)
          ActiveFilterToken(
            icon: _filterIcon(filter),
            label: 'Status: ${inventoryPurchaseOrderFilterLabel(filter)}',
            clearTooltip: 'Clear purchase order status filter',
            onClear: onFilterCleared,
          ),
        if (sort != InventoryPurchaseOrderSort.urgency)
          ActiveFilterToken(
            icon: Icons.sort_rounded,
            label: 'Sort: ${inventoryPurchaseOrderSortLabel(sort)}',
            clearTooltip: 'Reset purchase order sort',
            onClear: onSortCleared,
          ),
      ],
      onClearAll: onClearAll,
    );
  }
}

/// Whether the purchase-order queue has a user-visible active filter.
bool hasActiveInventoryPurchaseOrderFilters({
  required String query,
  required InventoryPurchaseOrderFilter filter,
}) {
  return query.trim().isNotEmpty || filter != InventoryPurchaseOrderFilter.all;
}

/// Whether the purchase-order queue has a visible non-default control.
bool hasActiveInventoryPurchaseOrderControls({
  required String query,
  required InventoryPurchaseOrderFilter filter,
  required InventoryPurchaseOrderSort sort,
}) {
  return hasActiveInventoryPurchaseOrderFilters(query: query, filter: filter) ||
      sort != InventoryPurchaseOrderSort.urgency;
}

IconData _filterIcon(InventoryPurchaseOrderFilter filter) {
  switch (filter) {
    case InventoryPurchaseOrderFilter.all:
      return Icons.view_list_rounded;
    case InventoryPurchaseOrderFilter.active:
      return Icons.timelapse_rounded;
    case InventoryPurchaseOrderFilter.needsReceiving:
      return Icons.move_to_inbox_rounded;
    case InventoryPurchaseOrderFilter.overdue:
      return Icons.warning_amber_rounded;
    case InventoryPurchaseOrderFilter.received:
      return Icons.verified_rounded;
    case InventoryPurchaseOrderFilter.cancelled:
      return Icons.cancel_rounded;
  }
}

@Preview(name: 'Purchase order active filters')
Widget inventoryPurchaseOrderActiveFilterBarPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: InventoryPurchaseOrderActiveFilterBar(
          query: 'PO-2025-001',
          filter: InventoryPurchaseOrderFilter.needsReceiving,
          sort: InventoryPurchaseOrderSort.valueHigh,
          onQueryCleared: () {},
          onFilterCleared: () {},
          onSortCleared: () {},
          onClearAll: () {},
        ),
      ),
    ),
  );
}

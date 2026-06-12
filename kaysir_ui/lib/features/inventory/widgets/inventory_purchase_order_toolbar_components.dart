import 'package:flutter/material.dart';

import '../../../widgets/ui/app_filter_bar.dart';
import '../../../widgets/ui/app_filter_chip_group.dart';
import '../models/inventory_purchase_order_saved_view.dart';
import '../models/inventory_purchase_order_workspace.dart';
import 'inventory_purchase_order_saved_view_button.dart';
import 'inventory_purchase_order_sort_field.dart';
import 'inventory_search_field.dart';

/// Search, status, saved-view, and sort controls for the purchase-order queue.
class InventoryPurchaseOrderToolbar extends StatelessWidget {
  const InventoryPurchaseOrderToolbar({
    super.key,
    required this.searchController,
    required this.filter,
    required this.sort,
    required this.summary,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
    this.savedViews = inventoryPurchaseOrderSavedViews,
    this.activeSavedViewId,
    this.onSavedViewSelected,
  });

  final TextEditingController searchController;
  final InventoryPurchaseOrderFilter filter;
  final InventoryPurchaseOrderSort sort;
  final InventoryPurchaseOrderSummary summary;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<InventoryPurchaseOrderFilter> onFilterChanged;
  final ValueChanged<InventoryPurchaseOrderSort> onSortChanged;
  final List<InventoryPurchaseOrderSavedView> savedViews;
  final String? activeSavedViewId;
  final ValueChanged<InventoryPurchaseOrderSavedView>? onSavedViewSelected;

  @override
  Widget build(BuildContext context) {
    return AppFilterBar(
      search: InventorySearchField(
        controller: searchController,
        hintText: 'Search order, supplier, status, item, or SKU',
        onChanged: onSearchChanged,
        clearTooltip: 'Clear purchase order search',
      ),
      filters: [
        AppFilterChipGroup<InventoryPurchaseOrderFilter>(
          value: filter,
          onChanged: onFilterChanged,
          options: [
            AppFilterChipOption(
              value: InventoryPurchaseOrderFilter.all,
              label: inventoryPurchaseOrderFilterLabel(
                InventoryPurchaseOrderFilter.all,
              ),
              icon: Icons.view_list_rounded,
              count: summary.orderCount,
            ),
            AppFilterChipOption(
              value: InventoryPurchaseOrderFilter.active,
              label: inventoryPurchaseOrderFilterLabel(
                InventoryPurchaseOrderFilter.active,
              ),
              icon: Icons.timelapse_rounded,
              count: summary.activeCount,
            ),
            AppFilterChipOption(
              value: InventoryPurchaseOrderFilter.needsReceiving,
              label: inventoryPurchaseOrderFilterLabel(
                InventoryPurchaseOrderFilter.needsReceiving,
              ),
              icon: Icons.move_to_inbox_rounded,
              count: summary.needsReceivingCount,
            ),
            AppFilterChipOption(
              value: InventoryPurchaseOrderFilter.overdue,
              label: inventoryPurchaseOrderFilterLabel(
                InventoryPurchaseOrderFilter.overdue,
              ),
              icon: Icons.warning_amber_rounded,
              count: summary.overdueCount,
            ),
            AppFilterChipOption(
              value: InventoryPurchaseOrderFilter.received,
              label: inventoryPurchaseOrderFilterLabel(
                InventoryPurchaseOrderFilter.received,
              ),
              icon: Icons.verified_rounded,
              count: summary.receivedCount,
            ),
            AppFilterChipOption(
              value: InventoryPurchaseOrderFilter.cancelled,
              label: inventoryPurchaseOrderFilterLabel(
                InventoryPurchaseOrderFilter.cancelled,
              ),
              icon: Icons.cancel_rounded,
              count: summary.cancelledCount,
            ),
          ],
        ),
      ],
      trailing: [
        _InventoryPurchaseOrderToolbarTrailingControls(
          savedViews: savedViews,
          activeSavedViewId: activeSavedViewId,
          onSavedViewSelected: onSavedViewSelected,
          sort: sort,
          onSortChanged: onSortChanged,
        ),
      ],
    );
  }
}

/// Compact trailing cluster for saved-view and sort controls.
class _InventoryPurchaseOrderToolbarTrailingControls extends StatelessWidget {
  const _InventoryPurchaseOrderToolbarTrailingControls({
    required this.savedViews,
    required this.activeSavedViewId,
    required this.onSavedViewSelected,
    required this.sort,
    required this.onSortChanged,
  });

  final List<InventoryPurchaseOrderSavedView> savedViews;
  final String? activeSavedViewId;
  final ValueChanged<InventoryPurchaseOrderSavedView>? onSavedViewSelected;
  final InventoryPurchaseOrderSort sort;
  final ValueChanged<InventoryPurchaseOrderSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final showSavedViews = savedViews.isNotEmpty && onSavedViewSelected != null;
    final sortField = InventoryPurchaseOrderSortField(
      value: sort,
      width: null,
      onChanged: onSortChanged,
    );

    if (!showSavedViews) return sortField;

    return Row(
      children: [
        InventoryPurchaseOrderSavedViewButton(
          savedViews: savedViews,
          activeSavedViewId: activeSavedViewId,
          onSelected: onSavedViewSelected,
        ),
        const SizedBox(width: 8),
        Expanded(child: sortField),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_filter_bar.dart';
import '../models/inventory_stock_opname_worksheet_filter.dart';
import 'inventory_search_field.dart';
import 'stock_opname_worksheet_filter_chips.dart';
import 'stock_opname_worksheet_preview_data.dart';
import 'stock_opname_worksheet_sort_field.dart';
import 'stock_opname_worksheet_toolbar_meta.dart';

/// Review toolbar for searching and filtering stock opname worksheet rows.
class InventoryStockOpnameWorksheetToolbar extends StatelessWidget {
  const InventoryStockOpnameWorksheetToolbar({
    super.key,
    required this.searchController,
    required this.state,
    required this.counts,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onResetFilters,
  });

  final TextEditingController searchController;
  final InventoryStockOpnameWorksheetFilterState state;
  final InventoryStockOpnameWorksheetFilterCounts counts;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<InventoryStockOpnameWorksheetFilter> onFilterChanged;
  final ValueChanged<InventoryStockOpnameWorksheetSort> onSortChanged;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    return AppFilterBar(
      contained: false,
      compactBreakpoint: 820,
      trailingWidth: 230,
      search: InventorySearchField(
        controller: searchController,
        hintText: 'Search product, SKU, count, or note',
        clearTooltip: 'Clear count sheet search',
        onChanged: onSearchChanged,
      ),
      filters: [
        InventoryStockOpnameWorksheetFilterChips(
          value: state.filter,
          counts: counts,
          onChanged: onFilterChanged,
        ),
      ],
      trailing: [
        InventoryStockOpnameWorksheetSortField(
          value: state.sort,
          onChanged: onSortChanged,
          width: double.infinity,
        ),
        InventoryStockOpnameWorksheetToolbarMeta(
          counts: counts,
          hasActiveFilters: state.hasActiveFilters,
          onResetFilters: onResetFilters,
        ),
      ],
    );
  }
}

@Preview(name: 'Inventory stock opname worksheet toolbar')
Widget inventoryStockOpnameWorksheetToolbarPreview() {
  final controller = inventoryStockOpnameWorksheetPreviewSearchController();

  return inventoryStockOpnameWorksheetPreviewScaffold(
    InventoryStockOpnameWorksheetToolbar(
      searchController: controller,
      state: inventoryStockOpnameWorksheetPreviewState(),
      counts: inventoryStockOpnameWorksheetPreviewCounts(),
      onSearchChanged: (_) {},
      onFilterChanged: (_) {},
      onSortChanged: (_) {},
      onResetFilters: () {},
    ),
  );
}

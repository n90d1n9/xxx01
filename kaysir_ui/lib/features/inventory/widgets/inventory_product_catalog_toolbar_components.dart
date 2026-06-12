import 'package:flutter/material.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_browser_controls.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_segmented_filter_bar.dart';

import '../models/inventory_product_catalog.dart';
import '../utils/inventory_product_catalog_browser_state.dart';

class InventoryProductCatalogToolbar extends StatelessWidget {
  const InventoryProductCatalogToolbar({
    super.key,
    required this.searchController,
    required this.filter,
    required this.records,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final TextEditingController searchController;
  final InventoryProductCatalogFilter filter;
  final List<InventoryProductCatalogRecord> records;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<InventoryProductCatalogFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final browserState = InventoryProductCatalogBrowserState.resolve(
      records: records,
      filter: filter,
      query: searchController.text,
    );

    return POSBrowserControls<InventoryProductCatalogFilter>(
      filterScrollKey: const ValueKey(
        'inventory-product-catalog-filter-scroll',
      ),
      selectedFilter: filter,
      filterOptions: POSSegmentedFilterOption.fromValues(
        InventoryProductCatalogFilter.values,
        labelBuilder: inventoryProductCatalogFilterLabel,
        countBuilder: browserState.countFor,
        iconBuilder: _filterIcon,
      ),
      onFilterSelected: onFilterChanged,
      searchController: searchController,
      searchHintText:
          'Search product, SKU, category, description, or warehouse',
      onSearchChanged: onSearchChanged,
      searchSummary:
          browserState.shouldShowSearchSummary
              ? POSBrowserSearchSummary.fromFilterSearchState(
                state: browserState.searchState,
                clearActionKey: const ValueKey(
                  'inventory-product-catalog-clear-search-action',
                ),
                recoveryActionKey: const ValueKey(
                  'inventory-product-catalog-show-search-matches-action',
                ),
                onClear: () {
                  searchController.clear();
                  onSearchChanged('');
                },
                onRecoverFilter: onFilterChanged,
              )
              : null,
    );
  }
}

IconData _filterIcon(InventoryProductCatalogFilter filter) {
  switch (filter) {
    case InventoryProductCatalogFilter.all:
      return Icons.view_list_rounded;
    case InventoryProductCatalogFilter.attention:
      return Icons.warning_amber_rounded;
    case InventoryProductCatalogFilter.inStock:
      return Icons.check_circle_rounded;
    case InventoryProductCatalogFilter.untracked:
      return Icons.visibility_off_rounded;
  }
}

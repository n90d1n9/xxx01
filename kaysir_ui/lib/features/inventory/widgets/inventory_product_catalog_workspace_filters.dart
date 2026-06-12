import 'package:flutter/material.dart';

import 'inventory_product_catalog_components.dart';
import 'inventory_product_catalog_workspace_contracts.dart';

class InventoryProductCatalogWorkspaceFilters extends StatelessWidget {
  const InventoryProductCatalogWorkspaceFilters({
    super.key,
    required this.workspaceContext,
    this.filterAccessory,
  });

  final InventoryProductCatalogWorkspaceContext workspaceContext;
  final Widget? filterAccessory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InventoryProductCatalogToolbar(
          searchController: workspaceContext.browserController.searchController,
          filter: workspaceContext.browserController.filter,
          records: workspaceContext.records,
          onSearchChanged: workspaceContext.browserActions.setQuery,
          onFilterChanged: workspaceContext.browserActions.setFilter,
        ),
        if (filterAccessory != null) ...[
          const SizedBox(height: 10),
          filterAccessory!,
        ],
      ],
    );
  }
}

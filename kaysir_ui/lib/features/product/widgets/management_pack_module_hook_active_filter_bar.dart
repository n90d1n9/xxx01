import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_active_filter_bar.dart';

import '../models/management_pack_module_hook_catalog_filter.dart';
import '../models/management_pack_module_hook_catalog_sort.dart';

/// Active control tokens for the management-pack module hook catalog.
class ProductManagementPackModuleHookActiveFilterBar extends StatelessWidget {
  const ProductManagementPackModuleHookActiveFilterBar({
    super.key,
    required this.filter,
    required this.kindFilter,
    required this.sort,
    required this.query,
    required this.onFilterCleared,
    required this.onKindFilterCleared,
    required this.onSortCleared,
    required this.onQueryCleared,
    required this.onClearAll,
  });

  final ProductManagementPackModuleHookCatalogFilter filter;
  final ProductManagementPackModuleHookKindFilter kindFilter;
  final ProductManagementPackModuleHookCatalogSort sort;
  final String query;
  final VoidCallback onFilterCleared;
  final VoidCallback onKindFilterCleared;
  final VoidCallback onSortCleared;
  final VoidCallback onQueryCleared;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim();

    return ActiveFilterBar(
      clearAllLabel: 'Reset all',
      tokens: [
        if (filter != ProductManagementPackModuleHookCatalogFilter.all)
          ActiveFilterToken(
            icon: _filterIcon(filter),
            label: 'Status ${filter.label}',
            clearTooltip: 'Clear module status filter',
            onClear: onFilterCleared,
          ),
        if (kindFilter != ProductManagementPackModuleHookKindFilter.all)
          ActiveFilterToken(
            icon: _kindFilterIcon(kindFilter),
            label: 'Hook type ${_kindFilterLabel(kindFilter)}',
            clearTooltip: 'Clear module hook type filter',
            onClear: onKindFilterCleared,
          ),
        if (sort != ProductManagementPackModuleHookCatalogSort.registryOrder)
          ActiveFilterToken(
            icon: Icons.sort_rounded,
            label: 'Sort ${sort.activeFilterLabel}',
            clearTooltip: 'Clear module sort',
            onClear: onSortCleared,
          ),
        if (trimmedQuery.isNotEmpty)
          ActiveFilterToken(
            icon: Icons.search_rounded,
            label: 'Search "$trimmedQuery"',
            clearTooltip: 'Clear module search filter',
            onClear: onQueryCleared,
          ),
      ],
      onClearAll: onClearAll,
    );
  }
}

@Preview(name: 'Management pack module active filters')
Widget productManagementPackModuleHookActiveFilterBarPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackModuleHookActiveFilterBar(
          filter: ProductManagementPackModuleHookCatalogFilter.inactive,
          kindFilter: ProductManagementPackModuleHookKindFilter.recommendation,
          sort: ProductManagementPackModuleHookCatalogSort.alphabetical,
          query: 'launch',
          onFilterCleared: () {},
          onKindFilterCleared: () {},
          onSortCleared: () {},
          onQueryCleared: () {},
          onClearAll: () {},
        ),
      ),
    ),
  );
}

IconData _filterIcon(ProductManagementPackModuleHookCatalogFilter filter) {
  switch (filter) {
    case ProductManagementPackModuleHookCatalogFilter.all:
      return Icons.apps_rounded;
    case ProductManagementPackModuleHookCatalogFilter.active:
      return Icons.check_circle_rounded;
    case ProductManagementPackModuleHookCatalogFilter.inactive:
      return Icons.pause_circle_filled_rounded;
    case ProductManagementPackModuleHookCatalogFilter.noHooks:
      return Icons.extension_off_rounded;
  }
}

IconData _kindFilterIcon(ProductManagementPackModuleHookKindFilter filter) {
  switch (filter) {
    case ProductManagementPackModuleHookKindFilter.all:
      return Icons.category_rounded;
    case ProductManagementPackModuleHookKindFilter.workspaceAction:
      return Icons.bolt_rounded;
    case ProductManagementPackModuleHookKindFilter.setupReadiness:
      return Icons.fact_check_rounded;
    case ProductManagementPackModuleHookKindFilter.recommendation:
      return Icons.tips_and_updates_rounded;
    case ProductManagementPackModuleHookKindFilter.moduleBriefAction:
      return Icons.ads_click_rounded;
    case ProductManagementPackModuleHookKindFilter.availabilityTemplate:
      return Icons.rule_rounded;
  }
}

String _kindFilterLabel(ProductManagementPackModuleHookKindFilter filter) {
  switch (filter) {
    case ProductManagementPackModuleHookKindFilter.all:
      return 'All';
    case ProductManagementPackModuleHookKindFilter.workspaceAction:
      return 'Workspace actions';
    case ProductManagementPackModuleHookKindFilter.setupReadiness:
      return 'Setup readiness';
    case ProductManagementPackModuleHookKindFilter.recommendation:
      return 'Recommendations';
    case ProductManagementPackModuleHookKindFilter.moduleBriefAction:
      return 'Module brief actions';
    case ProductManagementPackModuleHookKindFilter.availabilityTemplate:
      return 'Availability templates';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_filter_chip_group.dart';
import '../models/management_pack_contribution_source_group.dart';
import '../models/management_pack_module_hook_catalog_filter.dart';

/// Status filter chips for the management-pack module hook catalog.
class ProductManagementPackModuleHookFilterBar extends StatelessWidget {
  const ProductManagementPackModuleHookFilterBar({
    super.key,
    required this.groups,
    required this.value,
    required this.onChanged,
    this.kindFilter = ProductManagementPackModuleHookKindFilter.all,
    this.query = '',
  });

  final List<ProductManagementPackContributionSourceGroup> groups;
  final ProductManagementPackModuleHookCatalogFilter value;
  final ValueChanged<ProductManagementPackModuleHookCatalogFilter> onChanged;
  final ProductManagementPackModuleHookKindFilter kindFilter;
  final String query;

  @override
  Widget build(BuildContext context) {
    return AppFilterChipGroup<ProductManagementPackModuleHookCatalogFilter>(
      value: value,
      options: [
        for (final filter
            in ProductManagementPackModuleHookCatalogFilter.values)
          AppFilterChipOption(
            value: filter,
            label: filter.label,
            icon: _filterIcon(filter),
            count: countProductManagementPackModuleHookCatalogFilterMatches(
              groups: groups,
              filter: filter,
              kindFilter: kindFilter,
              query: query,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

@Preview(name: 'Management pack module hook filters')
Widget productManagementPackModuleHookFilterBarPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackModuleHookFilterBar(
          groups: const [],
          value: ProductManagementPackModuleHookCatalogFilter.all,
          onChanged: (_) {},
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

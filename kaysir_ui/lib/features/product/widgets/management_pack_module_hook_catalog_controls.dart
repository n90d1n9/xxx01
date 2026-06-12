import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack_contribution_source_group.dart';
import '../models/management_pack_module_hook_catalog_filter.dart';
import '../models/management_pack_module_hook_catalog_sort.dart';
import 'management_pack_module_hook_filter_bar.dart';
import 'management_pack_module_hook_kind_filter_field.dart';
import 'management_pack_module_hook_search_field.dart';
import 'management_pack_module_hook_sort_field.dart';

/// Combined search, filter, kind, sort, and reset controls for hook catalog.
class ProductManagementPackModuleHookCatalogControls extends StatelessWidget {
  const ProductManagementPackModuleHookCatalogControls({
    super.key,
    required this.groups,
    required this.filter,
    required this.kindFilter,
    required this.sort,
    required this.query,
    required this.queryController,
    required this.onFilterChanged,
    required this.onKindFilterChanged,
    required this.onSortChanged,
    required this.onQueryChanged,
    required this.onQueryCleared,
    required this.onReset,
  });

  final List<ProductManagementPackContributionSourceGroup> groups;
  final ProductManagementPackModuleHookCatalogFilter filter;
  final ProductManagementPackModuleHookKindFilter kindFilter;
  final ProductManagementPackModuleHookCatalogSort sort;
  final String query;
  final TextEditingController queryController;
  final ValueChanged<ProductManagementPackModuleHookCatalogFilter>
  onFilterChanged;
  final ValueChanged<ProductManagementPackModuleHookKindFilter>
  onKindFilterChanged;
  final ValueChanged<ProductManagementPackModuleHookCatalogSort> onSortChanged;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onQueryCleared;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final search = ProductManagementPackModuleHookSearchField(
      controller: queryController,
      query: query,
      onChanged: onQueryChanged,
      onClear: onQueryCleared,
    );
    final filters = ProductManagementPackModuleHookFilterBar(
      groups: groups,
      value: filter,
      kindFilter: kindFilter,
      query: query,
      onChanged: onFilterChanged,
    );
    final kindSelector = ProductManagementPackModuleHookKindFilterField(
      groups: groups,
      value: kindFilter,
      statusFilter: filter,
      query: query,
      onChanged: onKindFilterChanged,
    );
    final sortSelector = ProductManagementPackModuleHookSortField(
      value: sort,
      onChanged: onSortChanged,
    );
    final hasActiveControls =
        hasActiveProductManagementPackModuleHookCatalogControls(
          filter: filter,
          kindFilter: kindFilter,
          query: query,
          sort: sort,
        );
    final resetButton = IconButton.outlined(
      tooltip: 'Reset module filters',
      icon: const Icon(Icons.restart_alt_rounded),
      onPressed: hasActiveControls ? onReset : null,
      visualDensity: VisualDensity.compact,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 780) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              search,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: kindSelector),
                  const SizedBox(width: 10),
                  Expanded(child: sortSelector),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: filters),
                  if (hasActiveControls) ...[
                    const SizedBox(width: 8),
                    resetButton,
                  ],
                ],
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: search),
            const SizedBox(width: 12),
            SizedBox(width: 188, child: kindSelector),
            const SizedBox(width: 12),
            SizedBox(width: 156, child: sortSelector),
            const SizedBox(width: 12),
            Expanded(flex: 8, child: filters),
            if (hasActiveControls) ...[const SizedBox(width: 8), resetButton],
          ],
        );
      },
    );
  }
}

@Preview(name: 'Management pack module hook controls')
Widget productManagementPackModuleHookCatalogControlsPreview() {
  final controller = TextEditingController(text: 'catalog');

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackModuleHookCatalogControls(
          groups: const [],
          filter: ProductManagementPackModuleHookCatalogFilter.active,
          kindFilter: ProductManagementPackModuleHookKindFilter.all,
          sort: ProductManagementPackModuleHookCatalogSort.activeFirst,
          query: controller.text,
          queryController: controller,
          onFilterChanged: (_) {},
          onKindFilterChanged: (_) {},
          onSortChanged: (_) {},
          onQueryChanged: (_) {},
          onQueryCleared: () {},
          onReset: () {},
        ),
      ),
    ),
  );
}

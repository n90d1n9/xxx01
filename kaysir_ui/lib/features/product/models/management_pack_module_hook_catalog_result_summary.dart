import 'management_pack_module_hook_catalog_filter.dart';
import 'management_pack_module_hook_catalog_sort.dart';

/// User-facing result summary for the active hook catalog controls.
class ProductManagementPackModuleHookCatalogResultSummary {
  const ProductManagementPackModuleHookCatalogResultSummary({
    required this.totalCount,
    required this.visibleCount,
    required this.filter,
    required this.kindFilter,
    required this.query,
    this.sort = ProductManagementPackModuleHookCatalogSort.registryOrder,
  });

  final int totalCount;
  final int visibleCount;
  final ProductManagementPackModuleHookCatalogFilter filter;
  final ProductManagementPackModuleHookKindFilter kindFilter;
  final String query;
  final ProductManagementPackModuleHookCatalogSort sort;

  bool get hasActiveControls {
    return hasActiveProductManagementPackModuleHookCatalogControls(
      filter: filter,
      kindFilter: kindFilter,
      query: query,
      sort: sort,
    );
  }

  String get resultLabel {
    if (totalCount == 0) return 'No modules';
    if (!hasActiveControls && visibleCount == totalCount) {
      return 'Showing all ${_countLabel(totalCount, 'module')}';
    }

    return 'Showing $visibleCount of ${_countLabel(totalCount, 'module')}';
  }

  String get contextLabel {
    if (!hasActiveControls) return 'Unfiltered';

    final parts = <String>[
      if (filter != ProductManagementPackModuleHookCatalogFilter.all)
        filter.label,
      if (kindFilter != ProductManagementPackModuleHookKindFilter.all)
        kindFilter.label,
      if (sort != ProductManagementPackModuleHookCatalogSort.registryOrder)
        'Sorted ${sort.activeFilterLabel}',
      if (query.trim().isNotEmpty) 'Search',
    ];

    return parts.join(' + ');
  }
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}

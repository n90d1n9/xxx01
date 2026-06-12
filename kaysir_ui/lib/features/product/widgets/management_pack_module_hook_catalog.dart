import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/management_pack_contribution_bundle.dart';
import '../models/management_pack_contribution_source_group.dart';
import '../models/management_pack_module_hook_catalog_filter.dart';
import '../models/management_pack_module_hook_catalog_result_summary.dart';
import '../models/management_pack_module_hook_catalog_sort.dart';
import '../models/management_pack_module_hook_catalog_summary.dart';
import '../models/product_module_contribution_activation_summary.dart';
import 'management_pack_extension_hook_kind_section_list.dart';
import 'management_pack_module_hook_active_filter_bar.dart';
import 'management_pack_module_hook_catalog_controls.dart';
import 'management_pack_module_hook_empty_state.dart';
import 'management_pack_module_hook_group_header.dart';
import 'management_pack_module_hook_result_summary_divider.dart';
import 'management_pack_module_hook_summary_bar.dart';

/// Searchable and filterable catalog of management-pack module hooks.
class ProductManagementPackModuleHookCatalog extends StatefulWidget {
  const ProductManagementPackModuleHookCatalog({
    super.key,
    required this.groups,
  });

  final List<ProductManagementPackContributionSourceGroup> groups;

  @override
  State<ProductManagementPackModuleHookCatalog> createState() =>
      _ProductManagementPackModuleHookCatalogState();
}

class _ProductManagementPackModuleHookCatalogState
    extends State<ProductManagementPackModuleHookCatalog> {
  final _queryController = TextEditingController();
  var _filter = ProductManagementPackModuleHookCatalogFilter.all;
  var _kindFilter = ProductManagementPackModuleHookKindFilter.all;
  var _sort = ProductManagementPackModuleHookCatalogSort.registryOrder;
  var _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _clearStatusFilter() {
    setState(() {
      _filter = ProductManagementPackModuleHookCatalogFilter.all;
    });
  }

  void _clearKindFilter() {
    setState(() {
      _kindFilter = ProductManagementPackModuleHookKindFilter.all;
    });
  }

  void _clearSort() {
    setState(() {
      _sort = ProductManagementPackModuleHookCatalogSort.registryOrder;
    });
  }

  void _clearQuery() {
    _queryController.clear();
    setState(() => _query = '');
  }

  void _resetControls() {
    _queryController.clear();
    setState(() {
      _filter = ProductManagementPackModuleHookCatalogFilter.all;
      _kindFilter = ProductManagementPackModuleHookKindFilter.all;
      _sort = ProductManagementPackModuleHookCatalogSort.registryOrder;
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final summary = ProductManagementPackModuleHookCatalogSummary(
      groups: widget.groups,
    );
    final filteredGroups = filterProductManagementPackModuleHookCatalogGroups(
      groups: widget.groups,
      filter: _filter,
      kindFilter: _kindFilter,
      query: _query,
    );
    final visibleGroups = sortProductManagementPackModuleHookCatalogGroups(
      groups: filteredGroups,
      sort: _sort,
    );
    final resultSummary = ProductManagementPackModuleHookCatalogResultSummary(
      totalCount: widget.groups.length,
      visibleCount: visibleGroups.length,
      filter: _filter,
      kindFilter: _kindFilter,
      query: _query,
      sort: _sort,
    );
    final hasSearch = _query.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Extension hook catalog',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        if (widget.groups.isEmpty)
          Text(
            'No extension hooks registered for this pack',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          )
        else
          Column(
            children: [
              ProductManagementPackModuleHookSummaryBar(summary: summary),
              const SizedBox(height: 8),
              ProductManagementPackModuleHookCatalogControls(
                groups: widget.groups,
                filter: _filter,
                kindFilter: _kindFilter,
                sort: _sort,
                query: _query,
                queryController: _queryController,
                onFilterChanged: (filter) {
                  setState(() => _filter = filter);
                },
                onKindFilterChanged: (filter) {
                  setState(() => _kindFilter = filter);
                },
                onSortChanged: (sort) {
                  setState(() => _sort = sort);
                },
                onQueryChanged: (query) {
                  setState(() => _query = query);
                },
                onQueryCleared: _clearQuery,
                onReset: _resetControls,
              ),
              if (resultSummary.hasActiveControls) ...[
                const SizedBox(height: 8),
                ProductManagementPackModuleHookActiveFilterBar(
                  filter: _filter,
                  kindFilter: _kindFilter,
                  sort: _sort,
                  query: _query,
                  onFilterCleared: _clearStatusFilter,
                  onKindFilterCleared: _clearKindFilter,
                  onSortCleared: _clearSort,
                  onQueryCleared: _clearQuery,
                  onClearAll: _resetControls,
                ),
              ],
              const SizedBox(height: 8),
              if (resultSummary.hasActiveControls)
                ProductManagementPackModuleHookResultSummaryDivider(
                  summary: resultSummary,
                )
              else
                Divider(color: colorScheme.outlineVariant, height: 1),
              const SizedBox(height: 8),
              if (visibleGroups.isEmpty)
                ProductManagementPackModuleHookEmptyState(
                  hasSearch: hasSearch,
                  onReset: _resetControls,
                )
              else
                for (var index = 0; index < visibleGroups.length; index += 1)
                  _ModuleHookGroup(
                    group: visibleGroups[index],
                    showDivider: index != visibleGroups.length - 1,
                  ),
            ],
          ),
      ],
    );
  }
}

@Preview(name: 'Management pack module hook catalog')
Widget productManagementPackModuleHookCatalogPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductManagementPackModuleHookCatalog(groups: _previewGroups),
      ),
    ),
  );
}

/// Rendered module group with hook sections and separators.
class _ModuleHookGroup extends StatelessWidget {
  const _ModuleHookGroup({required this.group, required this.showDivider});

  final ProductManagementPackContributionSourceGroup group;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductManagementPackModuleHookGroupHeader(group: group),
        const SizedBox(height: 12),
        ProductManagementPackExtensionHookKindSectionList(
          sections: group.kindSections,
        ),
        if (showDivider) ...[
          const SizedBox(height: 14),
          Divider(color: colorScheme.outlineVariant, height: 1),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

final _previewGroups = [
  ProductManagementPackContributionSourceGroup(
    id: 'core_catalog',
    title: 'Core Catalog',
    activationSummary: const ProductModuleContributionActivationSummary(
      id: 'core_catalog',
      title: 'Core Catalog',
      description: 'Catalog workflows and recommendations',
      isActive: true,
      reasonLabel: 'Core catalog capability matched',
      actionContributionCount: 1,
      setupReadinessContributionCount: 0,
      recommendationContributionCount: 1,
    ),
    contributions: [
      ProductManagementPackContributionSummary(
        id: 'catalog_review_actions',
        kind: ProductManagementPackContributionKind.workspaceAction,
        title: 'Catalog review actions',
        detailLabel: '3 actions across 1 group',
        statusLabel: 'Active',
        isActive: true,
        outputCount: 3,
        outputLabels: const ['Review products'],
        sourceId: 'core_catalog',
        sourceTitle: 'Core Catalog',
      ),
      ProductManagementPackContributionSummary(
        id: 'quality_recommendations',
        kind: ProductManagementPackContributionKind.recommendation,
        title: 'Quality recommendations',
        detailLabel: '2 recommended steps',
        statusLabel: 'Active',
        isActive: true,
        outputCount: 2,
        outputLabels: const ['Fix missing SKUs', 'Review pricing'],
        sourceId: 'core_catalog',
        sourceTitle: 'Core Catalog',
      ),
    ],
  ),
  ProductManagementPackContributionSourceGroup(
    id: 'fresh_goods',
    title: 'Fresh Goods',
    activationSummary: const ProductModuleContributionActivationSummary(
      id: 'fresh_goods',
      title: 'Fresh Goods',
      description: 'Freshness and expiry workflows',
      isActive: false,
      reasonLabel: 'Requires freshness capability',
      actionContributionCount: 1,
      setupReadinessContributionCount: 1,
      recommendationContributionCount: 0,
    ),
    contributions: [
      ProductManagementPackContributionSummary(
        id: 'freshness_queue',
        kind: ProductManagementPackContributionKind.workspaceAction,
        title: 'Freshness queue',
        detailLabel: 'Pack capability inactive',
        statusLabel: 'Inactive',
        isActive: false,
        outputCount: 0,
        outputLabels: const ['Freshness queue'],
        sourceId: 'fresh_goods',
        sourceTitle: 'Fresh Goods',
      ),
    ],
  ),
];

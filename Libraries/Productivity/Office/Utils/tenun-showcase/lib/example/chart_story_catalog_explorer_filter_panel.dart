import 'package:flutter/material.dart';

import '../story/chart_story_catalog_presets.dart';
import '../story/chart_story_contract_coverage.dart';
import '../story/chart_story_groups.dart';
import '../story/chart_story_tier.dart';
import 'chart_story_catalog_explorer_facets.dart';
import 'chart_story_catalog_explorer_filter_controls.dart';
import 'chart_story_catalog_explorer_snapshot.dart';
import 'chart_story_catalog_explorer_state.dart';
import 'chart_story_tier_presentation.dart';

class ChartCatalogExplorerFilterPanel extends StatelessWidget {
  const ChartCatalogExplorerFilterPanel({
    super.key,
    required this.catalog,
    required this.filters,
    required this.snapshot,
    required this.queryController,
    required this.selectedPresetId,
    required this.onPresetSelected,
    required this.onTierSelected,
    required this.onContractStatusSelected,
    required this.onCategorySelected,
    required this.onGroupSelected,
    required this.onSectionSelected,
    required this.onDataShapeSelected,
    required this.onFamilySelected,
    required this.onClearQuery,
    required this.onClearTier,
    required this.onClearCategory,
    required this.onClearGroup,
    required this.onClearSection,
    required this.onClearDataShape,
    required this.onClearFamily,
    required this.onClearContractStatus,
    required this.onClearAll,
    this.groupLabelForValue,
    this.groupFacetLabelForValue,
  });

  final ChartStoryCatalog catalog;
  final ChartCatalogExplorerFilters filters;
  final ChartCatalogExplorerSnapshot snapshot;
  final TextEditingController queryController;
  final String? selectedPresetId;
  final ValueChanged<ChartStoryCatalogPreset> onPresetSelected;
  final ValueChanged<String> onTierSelected;
  final ValueChanged<ChartStoryContractStatusFilter> onContractStatusSelected;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onGroupSelected;
  final ValueChanged<String> onSectionSelected;
  final ValueChanged<String> onDataShapeSelected;
  final ValueChanged<String> onFamilySelected;
  final VoidCallback onClearQuery;
  final VoidCallback onClearTier;
  final VoidCallback onClearCategory;
  final VoidCallback onClearGroup;
  final VoidCallback onClearSection;
  final VoidCallback onClearDataShape;
  final VoidCallback onClearFamily;
  final VoidCallback onClearContractStatus;
  final VoidCallback onClearAll;
  final String Function(String value)? groupLabelForValue;
  final String Function(String value)? groupFacetLabelForValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: queryController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Search stories',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        ChartCatalogPresetWrap(
          selectedPresetId: selectedPresetId,
          presetCounts: {
            for (final preset in chartStoryCatalogPresets)
              preset.id: preset.entriesIn(catalog).length,
          },
          onSelected: onPresetSelected,
        ),
        const SizedBox(height: 16),
        ChartCatalogContractStatusFilterWrap(
          selectedStatus: filters.contractStatus,
          statusCounts: snapshot.contractStatusCounts,
          onSelected: onContractStatusSelected,
        ),
        const SizedBox(height: 16),
        ChartCatalogFacetWrap(
          title: 'Tier',
          values: catalog.tierKeys,
          valueCounts: snapshot.tierCounts,
          selectedValue: filters.tier,
          labelForValue: chartStoryTierLabelForKey,
          iconForValue: chartStoryTierIconForKey,
          tooltipForValue: chartStoryTierDescriptionForKey,
          onSelected: onTierSelected,
        ),
        const SizedBox(height: 16),
        ChartCatalogFacetWrap(
          title: 'Category',
          values: [for (final category in catalog.categories) category.label],
          valueCounts: snapshot.categoryCounts,
          selectedValue: filters.categoryLabel,
          onSelected: onCategorySelected,
        ),
        const SizedBox(height: 12),
        ChartCatalogFacetWrap(
          title: 'Group',
          values: [for (final group in catalog.groups) group.id],
          valueCounts: snapshot.groupCounts,
          selectedValue: filters.groupId,
          labelForValue: groupFacetLabelForValue,
          onSelected: onGroupSelected,
        ),
        const SizedBox(height: 12),
        ChartCatalogFacetWrap(
          title: 'Section',
          values: catalog.sections,
          valueCounts: snapshot.sectionCounts,
          selectedValue: filters.section,
          onSelected: onSectionSelected,
        ),
        const SizedBox(height: 12),
        ChartCatalogFacetWrap(
          title: 'Data shape',
          values: catalog.dataShapes,
          valueCounts: snapshot.dataShapeCounts,
          selectedValue: filters.dataShape,
          onSelected: onDataShapeSelected,
        ),
        const SizedBox(height: 12),
        ChartCatalogFacetWrap(
          title: 'Family',
          values: catalog.families,
          valueCounts: snapshot.familyCounts,
          selectedValue: filters.family,
          onSelected: onFamilySelected,
        ),
        if (filters.hasActiveFilters) ...[
          const SizedBox(height: 14),
          ChartCatalogActiveFilterSummary(
            query: filters.query.trim(),
            tier: filters.tier == null
                ? null
                : chartStoryTierLabelForKey(filters.tier!),
            tierTooltip: filters.tier == null
                ? null
                : chartStoryTierDescriptionForKey(filters.tier!),
            category: filters.categoryLabel,
            group: _activeGroupLabel,
            section: filters.section,
            dataShape: filters.dataShape,
            family: filters.family,
            contractStatus: filters.contractStatus,
            onClearQuery: onClearQuery,
            onClearTier: onClearTier,
            onClearCategory: onClearCategory,
            onClearGroup: onClearGroup,
            onClearSection: onClearSection,
            onClearDataShape: onClearDataShape,
            onClearFamily: onClearFamily,
            onClearContractStatus: onClearContractStatus,
            onClearAll: onClearAll,
          ),
        ],
      ],
    );
  }

  String? get _activeGroupLabel {
    final groupId = filters.groupId;
    if (groupId == null) {
      return null;
    }

    return groupLabelForValue?.call(groupId) ?? groupId;
  }
}

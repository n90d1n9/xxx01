import 'package:flutter/material.dart';

import '../story/chart_story_catalog_presets.dart';
import '../story/chart_story_contract_coverage.dart';
import 'chart_story_catalog_explorer_chips.dart';

class ChartCatalogPresetWrap extends StatelessWidget {
  const ChartCatalogPresetWrap({
    super.key,
    required this.selectedPresetId,
    required this.presetCounts,
    required this.onSelected,
  });

  final String? selectedPresetId;
  final Map<String, int> presetCounts;
  final ValueChanged<ChartStoryCatalogPreset> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick views',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in chartStoryCatalogPresets)
              Tooltip(
                message: preset.description,
                child: _PresetChip(
                  preset: preset,
                  count: presetCounts[preset.id] ?? 0,
                  selected: preset.id == selectedPresetId,
                  onSelected: onSelected,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class ChartCatalogActiveFilterSummary extends StatelessWidget {
  const ChartCatalogActiveFilterSummary({
    super.key,
    required this.query,
    required this.tier,
    required this.tierTooltip,
    required this.category,
    required this.group,
    required this.section,
    required this.dataShape,
    required this.family,
    required this.contractStatus,
    required this.onClearQuery,
    required this.onClearTier,
    required this.onClearCategory,
    required this.onClearGroup,
    required this.onClearSection,
    required this.onClearDataShape,
    required this.onClearFamily,
    required this.onClearContractStatus,
    required this.onClearAll,
  });

  final String query;
  final String? tier;
  final String? tierTooltip;
  final String? category;
  final String? group;
  final String? section;
  final String? dataShape;
  final String? family;
  final ChartStoryContractStatusFilter contractStatus;
  final VoidCallback onClearQuery;
  final VoidCallback onClearTier;
  final VoidCallback onClearCategory;
  final VoidCallback onClearGroup;
  final VoidCallback onClearSection;
  final VoidCallback onClearDataShape;
  final VoidCallback onClearFamily;
  final VoidCallback onClearContractStatus;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active filters',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (query.isNotEmpty)
              ChartCatalogFilterInputChip(
                icon: Icons.search,
                label: 'Search: $query',
                onDeleted: onClearQuery,
              ),
            if (tier != null)
              ChartCatalogFilterInputChip(
                icon: Icons.workspace_premium_outlined,
                label: 'Tier: $tier',
                onDeleted: onClearTier,
                tooltip: tierTooltip,
              ),
            if (category != null)
              ChartCatalogFilterInputChip(
                icon: Icons.category_outlined,
                label: 'Category: $category',
                onDeleted: onClearCategory,
              ),
            if (group != null)
              ChartCatalogFilterInputChip(
                icon: Icons.folder_outlined,
                label: 'Group: $group',
                onDeleted: onClearGroup,
              ),
            if (section != null)
              ChartCatalogFilterInputChip(
                icon: Icons.account_tree_outlined,
                label: 'Section: $section',
                onDeleted: onClearSection,
              ),
            if (dataShape != null)
              ChartCatalogFilterInputChip(
                icon: Icons.dataset_outlined,
                label: 'Data shape: $dataShape',
                onDeleted: onClearDataShape,
              ),
            if (family != null)
              ChartCatalogFilterInputChip(
                icon: Icons.auto_graph,
                label: 'Family: $family',
                onDeleted: onClearFamily,
              ),
            if (contractStatus != ChartStoryContractStatusFilter.all)
              ChartCatalogFilterInputChip(
                icon: Icons.fact_check_outlined,
                label: 'Contract: ${contractStatus.label}',
                onDeleted: onClearContractStatus,
              ),
            TextButton.icon(
              onPressed: onClearAll,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear filters'),
            ),
          ],
        ),
      ],
    );
  }
}

class ChartCatalogContractStatusFilterWrap extends StatelessWidget {
  const ChartCatalogContractStatusFilterWrap({
    super.key,
    required this.selectedStatus,
    required this.statusCounts,
    required this.onSelected,
  });

  final ChartStoryContractStatusFilter selectedStatus;
  final Map<ChartStoryContractStatusFilter, int> statusCounts;
  final ValueChanged<ChartStoryContractStatusFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contract status',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final status in chartStoryContractStatusFilters)
              _ContractStatusChip(
                status: status,
                count: statusCounts[status] ?? 0,
                selected: status == selectedStatus,
                onSelected: onSelected,
              ),
          ],
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.preset,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  final ChartStoryCatalogPreset preset;
  final int count;
  final bool selected;
  final ValueChanged<ChartStoryCatalogPreset> onSelected;

  @override
  Widget build(BuildContext context) {
    final isEnabled = selected || count > 0;

    return FilterChip(
      avatar: Icon(preset.hasFilters ? Icons.tune : Icons.all_inclusive),
      label: ChartCatalogChipLabel(
        label: preset.label,
        count: count,
        enabled: isEnabled,
      ),
      selected: selected,
      onSelected: isEnabled ? (_) => onSelected(preset) : null,
    );
  }
}

class _ContractStatusChip extends StatelessWidget {
  const _ContractStatusChip({
    required this.status,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  final ChartStoryContractStatusFilter status;
  final int count;
  final bool selected;
  final ValueChanged<ChartStoryContractStatusFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status.label),
          const SizedBox(width: 6),
          ChartCatalogCountBadge(count: count),
        ],
      ),
      selected: selected,
      onSelected: count == 0 ? null : (_) => onSelected(status),
    );
  }
}

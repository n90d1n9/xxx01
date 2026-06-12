import 'package:flutter/material.dart';

import 'chart_sample_explorer_logic.dart';
import 'chart_showcase_tier.dart';

class ChartFamilySortControl extends StatelessWidget {
  const ChartFamilySortControl({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final ChartFamilySortMode mode;
  final ValueChanged<ChartFamilySortMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: PopupMenuButton<ChartFamilySortMode>(
        tooltip: 'Sort chart families',
        initialValue: mode,
        onSelected: onChanged,
        itemBuilder: (context) => [
          for (final option in ChartFamilySortMode.values)
            PopupMenuItem(
              value: option,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: option == mode
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: colorScheme.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(chartFamilySortModeLabel(option)),
                ],
              ),
            ),
        ],
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.48),
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort, size: 18, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'Sort: ${chartFamilySortModeLabel(mode)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChartFamilyStatsStrip extends StatelessWidget {
  const ChartFamilyStatsStrip({
    super.key,
    required this.visibleStats,
    required this.totalStats,
    required this.filtered,
  });

  final ChartFamilyExplorerStats visibleStats;
  final ChartFamilyExplorerStats totalStats;
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ChartFamilyStatChip(
          label: 'Families',
          value: chartExplorerStatValue(
            visible: visibleStats.familyCount,
            total: totalStats.familyCount,
            filtered: filtered,
          ),
        ),
        _ChartFamilyStatChip(
          label: 'Samples',
          value: chartExplorerStatValue(
            visible: visibleStats.sampleCount,
            total: totalStats.sampleCount,
            filtered: filtered,
          ),
        ),
        _ChartFamilyStatChip(
          label: 'Types',
          value: chartExplorerStatValue(
            visible: visibleStats.typeCount,
            total: totalStats.typeCount,
            filtered: filtered,
          ),
        ),
      ],
    );
  }
}

class ChartTypeFilterStrip extends StatelessWidget {
  const ChartTypeFilterStrip({
    super.key,
    required this.options,
    required this.totalFamilyCount,
    required this.selectedType,
    required this.onSelected,
  });

  final List<ChartTypeFilterOption> options;
  final int totalFamilyCount;
  final String? selectedType;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chart type filters',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ChartTypeFilterChip(
              label: 'All ($totalFamilyCount)',
              tooltip: 'Show all chart families',
              selected: selectedType == null,
              onSelected: () => onSelected(null),
            ),
            for (final option in options)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _ChartTypeFilterChip(
                  label: '${option.type} (${option.familyCount})',
                  tooltip: 'Show ${option.type} chart families',
                  selected:
                      selectedType != null &&
                      chartTypeMatches(option.type, selectedType!),
                  onSelected: () => onSelected(option.type),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChartTierFilterStrip extends StatelessWidget {
  const ChartTierFilterStrip({
    super.key,
    required this.options,
    required this.totalFamilyCount,
    required this.selectedTierFilter,
    required this.onSelected,
  });

  final List<ChartTierFilterOption> options;
  final int totalFamilyCount;
  final ChartShowcaseTierFilter selectedTierFilter;
  final ValueChanged<ChartShowcaseTierFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chart tier filters',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ChartTypeFilterChip(
              label: 'All tiers ($totalFamilyCount)',
              tooltip: 'Show all chart tiers',
              selected: selectedTierFilter == ChartShowcaseTierFilter.all,
              onSelected: () => onSelected(ChartShowcaseTierFilter.all),
            ),
            for (final option in options)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _ChartTypeFilterChip(
                  label: '${option.tierFilter.label} (${option.familyCount})',
                  tooltip: 'Show ${option.tierFilter.label} chart families',
                  selected: selectedTierFilter == option.tierFilter,
                  onSelected: () => onSelected(option.tierFilter),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChartSampleResultLabel extends StatelessWidget {
  const ChartSampleResultLabel({
    super.key,
    required this.visibleCount,
    required this.totalCount,
  });

  final int visibleCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      chartSampleResultLabel(
        visibleCount: visibleCount,
        totalCount: totalCount,
      ),
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }
}

class ChartSampleFamilySearchField extends StatelessWidget {
  const ChartSampleFamilySearchField({
    super.key,
    required this.controller,
    required this.resultLabel,
    required this.onChanged,
    required this.clearTooltip,
    required this.onClear,
  });

  final TextEditingController controller;
  final String resultLabel;
  final ValueChanged<String> onChanged;
  final String clearTooltip;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: onClear == null
                ? null
                : IconButton(
                    tooltip: clearTooltip,
                    icon: const Icon(Icons.close),
                    onPressed: onClear,
                  ),
            labelText: 'Search families',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          resultLabel,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class ChartSampleFamilyEmptyState extends StatelessWidget {
  const ChartSampleFamilyEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      'No chart families found',
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }
}

class _ChartFamilyStatChip extends StatelessWidget {
  const _ChartFamilyStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: '$label: $value',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Text(
            '$label $value',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartTypeFilterChip extends StatelessWidget {
  const _ChartTypeFilterChip({
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ChoiceChip(
      label: Text(label),
      tooltip: tooltip,
      selected: selected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      selectedColor: colorScheme.primaryContainer.withValues(alpha: 0.64),
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.48,
      ),
      side: BorderSide(
        color: selected ? colorScheme.primary : colorScheme.outlineVariant,
      ),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

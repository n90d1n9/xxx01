import 'package:flutter/material.dart';

import '../story/chart_story_groups.dart';
import 'chart_story_catalog_result_tile.dart';
import 'chart_story_catalog_explorer_state.dart';

class ChartCatalogGroupedResultList extends StatelessWidget {
  const ChartCatalogGroupedResultList({
    super.key,
    required this.entries,
    required this.groupMode,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  final List<ChartStoryEntry> entries;
  final ChartCatalogResultGroupMode groupMode;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _EmptyResultState(
        showReset: hasActiveFilters,
        onReset: onClearFilters,
      );
    }

    final groups = groupChartCatalogEntries(entries, groupMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          _ResultSectionHeader(label: group.label, count: group.entries.length),
          const SizedBox(height: 8),
          for (final entry in group.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChartCatalogResultTile(entry: entry),
            ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class _EmptyResultState extends StatelessWidget {
  const _EmptyResultState({required this.showReset, required this.onReset});

  final bool showReset;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search_off, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No matching stories',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (showReset) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset search and filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultSectionHeader extends StatelessWidget {
  const _ResultSectionHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_outlined, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '$label ($count)',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

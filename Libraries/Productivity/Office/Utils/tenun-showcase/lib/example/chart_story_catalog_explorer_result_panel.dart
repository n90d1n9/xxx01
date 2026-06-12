import 'package:flutter/material.dart';

import 'chart_story_catalog_explorer_controls.dart';
import 'chart_story_catalog_explorer_results.dart';
import 'chart_story_catalog_explorer_snapshot.dart';
import 'chart_story_catalog_explorer_state.dart';

class ChartCatalogExplorerResultPanel extends StatelessWidget {
  const ChartCatalogExplorerResultPanel({
    super.key,
    required this.snapshot,
    required this.sortMode,
    required this.groupMode,
    required this.hasActiveFilters,
    required this.onSortModeChanged,
    required this.onGroupModeChanged,
    required this.onClearFilters,
  });

  final ChartCatalogExplorerSnapshot snapshot;
  final ChartCatalogResultSortMode sortMode;
  final ChartCatalogResultGroupMode groupMode;
  final bool hasActiveFilters;
  final ValueChanged<ChartCatalogResultSortMode> onSortModeChanged;
  final ValueChanged<ChartCatalogResultGroupMode> onGroupModeChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChartCatalogResultSortControl(
          sortMode: sortMode,
          onChanged: onSortModeChanged,
        ),
        const SizedBox(height: 14),
        ChartCatalogResultGroupControl(
          groupMode: groupMode,
          onChanged: onGroupModeChanged,
        ),
        const SizedBox(height: 14),
        Text(
          'Showing ${snapshot.visibleEntryCount} of ${snapshot.matchingEntryCount} matching stories',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ChartCatalogGroupedResultList(
          entries: snapshot.visibleEntries,
          groupMode: groupMode,
          hasActiveFilters: hasActiveFilters,
          onClearFilters: onClearFilters,
        ),
      ],
    );
  }
}

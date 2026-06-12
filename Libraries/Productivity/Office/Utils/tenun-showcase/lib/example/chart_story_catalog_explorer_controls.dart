import 'package:flutter/material.dart';

import 'chart_story_catalog_explorer_state.dart';

class ChartCatalogResultSortControl extends StatelessWidget {
  const ChartCatalogResultSortControl({
    super.key,
    required this.sortMode,
    required this.onChanged,
  });

  final ChartCatalogResultSortMode sortMode;
  final ValueChanged<ChartCatalogResultSortMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort results',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<ChartCatalogResultSortMode>(
            showSelectedIcon: false,
            selected: {sortMode},
            onSelectionChanged: (selection) => onChanged(selection.single),
            segments: const [
              ButtonSegment(
                value: ChartCatalogResultSortMode.catalog,
                icon: Icon(Icons.account_tree_outlined),
                label: Text('Catalog'),
              ),
              ButtonSegment(
                value: ChartCatalogResultSortMode.title,
                icon: Icon(Icons.sort_by_alpha),
                label: Text('A-Z'),
              ),
              ButtonSegment(
                value: ChartCatalogResultSortMode.tier,
                icon: Icon(Icons.workspace_premium_outlined),
                label: Text('Tier'),
              ),
              ButtonSegment(
                value: ChartCatalogResultSortMode.category,
                icon: Icon(Icons.category_outlined),
                label: Text('Category'),
              ),
              ButtonSegment(
                value: ChartCatalogResultSortMode.family,
                icon: Icon(Icons.auto_graph),
                label: Text('Family'),
              ),
              ButtonSegment(
                value: ChartCatalogResultSortMode.group,
                icon: Icon(Icons.folder_outlined),
                label: Text('Group'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChartCatalogResultGroupControl extends StatelessWidget {
  const ChartCatalogResultGroupControl({
    super.key,
    required this.groupMode,
    required this.onChanged,
  });

  final ChartCatalogResultGroupMode groupMode;
  final ValueChanged<ChartCatalogResultGroupMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group results',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<ChartCatalogResultGroupMode>(
            showSelectedIcon: false,
            selected: {groupMode},
            onSelectionChanged: (selection) => onChanged(selection.single),
            segments: const [
              ButtonSegment(
                value: ChartCatalogResultGroupMode.tier,
                icon: Icon(Icons.workspace_premium_outlined),
                label: Text('Tier'),
              ),
              ButtonSegment(
                value: ChartCatalogResultGroupMode.category,
                icon: Icon(Icons.category_outlined),
                label: Text('Category'),
              ),
              ButtonSegment(
                value: ChartCatalogResultGroupMode.group,
                icon: Icon(Icons.folder_outlined),
                label: Text('Group'),
              ),
              ButtonSegment(
                value: ChartCatalogResultGroupMode.section,
                icon: Icon(Icons.account_tree_outlined),
                label: Text('Section'),
              ),
              ButtonSegment(
                value: ChartCatalogResultGroupMode.dataShape,
                icon: Icon(Icons.dataset_outlined),
                label: Text('Shape'),
              ),
              ButtonSegment(
                value: ChartCatalogResultGroupMode.family,
                icon: Icon(Icons.auto_graph),
                label: Text('Family'),
              ),
              ButtonSegment(
                value: ChartCatalogResultGroupMode.contract,
                icon: Icon(Icons.fact_check_outlined),
                label: Text('Contract'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_filter.dart';
import '../models/dashboard_workspace_filter_counts.dart';

class DashboardWorkspaceFilterBar extends StatelessWidget {
  final DashboardWorkspaceFilter selectedFilter;
  final DashboardWorkspaceFilterCounts counts;
  final ValueChanged<DashboardWorkspaceFilter> onChanged;

  const DashboardWorkspaceFilterBar({
    super.key,
    required this.selectedFilter,
    required this.counts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<DashboardWorkspaceFilter>(
        segments:
            DashboardWorkspaceFilter.values
                .map(
                  (filter) => ButtonSegment<DashboardWorkspaceFilter>(
                    value: filter,
                    icon: Icon(_filterIcon(filter), size: 18),
                    label: Text(counts.labelFor(filter)),
                    tooltip: _filterTooltip(filter),
                    enabled:
                        filter == selectedFilter || counts.isAvailable(filter),
                  ),
                )
                .toList(),
        selected: {selectedFilter},
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return HrisColors.ink;
            }
            return HrisColors.muted;
          }),
          textStyle: WidgetStateProperty.all(
            Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}

IconData _filterIcon(DashboardWorkspaceFilter filter) {
  switch (filter) {
    case DashboardWorkspaceFilter.all:
      return Icons.apps_outlined;
    case DashboardWorkspaceFilter.strategic:
      return Icons.account_tree_outlined;
    case DashboardWorkspaceFilter.operational:
      return Icons.fact_check_outlined;
    case DashboardWorkspaceFilter.attention:
      return Icons.notification_important_outlined;
    case DashboardWorkspaceFilter.timeSensitive:
      return Icons.schedule_outlined;
    case DashboardWorkspaceFilter.critical:
      return Icons.priority_high_rounded;
    case DashboardWorkspaceFilter.elevated:
      return Icons.trending_up_outlined;
  }
}

String _filterTooltip(DashboardWorkspaceFilter filter) {
  switch (filter) {
    case DashboardWorkspaceFilter.all:
      return 'Show all HR workspaces';
    case DashboardWorkspaceFilter.strategic:
      return 'Show strategic HR workspaces';
    case DashboardWorkspaceFilter.operational:
      return 'Show operational HR workspaces';
    case DashboardWorkspaceFilter.attention:
      return 'Show workspaces with active risk signals';
    case DashboardWorkspaceFilter.timeSensitive:
      return 'Show workspaces with time-sensitive risk items';
    case DashboardWorkspaceFilter.critical:
      return 'Show critical risk workspaces';
    case DashboardWorkspaceFilter.elevated:
      return 'Show elevated risk workspaces';
  }
}

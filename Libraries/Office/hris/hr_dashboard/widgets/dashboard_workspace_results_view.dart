import 'package:flutter/material.dart';

import '../models/dashboard_workspace_entry.dart';
import '../models/dashboard_workspace_query.dart';
import '../models/dashboard_workspace_view_mode.dart';
import 'dashboard_workspace_empty_state.dart';
import 'dashboard_workspace_grouped_list.dart';
import 'dashboard_workspace_result_collections.dart';

class DashboardWorkspaceResultsView extends StatelessWidget {
  final List<DashboardWorkspaceEntry> entries;
  final DashboardWorkspaceQuery query;
  final DashboardWorkspaceViewMode viewMode;
  final VoidCallback onReset;
  final VoidCallback onClearSearch;
  final VoidCallback onClearFilter;
  final VoidCallback onClearSort;

  const DashboardWorkspaceResultsView({
    super.key,
    required this.entries,
    required this.query,
    required this.viewMode,
    required this.onReset,
    required this.onClearSearch,
    required this.onClearFilter,
    required this.onClearSort,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: LayoutBuilder(
        key: ValueKey(_stateKey),
        builder: (context, constraints) {
          if (entries.isEmpty) {
            return DashboardWorkspaceEmptyState(
              query: query,
              onReset: onReset,
              onClearSearch: onClearSearch,
              onClearFilter: onClearFilter,
              onClearSort: onClearSort,
            );
          }

          if (viewMode == DashboardWorkspaceViewMode.list) {
            if (query.isRiskFocused) {
              return DashboardWorkspaceGroupedList(entries: entries);
            }

            return DashboardWorkspaceList(entries: entries);
          }

          return DashboardWorkspaceGrid(
            entries: entries,
            maxWidth: constraints.maxWidth,
          );
        },
      ),
    );
  }

  String get _stateKey {
    if (entries.isEmpty) return 'empty';
    return viewMode.name;
  }
}

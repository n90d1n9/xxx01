import 'package:flutter/material.dart';

import '../models/dashboard_workspace_sort.dart';
import '../models/dashboard_workspace_view_mode.dart';
import 'dashboard_workspace_search_field.dart';
import 'dashboard_workspace_sort_menu.dart';
import 'dashboard_workspace_view_toggle.dart';

class DashboardWorkspaceToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final bool hasQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final DashboardWorkspaceSort selectedSort;
  final ValueChanged<DashboardWorkspaceSort> onSortChanged;
  final DashboardWorkspaceViewMode selectedViewMode;
  final ValueChanged<DashboardWorkspaceViewMode> onViewModeChanged;

  const DashboardWorkspaceToolbar({
    super.key,
    required this.searchController,
    required this.hasQuery,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.selectedSort,
    required this.onSortChanged,
    required this.selectedViewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DashboardWorkspaceSearchField(
                controller: searchController,
                hasQuery: hasQuery,
                onChanged: onSearchChanged,
                onClear: onSearchClear,
              ),
              const SizedBox(height: 12),
              DashboardWorkspaceSortMenu(
                selectedSort: selectedSort,
                onChanged: onSortChanged,
              ),
              const SizedBox(height: 12),
              DashboardWorkspaceViewToggle(
                selectedViewMode: selectedViewMode,
                onChanged: onViewModeChanged,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DashboardWorkspaceSearchField(
                controller: searchController,
                hasQuery: hasQuery,
                onChanged: onSearchChanged,
                onClear: onSearchClear,
              ),
            ),
            const SizedBox(width: 12),
            DashboardWorkspaceSortMenu(
              selectedSort: selectedSort,
              onChanged: onSortChanged,
            ),
            const SizedBox(width: 12),
            DashboardWorkspaceViewToggle(
              selectedViewMode: selectedViewMode,
              onChanged: onViewModeChanged,
            ),
          ],
        );
      },
    );
  }
}

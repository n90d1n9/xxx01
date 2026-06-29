import 'package:flutter/material.dart';

import 'dashboard_workspace_entry.dart';
import 'dashboard_workspace_filter.dart';
import 'dashboard_workspace_query.dart';
import 'dashboard_workspace_sort.dart';
import 'dashboard_workspace_view_mode.dart';

class DashboardWorkspaceSavedView {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final DashboardWorkspaceQuery query;
  final DashboardWorkspaceViewMode viewMode;

  const DashboardWorkspaceSavedView({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.query,
    required this.viewMode,
  });

  int visibleCountFor(Iterable<DashboardWorkspaceEntry> entries) {
    return query.applyTo(entries).length;
  }

  bool isActive({
    required DashboardWorkspaceQuery activeQuery,
    required DashboardWorkspaceViewMode activeViewMode,
  }) {
    return query == activeQuery && viewMode == activeViewMode;
  }
}

const dashboardWorkspaceSavedViews = [
  DashboardWorkspaceSavedView(
    id: 'all',
    label: 'Command center',
    description: 'Full HR command center',
    icon: Icons.dashboard_customize_outlined,
    query: DashboardWorkspaceQuery(),
    viewMode: DashboardWorkspaceViewMode.grid,
  ),
  DashboardWorkspaceSavedView(
    id: 'critical-risk',
    label: 'Critical risks',
    description: 'Highest pressure queues',
    icon: Icons.priority_high_rounded,
    query: DashboardWorkspaceQuery(
      filter: DashboardWorkspaceFilter.critical,
      sort: DashboardWorkspaceSort.risk,
    ),
    viewMode: DashboardWorkspaceViewMode.list,
  ),
  DashboardWorkspaceSavedView(
    id: 'time-sensitive',
    label: 'Due soon',
    description: 'Due soon across HR',
    icon: Icons.schedule_rounded,
    query: DashboardWorkspaceQuery(
      filter: DashboardWorkspaceFilter.timeSensitive,
      sort: DashboardWorkspaceSort.risk,
    ),
    viewMode: DashboardWorkspaceViewMode.list,
  ),
  DashboardWorkspaceSavedView(
    id: 'operational-queue',
    label: 'Operational queue',
    description: 'Daily HR service work',
    icon: Icons.task_alt_outlined,
    query: DashboardWorkspaceQuery(
      filter: DashboardWorkspaceFilter.operational,
      sort: DashboardWorkspaceSort.category,
    ),
    viewMode: DashboardWorkspaceViewMode.grid,
  ),
  DashboardWorkspaceSavedView(
    id: 'strategic-priorities',
    label: 'Strategic priorities',
    description: 'Planning and programs',
    icon: Icons.account_tree_outlined,
    query: DashboardWorkspaceQuery(
      filter: DashboardWorkspaceFilter.strategic,
      sort: DashboardWorkspaceSort.risk,
    ),
    viewMode: DashboardWorkspaceViewMode.grid,
  ),
];

import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_attention.dart';
import '../models/dashboard_workspace_discovery_state.dart';
import '../models/dashboard_workspace_entry.dart';
import '../models/dashboard_workspace_filter.dart';
import '../models/dashboard_workspace_filter_counts.dart';
import '../models/dashboard_workspace_saved_view.dart';
import '../models/dashboard_workspace_triage_summary.dart';
import 'dashboard_workspace_attention_spotlight.dart';
import 'dashboard_workspace_filter.dart';
import 'dashboard_workspace_results_summary.dart';
import 'dashboard_workspace_results_view.dart';
import 'dashboard_workspace_saved_views.dart';
import 'dashboard_workspace_toolbar.dart';
import 'dashboard_workspace_triage_strip.dart';

class WorkspaceLauncher extends StatefulWidget {
  final List<DashboardWorkspaceEntry> entries;

  const WorkspaceLauncher({super.key, required this.entries});

  @override
  State<WorkspaceLauncher> createState() => _WorkspaceLauncherState();
}

class _WorkspaceLauncherState extends State<WorkspaceLauncher> {
  late final TextEditingController _searchController;
  DashboardWorkspaceDiscoveryState _discoveryState =
      const DashboardWorkspaceDiscoveryState();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _discoveryState.query;
    final viewMode = _discoveryState.viewMode;
    final filterCounts = DashboardWorkspaceFilterCounts.fromEntries(
      widget.entries,
    );
    final filteredEntries = query.applyTo(widget.entries);
    final triageSummary = DashboardWorkspaceTriageSummary.fromEntries(
      filteredEntries,
    );
    final spotlightEntry = dashboardTopAttentionWorkspace(widget.entries);
    final activeSavedView = _discoveryState.activeSavedView(
      dashboardWorkspaceSavedViews,
    );
    final riskPressureFilter = dashboardWorkspaceRiskPressureFilter(
      triageSummary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HR Workspaces',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Jump into operational HR workflows and live exception queues.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
        ),
        if (spotlightEntry != null) ...[
          const SizedBox(height: 16),
          DashboardWorkspaceAttentionSpotlight(
            entry: spotlightEntry,
            onFocusAttention: _focusAttention,
          ),
        ],
        const SizedBox(height: 16),
        DashboardWorkspaceSavedViews(
          views: dashboardWorkspaceSavedViews,
          activeView: activeSavedView,
          entries: widget.entries,
          onSelected: _applySavedView,
        ),
        const SizedBox(height: 16),
        DashboardWorkspaceFilterBar(
          selectedFilter: query.filter,
          counts: filterCounts,
          onChanged:
              (filter) => setState(
                () => _discoveryState = _discoveryState.updateFilter(filter),
              ),
        ),
        const SizedBox(height: 16),
        DashboardWorkspaceToolbar(
          searchController: _searchController,
          hasQuery: query.hasSearch,
          onSearchChanged:
              (value) => setState(
                () => _discoveryState = _discoveryState.updateSearch(value),
              ),
          onSearchClear: _clearSearch,
          selectedSort: query.sort,
          onSortChanged:
              (sort) => setState(
                () => _discoveryState = _discoveryState.updateSort(sort),
              ),
          selectedViewMode: viewMode,
          onViewModeChanged:
              (viewMode) => setState(
                () =>
                    _discoveryState = _discoveryState.updateViewMode(viewMode),
              ),
        ),
        const SizedBox(height: 12),
        DashboardWorkspaceResultsSummary(
          visibleCount: filteredEntries.length,
          totalCount: widget.entries.length,
          query: query,
          onReset: _resetDiscovery,
          onClearSearch: _clearSearch,
          onClearFilter: _clearFilter,
          onClearSort: _clearSort,
        ),
        if (filteredEntries.isNotEmpty) ...[
          const SizedBox(height: 12),
          DashboardWorkspaceTriageStrip(
            summary: triageSummary,
            onRiskPressureTap:
                riskPressureFilter == null
                    ? null
                    : () => _focusRiskFilter(riskPressureFilter),
            onTimeSensitiveTap:
                triageSummary.hasTimeSensitive
                    ? () =>
                        _focusRiskFilter(DashboardWorkspaceFilter.timeSensitive)
                    : null,
            onNextFocusTap:
                triageSummary.nextFocus == null ? null : _focusAttention,
          ),
        ],
        const SizedBox(height: 16),
        DashboardWorkspaceResultsView(
          entries: filteredEntries,
          query: query,
          viewMode: viewMode,
          onReset: _resetDiscovery,
          onClearSearch: _clearSearch,
          onClearFilter: _clearFilter,
          onClearSort: _clearSort,
        ),
      ],
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _discoveryState = _discoveryState.clearSearch();
    });
  }

  void _resetDiscovery() {
    _searchController.clear();
    setState(() {
      _discoveryState = _discoveryState.resetDiscovery();
    });
  }

  void _clearFilter() {
    setState(() {
      _discoveryState = _discoveryState.clearFilter();
    });
  }

  void _clearSort() {
    setState(() {
      _discoveryState = _discoveryState.clearSort();
    });
  }

  void _focusRiskFilter(DashboardWorkspaceFilter filter) {
    setState(() {
      _discoveryState = _discoveryState.focusRiskFilter(filter);
    });
  }

  void _focusAttention() {
    _searchController.clear();
    setState(() {
      _discoveryState = _discoveryState.focusAttention();
    });
  }

  void _applySavedView(DashboardWorkspaceSavedView view) {
    _searchController.text = view.query.searchText;
    setState(() {
      _discoveryState = _discoveryState.applySavedView(view);
    });
  }
}

import 'dashboard_workspace_filter.dart';
import 'dashboard_workspace_query.dart';
import 'dashboard_workspace_saved_view.dart';
import 'dashboard_workspace_sort.dart';
import 'dashboard_workspace_triage_summary.dart';
import 'dashboard_workspace_view_mode.dart';

class DashboardWorkspaceDiscoveryState {
  final DashboardWorkspaceQuery query;
  final DashboardWorkspaceViewMode viewMode;

  const DashboardWorkspaceDiscoveryState({
    this.query = const DashboardWorkspaceQuery(),
    this.viewMode = DashboardWorkspaceViewMode.grid,
  });

  DashboardWorkspaceDiscoveryState copyWith({
    DashboardWorkspaceQuery? query,
    DashboardWorkspaceViewMode? viewMode,
  }) {
    return DashboardWorkspaceDiscoveryState(
      query: query ?? this.query,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  DashboardWorkspaceDiscoveryState updateSearch(String searchText) {
    return copyWith(query: query.copyWith(searchText: searchText));
  }

  DashboardWorkspaceDiscoveryState updateFilter(
    DashboardWorkspaceFilter filter,
  ) {
    return copyWith(query: query.copyWith(filter: filter));
  }

  DashboardWorkspaceDiscoveryState updateSort(DashboardWorkspaceSort sort) {
    return copyWith(query: query.copyWith(sort: sort));
  }

  DashboardWorkspaceDiscoveryState updateViewMode(
    DashboardWorkspaceViewMode viewMode,
  ) {
    return copyWith(viewMode: viewMode);
  }

  DashboardWorkspaceDiscoveryState resetDiscovery() {
    return const DashboardWorkspaceDiscoveryState();
  }

  DashboardWorkspaceDiscoveryState clearSearch() {
    return copyWith(query: query.clearSearch());
  }

  DashboardWorkspaceDiscoveryState clearFilter() {
    return copyWith(query: query.clearFilter());
  }

  DashboardWorkspaceDiscoveryState clearSort() {
    return copyWith(query: query.clearSort());
  }

  DashboardWorkspaceDiscoveryState focusRiskFilter(
    DashboardWorkspaceFilter filter,
  ) {
    return copyWith(
      query: query.copyWith(filter: filter, sort: DashboardWorkspaceSort.risk),
    );
  }

  DashboardWorkspaceDiscoveryState focusAttention() {
    return copyWith(query: query.focusAttention());
  }

  DashboardWorkspaceDiscoveryState applySavedView(
    DashboardWorkspaceSavedView view,
  ) {
    return DashboardWorkspaceDiscoveryState(
      query: view.query,
      viewMode: view.viewMode,
    );
  }

  DashboardWorkspaceSavedView? activeSavedView(
    Iterable<DashboardWorkspaceSavedView> views,
  ) {
    for (final view in views) {
      if (view.isActive(activeQuery: query, activeViewMode: viewMode)) {
        return view;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DashboardWorkspaceDiscoveryState &&
            other.query == query &&
            other.viewMode == viewMode;
  }

  @override
  int get hashCode => Object.hash(query, viewMode);
}

DashboardWorkspaceFilter? dashboardWorkspaceRiskPressureFilter(
  DashboardWorkspaceTriageSummary summary,
) {
  if (summary.criticalCount > 0) {
    return DashboardWorkspaceFilter.critical;
  }
  if (summary.elevatedCount > 0) {
    return DashboardWorkspaceFilter.elevated;
  }
  return null;
}

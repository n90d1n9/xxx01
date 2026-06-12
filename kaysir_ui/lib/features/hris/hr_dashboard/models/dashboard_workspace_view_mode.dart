enum DashboardWorkspaceViewMode { grid, list }

extension DashboardWorkspaceViewModeDetails on DashboardWorkspaceViewMode {
  String get label {
    switch (this) {
      case DashboardWorkspaceViewMode.grid:
        return 'Grid';
      case DashboardWorkspaceViewMode.list:
        return 'List';
    }
  }
}

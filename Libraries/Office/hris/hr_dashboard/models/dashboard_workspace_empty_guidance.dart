import 'dashboard_workspace_filter.dart';
import 'dashboard_workspace_query.dart';

enum DashboardWorkspaceRecoveryAction {
  clearSearch,
  clearFilter,
  clearSort,
  reset,
}

class DashboardWorkspaceRecoveryOption {
  final DashboardWorkspaceRecoveryAction action;
  final String label;
  final String detail;

  const DashboardWorkspaceRecoveryOption({
    required this.action,
    required this.label,
    required this.detail,
  });
}

class DashboardWorkspaceEmptyGuidance {
  final String title;
  final String message;
  final List<DashboardWorkspaceRecoveryOption> options;

  const DashboardWorkspaceEmptyGuidance({
    required this.title,
    required this.message,
    required this.options,
  });

  factory DashboardWorkspaceEmptyGuidance.fromQuery(
    DashboardWorkspaceQuery query,
  ) {
    if (!query.hasActiveDiscovery) {
      return const DashboardWorkspaceEmptyGuidance(
        title: 'No matching workspaces',
        message: 'Workspace modules will appear here when they are available.',
        options: [],
      );
    }

    final options = [
      if (query.hasSearch)
        DashboardWorkspaceRecoveryOption(
          action: DashboardWorkspaceRecoveryAction.clearSearch,
          label: 'Clear search',
          detail:
              'Remove "${query.searchText.trim()}" from the workspace scan.',
        ),
      if (query.hasActiveFilter)
        DashboardWorkspaceRecoveryOption(
          action: DashboardWorkspaceRecoveryAction.clearFilter,
          label: 'Clear filter',
          detail: 'Return from ${query.filter.nameLabel} to all workspaces.',
        ),
      if (query.hasActiveSort)
        DashboardWorkspaceRecoveryOption(
          action: DashboardWorkspaceRecoveryAction.clearSort,
          label: 'Clear sort',
          detail: 'Restore the recommended workspace order.',
        ),
      const DashboardWorkspaceRecoveryOption(
        action: DashboardWorkspaceRecoveryAction.reset,
        label: 'Reset discovery',
        detail: 'Clear every active discovery control.',
      ),
    ];

    return DashboardWorkspaceEmptyGuidance(
      title: _titleFor(query),
      message: _messageFor(query),
      options: options,
    );
  }
}

String _titleFor(DashboardWorkspaceQuery query) {
  if (query.hasSearch && query.hasActiveFilter) {
    return 'No match in ${query.filter.nameLabel}';
  }
  if (query.hasSearch) return 'No search match';
  if (query.isRiskFocused) return 'No risk workspaces in scope';
  if (query.hasActiveFilter) return 'No ${query.filter.nameLabel} workspaces';
  return 'No matching workspaces';
}

String _messageFor(DashboardWorkspaceQuery query) {
  if (query.hasSearch && query.hasActiveFilter) {
    return 'The search term does not match the selected workspace scope.';
  }
  if (query.hasSearch) {
    return 'Try a workspace name, route, metric, risk level, or queue keyword.';
  }
  if (query.isRiskFocused) {
    return 'There are no workspaces currently matching this risk lens.';
  }
  if (query.hasActiveFilter) {
    return 'This workspace category has no visible modules right now.';
  }
  if (query.hasActiveSort) {
    return 'No workspaces are available for this sorted view.';
  }
  return 'Clear the active discovery controls to bring the workspace list back.';
}

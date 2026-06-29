import 'dashboard_analytics.dart';
import 'dashboard_workspace_entry.dart';
import 'hris_workspace.dart';

enum DashboardWorkspaceFilter {
  all,
  strategic,
  operational,
  attention,
  timeSensitive,
  critical,
  elevated,
}

extension DashboardWorkspaceFilterDetails on DashboardWorkspaceFilter {
  bool includes(DashboardWorkspaceCategory category) {
    switch (this) {
      case DashboardWorkspaceFilter.all:
        return true;
      case DashboardWorkspaceFilter.strategic:
        return category == DashboardWorkspaceCategory.strategic;
      case DashboardWorkspaceFilter.operational:
        return category == DashboardWorkspaceCategory.operational;
      case DashboardWorkspaceFilter.attention:
        return true;
      case DashboardWorkspaceFilter.timeSensitive:
        return true;
      case DashboardWorkspaceFilter.critical:
        return true;
      case DashboardWorkspaceFilter.elevated:
        return true;
    }
  }

  bool includesEntry(DashboardWorkspaceEntry entry) {
    if (this == DashboardWorkspaceFilter.attention) {
      return entry.riskSignal?.shouldHighlight ?? false;
    }
    if (this == DashboardWorkspaceFilter.timeSensitive) {
      return (entry.riskSignal?.timeSensitiveRisks ?? 0) > 0;
    }
    if (this == DashboardWorkspaceFilter.critical) {
      return entry.riskSignal?.severity == DashboardRiskSeverity.critical;
    }
    if (this == DashboardWorkspaceFilter.elevated) {
      return entry.riskSignal?.severity == DashboardRiskSeverity.elevated;
    }

    return includes(entry.category);
  }

  String get nameLabel {
    switch (this) {
      case DashboardWorkspaceFilter.all:
        return 'All workspaces';
      case DashboardWorkspaceFilter.strategic:
        return 'Strategic';
      case DashboardWorkspaceFilter.operational:
        return 'Operational';
      case DashboardWorkspaceFilter.attention:
        return 'Attention';
      case DashboardWorkspaceFilter.timeSensitive:
        return 'Time-sensitive';
      case DashboardWorkspaceFilter.critical:
        return 'Critical';
      case DashboardWorkspaceFilter.elevated:
        return 'Elevated';
    }
  }
}

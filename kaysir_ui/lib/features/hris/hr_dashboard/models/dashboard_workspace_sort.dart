import 'dashboard_analytics.dart';
import 'dashboard_workspace_entry.dart';
import 'hris_workspace.dart';

enum DashboardWorkspaceSort { recommended, risk, name, category }

extension DashboardWorkspaceSortDetails on DashboardWorkspaceSort {
  String get label {
    switch (this) {
      case DashboardWorkspaceSort.recommended:
        return 'Recommended';
      case DashboardWorkspaceSort.risk:
        return 'Risk pressure';
      case DashboardWorkspaceSort.name:
        return 'Name A-Z';
      case DashboardWorkspaceSort.category:
        return 'Category';
    }
  }

  List<DashboardWorkspaceEntry> applyTo(
    Iterable<DashboardWorkspaceEntry> entries,
  ) {
    final sortedEntries = entries.toList();

    switch (this) {
      case DashboardWorkspaceSort.recommended:
        return sortedEntries;
      case DashboardWorkspaceSort.risk:
        sortedEntries.sort(_compareByRiskPressure);
        return sortedEntries;
      case DashboardWorkspaceSort.name:
        sortedEntries.sort(_compareByTitle);
        return sortedEntries;
      case DashboardWorkspaceSort.category:
        sortedEntries.sort((a, b) {
          final categoryComparison = _categoryRank(
            a.category,
          ).compareTo(_categoryRank(b.category));
          if (categoryComparison != 0) return categoryComparison;

          return _compareByTitle(a, b);
        });
        return sortedEntries;
    }
  }
}

int _compareByRiskPressure(
  DashboardWorkspaceEntry a,
  DashboardWorkspaceEntry b,
) {
  final severityComparison = _riskSeverityRank(
    b,
  ).compareTo(_riskSeverityRank(a));
  if (severityComparison != 0) return severityComparison;

  final totalRiskComparison = (b.riskSignal?.totalRisks ?? 0).compareTo(
    a.riskSignal?.totalRisks ?? 0,
  );
  if (totalRiskComparison != 0) return totalRiskComparison;

  final timeSensitiveComparison = (b.riskSignal?.timeSensitiveRisks ?? 0)
      .compareTo(a.riskSignal?.timeSensitiveRisks ?? 0);
  if (timeSensitiveComparison != 0) return timeSensitiveComparison;

  return _compareByTitle(a, b);
}

int _compareByTitle(DashboardWorkspaceEntry a, DashboardWorkspaceEntry b) {
  return a.title.toLowerCase().compareTo(b.title.toLowerCase());
}

int _riskSeverityRank(DashboardWorkspaceEntry entry) {
  switch (entry.riskSignal?.severity) {
    case DashboardRiskSeverity.critical:
      return 3;
    case DashboardRiskSeverity.elevated:
      return 2;
    case DashboardRiskSeverity.stable:
      return 1;
    case null:
      return 0;
  }
}

int _categoryRank(DashboardWorkspaceCategory category) {
  switch (category) {
    case DashboardWorkspaceCategory.strategic:
      return 0;
    case DashboardWorkspaceCategory.operational:
      return 1;
  }
}

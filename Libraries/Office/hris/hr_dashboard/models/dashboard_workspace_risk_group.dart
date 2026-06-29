import 'dashboard_analytics.dart';
import 'dashboard_workspace_entry.dart';

class DashboardWorkspaceRiskGroup {
  final DashboardRiskSeverity severity;
  final List<DashboardWorkspaceEntry> entries;

  const DashboardWorkspaceRiskGroup({
    required this.severity,
    required this.entries,
  });
}

List<DashboardWorkspaceRiskGroup> buildDashboardWorkspaceRiskGroups(
  Iterable<DashboardWorkspaceEntry> entries,
) {
  final groupedEntries = {
    for (final severity in DashboardRiskSeverity.values)
      severity: <DashboardWorkspaceEntry>[],
  };

  for (final entry in entries) {
    final severity = entry.riskSignal?.severity ?? DashboardRiskSeverity.stable;
    groupedEntries[severity]!.add(entry);
  }

  return [
    for (final severity in [
      DashboardRiskSeverity.critical,
      DashboardRiskSeverity.elevated,
      DashboardRiskSeverity.stable,
    ])
      if (groupedEntries[severity]!.isNotEmpty)
        DashboardWorkspaceRiskGroup(
          severity: severity,
          entries: groupedEntries[severity]!,
        ),
  ];
}

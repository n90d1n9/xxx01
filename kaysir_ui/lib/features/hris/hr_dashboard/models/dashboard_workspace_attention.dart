import 'dashboard_workspace_entry.dart';
import 'dashboard_workspace_sort.dart';

DashboardWorkspaceEntry? dashboardTopAttentionWorkspace(
  Iterable<DashboardWorkspaceEntry> entries,
) {
  final attentionEntries = entries.where(
    (entry) => entry.riskSignal?.shouldHighlight ?? false,
  );
  final rankedEntries = DashboardWorkspaceSort.risk.applyTo(attentionEntries);

  return rankedEntries.isEmpty ? null : rankedEntries.first;
}

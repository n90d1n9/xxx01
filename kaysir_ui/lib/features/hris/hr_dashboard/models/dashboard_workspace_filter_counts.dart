import 'dashboard_workspace_entry.dart';
import 'dashboard_workspace_filter.dart';
import 'dashboard_workspace_triage_summary.dart';
import 'hris_workspace.dart';

class DashboardWorkspaceFilterCounts {
  final int totalCount;
  final int strategicCount;
  final int operationalCount;
  final int attentionCount;
  final int timeSensitiveCount;
  final int criticalCount;
  final int elevatedCount;

  const DashboardWorkspaceFilterCounts({
    required this.totalCount,
    required this.strategicCount,
    required this.operationalCount,
    required this.attentionCount,
    required this.timeSensitiveCount,
    required this.criticalCount,
    required this.elevatedCount,
  });

  factory DashboardWorkspaceFilterCounts.fromEntries(
    Iterable<DashboardWorkspaceEntry> entries,
  ) {
    final workspaceEntries = entries.toList();
    final triageSummary = DashboardWorkspaceTriageSummary.fromEntries(
      workspaceEntries,
    );

    return DashboardWorkspaceFilterCounts(
      totalCount: workspaceEntries.length,
      strategicCount:
          workspaceEntries
              .where(
                (entry) =>
                    entry.category == DashboardWorkspaceCategory.strategic,
              )
              .length,
      operationalCount:
          workspaceEntries
              .where(
                (entry) =>
                    entry.category == DashboardWorkspaceCategory.operational,
              )
              .length,
      attentionCount: triageSummary.attentionCount,
      timeSensitiveCount: triageSummary.timeSensitiveWorkspaceCount,
      criticalCount: triageSummary.criticalCount,
      elevatedCount: triageSummary.elevatedCount,
    );
  }

  int countFor(DashboardWorkspaceFilter filter) {
    switch (filter) {
      case DashboardWorkspaceFilter.all:
        return totalCount;
      case DashboardWorkspaceFilter.strategic:
        return strategicCount;
      case DashboardWorkspaceFilter.operational:
        return operationalCount;
      case DashboardWorkspaceFilter.attention:
        return attentionCount;
      case DashboardWorkspaceFilter.timeSensitive:
        return timeSensitiveCount;
      case DashboardWorkspaceFilter.critical:
        return criticalCount;
      case DashboardWorkspaceFilter.elevated:
        return elevatedCount;
    }
  }

  bool isAvailable(DashboardWorkspaceFilter filter) {
    if (filter == DashboardWorkspaceFilter.all) return true;
    return countFor(filter) > 0;
  }

  String labelFor(DashboardWorkspaceFilter filter) {
    final count = countFor(filter);
    if (filter == DashboardWorkspaceFilter.all) return 'All $count';
    return '${filter.nameLabel} $count';
  }
}

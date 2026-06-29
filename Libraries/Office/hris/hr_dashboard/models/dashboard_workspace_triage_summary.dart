import 'dashboard_analytics.dart';
import 'dashboard_workspace_entry.dart';
import 'dashboard_workspace_sort.dart';

class DashboardWorkspaceTriageSummary {
  final int workspaceCount;
  final int attentionCount;
  final int timeSensitiveWorkspaceCount;
  final int criticalCount;
  final int elevatedCount;
  final int stableCount;
  final int totalRisks;
  final int timeSensitiveRisks;
  final DashboardWorkspaceEntry? nextFocus;

  const DashboardWorkspaceTriageSummary({
    required this.workspaceCount,
    required this.attentionCount,
    required this.timeSensitiveWorkspaceCount,
    required this.criticalCount,
    required this.elevatedCount,
    required this.stableCount,
    required this.totalRisks,
    required this.timeSensitiveRisks,
    required this.nextFocus,
  });

  factory DashboardWorkspaceTriageSummary.fromEntries(
    Iterable<DashboardWorkspaceEntry> entries,
  ) {
    final scopedEntries = entries.toList();
    var attentionCount = 0;
    var timeSensitiveWorkspaceCount = 0;
    var criticalCount = 0;
    var elevatedCount = 0;
    var stableCount = 0;
    var totalRisks = 0;
    var timeSensitiveRisks = 0;

    for (final entry in scopedEntries) {
      final signal = entry.riskSignal;
      if (signal == null) {
        stableCount++;
        continue;
      }

      totalRisks += signal.totalRisks;
      timeSensitiveRisks += signal.timeSensitiveRisks;
      if (signal.shouldHighlight) attentionCount++;
      if (signal.timeSensitiveRisks > 0) timeSensitiveWorkspaceCount++;

      switch (signal.severity) {
        case DashboardRiskSeverity.critical:
          criticalCount++;
          break;
        case DashboardRiskSeverity.elevated:
          elevatedCount++;
          break;
        case DashboardRiskSeverity.stable:
          stableCount++;
          break;
      }
    }

    final attentionEntries =
        scopedEntries
            .where((entry) => entry.riskSignal?.shouldHighlight ?? false)
            .toList();
    final rankedAttentionEntries = DashboardWorkspaceSort.risk.applyTo(
      attentionEntries,
    );

    return DashboardWorkspaceTriageSummary(
      workspaceCount: scopedEntries.length,
      attentionCount: attentionCount,
      timeSensitiveWorkspaceCount: timeSensitiveWorkspaceCount,
      criticalCount: criticalCount,
      elevatedCount: elevatedCount,
      stableCount: stableCount,
      totalRisks: totalRisks,
      timeSensitiveRisks: timeSensitiveRisks,
      nextFocus:
          rankedAttentionEntries.isEmpty ? null : rankedAttentionEntries.first,
    );
  }

  bool get hasAttention => attentionCount > 0;

  bool get hasTimeSensitive => timeSensitiveWorkspaceCount > 0;

  String get attentionLabel {
    if (workspaceCount == 0) return 'No workspaces';
    if (attentionCount == 0) return 'All stable';
    if (attentionCount == 1) return '1 needs attention';
    return '$attentionCount need attention';
  }

  String get criticalLabel {
    if (criticalCount == 1) return '1 critical';
    return '$criticalCount critical';
  }

  String get elevatedLabel {
    if (elevatedCount == 1) return '1 elevated';
    return '$elevatedCount elevated';
  }

  String get timeSensitiveLabel {
    if (timeSensitiveRisks == 1) return '1 time-sensitive';
    return '$timeSensitiveRisks time-sensitive';
  }

  String get totalRiskLabel {
    if (totalRisks == 1) return '1 total risk';
    return '$totalRisks total risks';
  }

  String get nextFocusLabel {
    return nextFocus == null ? 'Stable' : nextFocus!.title;
  }

  String get nextFocusDetail {
    return nextFocus?.riskSignal?.leadingSignal ?? 'No escalation queued';
  }
}

import 'dashboard_analytics.dart';
import 'hris_workspace.dart';

class DashboardWorkspaceRiskSignal {
  final DashboardRiskSeverity severity;
  final int totalRisks;
  final int timeSensitiveRisks;
  final String leadingSignal;

  const DashboardWorkspaceRiskSignal({
    required this.severity,
    required this.totalRisks,
    required this.timeSensitiveRisks,
    required this.leadingSignal,
  });

  factory DashboardWorkspaceRiskSignal.fromRiskItem(DashboardRiskItem item) {
    return DashboardWorkspaceRiskSignal(
      severity: item.severity,
      totalRisks: item.totalRisks,
      timeSensitiveRisks: item.timeSensitiveRisks,
      leadingSignal: item.leadingSignal,
    );
  }

  bool get shouldHighlight {
    return severity != DashboardRiskSeverity.stable || timeSensitiveRisks > 0;
  }

  String get severityLabel => severity.label;

  String get compactLabel => '$severityLabel $totalRisks';

  String get detailLabel => '$severityLabel - $totalRisks risks';
}

Map<HrisWorkspaceId, DashboardWorkspaceRiskSignal>
buildDashboardWorkspaceRiskSignalMap(DashboardRiskRollup? rollup) {
  if (rollup == null) return const {};

  return {
    for (final item in rollup.items)
      item.workspace.id: DashboardWorkspaceRiskSignal.fromRiskItem(item),
  };
}

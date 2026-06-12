import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_group.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';

void main() {
  test('workspace risk groups order entries by severity buckets', () {
    final groups = buildDashboardWorkspaceRiskGroups([
      _entry(HrisWorkspaceId.attendance),
      _entry(
        HrisWorkspaceId.peopleOps,
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.elevated,
          totalRisks: 4,
          timeSensitiveRisks: 1,
          leadingSignal: '1 approval risk',
        ),
      ),
      _entry(
        HrisWorkspaceId.compensation,
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.critical,
          totalRisks: 8,
          timeSensitiveRisks: 3,
          leadingSignal: '3 blocked reviews',
        ),
      ),
    ]);

    expect(groups.map((group) => group.severity), [
      DashboardRiskSeverity.critical,
      DashboardRiskSeverity.elevated,
      DashboardRiskSeverity.stable,
    ]);
    expect(groups.first.entries.single.title, 'Compensation');
    expect(groups.last.entries.single.title, 'Attendance');
  });
}

DashboardWorkspaceEntry _entry(
  HrisWorkspaceId id, {
  DashboardWorkspaceRiskSignal? riskSignal,
}) {
  return DashboardWorkspaceEntry(
    workspace: hrisWorkspaceById(id),
    description: 'Workspace description',
    riskSignal: riskSignal,
    metrics: const [
      DashboardWorkspaceMetric(
        icon: Icons.analytics_outlined,
        label: 'Open',
        value: '1',
      ),
    ],
  );
}

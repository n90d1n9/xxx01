import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_triage_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';

void main() {
  test('workspace triage summary ranks the next risk focus', () {
    final summary = DashboardWorkspaceTriageSummary.fromEntries([
      _entry(HrisWorkspaceId.attendance),
      _entry(
        HrisWorkspaceId.compensation,
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.elevated,
          totalRisks: 10,
          timeSensitiveRisks: 6,
          leadingSignal: '6 pay exceptions',
        ),
      ),
      _entry(
        HrisWorkspaceId.peopleOps,
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.critical,
          totalRisks: 8,
          timeSensitiveRisks: 3,
          leadingSignal: '3 blocked onboarding',
        ),
      ),
    ]);

    expect(summary.workspaceCount, 3);
    expect(summary.attentionCount, 2);
    expect(summary.timeSensitiveWorkspaceCount, 2);
    expect(summary.criticalCount, 1);
    expect(summary.elevatedCount, 1);
    expect(summary.stableCount, 1);
    expect(summary.totalRisks, 18);
    expect(summary.timeSensitiveRisks, 9);
    expect(summary.nextFocusLabel, 'People Operations');
    expect(summary.nextFocusDetail, '3 blocked onboarding');
    expect(summary.attentionLabel, '2 need attention');
    expect(summary.hasTimeSensitive, isTrue);
    expect(summary.criticalLabel, '1 critical');
    expect(summary.elevatedLabel, '1 elevated');
    expect(summary.timeSensitiveLabel, '9 time-sensitive');
    expect(summary.totalRiskLabel, '18 total risks');
  });

  test('workspace triage summary reports a stable empty state', () {
    final summary = DashboardWorkspaceTriageSummary.fromEntries([
      _entry(HrisWorkspaceId.attendance),
    ]);

    expect(summary.hasAttention, isFalse);
    expect(summary.hasTimeSensitive, isFalse);
    expect(summary.timeSensitiveWorkspaceCount, 0);
    expect(summary.nextFocus, isNull);
    expect(summary.nextFocusLabel, 'Stable');
    expect(summary.nextFocusDetail, 'No escalation queued');
    expect(summary.attentionLabel, 'All stable');
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

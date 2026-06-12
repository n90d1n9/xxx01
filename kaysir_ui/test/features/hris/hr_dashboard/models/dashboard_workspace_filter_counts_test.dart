import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_filter.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_filter_counts.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';

void main() {
  test(
    'workspace filter counts derive availability from workspace entries',
    () {
      final counts = DashboardWorkspaceFilterCounts.fromEntries([
        _entry(
          HrisWorkspaceId.peopleOps,
          riskSignal: const DashboardWorkspaceRiskSignal(
            severity: DashboardRiskSeverity.critical,
            totalRisks: 8,
            timeSensitiveRisks: 3,
            leadingSignal: '3 blocked onboarding',
          ),
        ),
        _entry(HrisWorkspaceId.attendance),
      ]);

      expect(counts.countFor(DashboardWorkspaceFilter.all), 2);
      expect(counts.countFor(DashboardWorkspaceFilter.strategic), 1);
      expect(counts.countFor(DashboardWorkspaceFilter.operational), 1);
      expect(counts.countFor(DashboardWorkspaceFilter.attention), 1);
      expect(counts.countFor(DashboardWorkspaceFilter.timeSensitive), 1);
      expect(counts.countFor(DashboardWorkspaceFilter.critical), 1);
      expect(counts.countFor(DashboardWorkspaceFilter.elevated), 0);
      expect(counts.isAvailable(DashboardWorkspaceFilter.elevated), isFalse);
      expect(
        counts.labelFor(DashboardWorkspaceFilter.timeSensitive),
        'Time-sensitive 1',
      );
    },
  );
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

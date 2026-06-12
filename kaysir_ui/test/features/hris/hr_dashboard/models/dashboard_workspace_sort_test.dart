import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_sort.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';

void main() {
  test(
    'workspace sort applies stable recommended, risk, name, and category orders',
    () {
      final entries = [
        _entry(
          HrisWorkspaceId.peopleOps,
          riskSignal: const DashboardWorkspaceRiskSignal(
            severity: DashboardRiskSeverity.elevated,
            totalRisks: 5,
            timeSensitiveRisks: 1,
            leadingSignal: '1 approval risk',
          ),
        ),
        _entry(HrisWorkspaceId.attendance),
        _entry(
          HrisWorkspaceId.compensation,
          riskSignal: const DashboardWorkspaceRiskSignal(
            severity: DashboardRiskSeverity.critical,
            totalRisks: 8,
            timeSensitiveRisks: 3,
            leadingSignal: '3 blocked reviews',
          ),
        ),
      ];

      expect(
        DashboardWorkspaceSort.recommended
            .applyTo(entries)
            .map((entry) => entry.title),
        ['People Operations', 'Attendance', 'Compensation'],
      );
      expect(
        DashboardWorkspaceSort.risk
            .applyTo(entries)
            .map((entry) => entry.title),
        ['Compensation', 'People Operations', 'Attendance'],
      );
      expect(
        DashboardWorkspaceSort.name
            .applyTo(entries)
            .map((entry) => entry.title),
        ['Attendance', 'Compensation', 'People Operations'],
      );
      expect(
        DashboardWorkspaceSort.category
            .applyTo(entries)
            .map((entry) => entry.title),
        ['Compensation', 'People Operations', 'Attendance'],
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

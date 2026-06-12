import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_filter.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_query.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_saved_view.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_sort.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_view_mode.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  test('workspace saved views define stable dashboard presets', () {
    expect(dashboardWorkspaceSavedViews.map((view) => view.id), [
      'all',
      hrisDashboardCriticalActionId,
      hrisDashboardTimeSensitiveActionId,
      'operational-queue',
      'strategic-priorities',
    ]);

    final critical = dashboardWorkspaceSavedViews.singleWhere(
      (view) => view.id == hrisDashboardCriticalActionId,
    );

    expect(critical.query.filter, DashboardWorkspaceFilter.critical);
    expect(critical.query.sort, DashboardWorkspaceSort.risk);
    expect(critical.viewMode, DashboardWorkspaceViewMode.list);
  });

  test('workspace saved views count and match active discovery state', () {
    final entries = [
      _entry(
        HrisWorkspaceId.peopleOps,
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.critical,
          totalRisks: 8,
          timeSensitiveRisks: 3,
          leadingSignal: '3 blocked onboarding',
        ),
      ),
      _entry(
        HrisWorkspaceId.attendance,
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.elevated,
          totalRisks: 4,
          timeSensitiveRisks: 1,
          leadingSignal: '1 late record',
        ),
      ),
      _entry(HrisWorkspaceId.leave),
    ];
    final critical = dashboardWorkspaceSavedViews.singleWhere(
      (view) => view.id == hrisDashboardCriticalActionId,
    );

    expect(critical.visibleCountFor(entries), 1);
    expect(
      critical.isActive(
        activeQuery: const DashboardWorkspaceQuery(
          filter: DashboardWorkspaceFilter.critical,
          sort: DashboardWorkspaceSort.risk,
        ),
        activeViewMode: DashboardWorkspaceViewMode.list,
      ),
      isTrue,
    );
    expect(
      critical.isActive(
        activeQuery: const DashboardWorkspaceQuery(
          filter: DashboardWorkspaceFilter.critical,
          sort: DashboardWorkspaceSort.risk,
        ),
        activeViewMode: DashboardWorkspaceViewMode.grid,
      ),
      isFalse,
    );
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
        label: 'Metric',
        value: '1',
      ),
    ],
  );
}

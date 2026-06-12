import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_discovery_state.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_filter.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_query.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_saved_view.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_sort.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_triage_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_view_mode.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';

void main() {
  test('workspace discovery state exposes the default command center view', () {
    const state = DashboardWorkspaceDiscoveryState();

    expect(state.query, const DashboardWorkspaceQuery());
    expect(state.viewMode, DashboardWorkspaceViewMode.grid);
    expect(state.activeSavedView(dashboardWorkspaceSavedViews)?.id, 'all');
  });

  test('workspace discovery state updates and clears individual controls', () {
    final state = const DashboardWorkspaceDiscoveryState()
        .updateSearch('payroll')
        .updateFilter(DashboardWorkspaceFilter.operational)
        .updateSort(DashboardWorkspaceSort.category)
        .updateViewMode(DashboardWorkspaceViewMode.list);

    expect(state.query.searchText, 'payroll');
    expect(state.query.filter, DashboardWorkspaceFilter.operational);
    expect(state.query.sort, DashboardWorkspaceSort.category);
    expect(state.viewMode, DashboardWorkspaceViewMode.list);

    final cleared = state.clearSearch().clearFilter().clearSort();

    expect(cleared.query, const DashboardWorkspaceQuery());
    expect(cleared.viewMode, DashboardWorkspaceViewMode.list);
    expect(state.resetDiscovery(), const DashboardWorkspaceDiscoveryState());
  });

  test('workspace discovery state applies focus shortcuts', () {
    const state = DashboardWorkspaceDiscoveryState(
      query: DashboardWorkspaceQuery(
        filter: DashboardWorkspaceFilter.strategic,
        sort: DashboardWorkspaceSort.name,
        searchText: 'people',
      ),
      viewMode: DashboardWorkspaceViewMode.list,
    );

    final riskFocused = state.focusRiskFilter(
      DashboardWorkspaceFilter.elevated,
    );

    expect(riskFocused.query.filter, DashboardWorkspaceFilter.elevated);
    expect(riskFocused.query.sort, DashboardWorkspaceSort.risk);
    expect(riskFocused.query.searchText, 'people');
    expect(riskFocused.viewMode, DashboardWorkspaceViewMode.list);

    final attentionFocused = state.focusAttention();

    expect(attentionFocused.query.filter, DashboardWorkspaceFilter.attention);
    expect(attentionFocused.query.sort, DashboardWorkspaceSort.risk);
    expect(attentionFocused.query.searchText, isEmpty);
    expect(attentionFocused.viewMode, DashboardWorkspaceViewMode.list);
  });

  test('workspace discovery state applies saved views', () {
    final savedView = dashboardWorkspaceSavedViews.singleWhere(
      (view) => view.id == 'time-sensitive',
    );

    final state = const DashboardWorkspaceDiscoveryState().applySavedView(
      savedView,
    );

    expect(state.query, savedView.query);
    expect(state.viewMode, savedView.viewMode);
    expect(state.activeSavedView(dashboardWorkspaceSavedViews), savedView);
  });

  test('workspace risk pressure filter prioritizes critical then elevated', () {
    final criticalSummary = DashboardWorkspaceTriageSummary.fromEntries([
      _entry(
        HrisWorkspaceId.peopleOps,
        severity: DashboardRiskSeverity.critical,
        totalRisks: 8,
      ),
      _entry(
        HrisWorkspaceId.attendance,
        severity: DashboardRiskSeverity.elevated,
        totalRisks: 4,
      ),
    ]);
    final elevatedSummary = DashboardWorkspaceTriageSummary.fromEntries([
      _entry(
        HrisWorkspaceId.attendance,
        severity: DashboardRiskSeverity.elevated,
        totalRisks: 4,
      ),
    ]);
    final stableSummary = DashboardWorkspaceTriageSummary.fromEntries([
      _entry(HrisWorkspaceId.leave),
    ]);

    expect(
      dashboardWorkspaceRiskPressureFilter(criticalSummary),
      DashboardWorkspaceFilter.critical,
    );
    expect(
      dashboardWorkspaceRiskPressureFilter(elevatedSummary),
      DashboardWorkspaceFilter.elevated,
    );
    expect(dashboardWorkspaceRiskPressureFilter(stableSummary), isNull);
  });
}

DashboardWorkspaceEntry _entry(
  HrisWorkspaceId id, {
  DashboardRiskSeverity? severity,
  int totalRisks = 0,
}) {
  return DashboardWorkspaceEntry(
    workspace: hrisWorkspaceById(id),
    description: 'Workspace description',
    riskSignal:
        severity == null
            ? null
            : DashboardWorkspaceRiskSignal(
              severity: severity,
              totalRisks: totalRisks,
              timeSensitiveRisks:
                  severity == DashboardRiskSeverity.stable ? 0 : 1,
              leadingSignal: '1 risk signal',
            ),
    metrics: const [
      DashboardWorkspaceMetric(
        icon: Icons.analytics_outlined,
        label: 'Metric',
        value: '1',
      ),
    ],
  );
}

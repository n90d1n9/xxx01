import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_filter.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_query.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_sort.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';

void main() {
  test('workspace query applies search, filter, and sort together', () {
    final entries = [
      _entry(HrisWorkspaceId.peopleOps, metricLabel: 'Hires'),
      _entry(HrisWorkspaceId.attendance, metricLabel: 'Late'),
      _entry(HrisWorkspaceId.compensation, metricLabel: 'Reviews'),
    ];

    const query = DashboardWorkspaceQuery(
      filter: DashboardWorkspaceFilter.strategic,
      sort: DashboardWorkspaceSort.name,
      searchText: 'e',
    );

    expect(query.hasActiveDiscovery, isTrue);
    expect(query.applyTo(entries).map((entry) => entry.title), [
      'Compensation',
      'People Operations',
    ]);
  });

  test('workspace query can focus attention items by risk pressure', () {
    final entries = [
      _entry(
        HrisWorkspaceId.peopleOps,
        metricLabel: 'Hires',
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.critical,
          totalRisks: 8,
          timeSensitiveRisks: 3,
          leadingSignal: '3 blocked onboarding',
        ),
      ),
      _entry(HrisWorkspaceId.attendance, metricLabel: 'Late'),
      _entry(
        HrisWorkspaceId.compensation,
        metricLabel: 'Reviews',
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.elevated,
          totalRisks: 4,
          timeSensitiveRisks: 1,
          leadingSignal: '1 blocked review',
        ),
      ),
    ];

    const query = DashboardWorkspaceQuery(
      filter: DashboardWorkspaceFilter.attention,
      sort: DashboardWorkspaceSort.risk,
    );

    expect(query.applyTo(entries).map((entry) => entry.title), [
      'People Operations',
      'Compensation',
    ]);
  });

  test('workspace query can filter by explicit risk severity and timing', () {
    final entries = [
      _entry(
        HrisWorkspaceId.peopleOps,
        metricLabel: 'Hires',
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.critical,
          totalRisks: 8,
          timeSensitiveRisks: 3,
          leadingSignal: '3 blocked onboarding',
        ),
      ),
      _entry(
        HrisWorkspaceId.compensation,
        metricLabel: 'Reviews',
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.elevated,
          totalRisks: 4,
          timeSensitiveRisks: 1,
          leadingSignal: '1 blocked review',
        ),
      ),
      _entry(HrisWorkspaceId.attendance, metricLabel: 'Late'),
    ];

    const criticalQuery = DashboardWorkspaceQuery(
      filter: DashboardWorkspaceFilter.critical,
    );
    const elevatedQuery = DashboardWorkspaceQuery(
      filter: DashboardWorkspaceFilter.elevated,
    );
    const timeSensitiveQuery = DashboardWorkspaceQuery(
      filter: DashboardWorkspaceFilter.timeSensitive,
    );

    expect(criticalQuery.isRiskFocused, isTrue);
    expect(criticalQuery.applyTo(entries).map((entry) => entry.title), [
      'People Operations',
    ]);
    expect(elevatedQuery.applyTo(entries).map((entry) => entry.title), [
      'Compensation',
    ]);
    expect(timeSensitiveQuery.isRiskFocused, isTrue);
    expect(timeSensitiveQuery.applyTo(entries).map((entry) => entry.title), [
      'People Operations',
      'Compensation',
    ]);
  });

  test('workspace query reset restores default discovery state', () {
    const query = DashboardWorkspaceQuery(
      filter: DashboardWorkspaceFilter.operational,
      sort: DashboardWorkspaceSort.category,
      searchText: 'attendance',
    );

    final resetQuery = query.resetDiscovery();

    expect(resetQuery.filter, DashboardWorkspaceFilter.all);
    expect(resetQuery.sort, DashboardWorkspaceSort.recommended);
    expect(resetQuery.searchText, isEmpty);
    expect(resetQuery.hasActiveDiscovery, isFalse);
  });

  test(
    'workspace query clear helpers reset one discovery control at a time',
    () {
      const query = DashboardWorkspaceQuery(
        filter: DashboardWorkspaceFilter.attention,
        sort: DashboardWorkspaceSort.risk,
        searchText: 'payroll',
      );

      expect(query.clearSearch().searchText, isEmpty);
      expect(query.clearSearch().filter, DashboardWorkspaceFilter.attention);
      expect(query.clearFilter().filter, DashboardWorkspaceFilter.all);
      expect(query.clearFilter().sort, DashboardWorkspaceSort.risk);
      expect(query.clearSort().sort, DashboardWorkspaceSort.recommended);
      expect(query.clearSort().searchText, 'payroll');

      final attentionQuery = query.focusAttention();
      expect(attentionQuery.filter, DashboardWorkspaceFilter.attention);
      expect(attentionQuery.sort, DashboardWorkspaceSort.risk);
      expect(attentionQuery.searchText, isEmpty);
    },
  );
}

DashboardWorkspaceEntry _entry(
  HrisWorkspaceId id, {
  required String metricLabel,
  DashboardWorkspaceRiskSignal? riskSignal,
}) {
  return DashboardWorkspaceEntry(
    workspace: hrisWorkspaceById(id),
    description: 'Workspace description',
    riskSignal: riskSignal,
    metrics: [
      DashboardWorkspaceMetric(
        icon: Icons.analytics_outlined,
        label: metricLabel,
        value: '1',
      ),
    ],
  );
}

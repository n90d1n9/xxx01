import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/hr_dashboard/states/hr_dashboard_controller.dart';
import 'package:kaysir/features/hris/hr_dashboard/states/metric_provider.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  test('HR dashboard metrics react to selected period', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final current = container.read(hrMetricsProvider);
    expect(current.map((metric) => metric.value), [5.2, 82.5, 4.2, 24]);

    container.read(selectedPeriodProvider.notifier).state = 'Last Month';

    final previous = container.read(hrMetricsProvider);
    expect(previous.map((metric) => metric.value), [4.8, 79.0, 4.0, 27]);
  });

  test('HR dashboard analytics providers expose chart-ready data', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final metrics = container.read(hrMetricsProvider);
    final hiringTrend = container.read(hiringTrendsProvider);
    final departmentPerformance = container.read(departmentPerformanceProvider);

    expect(metrics.first.percentChange, closeTo(-17.46, 0.01));
    expect(metrics[1].percentChange, closeTo(8.84, 0.01));
    expect(metrics.first.isPositive, isTrue);
    expect(metrics.last.isPositive, isTrue);
    expect(hiringTrend.length, 6);
    expect(departmentPerformance.length, 5);
    expect(departmentPerformance.first.department, 'Sales');
    expect(hiringTrend.last.month, 'Jun');
  });

  test('HR dashboard insight summary highlights executive signals', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final summary = container.read(dashboardInsightSummaryProvider);

    expect(summary.averageDepartmentPerformance, 87);
    expect(summary.strongestDepartment, 'Sales');
    expect(summary.fastestImprovingDepartment, 'HR');
    expect(summary.totalHires, 95);
    expect(summary.peakHiringMonth, 'Jun');
    expect(summary.improvedMetricCount, 4);
  });

  test('HR dashboard risk rollup ranks cross-workspace risks', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final rollup = container.read(dashboardRiskRollupProvider);

    expect(rollup.workspaceCount, 17);
    expect(rollup.items.map((item) => item.workspace.id).toSet(), {
      for (final workspace in hrisWorkspaces) workspace.id,
    });
    expect(rollup.totalRisks, 164);
    expect(rollup.timeSensitiveRisks, 121);
    expect(rollup.criticalWorkspaceCount, 6);
    expect(rollup.elevatedWorkspaceCount, 7);
    expect(rollup.stableWorkspaceCount, 4);
    expect(rollup.highestRiskWorkspace, 'Company Management');
    expect(rollup.topItems.map((item) => item.label), [
      'Company Management',
      'Manager',
      'Service Center',
    ]);
    expect(rollup.topItems.first.severity, DashboardRiskSeverity.critical);
  });

  test('HR dashboard view model assembles screen-ready data', () {
    final lastUpdated = DateTime(2026, 5, 31, 9, 15);
    final container = ProviderContainer(
      overrides: [
        hrDashboardClockProvider.overrideWithValue(() => lastUpdated),
      ],
    );
    addTearDown(container.dispose);

    final dashboard = container.read(hrDashboardViewModelProvider);

    expect(dashboard.selectedPeriod, 'This Month');
    expect(dashboard.isLoading, isFalse);
    expect(dashboard.lastUpdated, lastUpdated);
    expect(dashboard.hrMetrics.map((metric) => metric.value), [
      5.2,
      82.5,
      4.2,
      24,
    ]);
    expect(dashboard.reportTypes, hasLength(4));
    expect(dashboard.departmentPerformance, hasLength(5));
    expect(dashboard.hiringTrends, hasLength(6));
    expect(dashboard.insightSummary.totalHires, 95);
    expect(dashboard.riskRollup.workspaceCount, 17);
    expect(dashboard.actionSummary.recommendations.map((item) => item.id), [
      hrisDashboardCriticalActionId,
      hrisDashboardTimeSensitiveActionId,
      hrisDashboardScaleMomentumActionId,
    ]);
    expect(dashboard.workspaceEntries, hasLength(17));
    expect(
      dashboard.workspaceEntries.where((entry) => entry.riskSignal != null),
      hasLength(dashboard.riskRollup.items.length),
    );

    container.read(selectedPeriodProvider.notifier).state = 'Last Month';

    final updated = container.read(hrDashboardViewModelProvider);
    expect(updated.selectedPeriod, 'Last Month');
    expect(updated.hrMetrics.first.value, 4.8);
  });

  test(
    'HR dashboard controller changes period and refreshes loading state',
    () async {
      var now = DateTime(2026, 5, 31, 9, 15);
      final container = ProviderContainer(
        overrides: [
          hrDashboardRefreshDelayProvider.overrideWithValue(Duration.zero),
          hrDashboardClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(dashboardLastUpdatedProvider), now);

      now = DateTime(2026, 5, 31, 10, 45);
      final refresh = container
          .read(hrDashboardControllerProvider)
          .changePeriod('Last Month');

      expect(container.read(selectedPeriodProvider), 'Last Month');
      expect(container.read(isLoadingProvider), isTrue);

      await refresh;

      expect(container.read(isLoadingProvider), isFalse);
      expect(
        container.read(hrDashboardViewModelProvider).hrMetrics.first.value,
        4.8,
      );
      expect(container.read(hrDashboardViewModelProvider).lastUpdated, now);
    },
  );

  test('HR dashboard controller refresh updates dashboard freshness', () async {
    var now = DateTime(2026, 5, 31, 8, 0);
    final container = ProviderContainer(
      overrides: [
        hrDashboardRefreshDelayProvider.overrideWithValue(Duration.zero),
        hrDashboardClockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(hrDashboardViewModelProvider).lastUpdated, now);

    now = DateTime(2026, 5, 31, 11, 30);
    final refresh = container.read(hrDashboardControllerProvider).refresh();

    expect(container.read(isLoadingProvider), isTrue);

    await refresh;

    expect(container.read(isLoadingProvider), isFalse);
    expect(container.read(hrDashboardViewModelProvider).lastUpdated, now);
  });

  test('HR dashboard controller ignores null period changes', () async {
    final container = ProviderContainer(
      overrides: [
        hrDashboardRefreshDelayProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);

    await container.read(hrDashboardControllerProvider).changePeriod(null);

    expect(container.read(selectedPeriodProvider), 'This Month');
    expect(container.read(isLoadingProvider), isFalse);
  });
}

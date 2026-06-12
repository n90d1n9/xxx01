import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_insight_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_table_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_insights_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_table_provider.dart';

void main() {
  test('employee directory insights summarize visible table population', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final insights = container.read(employeeDirectoryInsightsProvider);

    expect(insights.visibleCount, 5);
    expect(insights.attentionProfileCount, 2);
    expect(insights.healthScore, 60);
    expect(insights.healthLabel, 'Watch');
    expect(insights.onboardingCount, 1);
    expect(insights.watchlistCount, 1);
    expect(insights.lowPerformanceCount, 1);
    expect(insights.locationCount, 4);
    expect(insights.averageTenureMonths, 51);
    expect(insights.topAttentionDepartment, 'Product');
    expect(insights.managerLoadAlertCount, 2);
    expect(insights.managerLoads.map((load) => load.manager), [
      'Emma Rodriguez',
      'Olivia Wilson',
    ]);
    expect(insights.actions.map((action) => action.title), [
      'Review watchlist profiles',
      'Schedule performance support',
      'Close onboarding readiness',
      'Balance manager coverage',
    ]);
    expect(
      insights.actions.first.priority,
      EmployeeDirectoryInsightPriority.critical,
    );
  });

  test('employee directory insights follow table status filters', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(employeeDirectoryTableStatusFilterProvider.notifier).state =
        EmployeeDirectoryTableStatusFilter.watchlist;

    final insights = container.read(employeeDirectoryInsightsProvider);

    expect(insights.visibleCount, 1);
    expect(insights.attentionProfileCount, 1);
    expect(insights.healthScore, 0);
    expect(insights.topAttentionDepartment, 'Product');
    expect(insights.managerLoadAlertCount, 0);
    expect(insights.actions.map((action) => action.title), [
      'Review watchlist profiles',
      'Schedule performance support',
    ]);
  });

  test('employee directory insights handle an empty table view', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(employeeDirectorySearchQueryProvider.notifier).state =
        'no matching employee';

    final insights = container.read(employeeDirectoryInsightsProvider);

    expect(insights.visibleCount, 0);
    expect(insights.healthScore, 0);
    expect(insights.healthLabel, 'No population');
    expect(insights.topAttentionDepartment, 'No department');
    expect(insights.actions.single.title, 'Refine table filters');
  });
}

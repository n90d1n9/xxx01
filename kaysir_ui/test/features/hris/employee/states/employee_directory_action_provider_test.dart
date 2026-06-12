import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_action_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_table_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_action_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_table_provider.dart';

void main() {
  test('employee directory action queue derives actions from visible rows', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final actions = container.read(employeeDirectoryActionQueueProvider);
    final summary = container.read(employeeDirectoryActionQueueSummaryProvider);

    expect(actions.map((action) => action.title), [
      'Review watchlist profiles',
      'Close onboarding readiness',
      'Schedule performance support',
      'Balance manager coverage',
    ]);
    expect(actions.first.id, 'watchlistReview-4');
    expect(actions.first.affectedEmployeeNames, ['David Kim']);
    expect(summary.totalCount, 4);
    expect(summary.openCount, 4);
    expect(summary.criticalCount, 1);
    expect(summary.dueSoonCount, 2);
    expect(summary.resolvedCount, 0);
  });

  test('employee directory action queue follows table filters', () {
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

    final actions = container.read(employeeDirectoryActionQueueProvider);

    expect(actions.map((action) => action.title), [
      'Review watchlist profiles',
      'Schedule performance support',
    ]);
  });

  test('employee directory action queue stores workflow overrides', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final action = container.read(employeeDirectoryActionQueueProvider).first;
    final notifier = container.read(
      employeeDirectoryActionOverridesProvider.notifier,
    );

    notifier.assign(action, 'People Ops Lead');

    var updated = container.read(employeeDirectoryActionQueueProvider).first;
    expect(updated.owner, 'People Ops Lead');
    expect(updated.status, EmployeeDirectoryActionStatus.inProgress);

    notifier.resolve(updated);
    updated = container
        .read(employeeDirectoryActionQueueProvider)
        .singleWhere((item) => item.id == action.id);

    final summary = container.read(employeeDirectoryActionQueueSummaryProvider);
    expect(updated.status, EmployeeDirectoryActionStatus.resolved);
    expect(summary.openCount, 3);
    expect(summary.resolvedCount, 1);
  });

  test('employee directory action queue handles an empty table view', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(employeeDirectorySearchQueryProvider.notifier).state =
        'no matching employee';

    final actions = container.read(employeeDirectoryActionQueueProvider);
    final summary = container.read(employeeDirectoryActionQueueSummaryProvider);

    expect(actions, isEmpty);
    expect(summary.totalCount, 0);
    expect(summary.openCount, 0);
  });
}

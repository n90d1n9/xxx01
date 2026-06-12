import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_activity_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_activity_provider.dart';

void main() {
  test('employee directory activity records governance events', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final members = buildEmployeeDirectoryMembers();
    final notifier = container.read(employeeDirectoryActivityProvider.notifier);

    notifier.recordCreated(members.first);
    notifier.recordUpdated(
      before: members.first,
      after: members.first.copyWith(position: 'Lead UX Designer'),
    );
    notifier.recordBulkStatusChanged(
      members: members.take(2).toList(),
      status: EmployeeDirectoryStatus.watchlist,
    );
    notifier.recordBulkProfileUpdated(
      members: members.take(2).toList(),
      changedFields: ['manager', 'department'],
      auditNote: 'Manager and department move approved',
    );
    notifier.recordExported(5);
    notifier.recordImported(2);
    notifier.recordActionUpdated(
      title: 'Review watchlist profiles resolved',
      detail: 'Review watchlist profiles resolved for 1 affected profiles.',
      affectedCount: 1,
    );
    notifier.recordRemoved(members.last);

    final events = container.read(employeeDirectoryActivityProvider);
    final summary = container.read(employeeDirectoryActivitySummaryProvider);
    final recent = container.read(employeeDirectoryRecentActivityProvider);

    expect(events.length, 8);
    expect(events.first.type, EmployeeDirectoryActivityType.removed);
    expect(events.first.title, 'Olivia Wilson removed');
    expect(summary.totalCount, 8);
    expect(summary.createCount, 1);
    expect(summary.updateCount, 1);
    expect(summary.bulkActionCount, 2);
    expect(summary.exportCount, 1);
    expect(summary.importCount, 1);
    expect(summary.queueActionCount, 1);
    expect(summary.removalCount, 1);
    expect(recent.length, 5);
    expect(events.map((event) => event.id), [
      'employee-directory-activity-8',
      'employee-directory-activity-7',
      'employee-directory-activity-6',
      'employee-directory-activity-5',
      'employee-directory-activity-4',
      'employee-directory-activity-3',
      'employee-directory-activity-2',
      'employee-directory-activity-1',
    ]);
  });

  test('employee directory activity caps recent history', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final member = buildEmployeeDirectoryMembers().first;
    final notifier = container.read(employeeDirectoryActivityProvider.notifier);

    for (var index = 0; index < 30; index++) {
      notifier.recordCreated(member.copyWith(name: 'Employee $index'));
    }

    final events = container.read(employeeDirectoryActivityProvider);
    final recent = container.read(employeeDirectoryRecentActivityProvider);

    expect(events.length, 25);
    expect(recent.length, 5);
    expect(events.first.title, 'Employee 29 created');
    expect(events.last.title, 'Employee 5 created');
  });
}

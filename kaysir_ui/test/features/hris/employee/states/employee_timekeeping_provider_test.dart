import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_timekeeping_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_timekeeping_provider.dart';

void main() {
  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
  }

  test('employee timekeeping highlights payroll-blocking exceptions', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeTimekeepingProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.totalOvertimeHours, 3.5);
    expect(profile.submittedEntryCount, 1);
    expect(profile.rejectedEntryCount, 1);
    expect(profile.payrollBlockingExceptionCount, 2);
    expect(profile.overdueExceptionCount, 1);
    expect(profile.attentionCount, 5);
    expect(profile.isReadyForPayroll, isFalse);
    expect(profile.nextAction, 'Resolve 2 payroll-blocking exceptions.');
  });

  test('employee timekeeping draft validates and appends exception', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeTimekeepingExceptionDraftProvider('3').notifier,
    );
    draftNotifier.setType(EmployeeTimekeepingExceptionType.overtime);
    draftNotifier.setOwner('Payroll Operations');
    draftNotifier.setMinutesImpact(60);
    draftNotifier.setPayrollImpact(true);
    draftNotifier.setNote('Overtime needs approval before payroll cutoff.');

    final draft =
        container.read(employeeTimekeepingExceptionDraftProvider('3'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final notifier = container.read(employeeTimekeepingProvider('3').notifier);
    final exception = notifier.addException(draft);

    expect(exception.id, 'ETK-3-001');
    expect(exception.status, EmployeeTimekeepingExceptionStatus.open);
    expect(
      container
          .read(employeeTimekeepingProvider('3'))!
          .payrollBlockingExceptionCount,
      1,
    );

    notifier.reviewException(exception.id);
    var stored = container
        .read(employeeTimekeepingProvider('3'))!
        .exceptions
        .singleWhere((item) => item.id == exception.id);
    expect(stored.status, EmployeeTimekeepingExceptionStatus.inReview);

    notifier.resolveException(exception.id);
    stored = container
        .read(employeeTimekeepingProvider('3'))!
        .exceptions
        .singleWhere((item) => item.id == exception.id);
    expect(stored.status, EmployeeTimekeepingExceptionStatus.resolved);
    expect(stored.payrollImpact, isFalse);
  });

  test('employee timekeeping updates timesheet entry workflow', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(employeeTimekeepingProvider('4').notifier);

    notifier.approveEntry('4-time-entry-1', 'Olivia Wilson');
    var entry = container
        .read(employeeTimekeepingProvider('4'))!
        .entries
        .singleWhere((item) => item.id == '4-time-entry-1');
    expect(entry.status, EmployeeTimesheetEntryStatus.approved);
    expect(entry.approvedBy, 'Olivia Wilson');

    notifier.markPayrollReady('4-time-entry-1');
    entry = container
        .read(employeeTimekeepingProvider('4'))!
        .entries
        .singleWhere((item) => item.id == '4-time-entry-1');
    expect(entry.status, EmployeeTimesheetEntryStatus.payrollReady);

    notifier.resolveException('4-time-exception-missing-clock');
    final profile = container.read(employeeTimekeepingProvider('4'))!;
    expect(profile.payrollBlockingExceptionCount, 1);
  });

  test('employee timekeeping returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeeTimekeepingProvider('missing')), isNull);
    expect(
      container.read(employeeTimekeepingExceptionDraftProvider('missing')),
      isNull,
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_case_log_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_case_log_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';

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

  test('employee HR case log highlights urgent follow-up work', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final log = container.read(employeeHrCaseLogProvider('4'));

    expect(log, isNotNull);
    expect(log!.employeeName, 'David Kim');
    expect(log.openCaseCount, 2);
    expect(log.overdueFollowUpCount, 1);
    expect(log.highPriorityCount, 1);
    expect(log.restrictedCaseCount, 1);
    expect(log.nextAction, 'Follow up on 1 overdue HR case.');
  });

  test('employee HR case note draft validates and appends note', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeHrCaseNoteDraftProvider('1').notifier,
    );
    draftNotifier.setBody('Manager documented retention themes and next step.');

    final draft = container.read(employeeHrCaseNoteDraftProvider('1'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final logNotifier = container.read(employeeHrCaseLogProvider('1').notifier);
    final note = logNotifier.addNote(draft);

    expect(note.id, 'HCN-1-002');
    expect(note.confidential, isTrue);
    expect(container.read(employeeHrCaseLogProvider('1'))!.notes.length, 2);
  });

  test('employee HR case intake draft validates and creates case', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeHrCaseIntakeDraftProvider('1').notifier,
    );
    draftNotifier.setTitle('Payroll correction request');
    draftNotifier.setOwner('Payroll Partner');
    draftNotifier.setSummary(
      'Investigate missing allowance in latest payroll.',
    );
    draftNotifier.setType(EmployeeHrCaseType.payroll);
    draftNotifier.setPriority(EmployeeHrCasePriority.critical);
    draftNotifier.setConfidentiality(EmployeeHrCaseConfidentiality.restricted);

    final draft = container.read(employeeHrCaseIntakeDraftProvider('1'))!;
    expect(draft.isReadyToCreate, isTrue);
    expect(draft.completionRatio, 1);

    final initialCount =
        container.read(employeeHrCaseLogProvider('1'))!.cases.length;
    final logNotifier = container.read(employeeHrCaseLogProvider('1').notifier);
    final record = logNotifier.createCase(draft);

    final updated = container.read(employeeHrCaseLogProvider('1'))!;
    expect(record.title, 'Payroll correction request');
    expect(record.status, EmployeeHrCaseStatus.open);
    expect(record.priority, EmployeeHrCasePriority.critical);
    expect(updated.cases.length, initialCount + 1);
    expect(updated.sortedCases.first.id, record.id);
  });

  test('employee HR case actions clear resolved urgency', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(employeeHrCaseLogProvider('4').notifier);

    notifier.resolveCase('4-case-performance');
    notifier.scheduleFollowUp('4-case-policy', DateTime(2026, 6, 10));

    final updated = container.read(employeeHrCaseLogProvider('4'))!;
    final performanceCase = updated.cases.singleWhere(
      (record) => record.id == '4-case-performance',
    );

    expect(performanceCase.status, EmployeeHrCaseStatus.resolved);
    expect(updated.highPriorityCount, 0);
    expect(updated.overdueFollowUpCount, 0);
    expect(updated.openCaseCount, 1);
    expect(updated.nextAction, 'Keep 1 HR case moving.');
  });
}

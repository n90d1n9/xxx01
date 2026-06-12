import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_job_history_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_job_history_provider.dart';

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

  test('employee job history highlights overdue manager evidence', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeJobHistoryProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.currentPosition, 'Product Manager');
    expect(profile.pendingEvidenceCount, 1);
    expect(profile.overdueCount, 1);
    expect(profile.reversedCount, 1);
    expect(profile.attentionCount, 1);
    expect(profile.nextAction, 'Resolve 1 overdue job-history event.');
  });

  test('employee job history adds evidence and reverses events', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeJobHistoryDraftProvider('2').notifier,
    );
    draftNotifier.setType(EmployeeJobHistoryEventType.compensationChange);
    draftNotifier.setTitle('Retention allowance update');
    draftNotifier.setFromValue('IDR 20,000,000');
    draftNotifier.setToValue('IDR 24,000,000');
    draftNotifier.setEffectiveDate(DateTime(2026, 6, 12));
    draftNotifier.setSource(EmployeeJobHistorySource.payroll);
    draftNotifier.setOwner('Payroll');
    draftNotifier.setNote('Allowance update approved for retention plan.');
    draftNotifier.setEvidence('Compensation committee approval');

    final draft = container.read(employeeJobHistoryDraftProvider('2'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final historyNotifier = container.read(
      employeeJobHistoryProfileProvider('2').notifier,
    );
    final event = historyNotifier.addEvent(draft);

    expect(event.id, 'EJH-2-004');
    expect(event.status, EmployeeJobHistoryStatus.scheduled);

    historyNotifier.markEffective(event.id);
    var profile = container.read(employeeJobHistoryProfileProvider('2'))!;

    expect(
      profile.history.singleWhere((entry) => entry.id == event.id).isEffective,
      isTrue,
    );

    historyNotifier.reverseEvent(event.id);
    profile = container.read(employeeJobHistoryProfileProvider('2'))!;

    expect(
      profile.history.singleWhere((entry) => entry.id == event.id).status,
      EmployeeJobHistoryStatus.reversed,
    );
  });

  test('employee job history returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeeJobHistoryProfileProvider('missing')),
      isNull,
    );
    expect(container.read(employeeJobHistoryDraftProvider('missing')), isNull);
  });
}

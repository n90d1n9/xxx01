import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_job_assignment_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_job_assignment_provider.dart';

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

  test('employee job assignments highlight onboarding confirmation work', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeJobAssignmentProfileProvider('5'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'Olivia Wilson');
    expect(profile.activeCount, 1);
    expect(profile.pendingApprovalCount, 1);
    expect(profile.attentionCount, 1);
    expect(
      profile.currentAssignment!.contractType,
      EmployeeEmploymentContractType.probationary,
    );
    expect(profile.nextAction, 'Review 1 pending assignment change.');
  });

  test('employee job assignment draft validates and appends assignment', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeJobAssignmentDraftProvider('3').notifier,
    );
    draftNotifier.setPosition('Senior HR Manager');
    draftNotifier.setNotes('Assignment approved for HR operations coverage.');

    final draft = container.read(employeeJobAssignmentDraftProvider('3'))!;
    expect(draft.isReadyToSchedule, isTrue);
    expect(draft.changedImpacts.single.label, 'Position');

    final profileNotifier = container.read(
      employeeJobAssignmentProfileProvider('3').notifier,
    );
    final assignment = profileNotifier.addDraft(draft);

    expect(assignment.id, 'EJA-3-002');
    expect(assignment.status, EmployeeJobAssignmentStatus.pendingApproval);
    expect(
      container
          .read(employeeJobAssignmentProfileProvider('3'))!
          .pendingApprovalCount,
      1,
    );
  });

  test(
    'employee job assignment approval and activation close prior assignment',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final draftNotifier = container.read(
        employeeJobAssignmentDraftProvider('3').notifier,
      );
      draftNotifier.setPosition('Senior HR Manager');
      draftNotifier.setStartDate(DateTime(2026, 5, 30));
      draftNotifier.setNotes(
        'Assignment activated for HR operations coverage.',
      );

      final profileNotifier = container.read(
        employeeJobAssignmentProfileProvider('3').notifier,
      );
      final assignment = profileNotifier.addDraft(
        container.read(employeeJobAssignmentDraftProvider('3'))!,
      );

      profileNotifier.approve(assignment.id);
      profileNotifier.activate(assignment.id);

      final updated =
          container.read(employeeJobAssignmentProfileProvider('3'))!;
      final previous = updated.assignments.singleWhere(
        (item) => item.id == 'EJA-3-001',
      );

      expect(updated.currentAssignment!.position, 'Senior HR Manager');
      expect(updated.activeCount, 1);
      expect(updated.historyCount, 1);
      expect(previous.status, EmployeeJobAssignmentStatus.completed);
      expect(previous.endDate, DateTime(2026, 5, 29));
      expect(updated.nextAction, 'Senior HR Manager assignment is current.');
    },
  );
}

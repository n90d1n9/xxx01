import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_action_workflow_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_next_action_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_action_workflow_provider.dart';
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

  test('employee action workflow seeds tasks from next best actions', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeActionWorkflowProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.tasks, isNotEmpty);
    expect(profile.openCount, greaterThan(0));
    expect(profile.nextAction, isNot('Employee action workflow is clear.'));
    expect(
      profile.tasks.map((task) => task.sourceLabel),
      isNot(contains('Manual follow-up')),
    );
  });

  test('employee action workflow updates task lifecycle', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final initial = container.read(employeeActionWorkflowProvider('4'))!;
    final task = initial.sortedTasks.first;
    final notifier = container.read(
      employeeActionWorkflowProvider('4').notifier,
    );

    notifier.startTask(task.id);
    expect(
      container.read(employeeActionWorkflowProvider('4'))!.inProgressCount,
      greaterThan(0),
    );

    notifier.completeTask(task.id);
    var updated = container.read(employeeActionWorkflowProvider('4'))!;
    expect(updated.completedCount, 1);
    expect(
      updated.tasks.singleWhere((item) => item.id == task.id).status,
      EmployeeActionTaskStatus.completed,
    );

    notifier.reopenTask(task.id);
    updated = container.read(employeeActionWorkflowProvider('4'))!;
    expect(
      updated.tasks.singleWhere((item) => item.id == task.id).status,
      EmployeeActionTaskStatus.open,
    );
  });

  test('employee action workflow validates and adds manual tasks', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeActionTaskDraftProvider('4').notifier,
    );
    draftNotifier.setTitle('Confirm payroll exception');
    draftNotifier.setDescription('Validate payroll exception before cutoff.');
    draftNotifier.setOwner('Payroll');
    draftNotifier.setArea(EmployeeNextActionArea.pay);
    draftNotifier.setPriority(EmployeeNextActionPriority.high);

    final draft = container.read(employeeActionTaskDraftProvider('4'))!;
    expect(draft.isReadyToAdd, isTrue);

    final task = container
        .read(employeeActionWorkflowProvider('4').notifier)
        .addDraft(draft);

    expect(task.sourceLabel, 'Manual follow-up');
    expect(task.priority, EmployeeNextActionPriority.high);
    expect(
      container
          .read(employeeActionWorkflowProvider('4'))!
          .tasks
          .map((item) => item.title),
      contains('Confirm payroll exception'),
    );
  });

  test('employee action workflow returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeeActionWorkflowProvider('missing')), isNull);
    expect(container.read(employeeActionTaskDraftProvider('missing')), isNull);
  });
}

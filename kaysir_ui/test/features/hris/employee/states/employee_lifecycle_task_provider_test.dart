import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_lifecycle_task_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_lifecycle_task_provider.dart';

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

  test('employee lifecycle plan seeds onboarding task pack', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final plan = container.read(employeeLifecyclePlanProvider('5'));

    expect(plan, isNotNull);
    expect(plan!.employeeName, 'Olivia Wilson');
    expect(plan.type, EmployeeLifecyclePlanType.onboarding);
    expect(plan.tasks, hasLength(3));
    expect(plan.blockedCount, 1);
    expect(plan.overdueCount, 1);
    expect(plan.completionRatio, 0);
    expect(plan.nextAction, 'Clear 1 blocked lifecycle task.');
  });

  test('employee lifecycle task draft adds and completes a custom task', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeLifecycleTaskDraftProvider('2').notifier,
    );
    draftNotifier.setTitle('Collect updated emergency contact');
    draftNotifier.setOwner('People Operations');
    draftNotifier.setDueDate(DateTime(2026, 6, 6));
    draftNotifier.setPriority(EmployeeLifecycleTaskPriority.high);

    final draft = container.read(employeeLifecycleTaskDraftProvider('2'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final planNotifier = container.read(
      employeeLifecyclePlanProvider('2').notifier,
    );
    final task = planNotifier.addTask(draft);

    expect(task.id, 'ELT-2-004');
    expect(task.title, 'Collect updated emergency contact');
    expect(task.status, EmployeeLifecycleTaskStatus.open);

    planNotifier.updateTaskStatus(task.id, EmployeeLifecycleTaskStatus.done);
    final plan = container.read(employeeLifecyclePlanProvider('2'))!;

    expect(plan.doneCount, 1);
    expect(plan.activeCount, 3);
    expect(
      plan.tasks.singleWhere((item) => item.id == task.id).isComplete,
      isTrue,
    );
  });

  test('employee lifecycle plan type switch replaces preset tasks', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeLifecyclePlanProvider('4').notifier,
    );
    final initial = container.read(employeeLifecyclePlanProvider('4'))!;

    expect(initial.type, EmployeeLifecyclePlanType.probationReview);
    expect(initial.tasks.map((task) => task.id), contains('4-probation-plan'));

    notifier.setPlanType(EmployeeLifecyclePlanType.offboarding);
    final offboarding = container.read(employeeLifecyclePlanProvider('4'))!;

    expect(offboarding.type, EmployeeLifecyclePlanType.offboarding);
    expect(offboarding.tasks, hasLength(3));
    expect(
      offboarding.tasks.map((task) => task.id),
      containsAll([
        '4-offboarding-exit',
        '4-offboarding-access',
        '4-offboarding-assets',
      ]),
    );
    expect(
      offboarding.tasks.map((task) => task.id),
      isNot(contains('4-probation-plan')),
    );
  });
}

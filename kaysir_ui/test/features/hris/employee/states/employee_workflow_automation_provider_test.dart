import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_automation_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_automation_provider.dart';

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

  test('employee workflow automation highlights failed hooks', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(
      employeeWorkflowAutomationProfileProvider('4'),
    );

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.failedCount, 1);
    expect(profile.dueCount, 1);
    expect(profile.generatedTaskCount, 5);
    expect(profile.attentionCount, 2);
    expect(profile.nextAction, 'Repair 1 failed workflow automation hook.');
  });

  test('employee workflow automation submits runs and pauses hook', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeWorkflowAutomationDraftProvider('2').notifier,
    );
    draftNotifier.setName('Policy review task sync');
    draftNotifier.setTrigger(
      EmployeeWorkflowAutomationTrigger.approvalPolicyIssue,
    );
    draftNotifier.setDelivery(
      EmployeeWorkflowAutomationDelivery.createWorkflowTask,
    );
    draftNotifier.setOwner('People Operations');
    draftNotifier.setSourceLabel('Approval policy');
    draftNotifier.setGeneratedTaskTitle('Review approval policy routing');
    draftNotifier.setSlaHours(24);
    draftNotifier.setRisk(EmployeeWorkflowAutomationRisk.high);
    draftNotifier.setNextRunAt(DateTime(2026, 6, 1));
    draftNotifier.setNotes('Create review tasks when policy routing changes.');

    final draft = container.read(employeeWorkflowAutomationDraftProvider('2'))!;
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);

    final notifier = container.read(
      employeeWorkflowAutomationProfileProvider('2').notifier,
    );
    final hook = notifier.submitDraft(draft);

    expect(hook.id, 'EWA-2-003');
    expect(hook.status, EmployeeWorkflowAutomationStatus.draft);

    notifier.activate(hook.id);
    notifier.runNow(hook.id);

    var profile =
        container.read(employeeWorkflowAutomationProfileProvider('2'))!;
    final runHook = profile.hooks.singleWhere((item) => item.id == hook.id);
    expect(runHook.status, EmployeeWorkflowAutomationStatus.active);
    expect(runHook.generatedTaskCount, 1);
    expect(runHook.lastRunAt, DateTime(2026, 5, 30));

    notifier.pause(hook.id);
    profile = container.read(employeeWorkflowAutomationProfileProvider('2'))!;

    expect(
      profile.hooks.singleWhere((item) => item.id == hook.id).status,
      EmployeeWorkflowAutomationStatus.paused,
    );
  });

  test('employee workflow automation returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeeWorkflowAutomationProfileProvider('missing')),
      isNull,
    );
    expect(
      container.read(employeeWorkflowAutomationDraftProvider('missing')),
      isNull,
    );
  });
}

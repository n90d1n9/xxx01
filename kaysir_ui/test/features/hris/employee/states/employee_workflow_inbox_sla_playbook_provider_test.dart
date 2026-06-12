import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_sla_playbook_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_profile_change_governance_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_sla_playbook_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_sla_provider.dart';

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

  test('employee workflow inbox SLA playbook prioritizes recovery steps', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final sla = container.read(employeeWorkflowInboxSlaProvider('4'))!;
    final playbook = container.read(
      employeeWorkflowInboxSlaPlaybookProvider('4'),
    );

    expect(playbook, isNotNull);
    expect(playbook!.employeeName, 'David Kim');
    expect(playbook.totalCount, greaterThan(0));
    expect(playbook.recoveryItemCount, greaterThanOrEqualTo(sla.readyCount));
    expect(playbook.nextAction, isNot('No SLA recovery playbook needed.'));
    expect(
      playbook.steps.map((step) => step.type),
      contains(EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance),
    );
    expect(playbook.topSteps.first.itemCount, greaterThan(0));
  });

  test('employee workflow inbox SLA playbook follows completed work', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final initial =
        container.read(employeeWorkflowInboxSlaPlaybookProvider('4'))!;
    final ready = initial.steps.singleWhere(
      (step) =>
          step.type == EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
    );

    container
        .read(employeeProfileChangeGovernanceProvider('4').notifier)
        .apply('EPC-4-seed-001');

    final updated =
        container.read(employeeWorkflowInboxSlaPlaybookProvider('4'))!;
    final updatedReady = updated.steps.where(
      (step) =>
          step.type == EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
    );

    if (updatedReady.isNotEmpty) {
      expect(updatedReady.single.itemCount, lessThan(ready.itemCount));
    } else {
      expect(ready.itemCount, greaterThan(0));
    }
  });

  test(
    'employee workflow inbox SLA playbook returns null for missing employee',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(
        container.read(employeeWorkflowInboxSlaPlaybookProvider('missing')),
        isNull,
      );
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_action_sla_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_action_workflow_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_action_sla_provider.dart';
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

  test('employee action SLA summarizes escalation and owner load', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeActionSlaProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.signals, isNotEmpty);
    expect(profile.ownerLoads, isNotEmpty);
    expect(profile.dueTodayCount, greaterThan(0));
    expect(profile.escalatedCount, greaterThan(0));
    expect(profile.nextAction, contains('Escalate'));
    expect(profile.topSignals.first.needsAttention, isTrue);
  });

  test('employee action SLA reacts when a workflow task closes', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final initial = container.read(employeeActionSlaProfileProvider('4'))!;
    final signal = initial.topSignals.first;

    container
        .read(employeeActionWorkflowProvider('4').notifier)
        .completeTask(signal.taskId);

    final updated = container.read(employeeActionSlaProfileProvider('4'))!;
    final closedSignal = updated.signals.singleWhere(
      (item) => item.taskId == signal.taskId,
    );

    expect(closedSignal.state, EmployeeActionSlaState.closed);
    expect(closedSignal.escalationLevel, EmployeeActionEscalationLevel.none);
    expect(
      container
          .read(employeeActionWorkflowProvider('4'))!
          .tasks
          .singleWhere((task) => task.id == signal.taskId)
          .status,
      EmployeeActionTaskStatus.completed,
    );
  });

  test('employee action SLA returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeeActionSlaProfileProvider('missing')), isNull);
  });
}

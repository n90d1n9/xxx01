import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_profile_change_governance_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_provider.dart';
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

  test('employee workflow inbox SLA summarizes cross-source risks', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final inbox = container.read(employeeWorkflowInboxProvider('4'))!;
    final sla = container.read(employeeWorkflowInboxSlaProvider('4'));

    expect(sla, isNotNull);
    expect(sla!.employeeName, 'David Kim');
    expect(sla.totalCount, inbox.totalCount);
    expect(sla.readyCount, greaterThan(0));
    expect(sla.ownerLoads, isNotEmpty);
    expect(sla.topSignals.first.needsAttention, isTrue);
    expect(
      sla.nextAction,
      anyOf(startsWith('Clear'), startsWith('Escalate'), startsWith('Recover')),
    );

    final profileChangeSignal = sla.signals.singleWhere(
      (signal) => signal.source == EmployeeWorkflowInboxSource.profileChange,
    );
    expect(profileChangeSignal.isReady, isTrue);
    expect(profileChangeSignal.action, EmployeeWorkflowInboxAction.apply);
  });

  test('employee workflow inbox SLA follows source workflow changes', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profileChangeSignal = container
        .read(employeeWorkflowInboxSlaProvider('4'))!
        .signals
        .singleWhere(
          (signal) =>
              signal.source == EmployeeWorkflowInboxSource.profileChange,
        );

    container
        .read(employeeProfileChangeGovernanceProvider('4').notifier)
        .apply(profileChangeSignal.sourceRecordId);

    final updated = container.read(employeeWorkflowInboxSlaProvider('4'))!;
    expect(
      updated.signals.map((signal) => signal.itemId),
      isNot(contains(profileChangeSignal.itemId)),
    );
  });

  test('employee workflow inbox SLA returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeeWorkflowInboxSlaProvider('missing')), isNull);
  });
}

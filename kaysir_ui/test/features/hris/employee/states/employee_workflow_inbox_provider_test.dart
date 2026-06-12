import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_workflow_inbox_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_profile_change_governance_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_workflow_inbox_provider.dart';

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

  test('employee workflow inbox aggregates active HR workflow sources', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final inbox = container.read(employeeWorkflowInboxProvider('4'));

    expect(inbox, isNotNull);
    expect(inbox!.employeeName, 'David Kim');
    expect(inbox.totalCount, greaterThan(0));
    expect(inbox.readyCount, greaterThan(0));
    final peopleOps = inbox.ownerLoadFor('People Operations');
    expect(peopleOps, isNotNull);
    expect(peopleOps!.readyCount, greaterThan(0));
    expect(inbox.items.where((item) => item.hasPrimaryAction), isNotEmpty);
    expect(inbox.countFor(EmployeeWorkflowInboxFilter.ready), inbox.readyCount);
    expect(
      inbox.itemsFor(
        EmployeeWorkflowInboxFilter.all,
        owner: 'People Operations',
      ),
      everyElement(
        isA<EmployeeWorkflowInboxItem>().having(
          (item) => item.owner,
          'owner',
          'People Operations',
        ),
      ),
    );
    expect(
      inbox.itemsFor(EmployeeWorkflowInboxFilter.profileChange),
      everyElement(
        isA<EmployeeWorkflowInboxItem>().having(
          (item) => item.source,
          'source',
          EmployeeWorkflowInboxSource.profileChange,
        ),
      ),
    );
    expect(inbox.nextAction, startsWith('Act on'));
    expect(
      inbox.nextActionFor(EmployeeWorkflowInboxFilter.profileChange),
      startsWith('Review'),
    );
    expect(
      inbox.items.map((item) => item.source),
      contains(EmployeeWorkflowInboxSource.actionWorkflow),
    );
    expect(
      inbox.items.map((item) => item.source),
      contains(EmployeeWorkflowInboxSource.profileChange),
    );
    final profileChange = inbox.items.singleWhere(
      (item) => item.source == EmployeeWorkflowInboxSource.profileChange,
    );
    expect(profileChange.sourceRecordId, 'EPC-4-seed-001');
    expect(profileChange.primaryAction, EmployeeWorkflowInboxAction.apply);
  });

  test('employee workflow inbox follows source state transitions', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profileChangeItem = container
        .read(employeeWorkflowInboxProvider('4'))!
        .items
        .singleWhere(
          (item) => item.source == EmployeeWorkflowInboxSource.profileChange,
        );

    container
        .read(employeeProfileChangeGovernanceProvider('4').notifier)
        .apply(profileChangeItem.id.replaceFirst('profile-change-', ''));

    final updated = container.read(employeeWorkflowInboxProvider('4'))!;
    expect(updated.countFor(EmployeeWorkflowInboxFilter.profileChange), 0);
    expect(
      updated.items.map((item) => item.source),
      isNot(contains(EmployeeWorkflowInboxSource.profileChange)),
    );
  });

  test('employee workflow inbox returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeeWorkflowInboxProvider('missing')), isNull);
  });
}

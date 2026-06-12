import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_position_control_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_position_control_provider.dart';

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

  test('employee position control highlights budget and approval work', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeePositionControlProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.position.positionCode, 'POS-PROD-004');
    expect(profile.position.isOverBudget, isTrue);
    expect(profile.position.budgetVariance, 650);
    expect(profile.position.criticality, EmployeePositionCriticality.critical);
    expect(profile.openRequisitionCount, 1);
    expect(profile.pendingApprovalCount, 1);
    expect(profile.attentionCount, 2);
    expect(profile.nextAction, 'Resolve position budget variance.');
  });

  test(
    'employee position requisition draft validates and progresses workflow',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final draftNotifier = container.read(
        employeePositionRequisitionDraftProvider('3').notifier,
      );
      draftNotifier.setType(EmployeePositionRequisitionType.backfill);
      draftNotifier.setTitle('HR operations backfill');
      draftNotifier.setOwner('People Operations');
      draftNotifier.setRequestedFte(1);
      draftNotifier.setBusinessCase(
        'Backfill needed to preserve HR operations service coverage.',
      );

      final draft =
          container.read(employeePositionRequisitionDraftProvider('3'))!;
      expect(draft.isReadyToAdd, isTrue);
      expect(draft.completionRatio, 1);

      final notifier = container.read(
        employeePositionControlProvider('3').notifier,
      );
      final requisition = notifier.addRequisition(draft);

      expect(requisition.id, 'EPC-3-001');
      expect(requisition.status, EmployeePositionRequisitionStatus.submitted);

      notifier.approveRequisition(requisition.id);
      var profile = container.read(employeePositionControlProvider('3'))!;
      var stored = profile.requisitions.singleWhere(
        (item) => item.id == requisition.id,
      );
      expect(stored.status, EmployeePositionRequisitionStatus.approved);

      notifier.openRequisition(requisition.id);
      profile = container.read(employeePositionControlProvider('3'))!;
      stored = profile.requisitions.singleWhere(
        (item) => item.id == requisition.id,
      );
      expect(stored.status, EmployeePositionRequisitionStatus.open);

      notifier.fillRequisition(requisition.id);
      profile = container.read(employeePositionControlProvider('3'))!;
      stored = profile.requisitions.singleWhere(
        (item) => item.id == requisition.id,
      );
      expect(stored.status, EmployeePositionRequisitionStatus.filled);

      notifier.freezePosition();
      profile = container.read(employeePositionControlProvider('3'))!;
      expect(profile.position.status, EmployeePositionStatus.frozen);

      notifier.unfreezePosition();
      profile = container.read(employeePositionControlProvider('3'))!;
      expect(profile.position.status, EmployeePositionStatus.filled);
    },
  );

  test('employee position control returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeePositionControlProvider('missing')), isNull);
    expect(
      container.read(employeePositionRequisitionDraftProvider('missing')),
      isNull,
    );
  });
}

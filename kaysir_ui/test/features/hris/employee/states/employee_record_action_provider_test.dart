import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_record_action_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_record_action_provider.dart';

void main() {
  test('employee record action draft validates promotion impact', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeRecordActionDraftProvider('1').notifier,
    );
    notifier.setTargetPosition('Senior UX Designer');
    notifier.setEffectiveDate(DateTime(2026, 6, 15));
    notifier.setReason('Promotion approved after design calibration.');

    final draft = container.read(employeeRecordActionDraftProvider('1'));

    expect(draft, isNotNull);
    expect(draft!.employeeName, 'Sarah Johnson');
    expect(draft.actionType, EmployeeRecordActionType.promotion);
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);
    expect(draft.impacts.single.label, 'Position');
    expect(draft.impacts.single.fromValue, 'UX Designer');
    expect(draft.impacts.single.toValue, 'Senior UX Designer');
  });

  test(
    'employee record action queue submits approves and applies transfer',
    () {
      final container = ProviderContainer(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
      );
      addTearDown(container.dispose);

      final draftNotifier = container.read(
        employeeRecordActionDraftProvider('4').notifier,
      );
      draftNotifier.setActionType(EmployeeRecordActionType.transfer);
      draftNotifier.setTargetPosition('Engineering Product Manager');
      draftNotifier.setTargetDepartment('Engineering');
      draftNotifier.setTargetManager('Michael Chen');
      draftNotifier.setEffectiveDate(DateTime(2026, 6, 20));
      draftNotifier.setReason(
        'Transfer approved for platform delivery coverage.',
      );

      final queue = container.read(
        employeeRecordActionRequestsProvider.notifier,
      );
      final request = queue.submitDraft(
        container.read(employeeRecordActionDraftProvider('4'))!,
      );

      expect(request.id, 'ERA-001');
      expect(request.impacts.map((impact) => impact.label), [
        'Position',
        'Department',
        'Manager',
      ]);

      queue.approve(request.id);
      final approved = container
          .read(employeeRecordActionRequestsProvider)
          .singleWhere((item) => item.id == request.id);
      expect(approved.status, EmployeeRecordActionStatus.approved);
      expect(
        container.read(employeeRecordActionSummaryProvider('4')).approvedCount,
        1,
      );

      final member = container
          .read(employeeDirectoryMembersProvider)
          .singleWhere((item) => item.id == approved.employeeId);
      container
          .read(employeeDirectoryMembersProvider.notifier)
          .updateMember(approved.applyTo(member));
      queue.markApplied(approved.id);

      final updatedMember = container
          .read(employeeDirectoryMembersProvider)
          .singleWhere((item) => item.id == '4');
      final summary = container.read(employeeRecordActionSummaryProvider('4'));

      expect(updatedMember.position, 'Engineering Product Manager');
      expect(updatedMember.department, 'Engineering');
      expect(updatedMember.manager, 'Michael Chen');
      expect(summary.appliedCount, 1);
      expect(summary.nextAction, 'No employee record changes are waiting.');
    },
  );

  test('employee record action draft requires manager changes to differ', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeRecordActionDraftProvider('2').notifier,
    );
    notifier.setActionType(EmployeeRecordActionType.managerChange);
    notifier.setEffectiveDate(DateTime(2026, 6, 10));
    notifier.setReason('Manager reassignment for new engineering tribe.');

    var draft = container.read(employeeRecordActionDraftProvider('2'))!;
    expect(draft.isReadyToSubmit, isFalse);
    expect(
      draft.validationErrors,
      contains('Change at least one employee record field'),
    );

    notifier.setTargetManager('Sarah Johnson');
    draft = container.read(employeeRecordActionDraftProvider('2'))!;

    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.impacts.single.label, 'Manager');
    expect(draft.impacts.single.fromValue, 'David Kim');
    expect(draft.impacts.single.toValue, 'Sarah Johnson');
  });
}

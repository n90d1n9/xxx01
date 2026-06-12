import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_profile_change_governance_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_profile_change_governance_provider.dart';

void main() {
  test(
    'employee profile change governance seeds apply-ready watchlist change',
    () {
      final container = ProviderContainer(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
      );
      addTearDown(container.dispose);

      final profile = container.read(
        employeeProfileChangeGovernanceProvider('4'),
      );

      expect(profile, isNotNull);
      expect(profile!.employeeName, 'David Kim');
      expect(profile.dueToApplyCount, 1);
      expect(profile.nextAction, 'Apply 1 effective profile change.');

      final request = profile.sortedRequests.single;
      expect(request.field, EmployeeProfileChangeField.manager);
      expect(request.currentValue, 'Olivia Wilson');
      expect(request.proposedValue, 'Emma Rodriguez');
      expect(request.canApply(profile.asOfDate), isTrue);

      container
          .read(employeeProfileChangeGovernanceProvider('4').notifier)
          .apply(request.id);

      final applied =
          container
              .read(employeeProfileChangeGovernanceProvider('4'))!
              .sortedRequests
              .single;
      expect(applied.status, EmployeeProfileChangeStatus.applied);
    },
  );

  test('employee profile change governance submits reviews and schedules', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeProfileChangeDraftProvider('1').notifier,
    );
    draftNotifier.setField(EmployeeProfileChangeField.payrollGroup);
    draftNotifier.setProposedValue('ID-Biweekly');
    draftNotifier.setReason('Move employee into the new payroll cycle.');

    final draft = container.read(employeeProfileChangeDraftProvider('1'))!;
    expect(draft.currentValue, 'ID-Monthly');
    expect(draft.isReadyToSubmit, isTrue);

    final request = container
        .read(employeeProfileChangeGovernanceProvider('1').notifier)
        .addDraft(draft);

    expect(request.status, EmployeeProfileChangeStatus.submitted);
    expect(request.riskLabel, 'Payroll impact');

    final notifier = container.read(
      employeeProfileChangeGovernanceProvider('1').notifier,
    );
    notifier.startReview(request.id);
    notifier.approve(request.id);
    notifier.schedule(request.id);

    final scheduled =
        container
            .read(employeeProfileChangeGovernanceProvider('1'))!
            .sortedRequests
            .single;
    expect(scheduled.status, EmployeeProfileChangeStatus.scheduled);
    expect(scheduled.canApply(DateTime(2026, 5, 30)), isFalse);
  });
}

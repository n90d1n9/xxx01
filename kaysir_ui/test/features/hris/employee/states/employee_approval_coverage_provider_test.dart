import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_approval_coverage_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_approval_coverage_provider.dart';
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

  test('employee approval coverage highlights blocked delegations', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeApprovalCoverageProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.blockedCount, 1);
    expect(profile.expiredCount, 1);
    expect(profile.pendingCount, 1);
    expect(profile.attentionCount, 3);
    expect(profile.nextAction, 'Clear 1 blocked approval delegation.');
  });

  test(
    'employee approval coverage submits activates and blocks delegation',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final draftNotifier = container.read(
        employeeApprovalDelegationDraftProvider('2').notifier,
      );
      draftNotifier.setArea(EmployeeApprovalCoverageArea.access);
      draftNotifier.setPrimaryApprover('David Kim');
      draftNotifier.setDelegateApprover('IT Security');
      draftNotifier.setStartDate(DateTime(2026, 5, 30));
      draftNotifier.setEndDate(DateTime(2026, 6, 30));
      draftNotifier.setRisk(EmployeeApprovalCoverageRisk.high);
      draftNotifier.setReason('Cover approvals during promotion transition.');

      final draft =
          container.read(employeeApprovalDelegationDraftProvider('2'))!;
      expect(draft.isReadyToSubmit, isTrue);
      expect(draft.completionRatio, 1);

      final notifier = container.read(
        employeeApprovalCoverageProvider('2').notifier,
      );
      final delegation = notifier.submitDraft(draft);

      expect(delegation.id, 'EAC-2-003');
      expect(delegation.status, EmployeeApprovalCoverageStatus.pending);

      notifier.activate(delegation.id);
      var profile = container.read(employeeApprovalCoverageProvider('2'))!;

      expect(
        profile.delegations
            .singleWhere((item) => item.id == delegation.id)
            .status,
        EmployeeApprovalCoverageStatus.active,
      );

      notifier.block(delegation.id);
      profile = container.read(employeeApprovalCoverageProvider('2'))!;

      expect(profile.blockedCount, 1);
    },
  );

  test('employee approval coverage returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeeApprovalCoverageProvider('missing')), isNull);
    expect(
      container.read(employeeApprovalDelegationDraftProvider('missing')),
      isNull,
    );
  });
}

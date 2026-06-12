import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_reimbursement_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_reimbursement_provider.dart';

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

  test('employee reimbursement profile highlights expense follow-up work', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeReimbursementProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.missingReceiptCount, 1);
    expect(profile.submittedCount, 1);
    expect(profile.approvedCount, 1);
    expect(profile.lowAllowanceCount, 1);
    expect(profile.attentionCount, 4);
    expect(profile.nextAction, 'Attach 1 missing receipt.');
  });

  test('employee expense draft validates and reserves allowance', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeExpenseDraftProvider('3').notifier,
    );
    draftNotifier
      ..setMerchant('Grab')
      ..setAmount(150000)
      ..setDescription('Taxi ride to attend an HR workshop.');

    final draft = container.read(employeeExpenseDraftProvider('3'))!;
    expect(draft.isReadyToSubmit, isTrue);

    final profileNotifier = container.read(
      employeeReimbursementProfileProvider('3').notifier,
    );
    final claim = profileNotifier.submitDraft(draft);
    final profile = container.read(employeeReimbursementProfileProvider('3'))!;
    final travelAllowance =
        profile.allowanceFor(EmployeeExpenseCategory.travel)!;

    expect(claim.id, 'EEX-3-001');
    expect(claim.status, EmployeeExpenseClaimStatus.submitted);
    expect(profile.submittedCount, 1);
    expect(travelAllowance.pendingAmount, 150000);
  });

  test(
    'employee reimbursement actions attach approve and reimburse claims',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        employeeReimbursementProfileProvider('4').notifier,
      );

      notifier.attachReceipt('EEX-4-001');
      var profile = container.read(employeeReimbursementProfileProvider('4'))!;
      expect(profile.missingReceiptCount, 0);
      expect(profile.submittedCount, 1);

      notifier.approveClaim('EEX-4-001');
      profile = container.read(employeeReimbursementProfileProvider('4'))!;
      expect(profile.submittedCount, 0);
      expect(profile.approvedCount, 2);

      notifier.reimburseClaim('EEX-4-002');
      profile = container.read(employeeReimbursementProfileProvider('4'))!;
      final reimbursed = profile.claims.singleWhere(
        (claim) => claim.id == 'EEX-4-002',
      );

      expect(reimbursed.status, EmployeeExpenseClaimStatus.reimbursed);
      expect(profile.approvedCount, 1);
      expect(profile.attentionCount, 2);
    },
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_cutoff_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_cutoff_provider.dart';

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

  test('employee payroll cutoff aggregates cross-module blockers', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(
      employeePayrollCutoffReconciliationProvider('4'),
    );

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.blockingCount, 7);
    expect(profile.openWarningCount, 2);
    expect(profile.attentionCount, 9);
    expect(profile.stage, EmployeePayrollCutoffStage.resolvingExceptions);
    expect(profile.nextAction, 'Resolve 7 payroll cutoff blockers.');
    expect(
      profile.items.map((item) => item.id),
      containsAll([
        'payroll-bank',
        'payroll-tax',
        'timekeeping-payroll-blockers',
        'leave-blackout-conflicts',
      ]),
    );
  });

  test('employee payroll cutoff item actions progress readiness', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeePayrollCutoffReconciliationProvider('4').notifier,
    );

    notifier.reviewItem('payroll-bank');
    var item = container
        .read(employeePayrollCutoffReconciliationProvider('4'))!
        .items
        .singleWhere((entry) => entry.id == 'payroll-bank');
    expect(item.status, EmployeePayrollCutoffItemStatus.inReview);

    notifier.resolveItem('payroll-bank');
    item = container
        .read(employeePayrollCutoffReconciliationProvider('4'))!
        .items
        .singleWhere((entry) => entry.id == 'payroll-bank');
    expect(item.status, EmployeePayrollCutoffItemStatus.resolved);
    expect(
      container
          .read(employeePayrollCutoffReconciliationProvider('4'))!
          .blockingCount,
      6,
    );

    notifier.waiveItem('leave-pending-requests');
    item = container
        .read(employeePayrollCutoffReconciliationProvider('4'))!
        .items
        .singleWhere((entry) => entry.id == 'leave-pending-requests');
    expect(item.status, EmployeePayrollCutoffItemStatus.waived);
  });

  test('employee payroll cutoff signs off clean payroll period', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(
      employeePayrollCutoffReconciliationProvider('3'),
    );
    expect(profile, isNotNull);
    expect(profile!.blockingCount, 0);
    expect(profile.openWarningCount, 0);
    expect(profile.completionRatio, 1);
    expect(profile.stage, EmployeePayrollCutoffStage.readyForPayroll);

    final draftNotifier = container.read(
      employeePayrollCutoffSignoffDraftProvider('3').notifier,
    );
    draftNotifier.setNote('Payroll cutoff reviewed and ready for release.');

    final signoff = container
        .read(employeePayrollCutoffReconciliationProvider('3').notifier)
        .submitSignoff(
          container.read(employeePayrollCutoffSignoffDraftProvider('3'))!,
        );

    expect(signoff.id, 'PCS-3-20260530');
    final signedProfile =
        container.read(employeePayrollCutoffReconciliationProvider('3'))!;
    expect(signedProfile.signoff, isNotNull);
    expect(signedProfile.attentionCount, 0);
    expect(signedProfile.stage, EmployeePayrollCutoffStage.signedOff);
  });

  test('employee payroll cutoff returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeePayrollCutoffReconciliationProvider('missing')),
      isNull,
    );
    expect(
      container.read(employeePayrollCutoffSignoffDraftProvider('missing')),
      isNull,
    );
  });
}

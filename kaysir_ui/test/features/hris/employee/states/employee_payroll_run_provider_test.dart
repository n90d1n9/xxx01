import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_run_provider.dart';

import '../helpers/payroll_run_kickoff_test_helpers.dart';

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

  test('employee payroll run preview highlights blocked run export', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeePayrollRunProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.status, EmployeePayrollRunStatus.blocked);
    expect(profile.blockerCount, 14);
    expect(profile.payrollSetupIssueCount, 3);
    expect(profile.cutoffBlockerCount, 7);
    expect(profile.varianceApprovalCount, 6);
    expect(profile.holdLineCount, 7);
    expect(profile.pendingLineCount, 3);
    expect(profile.netPay, greaterThan(0));
    expect(profile.canReview, isFalse);
    expect(profile.nextAction, 'Clear 14 payroll run blockers.');
  });

  test('employee payroll run review and export workflow', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    var profile = container.read(employeePayrollRunProvider('3'));

    expect(profile, isNotNull);
    expect(profile!.status, EmployeePayrollRunStatus.draft);
    expect(profile.blockerCount, 0);
    expect(profile.grossEarnings, 26500000);
    expect(profile.deductions, 1325000);
    expect(profile.netPay, 25175000);
    expect(profile.canReview, isTrue);

    final draftNotifier = container.read(
      employeePayrollRunReviewDraftProvider('3').notifier,
    );
    draftNotifier
      ..setNote('Payroll run reviewed for export readiness.')
      ..setPayslipVisible(true);

    final notifier = container.read(employeePayrollRunProvider('3').notifier);
    notifier.markReviewed(
      container.read(employeePayrollRunReviewDraftProvider('3'))!,
    );

    profile = container.read(employeePayrollRunProvider('3'))!;
    expect(profile.status, EmployeePayrollRunStatus.ready);
    expect(profile.reviewNote, 'Payroll run reviewed for export readiness.');
    expect(profile.payslipVisible, isTrue);
    expect(profile.canExport, isTrue);

    notifier.exportRun('PAY-202606');
    profile = container.read(employeePayrollRunProvider('3'))!;
    expect(profile.status, EmployeePayrollRunStatus.exported);
    expect(profile.exportBatchId, 'PAY-202606');
    expect(profile.attentionCount, 0);
  });

  test('employee payroll run consumes directory launch reference', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    seedPayrollRunKickoffTestRecord(container);

    var profile = container.read(employeePayrollRunProvider('3'));

    expect(profile, isNotNull);
    expect(profile!.launchContext?.runReference, 'RUN-202605-001');
    expect(
      profile.launchContext?.sourceLabel,
      'PAY-202605-001 / 2026.05.30-001',
    );

    final draftNotifier = container.read(
      employeePayrollRunReviewDraftProvider('3').notifier,
    );
    draftNotifier.setNote('Payroll run reviewed after directory kickoff.');

    final notifier = container.read(employeePayrollRunProvider('3').notifier);
    notifier.markReviewed(
      container.read(employeePayrollRunReviewDraftProvider('3'))!,
    );
    notifier.exportRun('');

    profile = container.read(employeePayrollRunProvider('3'))!;
    expect(profile.status, EmployeePayrollRunStatus.exported);
    expect(profile.exportBatchId, 'RUN-202605-001');
    expect(profile.nextAction, 'Payroll run exported in RUN-202605-001.');
  });

  test('employee payroll run returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeePayrollRunProvider('missing')), isNull);
    expect(
      container.read(employeePayrollRunReviewDraftProvider('missing')),
      isNull,
    );
  });
}

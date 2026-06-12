import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_run_console_provider.dart';
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

  test('employee payroll run console waits for launched run', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final review = container.read(employeePayrollRunConsoleProvider);

    expect(review.hasActiveRun, isFalse);
    expect(review.statusLabel, 'No run');
    expect(review.employeeCount, 0);
    expect(review.nextAction, 'Launch payroll run after import validation.');
  });

  test('employee payroll run console summarizes launched coverage', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    seedPayrollRunKickoffTestRecord(container);

    final review = container.read(employeePayrollRunConsoleProvider);

    expect(review.hasActiveRun, isTrue);
    expect(review.activeRun?.runReference, 'RUN-202605-001');
    expect(review.employeeCount, 5);
    expect(review.exportedCount, 0);
    expect(review.exportedLabel, '0/5 exported');
    expect(review.closeLabel, '0/5 closed');
    expect(review.statusLabel, 'Launched');
    expect(review.nextAction, 'Export 5 employee payroll runs.');
    expect(
      review.rows.map((row) => row.employeeName),
      contains('Emma Rodriguez'),
    );
  });

  test('employee payroll run console reacts to employee export', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    seedPayrollRunKickoffTestRecord(container);

    final draftNotifier = container.read(
      employeePayrollRunReviewDraftProvider('3').notifier,
    );
    draftNotifier
      ..setNote('Payroll run reviewed from console coverage.')
      ..setPayslipVisible(true);

    final runNotifier = container.read(
      employeePayrollRunProvider('3').notifier,
    );
    runNotifier.markReviewed(
      container.read(employeePayrollRunReviewDraftProvider('3'))!,
    );
    runNotifier.exportRun('');

    final review = container.read(employeePayrollRunConsoleProvider);
    final rafi = review.rows.singleWhere((row) => row.employeeId == '3');

    expect(review.exportedCount, 1);
    expect(review.exportedLabel, '1/5 exported');
    expect(review.paymentLabel, '0/5 paid');
    expect(rafi.exportBatchId, 'RUN-202605-001');
    expect(rafi.stageLabel, 'Exported');
    expect(rafi.nextAction, 'Settle payroll payment before period close.');
  });
}

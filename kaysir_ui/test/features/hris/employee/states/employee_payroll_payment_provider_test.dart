import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_payment_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_payment_provider.dart';
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

  void exportCleanPayrollRun(
    ProviderContainer container, {
    String batchId = 'PAY-202606',
  }) {
    final draftNotifier = container.read(
      employeePayrollRunReviewDraftProvider('3').notifier,
    );
    draftNotifier.setNote('Payroll run reviewed for payment release.');

    final runNotifier = container.read(
      employeePayrollRunProvider('3').notifier,
    );
    runNotifier.markReviewed(
      container.read(employeePayrollRunReviewDraftProvider('3'))!,
    );
    runNotifier.exportRun(batchId);
  }

  test('employee payroll payment blocks before payroll run export', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeePayrollPaymentProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.status, EmployeePayrollPaymentStatus.blocked);
    expect(profile.runStatus, EmployeePayrollRunStatus.blocked);
    expect(profile.blockingCount, 2);
    expect(profile.canSchedule, isFalse);
    expect(profile.nextAction, 'Export payroll run before payment scheduling.');
  });

  test('employee payroll payment schedules and settles exported run', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    exportCleanPayrollRun(container);

    var profile = container.read(employeePayrollPaymentProvider('3'));

    expect(profile, isNotNull);
    expect(profile!.status, EmployeePayrollPaymentStatus.ready);
    expect(profile.exportBatchId, 'PAY-202606');
    expect(profile.netPay, 25175000);
    expect(profile.canSchedule, isTrue);

    final draftNotifier = container.read(
      employeePayrollPaymentDraftProvider('3').notifier,
    );
    draftNotifier.setNote('Payment file reviewed for bank settlement.');

    final notifier = container.read(
      employeePayrollPaymentProvider('3').notifier,
    );
    notifier.schedule(
      container.read(employeePayrollPaymentDraftProvider('3'))!,
    );

    profile = container.read(employeePayrollPaymentProvider('3'))!;
    expect(profile.status, EmployeePayrollPaymentStatus.scheduled);
    expect(profile.paymentReference, 'PAYMENT-202606');
    expect(profile.scheduledInstructionCount, 1);
    expect(profile.canMarkPaid, isTrue);

    notifier.markPaid();
    profile = container.read(employeePayrollPaymentProvider('3'))!;
    expect(profile.status, EmployeePayrollPaymentStatus.paid);
    expect(profile.settledInstructionCount, 1);
    expect(profile.attentionCount, 0);
  });

  test('employee payroll payment inherits directory launch reference', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    seedPayrollRunKickoffTestRecord(container);
    exportCleanPayrollRun(container, batchId: '');

    final profile = container.read(employeePayrollPaymentProvider('3'));

    expect(profile, isNotNull);
    expect(profile!.status, EmployeePayrollPaymentStatus.ready);
    expect(profile.exportBatchId, 'RUN-202605-001');
    expect(profile.nextAction, 'Schedule net pay disbursement.');
  });

  test('employee payroll payment can hold and reopen ready instruction', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    exportCleanPayrollRun(container);

    final notifier = container.read(
      employeePayrollPaymentProvider('3').notifier,
    );
    notifier.hold();

    var profile = container.read(employeePayrollPaymentProvider('3'))!;
    expect(profile.status, EmployeePayrollPaymentStatus.held);
    expect(profile.attentionCount, 1);

    notifier.reopen();
    profile = container.read(employeePayrollPaymentProvider('3'))!;
    expect(profile.status, EmployeePayrollPaymentStatus.ready);
    expect(profile.canSchedule, isTrue);
  });

  test('employee payroll payment returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeePayrollPaymentProvider('missing')), isNull);
    expect(
      container.read(employeePayrollPaymentDraftProvider('missing')),
      isNull,
    );
  });
}

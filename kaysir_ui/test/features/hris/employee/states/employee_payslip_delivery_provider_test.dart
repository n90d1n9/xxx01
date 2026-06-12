import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payslip_delivery_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payslip_delivery_provider.dart';
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
    draftNotifier
      ..setNote('Payroll run reviewed for payslip delivery.')
      ..setPayslipVisible(true);

    final runNotifier = container.read(
      employeePayrollRunProvider('3').notifier,
    );
    runNotifier.markReviewed(
      container.read(employeePayrollRunReviewDraftProvider('3'))!,
    );
    runNotifier.exportRun(batchId);
  }

  test('employee payslip delivery blocks before payroll run export', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeePayslipDeliveryProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.status, EmployeePayslipDeliveryStatus.blocked);
    expect(profile.runStatus, EmployeePayrollRunStatus.blocked);
    expect(profile.blockingCount, 1);
    expect(profile.canRelease, isFalse);
    expect(profile.nextAction, 'Export payroll run before payslip delivery.');
  });

  test('employee payslip delivery releases exported payslip', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    exportCleanPayrollRun(container);

    var profile = container.read(employeePayslipDeliveryProvider('3'));

    expect(profile, isNotNull);
    expect(profile!.status, EmployeePayslipDeliveryStatus.ready);
    expect(profile.exportBatchId, 'PAY-202606');
    expect(profile.netPay, 25175000);
    expect(profile.queuedChannelCount, 3);
    expect(profile.canRelease, isTrue);

    final draftNotifier = container.read(
      employeePayslipReleaseDraftProvider('3').notifier,
    );
    draftNotifier.setNote('Payslip release approved for employee portal.');

    final notifier = container.read(
      employeePayslipDeliveryProvider('3').notifier,
    );
    notifier.release(container.read(employeePayslipReleaseDraftProvider('3'))!);

    profile = container.read(employeePayslipDeliveryProvider('3'))!;
    expect(profile.status, EmployeePayslipDeliveryStatus.published);
    expect(
      profile.releaseNote,
      'Payslip release approved for employee portal.',
    );
    expect(profile.deliveredChannelCount, 3);
    expect(profile.attentionCount, 0);
  });

  test('employee payslip delivery inherits directory launch reference', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    seedPayrollRunKickoffTestRecord(container);
    exportCleanPayrollRun(container, batchId: '');

    final profile = container.read(employeePayslipDeliveryProvider('3'));

    expect(profile, isNotNull);
    expect(profile!.status, EmployeePayslipDeliveryStatus.ready);
    expect(profile.exportBatchId, 'RUN-202605-001');
    expect(profile.nextAction, 'Release payslip to employee self-service.');
  });

  test('employee payslip delivery can suppress and reopen ready payslip', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    exportCleanPayrollRun(container);

    final notifier = container.read(
      employeePayslipDeliveryProvider('3').notifier,
    );
    notifier.suppress();

    var profile = container.read(employeePayslipDeliveryProvider('3'))!;
    expect(profile.status, EmployeePayslipDeliveryStatus.suppressed);
    expect(profile.attentionCount, 1);

    notifier.reopen();
    profile = container.read(employeePayslipDeliveryProvider('3'))!;
    expect(profile.status, EmployeePayslipDeliveryStatus.ready);
    expect(profile.canRelease, isTrue);
  });

  test('employee payslip delivery returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeePayslipDeliveryProvider('missing')), isNull);
    expect(
      container.read(employeePayslipReleaseDraftProvider('missing')),
      isNull,
    );
  });
}

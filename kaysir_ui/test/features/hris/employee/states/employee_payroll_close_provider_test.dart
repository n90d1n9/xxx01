import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_close_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payslip_delivery_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_close_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_payment_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_run_provider.dart';

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

  void prepareReadyClose(ProviderContainer container) {
    final runDraftNotifier = container.read(
      employeePayrollRunReviewDraftProvider('3').notifier,
    );
    runDraftNotifier
      ..setNote('Payroll run reviewed for period close.')
      ..setPayslipVisible(true);

    final runNotifier = container.read(
      employeePayrollRunProvider('3').notifier,
    );
    runNotifier.markReviewed(
      container.read(employeePayrollRunReviewDraftProvider('3'))!,
    );
    runNotifier.exportRun('PAY-202606');

    final paymentDraftNotifier = container.read(
      employeePayrollPaymentDraftProvider('3').notifier,
    );
    paymentDraftNotifier.setNote('Payment file reviewed for settlement.');
    final paymentNotifier = container.read(
      employeePayrollPaymentProvider('3').notifier,
    );
    paymentNotifier.schedule(
      container.read(employeePayrollPaymentDraftProvider('3'))!,
    );
    paymentNotifier.markPaid();

    final releaseDraftNotifier = container.read(
      employeePayslipReleaseDraftProvider('3').notifier,
    );
    releaseDraftNotifier.setNote('Payslip released before payroll close.');
    container
        .read(employeePayslipDeliveryProvider('3').notifier)
        .release(container.read(employeePayslipReleaseDraftProvider('3'))!);
  }

  test(
    'employee payroll close blocks until run payment and payslip are final',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final profile = container.read(employeePayrollCloseProvider('4'));

      expect(profile, isNotNull);
      expect(profile!.employeeName, 'David Kim');
      expect(profile.status, EmployeePayrollCloseStatus.blocked);
      expect(profile.blockingCount, 3);
      expect(profile.canPost, isFalse);
      expect(profile.nextAction, 'Export payroll run before period close.');
    },
  );

  test('employee payroll close posts balanced journal and closes period', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    prepareReadyClose(container);

    var profile = container.read(employeePayrollCloseProvider('3'));

    expect(profile, isNotNull);
    expect(profile!.status, EmployeePayrollCloseStatus.ready);
    expect(profile.isBalanced, isTrue);
    expect(profile.totalDebits, 27560000);
    expect(profile.totalCredits, 27560000);
    expect(profile.journalLines.length, 5);
    expect(profile.canPost, isTrue);

    final draftNotifier = container.read(
      employeePayrollCloseDraftProvider('3').notifier,
    );
    draftNotifier.setNote('Accounting handoff reviewed for payroll close.');

    final notifier = container.read(employeePayrollCloseProvider('3').notifier);
    notifier.postJournal(
      container.read(employeePayrollCloseDraftProvider('3'))!,
    );

    profile = container.read(employeePayrollCloseProvider('3'))!;
    expect(profile.status, EmployeePayrollCloseStatus.posted);
    expect(profile.journalBatchId, 'JRN-202606');
    expect(profile.canClose, isTrue);
    expect(
      profile.journalLines.every(
        (line) => line.status == EmployeePayrollJournalLineStatus.posted,
      ),
      isTrue,
    );

    notifier.closePeriod();
    profile = container.read(employeePayrollCloseProvider('3'))!;
    expect(profile.status, EmployeePayrollCloseStatus.closed);
    expect(profile.attentionCount, 0);
  });

  test('employee payroll close returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(container.read(employeePayrollCloseProvider('missing')), isNull);
    expect(
      container.read(employeePayrollCloseDraftProvider('missing')),
      isNull,
    );
  });
}

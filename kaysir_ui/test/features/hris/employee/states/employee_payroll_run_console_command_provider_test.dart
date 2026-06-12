import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_close_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_payment_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_command_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payslip_delivery_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_close_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_payment_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_run_console_audit_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_run_console_command_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_run_console_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payroll_run_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_payslip_delivery_provider.dart';

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

  test('payroll run console command waits for launched run', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final result = container
        .read(employeePayrollRunConsoleCommandControllerProvider)
        .run(EmployeePayrollRunConsoleCommandType.prepareExport);

    expect(result.completedCount, 0);
    expect(
      result.message,
      'Launch payroll run before running console actions.',
    );
    expect(
      container.read(employeePayrollRunConsoleCommandResultProvider),
      result,
    );
    expect(container.read(employeePayrollRunConsoleAuditProvider), isEmpty);
  });

  test('payroll run console command plan exposes eligible operations', () {
    final container = buildContainer();
    addTearDown(container.dispose);
    seedPayrollRunKickoffTestRecord(container);

    final plan = EmployeePayrollRunConsoleCommandPlan.fromReview(
      container.read(employeePayrollRunConsoleProvider),
    );
    final exportCommand = plan.commands.singleWhere(
      (command) =>
          command.type == EmployeePayrollRunConsoleCommandType.prepareExport,
    );

    expect(
      plan.primaryCommand?.type,
      EmployeePayrollRunConsoleCommandType.prepareExport,
    );
    expect(exportCommand.eligibleCount, 1);
    expect(exportCommand.blockedCount, 4);
    expect(exportCommand.readinessLabel, '1 ready');
    expect(plan.scopeLabel, 'All 5 run employees');
  });

  test('payroll run console command plan scopes to selected employees', () {
    final container = buildContainer();
    addTearDown(container.dispose);
    seedPayrollRunKickoffTestRecord(container);

    final plan = EmployeePayrollRunConsoleCommandPlan.fromReview(
      container.read(employeePayrollRunConsoleProvider),
      targetEmployeeIds: const {'3'},
    );
    final exportCommand = plan.commands.singleWhere(
      (command) =>
          command.type == EmployeePayrollRunConsoleCommandType.prepareExport,
    );

    expect(plan.isSelectionScoped, isTrue);
    expect(plan.scopeLabel, '1 selected in run');
    expect(
      plan.scopeDescription,
      'Commands apply only to the selected employee cohort.',
    );
    expect(exportCommand.eligibleCount, 1);
    expect(exportCommand.blockedCount, 0);
  });

  test('payroll run console commands advance eligible employee lifecycle', () {
    final container = buildContainer();
    addTearDown(container.dispose);
    seedPayrollRunKickoffTestRecord(container);

    final controller = container.read(
      employeePayrollRunConsoleCommandControllerProvider,
    );

    final exportResult = controller.run(
      EmployeePayrollRunConsoleCommandType.prepareExport,
    );
    expect(exportResult.completedCount, 1);
    expect(exportResult.skippedCount, 4);
    expect(
      exportResult.message,
      '1 employee prepared and exported, 4 skipped.',
    );
    expect(
      container.read(employeePayrollRunProvider('3'))!.status,
      EmployeePayrollRunStatus.exported,
    );
    expect(
      container.read(employeePayrollRunProvider('4'))!.status,
      EmployeePayrollRunStatus.blocked,
    );

    final paymentResult = controller.run(
      EmployeePayrollRunConsoleCommandType.settlePayment,
    );
    expect(paymentResult.completedCount, 1);
    expect(paymentResult.message, '1 employee settled, 4 skipped.');
    expect(
      container.read(employeePayrollPaymentProvider('3'))!.status,
      EmployeePayrollPaymentStatus.paid,
    );

    final payslipResult = controller.run(
      EmployeePayrollRunConsoleCommandType.publishPayslip,
    );
    expect(payslipResult.completedCount, 1);
    expect(payslipResult.message, '1 employee published, 4 skipped.');
    expect(
      container.read(employeePayslipDeliveryProvider('3'))!.status,
      EmployeePayslipDeliveryStatus.published,
    );

    final closeResult = controller.run(
      EmployeePayrollRunConsoleCommandType.closePeriod,
    );
    expect(closeResult.completedCount, 1);
    expect(closeResult.message, '1 employee closed, 4 skipped.');
    expect(
      container.read(employeePayrollCloseProvider('3'))!.status,
      EmployeePayrollCloseStatus.closed,
    );

    final review = container.read(employeePayrollRunConsoleProvider);
    expect(review.exportedCount, 1);
    expect(review.paidCount, 1);
    expect(review.payslipPublishedCount, 1);
    expect(review.closedCount, 1);
    expect(
      container.read(employeePayrollRunConsoleAuditProvider),
      hasLength(4),
    );
  });

  test('payroll run console commands only mutate selected employees', () {
    final container = buildContainer();
    addTearDown(container.dispose);
    seedPayrollRunKickoffTestRecord(container);

    final result = container
        .read(employeePayrollRunConsoleCommandControllerProvider)
        .run(
          EmployeePayrollRunConsoleCommandType.prepareExport,
          targetEmployeeIds: const {'3'},
        );

    expect(result.completedCount, 1);
    expect(result.skippedCount, 0);
    expect(result.message, '1 employee prepared and exported.');
    expect(
      container.read(employeePayrollRunProvider('3'))!.status,
      EmployeePayrollRunStatus.exported,
    );
    expect(
      container.read(employeePayrollRunProvider('4'))!.status,
      EmployeePayrollRunStatus.blocked,
    );

    final event = container.read(employeePayrollRunConsoleAuditProvider).single;
    expect(event.runReference, 'RUN-202605-001');
    expect(event.scopeLabel, '1 selected in run');
    expect(event.operatorName, 'Payroll Lead');
    expect(event.targetEmployeeCount, 1);
    expect(event.completedCount, 1);
    expect(event.skippedCount, 0);
    expect(event.status, EmployeePayrollRunConsoleAuditStatus.completed);
    expect(event.occurredAt, DateTime(2026, 5, 30));
  });

  test('payroll run console command reports uncovered selection', () {
    final container = buildContainer();
    addTearDown(container.dispose);
    seedPayrollRunKickoffTestRecord(container);

    final result = container
        .read(employeePayrollRunConsoleCommandControllerProvider)
        .run(
          EmployeePayrollRunConsoleCommandType.prepareExport,
          targetEmployeeIds: const {'missing'},
        );

    expect(result.completedCount, 0);
    expect(result.skippedCount, 0);
    expect(
      result.message,
      'Prepare export has no selected employees in this payroll run.',
    );

    final event = container.read(employeePayrollRunConsoleAuditProvider).single;
    expect(event.scopeLabel, '1 selected, none in this run');
    expect(event.targetEmployeeCount, 0);
    expect(event.completedCount, 0);
    expect(event.status, EmployeePayrollRunConsoleAuditStatus.noChange);
  });
}

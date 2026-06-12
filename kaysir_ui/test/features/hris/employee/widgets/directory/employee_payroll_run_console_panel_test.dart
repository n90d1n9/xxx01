import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_close_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_payment_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_command_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payslip_delivery_models.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_run_console_panel.dart';

import '../../helpers/payroll_run_kickoff_test_helpers.dart';

void main() {
  testWidgets('employee payroll run console renders coverage table', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeePayrollRunConsolePanel(review: _review()),
          ),
        ),
      ),
    );

    expect(find.text('Payroll run console'), findsOneWidget);
    expect(find.text('RUN-202605-001'), findsWidgets);
    expect(find.text('1/2 exported'), findsOneWidget);
    expect(find.text('Guided payroll actions'), findsOneWidget);
    expect(find.text('All 2 run employees'), findsOneWidget);
    expect(find.text('Operation audit timeline'), findsOneWidget);
    expect(find.text('No payroll console events yet.'), findsOneWidget);
    expect(find.text('Settle pay'), findsWidgets);
    expect(find.text('1 ready'), findsWidgets);
    expect(find.text('Sarah Johnson'), findsOneWidget);
    expect(find.text('Maya Santoso'), findsOneWidget);
    expect(find.text('Payment scheduled'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
  });

  testWidgets('employee payroll run console dispatches guided command', (
    tester,
  ) async {
    EmployeePayrollRunConsoleCommandType? selectedCommand;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeePayrollRunConsolePanel(
              review: _review(),
              targetEmployeeIds: const {'1'},
              onRunCommand: (type) => selectedCommand = type,
            ),
          ),
        ),
      ),
    );

    expect(find.text('1 selected in run'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('employee-payroll-run-console-command-settlePayment'),
      ),
    );
    await tester.pump();

    expect(selectedCommand, EmployeePayrollRunConsoleCommandType.settlePayment);
  });

  testWidgets('employee payroll run console renders audit events', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeePayrollRunConsolePanel(
              review: _review(),
              auditEvents: [_auditEvent()],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Operation audit timeline'), findsOneWidget);
    expect(find.text('1 event'), findsOneWidget);
    expect(find.text('1 employee settled.'), findsOneWidget);
    expect(find.text('1 selected in run'), findsOneWidget);
    expect(find.text('Payroll Lead'), findsWidgets);
  });
}

EmployeePayrollRunConsoleReview _review() {
  return EmployeePayrollRunConsoleReview(
    records: [buildPayrollRunKickoffTestRecord(loadedProfileCount: 2)],
    rows: const [
      EmployeePayrollRunConsoleEmployeeRow(
        employeeId: '1',
        employeeName: 'Sarah Johnson',
        runStatus: EmployeePayrollRunStatus.exported,
        paymentStatus: EmployeePayrollPaymentStatus.scheduled,
        payslipStatus: EmployeePayslipDeliveryStatus.ready,
        closeStatus: EmployeePayrollCloseStatus.blocked,
        exportBatchId: 'RUN-202605-001',
        paymentReference: 'PAYMENT-202605',
        nextAction: 'Confirm payroll payment settlement.',
        netPay: 25175000,
        currencyCode: 'IDR',
        attentionCount: 1,
      ),
      EmployeePayrollRunConsoleEmployeeRow(
        employeeId: '2',
        employeeName: 'Maya Santoso',
        runStatus: EmployeePayrollRunStatus.blocked,
        paymentStatus: EmployeePayrollPaymentStatus.blocked,
        payslipStatus: EmployeePayslipDeliveryStatus.blocked,
        closeStatus: EmployeePayrollCloseStatus.blocked,
        exportBatchId: '',
        paymentReference: '',
        nextAction: 'Clear payroll run blockers.',
        netPay: 18000000,
        currencyCode: 'IDR',
        attentionCount: 4,
      ),
    ],
  );
}

EmployeePayrollRunConsoleAuditEvent _auditEvent() {
  return EmployeePayrollRunConsoleAuditEvent(
    id: 'payroll-console-audit-1',
    runReference: 'RUN-202605-001',
    commandType: EmployeePayrollRunConsoleCommandType.settlePayment,
    scopeLabel: '1 selected in run',
    operatorName: 'Payroll Lead',
    occurredAt: DateTime(2026, 5, 30, 9, 30),
    targetEmployeeCount: 1,
    completedCount: 1,
    skippedCount: 0,
    errors: const [],
    message: '1 employee settled.',
  );
}

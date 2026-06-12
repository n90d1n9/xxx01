import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_access_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_decision_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_package_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_command_models.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_run_console_audit_handoff_panel.dart';

void main() {
  testWidgets('payroll audit handoff submits and approves ready package', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeePayrollRunConsoleAuditHandoffPanel(
              package: _readyPackage(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Payroll close handoff'), findsOneWidget);
    expect(find.text('Needs detail'), findsOneWidget);

    await tester.enterText(
      find.byKey(
        const ValueKey('employee-payroll-audit-handoff-reviewer-field'),
      ),
      'Alya Rahman',
    );
    await tester.enterText(
      find.byKey(
        const ValueKey('employee-payroll-audit-handoff-approver-field'),
      ),
      'Rafi Pratama',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-payroll-audit-handoff-note-field')),
      'Reviewed payroll evidence before handoff.',
    );
    await tester.pumpAndSettle();

    final submit = find.byKey(
      const ValueKey('employee-payroll-audit-handoff-submit-button'),
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('Payroll handoff submitted'), findsOneWidget);
    expect(find.text('Submitted'), findsWidgets);
    expect(
      find.text('5/5 package checks, 4/4 command stages.'),
      findsOneWidget,
    );

    final approve = find.byKey(
      const ValueKey('employee-payroll-audit-decision-approve-button'),
    );
    await tester.ensureVisible(approve);
    expect(tester.widget<FilledButton>(approve).onPressed, isNull);

    await _selectAllDecisionAttestations(tester);
    expect(tester.widget<FilledButton>(approve).onPressed, isNotNull);
    await tester.tap(approve);
    await tester.pumpAndSettle();

    expect(find.text('Approved'), findsWidgets);
    expect(
      find.text('Approved by Rafi Pratama for payroll close archive.'),
      findsOneWidget,
    );
    expect(find.text('Close approval receipt'), findsOneWidget);
    expect(find.text('3/3 controls'), findsOneWidget);
    expect(find.text('5/5 package, 4/4 commands'), findsOneWidget);
    expect(find.text('Evidence reviewed'), findsOneWidget);
  });

  testWidgets('payroll audit handoff blocks submit for approver role', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeePayrollRunConsoleAuditHandoffPanel(
              package: _readyPackage(),
              role: EmployeePayrollRunConsoleAuditRole.payrollApprover,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(
        const ValueKey('employee-payroll-audit-handoff-reviewer-field'),
      ),
      'Alya Rahman',
    );
    await tester.enterText(
      find.byKey(
        const ValueKey('employee-payroll-audit-handoff-approver-field'),
      ),
      'Rafi Pratama',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-payroll-audit-handoff-note-field')),
      'Reviewed payroll evidence before handoff.',
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Switch to payroll reviewer to submit payroll close handoffs.'),
      findsWidgets,
    );

    final submit = find.byKey(
      const ValueKey('employee-payroll-audit-handoff-submit-button'),
    );
    await tester.ensureVisible(submit);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
  });

  testWidgets('payroll audit handoff returns with decision note', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeePayrollRunConsoleAuditHandoffPanel(
              package: _readyPackage(),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(
        const ValueKey('employee-payroll-audit-handoff-reviewer-field'),
      ),
      'Alya Rahman',
    );
    await tester.enterText(
      find.byKey(
        const ValueKey('employee-payroll-audit-handoff-approver-field'),
      ),
      'Rafi Pratama',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-payroll-audit-handoff-note-field')),
      'Reviewed payroll evidence before handoff.',
    );
    await tester.pumpAndSettle();

    final submit = find.byKey(
      const ValueKey('employee-payroll-audit-handoff-submit-button'),
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    final returnButton = find.byKey(
      const ValueKey('employee-payroll-audit-decision-return-button'),
    );
    await tester.ensureVisible(returnButton);
    expect(tester.widget<OutlinedButton>(returnButton).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('employee-payroll-audit-decision-note-field')),
      'Refresh bank proof before archive.',
    );
    await tester.pumpAndSettle();

    expect(tester.widget<OutlinedButton>(returnButton).onPressed, isNotNull);
    await tester.tap(returnButton);
    await tester.pumpAndSettle();

    expect(find.text('Returned'), findsWidgets);
    expect(
      find.text('Returned by Rafi Pratama: Refresh bank proof before archive.'),
      findsOneWidget,
    );
    expect(find.text('Returned evidence receipt'), findsOneWidget);
    expect(find.text('Return note captured'), findsOneWidget);
  });
}

Future<void> _selectAllDecisionAttestations(WidgetTester tester) async {
  for (final attestation
      in EmployeePayrollRunConsoleAuditDecisionAttestation.values) {
    final checkbox = find.byKey(
      ValueKey(
        'employee-payroll-audit-decision-attestation-${attestation.name}',
      ),
    );
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();
  }
}

EmployeePayrollRunConsoleAuditEvidencePackage _readyPackage() {
  return EmployeePayrollRunConsoleAuditEvidencePackage(
    report: EmployeePayrollRunConsoleAuditEvidenceReport(
      summary: EmployeePayrollRunConsoleAuditSummary(
        events: [
          _event(
            id: 'prepare',
            type: EmployeePayrollRunConsoleCommandType.prepareExport,
            completedCount: 2,
          ),
          _event(
            id: 'settle',
            type: EmployeePayrollRunConsoleCommandType.settlePayment,
            completedCount: 2,
          ),
          _event(
            id: 'publish',
            type: EmployeePayrollRunConsoleCommandType.publishPayslip,
            completedCount: 2,
          ),
          _event(
            id: 'close',
            type: EmployeePayrollRunConsoleCommandType.closePeriod,
            completedCount: 1,
          ),
        ],
      ),
    ),
  );
}

EmployeePayrollRunConsoleAuditEvent _event({
  required String id,
  required EmployeePayrollRunConsoleCommandType type,
  required int completedCount,
}) {
  return EmployeePayrollRunConsoleAuditEvent(
    id: id,
    runReference: 'RUN-202605-001',
    commandType: type,
    scopeLabel: 'All 5 run employees',
    operatorName: 'Payroll Lead',
    occurredAt: DateTime(2026, 5, 30, 9, 30),
    targetEmployeeCount: completedCount,
    completedCount: completedCount,
    skippedCount: 0,
    errors: const [],
    message: '${type.label} audit evidence captured.',
  );
}

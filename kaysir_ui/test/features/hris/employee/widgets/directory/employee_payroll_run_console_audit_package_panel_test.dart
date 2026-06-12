import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_decision_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_package_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_command_models.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_run_console_audit_package_panel.dart';

void main() {
  testWidgets('payroll audit package role guidance follows handoff state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeePayrollRunConsoleAuditPackagePanel(
              package: _readyPackage(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Audit role controls'), findsOneWidget);
    expect(find.text('Complete handoff inputs'), findsOneWidget);
    expect(find.text('Reviewer is required.'), findsWidgets);

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

    expect(find.text('Submit close handoff'), findsOneWidget);
    expect(
      find.text('The handoff is complete and ready for approver review.'),
      findsOneWidget,
    );

    final submit = find.byKey(
      const ValueKey('employee-payroll-audit-handoff-submit-button'),
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    final roleSelector = find.byKey(
      const ValueKey('employee-payroll-audit-role-selector'),
    );
    await tester.ensureVisible(roleSelector);
    await tester.tap(
      find.descendant(of: roleSelector, matching: find.text('Approver')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Decide submitted handoff'), findsOneWidget);
    expect(
      find.text(
        'Approve the payroll close evidence or return it for revision.',
      ),
      findsOneWidget,
    );

    final approve = find.widgetWithText(FilledButton, 'Approve');
    await tester.ensureVisible(approve);
    expect(tester.widget<FilledButton>(approve).onPressed, isNull);

    await _selectAllDecisionAttestations(tester);
    expect(tester.widget<FilledButton>(approve).onPressed, isNotNull);
    await tester.tap(approve);
    await tester.pumpAndSettle();

    expect(find.text('Payroll close archive pack'), findsOneWidget);
    expect(find.text('Archive ready'), findsWidgets);
    expect(find.text('Archive pack ready for retention.'), findsOneWidget);
    expect(find.text('3/3 controls'), findsWidgets);

    final archiveButton = find.byKey(
      const ValueKey('employee-payroll-audit-archive-button'),
    );
    await tester.ensureVisible(archiveButton);
    expect(tester.widget<FilledButton>(archiveButton).onPressed, isNotNull);
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

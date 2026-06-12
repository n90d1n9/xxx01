import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_access_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_export_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_handoff_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_package_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_command_models.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_run_console_audit_access_panel.dart';

void main() {
  testWidgets('payroll audit access panel switches active role', (
    tester,
  ) async {
    var role = EmployeePayrollRunConsoleAuditRole.payrollReviewer;
    final package = _readyPackage();
    final handoffReview = _readyHandoffReview(package);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: EmployeePayrollRunConsoleAuditAccessPanel(
                  review: EmployeePayrollRunConsoleAuditAccessReview(
                    role: role,
                    exportPreview: EmployeePayrollRunConsoleAuditExportPreview(
                      package: package,
                      generatedAt: DateTime(2026, 6, 1, 12),
                    ),
                    handoffReview: handoffReview,
                  ),
                  onRoleChanged:
                      (value) => setState(() {
                        role = value;
                      }),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Audit role controls'), findsOneWidget);
    expect(
      find.text('Validates evidence and submits the close handoff.'),
      findsOneWidget,
    );
    expect(find.text('Submit close handoff'), findsOneWidget);
    expect(
      find.text('The handoff is complete and ready for approver review.'),
      findsOneWidget,
    );
    expect(
      find.text('Payroll reviewer can submit the complete close handoff.'),
      findsOneWidget,
    );
    expect(
      find.text('Switch to payroll officer to copy audit exports.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Approver'));
    await tester.pumpAndSettle();

    expect(role, EmployeePayrollRunConsoleAuditRole.payrollApprover);
    expect(
      find.text('Approves or returns submitted close handoffs.'),
      findsOneWidget,
    );
    expect(find.text('Wait for handoff submission'), findsOneWidget);
    expect(
      find.text('Switch to payroll reviewer to submit payroll close handoffs.'),
      findsOneWidget,
    );
  });
}

EmployeePayrollRunConsoleAuditEvidencePackage _readyPackage() {
  return EmployeePayrollRunConsoleAuditEvidencePackage(
    report: EmployeePayrollRunConsoleAuditEvidenceReport(
      summary: EmployeePayrollRunConsoleAuditSummary(
        events: [
          _event(
            id: 'prepare',
            type: EmployeePayrollRunConsoleCommandType.prepareExport,
          ),
          _event(
            id: 'settle',
            type: EmployeePayrollRunConsoleCommandType.settlePayment,
          ),
          _event(
            id: 'publish',
            type: EmployeePayrollRunConsoleCommandType.publishPayslip,
          ),
          _event(
            id: 'close',
            type: EmployeePayrollRunConsoleCommandType.closePeriod,
          ),
        ],
      ),
    ),
  );
}

EmployeePayrollRunConsoleAuditHandoffReview _readyHandoffReview(
  EmployeePayrollRunConsoleAuditEvidencePackage package,
) {
  return EmployeePayrollRunConsoleAuditHandoffReview.fromState(
    package: package,
    draft: EmployeePayrollRunConsoleAuditHandoffDraft(
      reviewer: 'Alya Rahman',
      approver: 'Rafi Pratama',
      dueDate: DateTime(2026, 6, 1),
      note: 'Reviewed payroll evidence before handoff.',
    ),
    handoffs: const [],
  );
}

EmployeePayrollRunConsoleAuditEvent _event({
  required String id,
  required EmployeePayrollRunConsoleCommandType type,
}) {
  return EmployeePayrollRunConsoleAuditEvent(
    id: id,
    runReference: 'RUN-202605-001',
    commandType: type,
    scopeLabel: 'All 5 run employees',
    operatorName: 'Payroll Lead',
    occurredAt: DateTime(2026, 5, 30, 9, 30),
    targetEmployeeCount: 3,
    completedCount: 3,
    skippedCount: 0,
    errors: const [],
    message: '${type.label} audit evidence captured.',
  );
}

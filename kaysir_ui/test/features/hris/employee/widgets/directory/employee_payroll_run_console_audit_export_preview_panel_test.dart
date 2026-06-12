import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_access_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_package_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_command_models.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_run_console_audit_export_preview_panel.dart';

void main() {
  testWidgets('payroll audit export preview renders csv package', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeePayrollRunConsoleAuditExportPreviewPanel(
              package: _readyPackage(),
              generatedAt: DateTime(2026, 6, 1, 12),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Audit export preview'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Export preview ready'), findsOneWidget);
    expect(find.text('CSV sample'), findsOneWidget);
    expect(
      find.text(
        'event_id,run_reference,command,status,operator,occurred_at,scope,target_count,completed_count,skipped_count,errors,message',
      ),
      findsOneWidget,
    );
    expect(
      find.text('pkg-run-202605-001-04-audit-events.csv - 4 audit events'),
      findsOneWidget,
    );
    expect(find.text('1 more rows included'), findsOneWidget);

    final copyButton = find.byKey(
      const ValueKey('employee-payroll-audit-export-copy-csv-button'),
    );
    await tester.ensureVisible(copyButton);
    expect(tester.widget<FilledButton>(copyButton).onPressed, isNotNull);
  });

  testWidgets('payroll audit export preview disables copy for auditor role', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeePayrollRunConsoleAuditExportPreviewPanel(
              package: _readyPackage(),
              generatedAt: DateTime(2026, 6, 1, 12),
              role: EmployeePayrollRunConsoleAuditRole.auditor,
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Auditor can review evidence but cannot copy audit exports.'),
      findsOneWidget,
    );

    final copyButton = find.byKey(
      const ValueKey('employee-payroll-audit-export-copy-csv-button'),
    );
    await tester.ensureVisible(copyButton);
    expect(tester.widget<FilledButton>(copyButton).onPressed, isNull);
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

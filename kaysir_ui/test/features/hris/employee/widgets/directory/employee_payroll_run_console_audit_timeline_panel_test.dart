import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_audit_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_payroll_run_console_command_models.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_run_console_audit_timeline_panel.dart';

void main() {
  testWidgets('payroll run console audit timeline filters by outcome', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeePayrollRunConsoleAuditTimelinePanel(
              events: [
                _event(
                  id: 'completed',
                  message: '2 employees prepared and exported, 1 skipped.',
                  completedCount: 2,
                  skippedCount: 1,
                ),
                _event(
                  id: 'review',
                  commandType:
                      EmployeePayrollRunConsoleCommandType.settlePayment,
                  message: 'Settle pay could not update employees.',
                  completedCount: 0,
                  skippedCount: 3,
                  errors: const ['Maya Santoso: Verify bank account first.'],
                ),
                _event(
                  id: 'no-change',
                  commandType: EmployeePayrollRunConsoleCommandType.closePeriod,
                  message: 'Close period had no eligible employees.',
                  completedCount: 0,
                  skippedCount: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Audit evidence status'), findsOneWidget);
    expect(find.text('Review needed'), findsOneWidget);
    expect(find.text('Review 1 payroll console event.'), findsOneWidget);
    expect(
      find.text('Resolve review items before closing this payroll run.'),
      findsOneWidget,
    );
    expect(find.text('Close evidence package'), findsOneWidget);
    expect(find.text('3/5 ready'), findsWidgets);
    expect(find.text('PKG-RUN-202605-001-03'), findsWidgets);
    expect(
      find.text('Clear review items before package handoff.'),
      findsOneWidget,
    );
    expect(find.text('Review clearance'), findsOneWidget);
    expect(find.text('1 event needs review'), findsOneWidget);
    expect(find.text('Command stage coverage'), findsOneWidget);
    expect(find.text('3/4 evidenced'), findsWidgets);
    expect(find.text('Publish payslips'), findsOneWidget);
    expect(find.text('No command evidence captured'), findsOneWidget);
    expect(find.text('Audit role controls'), findsOneWidget);
    expect(find.text('Audit export preview'), findsOneWidget);
    expect(find.text('Resolve package checks first'), findsWidgets);
    expect(
      find.text('pkg-run-202605-001-03-audit-events.csv - 3 audit events'),
      findsOneWidget,
    );
    expect(find.text('Payroll close handoff'), findsOneWidget);
    expect(
      find.text('Resolve 1 audit review event before handoff.'),
      findsWidgets,
    );
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Review (1)'), findsOneWidget);
    expect(
      find.text('2 employees prepared and exported, 1 skipped.'),
      findsOneWidget,
    );
    expect(find.text('Settle pay could not update employees.'), findsOneWidget);
    expect(
      find.text('Close period had no eligible employees.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Review (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review (1)'));
    await tester.pumpAndSettle();

    expect(find.text('1 of 3'), findsOneWidget);
    expect(
      find.text('2 employees prepared and exported, 1 skipped.'),
      findsNothing,
    );
    expect(find.text('Settle pay could not update employees.'), findsOneWidget);
    expect(find.text('Close period had no eligible employees.'), findsNothing);
  });
}

EmployeePayrollRunConsoleAuditEvent _event({
  required String id,
  required String message,
  required int completedCount,
  required int skippedCount,
  EmployeePayrollRunConsoleCommandType commandType =
      EmployeePayrollRunConsoleCommandType.prepareExport,
  List<String> errors = const [],
}) {
  return EmployeePayrollRunConsoleAuditEvent(
    id: id,
    runReference: 'RUN-202605-001',
    commandType: commandType,
    scopeLabel: 'All 5 run employees',
    operatorName: 'Payroll Lead',
    occurredAt: DateTime(2026, 5, 30, 9, 30),
    targetEmployeeCount: completedCount + skippedCount,
    completedCount: completedCount,
    skippedCount: skippedCount,
    errors: errors,
    message: message,
  );
}

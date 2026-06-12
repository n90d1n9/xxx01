import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payslip_delivery_panel.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_close_panel.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_payment_panel.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_run_preview_panel.dart';

void main() {
  testWidgets('employee payroll close posts journal and closes period', (
    tester,
  ) async {
    final asOfDate = DateTime(2026, 5, 30);
    final member = buildEmployeeDirectoryMembers().singleWhere(
      (employee) => employee.id == '3',
    );
    final snapshot = buildEmployeeManagementSnapshot(
      member: member,
      asOfDate: asOfDate,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(asOfDate),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    EmployeePayrollRunPreviewPanel(snapshot: snapshot),
                    const SizedBox(height: 12),
                    EmployeePayrollPaymentPanel(snapshot: snapshot),
                    const SizedBox(height: 12),
                    EmployeePayslipDeliveryPanel(snapshot: snapshot),
                    const SizedBox(height: 12),
                    EmployeePayrollClosePanel(snapshot: snapshot),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Payroll close'), findsOneWidget);
    expect(find.text('Close readiness'), findsOneWidget);
    expect(find.text('Export payroll run before period close.'), findsWidgets);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Review note',
      ),
      'Payroll run reviewed for period close.',
    );
    await tester.pump();

    final visibleToggle = find.text('Make payslip visible after export');
    await tester.ensureVisible(visibleToggle);
    await tester.tap(visibleToggle);
    await tester.pump();

    final reviewButton = find.widgetWithText(FilledButton, 'Mark reviewed');
    await tester.ensureVisible(reviewButton);
    await tester.tap(reviewButton);
    await tester.pumpAndSettle();

    final exportButton = find.widgetWithText(FilledButton, 'Export payroll');
    await tester.ensureVisible(exportButton);
    await tester.tap(exportButton);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Payment note',
      ),
      'Payment file reviewed for settlement.',
    );
    await tester.pump();

    final scheduleButton = find.widgetWithText(
      FilledButton,
      'Schedule payment',
    );
    await tester.ensureVisible(scheduleButton);
    await tester.tap(scheduleButton);
    await tester.pumpAndSettle();

    final paidButton = find.widgetWithText(FilledButton, 'Mark paid');
    await tester.ensureVisible(paidButton);
    await tester.tap(paidButton);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Release note',
      ),
      'Payslip released before payroll close.',
    );
    await tester.pump();

    final releaseButton = find.widgetWithText(FilledButton, 'Release payslip');
    await tester.ensureVisible(releaseButton);
    await tester.tap(releaseButton);
    await tester.pumpAndSettle();

    expect(find.text('Post payroll accounting journal.'), findsWidgets);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Close note',
      ),
      'Accounting handoff reviewed for payroll close.',
    );
    await tester.pump();

    final postButton = find.widgetWithText(FilledButton, 'Post journal');
    await tester.ensureVisible(postButton);
    await tester.tap(postButton);
    await tester.pumpAndSettle();

    expect(find.text('Posted'), findsWidgets);

    final closeButton = find.widgetWithText(FilledButton, 'Close period');
    await tester.ensureVisible(closeButton);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    expect(find.text('Closed'), findsWidgets);
    expect(find.text('Payroll period closed'), findsOneWidget);
  });
}

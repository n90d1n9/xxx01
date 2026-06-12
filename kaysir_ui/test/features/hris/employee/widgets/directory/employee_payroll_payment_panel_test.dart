import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_payment_panel.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_run_preview_panel.dart';

void main() {
  testWidgets('employee payroll payment schedules and settles exported run', (
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Payment disbursement'), findsOneWidget);
    expect(find.text('Payment readiness'), findsOneWidget);
    expect(
      find.text('Export payroll run before payment scheduling.'),
      findsWidgets,
    );

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Review note',
      ),
      'Payroll run reviewed for payment release.',
    );
    await tester.pump();

    final reviewButton = find.widgetWithText(FilledButton, 'Mark reviewed');
    await tester.ensureVisible(reviewButton);
    await tester.tap(reviewButton);
    await tester.pumpAndSettle();

    final exportButton = find.widgetWithText(FilledButton, 'Export payroll');
    await tester.ensureVisible(exportButton);
    await tester.tap(exportButton);
    await tester.pumpAndSettle();

    expect(find.text('Schedule net pay disbursement.'), findsWidgets);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Payment note',
      ),
      'Payment file reviewed for bank settlement.',
    );
    await tester.pump();

    final scheduleButton = find.widgetWithText(
      FilledButton,
      'Schedule payment',
    );
    await tester.ensureVisible(scheduleButton);
    await tester.tap(scheduleButton);
    await tester.pumpAndSettle();

    expect(find.text('Scheduled'), findsWidgets);

    final paidButton = find.widgetWithText(FilledButton, 'Mark paid');
    await tester.ensureVisible(paidButton);
    await tester.tap(paidButton);
    await tester.pumpAndSettle();

    expect(find.text('Paid'), findsWidgets);
    expect(find.text('Payroll payment settled'), findsOneWidget);
  });
}

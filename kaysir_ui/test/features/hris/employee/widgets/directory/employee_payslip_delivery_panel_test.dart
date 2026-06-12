import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payslip_delivery_panel.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_run_preview_panel.dart';

void main() {
  testWidgets('employee payslip delivery releases exported payroll run', (
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
                    EmployeePayslipDeliveryPanel(snapshot: snapshot),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Payslip delivery'), findsOneWidget);
    expect(find.text('Delivery readiness'), findsOneWidget);
    expect(
      find.text('Export payroll run before payslip delivery.'),
      findsWidgets,
    );

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Review note',
      ),
      'Payroll run reviewed for payslip delivery.',
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

    expect(
      find.text('Release payslip to employee self-service.'),
      findsWidgets,
    );

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Release note',
      ),
      'Payslip release approved for employee portal.',
    );
    await tester.pump();

    final releaseButton = find.widgetWithText(FilledButton, 'Release payslip');
    await tester.ensureVisible(releaseButton);
    await tester.tap(releaseButton);
    await tester.pumpAndSettle();

    expect(find.text('Published'), findsWidgets);
    expect(find.text('Employee self-service'), findsWidgets);
    expect(find.text('Payslip released'), findsOneWidget);
  });
}

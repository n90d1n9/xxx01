import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_cutoff_reconciliation_panel.dart';

void main() {
  testWidgets('employee payroll cutoff panel signs off ready period', (
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
                child: EmployeePayrollCutoffReconciliationPanel(
                  snapshot: snapshot,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Payroll cutoff reconciliation'), findsOneWidget);
    expect(find.text('Ready for payroll'), findsWidgets);
    expect(find.text('Sign off cutoff'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Sign-off note',
      ),
      'Payroll cutoff reviewed and ready for release.',
    );
    await tester.pump();

    final signOffButton = find.widgetWithText(FilledButton, 'Sign off cutoff');
    await tester.ensureVisible(signOffButton);
    await tester.tap(signOffButton);
    await tester.pumpAndSettle();

    expect(find.text('Cutoff signed off'), findsOneWidget);
    expect(
      find.text('Payroll cutoff reviewed and ready for release.'),
      findsOneWidget,
    );
  });
}

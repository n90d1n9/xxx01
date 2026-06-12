import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_timekeeping_center_panel.dart';

void main() {
  testWidgets('employee timekeeping center adds payroll exception', (
    tester,
  ) async {
    final asOfDate = DateTime(2026, 5, 30);
    final member = buildEmployeeDirectoryMembers().singleWhere(
      (employee) => employee.id == '4',
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
                child: EmployeeTimekeepingCenterPanel(snapshot: snapshot),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Timekeeping and timesheets'), findsOneWidget);
    expect(find.text('Missing clock-out'), findsWidgets);
    expect(find.text('Add exception'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Owner',
      ),
      'Payroll Operations',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Exception note',
      ),
      'Overtime approval is missing for payroll cutoff.',
    );
    await tester.pump();

    final addButton = find.widgetWithText(FilledButton, 'Add exception');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Overtime approval is missing for payroll cutoff.'),
      findsOneWidget,
    );
  });
}

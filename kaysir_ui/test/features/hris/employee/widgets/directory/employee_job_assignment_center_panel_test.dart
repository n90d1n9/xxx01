import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_job_assignment_center_panel.dart';

void main() {
  testWidgets('employee job assignment center adds assignment', (tester) async {
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
            body: SingleChildScrollView(
              child: EmployeeJobAssignmentCenterPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Job assignment center'), findsOneWidget);
    expect(find.text('HR Manager'), findsWidgets);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Position',
      ),
      'Senior HR Manager',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Notes',
      ),
      'Assignment approved for HR operations coverage.',
    );
    await tester.pump();

    final addButton = find.widgetWithText(FilledButton, 'Add assignment');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Senior HR Manager'), findsOneWidget);
    expect(find.text('Pending approval'), findsOneWidget);
  });
}

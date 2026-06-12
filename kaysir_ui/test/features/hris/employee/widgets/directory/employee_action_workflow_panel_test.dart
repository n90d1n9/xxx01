import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_action_workflow_panel.dart';

void main() {
  testWidgets('employee action workflow panel adds manual task', (
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
            body: SingleChildScrollView(
              child: EmployeeActionWorkflowPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Action workflow'), findsOneWidget);
    expect(find.text('Open'), findsWidgets);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Add task'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Task title',
      ),
      'Confirm payroll exception',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Follow-up',
      ),
      'Validate payroll exception before cutoff.',
    );
    await tester.pump();

    final addButton = find.widgetWithText(FilledButton, 'Add task');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Confirm payroll exception'), findsOneWidget);
    expect(find.text('Manual follow-up'), findsOneWidget);
  });
}

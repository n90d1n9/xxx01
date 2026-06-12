import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_action_activity_panel.dart';

void main() {
  testWidgets('employee action activity panel adds update', (tester) async {
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
              child: EmployeeActionActivityPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Action activity log'), findsOneWidget);
    expect(find.text('Updates'), findsOneWidget);
    expect(find.text('Add update'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Activity update',
      ),
      'Confirmed owner is collecting the required evidence.',
    );
    await tester.pump();

    final addButton = find.widgetWithText(FilledButton, 'Add update');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Confirmed owner is collecting the required evidence.'),
      findsOneWidget,
    );
    expect(find.text('Note'), findsWidgets);
  });
}

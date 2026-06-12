import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_manager_change_readiness_center_panel.dart';

void main() {
  testWidgets('employee manager change readiness center adds checklist item', (
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
              child: EmployeeManagerChangeReadinessCenterPanel(
                snapshot: snapshot,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Manager change readiness'), findsOneWidget);
    expect(
      find.text('Capture outgoing manager recovery notes'),
      findsOneWidget,
    );
    expect(find.text('Add item'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Checklist title',
      ),
      'Confirm delegated approval owner',
    );
    await tester.pump();

    final addButton = find.widgetWithText(FilledButton, 'Add item');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Confirm delegated approval owner'), findsOneWidget);
  });
}

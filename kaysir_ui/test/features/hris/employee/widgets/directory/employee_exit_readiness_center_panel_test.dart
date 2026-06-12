import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_exit_readiness_center_panel.dart';

void main() {
  testWidgets('employee exit readiness center adds clearance item', (
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
              child: EmployeeExitReadinessCenterPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Exit readiness'), findsOneWidget);
    expect(
      find.text('Finalize separation notice and rationale'),
      findsOneWidget,
    );
    expect(find.text('Add clearance'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Clearance title',
      ),
      'Recover admin token',
    );
    await tester.pump();

    final addButton = find.widgetWithText(FilledButton, 'Add clearance');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Recover admin token'), findsOneWidget);
  });
}

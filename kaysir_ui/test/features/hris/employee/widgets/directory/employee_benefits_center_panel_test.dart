import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_benefits_center_panel.dart';

void main() {
  testWidgets('employee benefits center adds a dependent', (tester) async {
    final asOfDate = DateTime(2026, 5, 30);
    final member = buildEmployeeDirectoryMembers().singleWhere(
      (employee) => employee.id == '1',
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
              child: EmployeeBenefitsCenterPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Benefits and dependents'), findsOneWidget);
    expect(find.text('Kaysir Health Plus'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Dependent name',
      ),
      'Mira Johnson',
    );
    await tester.tap(find.text('Select birth date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(FilledButton, 'Add dependent');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Mira Johnson'), findsOneWidget);
  });
}

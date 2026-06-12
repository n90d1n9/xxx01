import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_data_quality_panel.dart';

void main() {
  testWidgets('employee data quality panel adds issue', (tester) async {
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
              child: EmployeeDataQualityPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Data quality center'), findsOneWidget);
    expect(find.text('High risk'), findsOneWidget);
    expect(find.text('Add issue'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Issue title',
      ),
      'Manager field mismatch',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Issue detail',
      ),
      'Manager name differs from reporting record.',
    );
    await tester.pump();

    final addButton = find.widgetWithText(FilledButton, 'Add issue');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Manager field mismatch'), findsOneWidget);
    expect(
      find.text('Manager name differs from reporting record.'),
      findsOneWidget,
    );
  });
}

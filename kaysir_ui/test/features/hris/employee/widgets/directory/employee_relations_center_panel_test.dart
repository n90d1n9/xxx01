import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_relations_center_panel.dart';

void main() {
  testWidgets('employee relations center records recognition event', (
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
            body: SingleChildScrollView(
              child: EmployeeRelationsCenterPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Recognition and conduct'), findsOneWidget);
    expect(
      find.text('Human Resources contribution recognized'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Summary',
      ),
      'Recognized calm ownership during a customer escalation.',
    );
    await tester.pump();

    final recordButton = find.widgetWithText(FilledButton, 'Record event');
    await tester.ensureVisible(recordButton);
    await tester.tap(recordButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Recognized calm ownership during a customer escalation.'),
      findsOneWidget,
    );
    expect(find.text('Documented'), findsWidgets);
  });
}

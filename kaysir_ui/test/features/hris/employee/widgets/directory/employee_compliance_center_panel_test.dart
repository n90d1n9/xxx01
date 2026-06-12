import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_compliance_center_panel.dart';

void main() {
  testWidgets('employee compliance center adds a document', (tester) async {
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
              child: EmployeeComplianceCenterPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Compliance center'), findsOneWidget);
    expect(find.text('Growth and retention plan'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Document title',
      ),
      'Security certification',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Notes',
      ),
      'Certification uploaded for annual compliance.',
    );
    await tester.pump();

    final addButton = find.widgetWithText(FilledButton, 'Add document');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Security certification'), findsOneWidget);
  });
}

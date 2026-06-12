import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_data_correction_panel.dart';

void main() {
  testWidgets('employee data correction panel submits correction', (
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
              child: EmployeeDataCorrectionPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Data correction workflow'), findsOneWidget);
    expect(find.text('Submit correction'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Proposed value',
      ),
      'Verified reporting manager: Olivia Wilson',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Correction rationale',
      ),
      'Correct manager value after HR validation.',
    );
    await tester.pump();

    final submitButton = find.widgetWithText(FilledButton, 'Submit correction');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Verified reporting manager: Olivia Wilson'),
      findsOneWidget,
    );
    expect(
      find.text('Correct manager value after HR validation.'),
      findsOneWidget,
    );
  });
}

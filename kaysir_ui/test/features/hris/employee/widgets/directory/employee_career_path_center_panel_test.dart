import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_career_path_center_panel.dart';

void main() {
  testWidgets('employee career path center proposes a move', (tester) async {
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
              child: EmployeeCareerPathCenterPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Career and succession'), findsOneWidget);
    expect(find.text('No career moves proposed.'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Summary',
      ),
      'Prepare promotion panel after readiness calibration.',
    );
    await tester.pump();

    final proposeButton = find.widgetWithText(FilledButton, 'Propose move');
    await tester.ensureVisible(proposeButton);
    await tester.tap(proposeButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Prepare promotion panel after readiness calibration.'),
      findsOneWidget,
    );
    expect(find.text('Proposed'), findsWidgets);
  });
}

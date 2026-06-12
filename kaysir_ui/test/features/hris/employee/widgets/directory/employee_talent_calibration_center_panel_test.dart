import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_talent_calibration_center_panel.dart';

void main() {
  testWidgets('employee talent calibration center adds follow-up', (
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
            body: SizedBox(
              width: 1000,
              child: SingleChildScrollView(
                child: EmployeeTalentCalibrationCenterPanel(snapshot: snapshot),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Talent calibration'), findsOneWidget);
    expect(find.text('Weekly manager calibration checkpoint'), findsOneWidget);
    expect(find.text('Add follow-up'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Follow-up title',
      ),
      'Talent council readout',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Owner',
      ),
      'Talent Council',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Calibration notes',
      ),
      'Prepare calibration evidence for the next council readout.',
    );
    await tester.pump();

    final addButton = find.widgetWithText(FilledButton, 'Add follow-up');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Talent council readout'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_skill_inventory_center_panel.dart';

void main() {
  testWidgets('employee skill inventory center adds skill evidence', (
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
                child: EmployeeSkillInventoryCenterPanel(snapshot: snapshot),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Skills inventory'), findsOneWidget);
    expect(find.text('Roadmap analytics'), findsWidgets);
    expect(find.text('Add evidence'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Skill name',
      ),
      'Opportunity sizing',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Verifier',
      ),
      'Product Talent Council',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Evidence summary',
      ),
      'Validated opportunity sizing through customer playback.',
    );
    await tester.pump();

    final addButton = find.widgetWithText(FilledButton, 'Add evidence');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Opportunity sizing'), findsOneWidget);
  });
}

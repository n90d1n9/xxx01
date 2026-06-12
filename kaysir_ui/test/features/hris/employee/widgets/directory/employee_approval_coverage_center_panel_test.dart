import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_approval_coverage_center_panel.dart';

void main() {
  testWidgets('employee approval coverage center adds delegation', (
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
              child: EmployeeApprovalCoverageCenterPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Approval coverage'), findsOneWidget);
    expect(find.text('Olivia Wilson to HR Business Partner'), findsOneWidget);
    expect(find.text('Add delegation'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Delegate approver',
      ),
      'People Operations',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Reason',
      ),
      'Cover approvals while manager transition is reviewed.',
    );
    await tester.pump();

    final addButton = find.widgetWithText(FilledButton, 'Add delegation');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Cover approvals while manager transition is reviewed.'),
      findsOneWidget,
    );
  });
}

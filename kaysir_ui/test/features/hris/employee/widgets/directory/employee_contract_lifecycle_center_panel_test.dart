import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_contract_lifecycle_center_panel.dart';

void main() {
  testWidgets(
    'employee contract lifecycle center renders and submits a change',
    (tester) async {
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
                child: EmployeeContractLifecycleCenterPanel(snapshot: snapshot),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Contract lifecycle'), findsOneWidget);
      expect(find.text('No contract changes submitted.'), findsOneWidget);

      await tester.enterText(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == 'Detail',
        ),
        'Move employee to permanent contract after HR review.',
      );
      await tester.pump();

      final addButton = find.widgetWithText(
        FilledButton,
        'Add contract change',
      );
      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Move employee to permanent contract after HR review.'),
        findsOneWidget,
      );
      expect(find.text('Submitted'), findsWidgets);
    },
  );
}

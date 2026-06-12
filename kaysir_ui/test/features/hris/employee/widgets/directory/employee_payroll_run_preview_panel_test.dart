import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_roster_payroll_run_kickoff_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_payroll_run_preview_panel.dart';

import '../../helpers/payroll_run_kickoff_test_helpers.dart';

void main() {
  testWidgets('employee payroll run preview reviews and exports clean run', (
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
            body: SizedBox(
              width: 1000,
              child: SingleChildScrollView(
                child: EmployeePayrollRunPreviewPanel(snapshot: snapshot),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Payroll run preview'), findsOneWidget);
    expect(find.text('Run readiness'), findsOneWidget);
    expect(find.text('Base pay'), findsWidgets);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Review note',
      ),
      'Payroll run reviewed for export readiness.',
    );
    await tester.pump();

    final reviewButton = find.widgetWithText(FilledButton, 'Mark reviewed');
    await tester.ensureVisible(reviewButton);
    await tester.tap(reviewButton);
    await tester.pumpAndSettle();

    expect(find.text('Ready'), findsWidgets);

    final exportButton = find.widgetWithText(FilledButton, 'Export payroll');
    await tester.ensureVisible(exportButton);
    await tester.tap(exportButton);
    await tester.pumpAndSettle();

    expect(find.text('Exported'), findsWidgets);
    expect(find.text('PAY-202606'), findsOneWidget);
  });

  testWidgets('employee payroll run preview uses directory kickoff reference', (
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
    final recordsNotifier =
        EmployeeDirectoryRosterPayrollRunKickoffRecordsNotifier()
          ..add(buildPayrollRunKickoffTestRecord());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(asOfDate),
          employeeDirectoryRosterPayrollRunKickoffRecordsProvider.overrideWith(
            (ref) => recordsNotifier,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              child: SingleChildScrollView(
                child: EmployeePayrollRunPreviewPanel(snapshot: snapshot),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Directory payroll kickoff'), findsOneWidget);
    expect(find.text('RUN-202605-001'), findsOneWidget);
    expect(find.text('PAY-202605-001'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Review note',
      ),
      'Payroll run reviewed after directory kickoff.',
    );
    await tester.pump();

    final reviewButton = find.widgetWithText(FilledButton, 'Mark reviewed');
    await tester.ensureVisible(reviewButton);
    await tester.tap(reviewButton);
    await tester.pumpAndSettle();

    final exportButton = find.widgetWithText(FilledButton, 'Export payroll');
    await tester.ensureVisible(exportButton);
    await tester.tap(exportButton);
    await tester.pumpAndSettle();

    expect(find.text('Exported'), findsWidgets);
    expect(find.text('RUN-202605-001'), findsWidgets);
  });
}

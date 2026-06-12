import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_action_sla_panel.dart';

void main() {
  testWidgets('employee action SLA panel renders escalation signals', (
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
              child: EmployeeActionSlaPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Action SLA monitor'), findsOneWidget);
    expect(find.text('Escalated'), findsOneWidget);
    expect(find.text('Owner risk'), findsOneWidget);
    expect(find.text('Due today'), findsWidgets);
    expect(find.textContaining('Escalate'), findsWidgets);
  });
}

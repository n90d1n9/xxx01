import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_directory_detail_sheet.dart';

void main() {
  testWidgets('employee detail sheet switches profile sections', (
    tester,
  ) async {
    final asOfDate = DateTime(2026, 5, 30);
    final employee = buildEmployeeDirectoryMembers().first.copyWith(
      avatarUrl: '',
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
              height: 1600,
              child: EmployeeDirectoryDetailSheet(
                employee: employee,
                asOfDate: asOfDate,
                onMessage: () {},
                onSchedule: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Attention summary'), findsOneWidget);
    expect(find.text('Next best actions'), findsWidgets);
    expect(find.text('Action workflow'), findsOneWidget);
    expect(find.text('Workflow automation hooks'), findsOneWidget);
    expect(find.text('Action SLA monitor'), findsOneWidget);
    expect(find.text('Action activity log'), findsOneWidget);
    expect(find.text('Employee management'), findsWidgets);
    expect(find.text('Profile completeness'), findsWidgets);
    expect(find.text('Data quality center'), findsOneWidget);
    expect(find.text('Data correction workflow'), findsOneWidget);
    expect(find.text('Correction governance'), findsOneWidget);
    expect(find.text('Employee audit trail'), findsOneWidget);
    expect(find.text('Employee 360 timeline'), findsOneWidget);

    final recordsTab = find.byKey(
      const ValueKey('employee-profile-section-records'),
    );
    await tester.ensureVisible(recordsTab);
    await tester.tap(recordsTab);
    await tester.pumpAndSettle();

    expect(find.text('Personal records'), findsWidgets);
    expect(find.text('Document vault'), findsOneWidget);
    expect(find.text('Work authorization'), findsOneWidget);
    expect(find.text('Accommodation support'), findsOneWidget);
    expect(find.text('Document request center'), findsOneWidget);
    expect(find.text('Compliance center'), findsOneWidget);
    expect(find.text('HR case log'), findsOneWidget);
    expect(find.text('Create case'), findsOneWidget);
    expect(find.text('Employee audit trail'), findsNothing);

    final workTab = find.byKey(const ValueKey('employee-profile-section-work'));
    await tester.ensureVisible(workTab);
    await tester.tap(workTab);
    await tester.pumpAndSettle();

    expect(find.text('Organization and reporting'), findsOneWidget);
    expect(find.text('Position control'), findsOneWidget);
    expect(find.text('Manager change readiness'), findsOneWidget);
    expect(find.text('Approval coverage'), findsOneWidget);
    expect(find.text('Approval policy rules'), findsOneWidget);
    expect(find.text('Job assignment center'), findsOneWidget);
    expect(find.text('Job history ledger'), findsOneWidget);
    expect(find.text('Contract lifecycle'), findsOneWidget);
    expect(find.text('Schedule and attendance'), findsOneWidget);
    expect(find.text('Timekeeping and timesheets'), findsOneWidget);
    expect(find.text('Leave and absence'), findsOneWidget);
    expect(find.text('Lifecycle task center'), findsOneWidget);
    expect(find.text('Exit readiness'), findsOneWidget);

    final growthTab = find.byKey(
      const ValueKey('employee-profile-section-growth'),
    );
    await tester.ensureVisible(growthTab);
    await tester.tap(growthTab);
    await tester.pumpAndSettle();

    expect(find.text('Performance and goals'), findsOneWidget);
    expect(find.text('Performance support plan'), findsWidgets);
    expect(find.text('Skills inventory'), findsOneWidget);
    expect(find.text('Talent calibration'), findsOneWidget);
    expect(find.text('Career and succession'), findsOneWidget);
    expect(find.text('Succession coverage'), findsWidgets);
    expect(find.text('Mobility readiness'), findsOneWidget);
    expect(find.text('Engagement and retention'), findsOneWidget);
    expect(find.text('Recognition and conduct'), findsOneWidget);
    expect(find.text('Development center'), findsOneWidget);

    final payTab = find.byKey(const ValueKey('employee-profile-section-pay'));
    await tester.ensureVisible(payTab);
    await tester.tap(payTab);
    await tester.pumpAndSettle();

    expect(find.text('Payroll and tax'), findsOneWidget);
    expect(find.text('Payroll cutoff reconciliation'), findsOneWidget);
    expect(find.text('Payroll variance review'), findsOneWidget);
    expect(find.text('Payroll run preview'), findsOneWidget);
    expect(find.text('Payment disbursement'), findsOneWidget);
    expect(find.text('Payslip delivery'), findsWidgets);
    expect(find.text('Payroll close'), findsWidgets);
    expect(find.text('Compensation review'), findsOneWidget);
    expect(find.text('Expenses and reimbursement'), findsOneWidget);
    expect(find.text('Benefits and dependents'), findsOneWidget);
    expect(find.text('Organization and reporting'), findsNothing);

    final securityTab = find.byKey(
      const ValueKey('employee-profile-section-security'),
    );
    await tester.ensureVisible(securityTab);
    await tester.tap(securityTab);
    await tester.pumpAndSettle();

    expect(find.text('Access governance'), findsOneWidget);
    expect(find.text('Assets and access'), findsOneWidget);
    expect(find.text('Personal records'), findsNothing);
  });
}

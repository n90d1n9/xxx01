import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_profile_change_governance_panel.dart';

void main() {
  testWidgets('employee profile change governance submits and reviews change', (
    tester,
  ) async {
    final asOfDate = DateTime(2026, 5, 30);
    final member = buildEmployeeDirectoryMembers().first;
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
              child: EmployeeProfileChangeGovernancePanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Profile change governance'), findsOneWidget);
    expect(find.text('No governed profile changes pending.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('employee-profile-change-proposed-field')),
      'David Kim',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-profile-change-reason-field')),
      'Move reporting line for the new product squad.',
    );
    await tester.pumpAndSettle();

    final submit = find.byKey(
      const ValueKey('employee-profile-change-submit-button'),
    );
    await tester.ensureVisible(submit);
    expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('Submitted'), findsWidgets);
    expect(find.text('Manager: Emma Rodriguez -> David Kim'), findsOneWidget);

    final review = find.byKey(
      const ValueKey('employee-profile-change-start-review-EPC-1-001'),
    );
    await tester.ensureVisible(review);
    await tester.tap(review);
    await tester.pumpAndSettle();

    expect(find.text('In review'), findsWidgets);

    final approve = find.byKey(
      const ValueKey('employee-profile-change-approve-EPC-1-001'),
    );
    await tester.ensureVisible(approve);
    expect(tester.widget<FilledButton>(approve).onPressed, isNotNull);
  });
}

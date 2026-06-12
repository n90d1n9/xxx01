import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_document_vault_center_panel.dart';

void main() {
  testWidgets('employee document vault center adds document', (tester) async {
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
              child: EmployeeDocumentVaultCenterPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Document vault'), findsOneWidget);
    expect(find.text('Required document coverage'), findsOneWidget);
    expect(find.text('Collect 2 required documents.'), findsOneWidget);
    expect(find.text('50% covered'), findsWidgets);
    expect(find.text('Payroll and tax evidence'), findsOneWidget);
    expect(find.text('Policy acknowledgement'), findsOneWidget);
    expect(find.text('Government ID'), findsOneWidget);
    expect(find.text('Employment agreement'), findsWidgets);

    final payrollRequestButton = find.byKey(
      const ValueKey('employee-document-vault-coverage-request-payroll-tax'),
    );
    await tester.ensureVisible(payrollRequestButton);
    await tester.tap(payrollRequestButton);
    await tester.pumpAndSettle();

    expect(
      find.text('EDR-3-001 created for Payroll and tax evidence'),
      findsOneWidget,
    );
    expect(find.text('Request open'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Summary',
      ),
      'Certificate uploaded for HR review and restricted manager access.',
    );
    await tester.pump();

    final submitButton = find.widgetWithText(FilledButton, 'Add to vault');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Certificate uploaded for HR review and restricted manager access.',
      ),
      findsOneWidget,
    );
    expect(find.text('Pending review'), findsWidgets);
  });
}

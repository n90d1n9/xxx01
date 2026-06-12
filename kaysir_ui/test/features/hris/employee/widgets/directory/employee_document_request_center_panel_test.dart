import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_document_lifecycle_audit_panel.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_document_request_center_panel.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_document_vault_center_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('employee document request center submits a request', (
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
            body: SingleChildScrollView(
              child: EmployeeDocumentRequestCenterPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Document request center'), findsOneWidget);
    expect(find.text('No document requests submitted.'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Purpose',
      ),
      'Prepare salary certificate for visa appointment.',
    );
    await tester.pump();

    final addButton = find.widgetWithText(FilledButton, 'Add document request');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Prepare salary certificate for visa appointment.'),
      findsOneWidget,
    );
    expect(find.text('Requested'), findsWidgets);
  });

  testWidgets('employee document request center fulfills linked vault request', (
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
            body: SingleChildScrollView(
              child: Column(
                children: [
                  EmployeeDocumentVaultCenterPanel(snapshot: snapshot),
                  EmployeeDocumentRequestCenterPanel(snapshot: snapshot),
                  EmployeeDocumentLifecycleAuditPanel(snapshot: snapshot),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final payrollRequestButton = find.byKey(
      const ValueKey('employee-document-vault-coverage-request-payroll-tax'),
    );
    await tester.ensureVisible(payrollRequestButton);
    await tester.tap(payrollRequestButton);
    await tester.pumpAndSettle();

    expect(find.text('Payroll and tax evidence request'), findsWidgets);

    final issueButton = find.widgetWithText(FilledButton, 'Issue');
    await tester.ensureVisible(issueButton);
    await tester.tap(issueButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Payroll and tax evidence fulfilled in document vault'),
      findsOneWidget,
    );
    expect(find.text('Document request EDR-3-001'), findsOneWidget);
    expect(find.text('75% covered'), findsWidgets);
    expect(find.text('Document lifecycle audit trail'), findsOneWidget);
    expect(find.text('Request created'), findsOneWidget);
    expect(find.text('Request issued'), findsOneWidget);
    expect(find.text('Vault fulfilled'), findsOneWidget);
    expect(
      find.text('Showing 3 of 3 document lifecycle events'),
      findsOneWidget,
    );
    expect(find.text('Lifecycle audit export preview'), findsOneWidget);
    expect(find.text('Lifecycle audit export ready.'), findsOneWidget);
    expect(find.text('Lifecycle export receipt history'), findsOneWidget);
    expect(find.text('No lifecycle audit export receipts yet'), findsOneWidget);
    expect(
      find.text(
        'Latest document event: Vault fulfilled for Payroll and tax evidence.',
      ),
      findsOneWidget,
    );

    final copyCsvButton = find.byKey(
      const ValueKey(
        'employee-document-lifecycle-audit-export-copy-csv-button',
      ),
    );
    await tester.ensureVisible(copyCsvButton);
    await tester.tap(copyCsvButton);
    await tester.pumpAndSettle();

    expect(find.text('1 logged'), findsOneWidget);
    expect(
      find.text('Copy CSV by People Operations - 3 events'),
      findsOneWidget,
    );

    final fulfillmentFilter = find.byKey(
      const ValueKey('employee-document-lifecycle-audit-filter-fulfillment'),
    );
    await tester.ensureVisible(fulfillmentFilter);
    await tester.tap(fulfillmentFilter);
    await tester.pumpAndSettle();

    expect(
      find.text('Showing 1 of 3 document lifecycle events'),
      findsOneWidget,
    );
    expect(find.text('Filtered lifecycle audit export ready.'), findsOneWidget);
    expect(find.text('Vault fulfilled'), findsOneWidget);
    expect(find.text('Request created'), findsNothing);

    final allFilter = find.byKey(
      const ValueKey('employee-document-lifecycle-audit-filter-all'),
    );
    await tester.ensureVisible(allFilter);
    await tester.tap(allFilter);
    await tester.pumpAndSettle();

    final auditSearch = find.byKey(
      const ValueKey('employee-document-lifecycle-audit-search-field'),
    );
    await tester.ensureVisible(auditSearch);
    await tester.enterText(auditSearch, 'payroll');
    await tester.pumpAndSettle();

    expect(
      find.text('Showing 3 of 3 document lifecycle events'),
      findsOneWidget,
    );

    await tester.enterText(auditSearch, 'missing document');
    await tester.pumpAndSettle();

    expect(
      find.text('Showing 0 of 3 document lifecycle events'),
      findsOneWidget,
    );
    expect(
      find.text('No document lifecycle audit events match this view'),
      findsOneWidget,
    );
    expect(find.text('No audit events available for export.'), findsOneWidget);
  });
}

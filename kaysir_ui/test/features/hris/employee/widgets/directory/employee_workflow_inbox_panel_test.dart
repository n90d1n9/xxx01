import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/data/employee_directory_seed_data.dart';
import 'package:kaysir/features/hris/employee/data/employee_management_seed_data.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_workflow_inbox_panel.dart';

void main() {
  testWidgets('employee workflow inbox panel renders aggregated queue', (
    tester,
  ) async {
    final copiedClipboardValues = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final data = call.arguments as Map<Object?, Object?>;
          copiedClipboardValues.add(data['text']! as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

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
              child: EmployeeWorkflowInboxPanel(snapshot: snapshot),
            ),
          ),
        ),
      ),
    );

    expect(find.text('HR workflow inbox'), findsOneWidget);
    expect(find.textContaining('Act on'), findsOneWidget);
    expect(find.text('Ready'), findsWidgets);
    expect(find.text('Profile change'), findsWidgets);
    expect(find.text('Workflow task'), findsWidgets);
    expect(find.text('Manager change'), findsWidgets);
    expect(find.text('Apply'), findsWidgets);
    expect(find.text('Inbox SLA health'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'employee-workflow-inbox-sla-signal-',
            ),
      ),
      findsWidgets,
    );
    expect(find.text('SLA recovery playbook'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'employee-workflow-inbox-sla-playbook-step-',
            ),
      ),
      findsWidgets,
    );

    final playbookAction = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith(
            'employee-workflow-inbox-sla-playbook-action-',
          ),
    );
    await tester.ensureVisible(playbookAction.first);
    await tester.tap(playbookAction.first);
    await tester.pumpAndSettle();

    expect(find.text('Record playbook action'), findsOneWidget);
    const playbookReason = 'Recover ready queue before payroll cutoff';
    await tester.enterText(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-reason-field',
        ),
      ),
      playbookReason,
    );
    await tester.tap(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-record-button',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'employee-workflow-inbox-sla-playbook-receipt-',
            ),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('recorded for'), findsOneWidget);
    expect(find.text(playbookReason), findsOneWidget);
    expect(find.text('Playbook audit trail'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('employee-workflow-inbox-sla-playbook-action-timeline'),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'employee-workflow-inbox-sla-playbook-action-timeline-entry-',
            ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-filter-summary',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Showing 1 of 1 audit events'), findsOneWidget);
    expect(find.text('1/1 with reason'), findsOneWidget);

    final correctReasonButton = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-sla-playbook-correct-reason-EWP-4-001',
      ),
    );
    await tester.ensureVisible(correctReasonButton);
    await tester.tap(correctReasonButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-reason-correction-dialog',
        ),
      ),
      findsOneWidget,
    );
    const correctedReason = 'Recovery reassigned to HR lead for same-day close';
    await tester.enterText(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-reason-correction-field',
        ),
      ),
      correctedReason,
    );
    await tester.tap(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-reason-correction-save-button',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(correctedReason), findsOneWidget);
    expect(find.text('1 correction'), findsOneWidget);
    expect(find.text('Showing 2 of 2 audit events'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-playbook-action-timeline-entry-EWP-4-002',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Playbook audit package'), findsOneWidget);
    expect(find.text('Playbook audit package ready'), findsOneWidget);
    expect(find.text('CSV audit sample'), findsOneWidget);
    expect(find.text('Plain-text package'), findsOneWidget);
    expect(
      find.text('employee-4-workflow-inbox-playbook-audit-full.csv - 2 events'),
      findsOneWidget,
    );
    final auditCopyCsv = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-sla-playbook-audit-export-copy-csv-button',
      ),
    );
    await tester.ensureVisible(auditCopyCsv);
    expect(tester.widget<FilledButton>(auditCopyCsv).onPressed, isNotNull);
    expect(
      find.text('People Operations can copy this playbook audit CSV.'),
      findsOneWidget,
    );

    final auditCopyText = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-sla-playbook-audit-export-copy-text-button',
      ),
    );
    expect(tester.widget<OutlinedButton>(auditCopyText).onPressed, isNotNull);

    final auditAuditorRole = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-sla-playbook-audit-export-role-hrAuditor',
      ),
    );
    await tester.ensureVisible(auditAuditorRole);
    await tester.tap(auditAuditorRole);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'HR auditor can review playbook audit packages but cannot copy CSV files.',
      ),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(auditCopyCsv).onPressed, isNull);
    expect(tester.widget<OutlinedButton>(auditCopyText).onPressed, isNull);

    final auditManagerRole = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-sla-playbook-audit-export-role-manager',
      ),
    );
    await tester.ensureVisible(auditManagerRole);
    await tester.tap(auditManagerRole);
    await tester.pumpAndSettle();

    expect(
      find.text('Manager can copy this redacted playbook audit CSV.'),
      findsOneWidget,
    );
    expect(find.text('Manager redacted package ready'), findsOneWidget);
    expect(
      find.text(
        'employee-4-workflow-inbox-playbook-audit-full-manager-redacted.csv - 1 event',
      ),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(auditCopyCsv).onPressed, isNotNull);
    expect(tester.widget<OutlinedButton>(auditCopyText).onPressed, isNotNull);

    await tester.ensureVisible(auditCopyCsv);
    await tester.tap(auditCopyCsv);
    await tester.pumpAndSettle();

    expect(copiedClipboardValues, isNotEmpty);
    expect(copiedClipboardValues.last, isNot(contains('Reason correction')));
    expect(find.text('CSV copied and delivery logged'), findsOneWidget);
    expect(find.text('Audit export delivery history'), findsOneWidget);
    expect(find.text('Copy CSV by Manager - 1 event'), findsOneWidget);
    expect(
      find.text(
        'employee-4-workflow-inbox-playbook-audit-full-manager-redacted.csv - redacted evidence',
      ),
      findsOneWidget,
    );
    expect(find.text('1 logged'), findsOneWidget);

    final actionAuditScope = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-sla-playbook-audit-export-scope-actions',
      ),
    );
    await tester.ensureVisible(actionAuditScope);
    await tester.tap(actionAuditScope);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'employee-4-workflow-inbox-playbook-audit-actions-manager-redacted.csv - 1 event',
      ),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(auditCopyCsv).onPressed, isNotNull);

    final correctionAuditScope = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-sla-playbook-audit-export-scope-corrections',
      ),
    );
    await tester.ensureVisible(correctionAuditScope);
    await tester.tap(correctionAuditScope);
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.key ==
                const ValueKey(
                  'employee-workflow-inbox-sla-playbook-audit-export-copy-permission',
                ) &&
            widget.data == 'No redacted events match this audit scope',
      ),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(auditCopyCsv).onPressed, isNull);
    expect(
      find.text(
        'employee-4-workflow-inbox-playbook-audit-corrections-manager-redacted.csv - 0 events',
      ),
      findsOneWidget,
    );

    final profileChangeFilter = find.byKey(
      const ValueKey('employee-workflow-inbox-filter-profileChange'),
    );
    await tester.ensureVisible(profileChangeFilter);
    await tester.tap(profileChangeFilter);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Showing Profile changes - All owners - 1/'),
      findsOneWidget,
    );
    expect(find.text('Manager change'), findsWidgets);

    final peopleOpsOwner = find.byKey(
      const ValueKey('employee-workflow-inbox-owner-people-operations'),
    );
    await tester.ensureVisible(peopleOpsOwner);
    await tester.tap(peopleOpsOwner);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Showing Profile changes - People Operations - 1/'),
      findsOneWidget,
    );
    expect(find.text('Manager change'), findsWidgets);

    final applyProfileChange = find.byKey(
      const ValueKey(
        'employee-workflow-inbox-primary-action-profile-change-EPC-4-seed-001',
      ),
    );
    await tester.ensureVisible(applyProfileChange);
    await tester.tap(applyProfileChange);
    await tester.pumpAndSettle();

    expect(find.text('Apply: Manager change'), findsOneWidget);
    expect(find.text('No profile changes workflow items'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-item-profile-change-EPC-4-seed-001',
        ),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey(
          'employee-workflow-inbox-sla-signal-profile-change-EPC-4-seed-001',
        ),
      ),
      findsNothing,
    );
    expect(find.text('Inbox action receipts'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('employee-workflow-inbox-receipt-EWI-4-001')),
      findsOneWidget,
    );
    expect(find.text('Apply completed from Profile change.'), findsOneWidget);
    expect(find.text('Receipt export preview'), findsOneWidget);
    expect(find.text('Receipt export preview ready'), findsOneWidget);
    expect(find.text('CSV sample'), findsOneWidget);
    expect(
      find.text(
        'receipt_id,employee_id,employee_name,workflow_item_id,source_record_id,source,action,area,actor,owner,previous_status,decided_at,title',
      ),
      findsOneWidget,
    );
    expect(
      find.text('employee-4-workflow-inbox-receipts-all.csv - 1 receipt'),
      findsOneWidget,
    );

    final copyButton = find.byKey(
      const ValueKey('employee-workflow-inbox-receipt-export-copy-csv-button'),
    );
    await tester.ensureVisible(copyButton);
    expect(tester.widget<FilledButton>(copyButton).onPressed, isNotNull);
    expect(
      find.text('People Operations can copy this ready receipt export.'),
      findsOneWidget,
    );

    final auditorRole = find.byKey(
      const ValueKey('employee-workflow-inbox-receipt-export-role-hrAuditor'),
    );
    await tester.ensureVisible(auditorRole);
    await tester.tap(auditorRole);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'HR auditor can review receipt exports but cannot copy CSV files.',
      ),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(copyButton).onPressed, isNull);

    final payrollScope = find.byKey(
      const ValueKey('employee-workflow-inbox-receipt-export-scope-payroll'),
    );
    await tester.ensureVisible(payrollScope);
    await tester.tap(payrollScope);
    await tester.pumpAndSettle();

    expect(
      find.text('No payroll receipts match this export scope'),
      findsNWidgets(2),
    );
    expect(
      find.text('employee-4-workflow-inbox-receipts-payroll.csv - 0 receipts'),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(copyButton).onPressed, isNull);
  });
}

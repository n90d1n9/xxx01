import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_export_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_filter_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_models.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_document_lifecycle_audit_export_preview_panel.dart';

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

  testWidgets('document lifecycle audit export preview renders csv package', (
    tester,
  ) async {
    final profile = _profile();
    EmployeeDocumentLifecycleAuditExportPreview? copiedPreview;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeeDocumentLifecycleAuditExportPreviewPanel(
              profile: profile,
              entries: profile.sortedEntries,
              query: const EmployeeDocumentLifecycleAuditFilterQuery(),
              generatedAt: DateTime(2026, 6, 1, 12),
              onCopied: (preview) => copiedPreview = preview,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Lifecycle audit export preview'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Lifecycle audit export ready.'), findsOneWidget);
    expect(find.text('CSV sample'), findsOneWidget);
    expect(
      find.text(
        'event_id,employee_id,employee_name,event_type,event_group,subject_id,title,actor,owner,detail,correlation_id,occurred_at',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'aisha-rahman-document-lifecycle-audit-all-20260601.csv - 3 audit events',
      ),
      findsOneWidget,
    );

    final copyButton = find.byKey(
      const ValueKey(
        'employee-document-lifecycle-audit-export-copy-csv-button',
      ),
    );
    await tester.ensureVisible(copyButton);
    expect(tester.widget<FilledButton>(copyButton).onPressed, isNotNull);

    await tester.tap(copyButton);
    await tester.pumpAndSettle();

    expect(copiedPreview?.rowCount, 3);
    expect(find.text('Document lifecycle audit CSV copied'), findsOneWidget);
  });

  testWidgets('document lifecycle audit export preview disables empty export', (
    tester,
  ) async {
    final profile = _profile();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeeDocumentLifecycleAuditExportPreviewPanel(
              profile: profile,
              entries: const [],
              query: const EmployeeDocumentLifecycleAuditFilterQuery(
                searchText: 'missing',
              ),
              generatedAt: DateTime(2026, 6, 1, 12),
            ),
          ),
        ),
      ),
    );

    expect(find.text('No rows'), findsOneWidget);
    expect(find.text('No audit events available for export.'), findsOneWidget);

    final copyButton = find.byKey(
      const ValueKey(
        'employee-document-lifecycle-audit-export-copy-csv-button',
      ),
    );
    await tester.ensureVisible(copyButton);
    expect(tester.widget<FilledButton>(copyButton).onPressed, isNull);
  });
}

EmployeeDocumentLifecycleAuditProfile _profile() {
  return EmployeeDocumentLifecycleAuditProfile(
    employeeId: '3',
    employeeName: 'Aisha Rahman',
    asOfDate: DateTime(2026, 6, 1),
    entries: [
      _entry(
        id: 'EDLA-3-001',
        type: EmployeeDocumentLifecycleAuditEventType.requestCreated,
      ),
      _entry(
        id: 'EDLA-3-002',
        type: EmployeeDocumentLifecycleAuditEventType.requestIssued,
      ),
      _entry(
        id: 'EDLA-3-003',
        type: EmployeeDocumentLifecycleAuditEventType.vaultFulfilled,
      ),
    ],
  );
}

EmployeeDocumentLifecycleAuditEntry _entry({
  required String id,
  required EmployeeDocumentLifecycleAuditEventType type,
}) {
  return EmployeeDocumentLifecycleAuditEntry(
    id: id,
    employeeId: '3',
    employeeName: 'Aisha Rahman',
    type: type,
    subjectId: 'EDR-3-001',
    title: 'Payroll and tax evidence',
    actor: 'People Operations',
    owner: 'Aisha Rahman',
    detail: '${type.label} for payroll evidence.',
    correlationId: 'EDR-3-001',
    occurredAt: DateTime(2026, 5, 30),
  );
}

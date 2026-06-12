import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_export_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_filter_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_models.dart';

void main() {
  group('EmployeeDocumentLifecycleAuditExportPreview', () {
    test('builds ready csv export for all lifecycle audit events', () {
      final profile = buildProfile([
        buildEntry(
          id: 'EDLA-3-002',
          type: EmployeeDocumentLifecycleAuditEventType.requestIssued,
          detail: 'Issued through employee portal.',
          occurredAt: DateTime(2026, 5, 31),
        ),
        buildEntry(
          id: 'EDLA-3-001',
          type: EmployeeDocumentLifecycleAuditEventType.requestCreated,
          detail: 'Requested payroll evidence, with review.',
          occurredAt: DateTime(2026, 5, 30),
        ),
      ]);
      final preview = EmployeeDocumentLifecycleAuditExportPreview(
        profile: profile,
        entries: profile.sortedEntries,
        query: const EmployeeDocumentLifecycleAuditFilterQuery(),
        generatedAt: DateTime(2026, 6, 1, 12),
      );

      expect(preview.status, EmployeeDocumentLifecycleAuditExportStatus.ready);
      expect(preview.isReady, isTrue);
      expect(
        preview.fileName,
        'aisha-rahman-document-lifecycle-audit-all-20260601.csv',
      );
      expect(preview.rowCountLabel, '2 audit events');
      expect(
        preview.manifestItems.singleWhere((item) => item.label == 'Rows').value,
        '2/2',
      );
      expect(
        preview.csvContent,
        contains('event_id,employee_id,employee_name,event_type,event_group'),
      );
      expect(
        preview.csvContent,
        contains('"Requested payroll evidence, with review."'),
      );
      expect(
        preview.csvContent.indexOf('EDLA-3-001'),
        lessThan(preview.csvContent.indexOf('EDLA-3-002')),
      );
    });

    test('marks filtered lifecycle audit exports as scoped', () {
      final profile = buildProfile([
        buildEntry(
          id: 'EDLA-3-001',
          type: EmployeeDocumentLifecycleAuditEventType.requestCreated,
        ),
        buildEntry(
          id: 'EDLA-3-002',
          type: EmployeeDocumentLifecycleAuditEventType.vaultFulfilled,
        ),
      ]);
      const query = EmployeeDocumentLifecycleAuditFilterQuery(
        group: EmployeeDocumentLifecycleAuditFilterGroup.fulfillment,
      );
      final preview = EmployeeDocumentLifecycleAuditExportPreview(
        profile: profile,
        entries: query.applyTo(profile.sortedEntries),
        query: query,
        generatedAt: DateTime(2026, 6, 1, 12),
      );

      expect(preview.status, EmployeeDocumentLifecycleAuditExportStatus.scoped);
      expect(preview.rowCount, 1);
      expect(
        preview.exportActionLabel,
        'Filtered lifecycle audit export ready.',
      );
      expect(
        preview.fileName,
        'aisha-rahman-document-lifecycle-audit-fulfilled-20260601.csv',
      );
    });

    test('marks empty lifecycle audit exports as unavailable', () {
      final profile = buildProfile([
        buildEntry(
          id: 'EDLA-3-001',
          type: EmployeeDocumentLifecycleAuditEventType.requestCreated,
        ),
      ]);
      const query = EmployeeDocumentLifecycleAuditFilterQuery(
        searchText: 'missing',
      );
      final preview = EmployeeDocumentLifecycleAuditExportPreview(
        profile: profile,
        entries: query.applyTo(profile.sortedEntries),
        query: query,
        generatedAt: DateTime(2026, 6, 1, 12),
      );

      expect(preview.status, EmployeeDocumentLifecycleAuditExportStatus.empty);
      expect(preview.isReady, isFalse);
      expect(preview.rowCount, 0);
      expect(
        preview.exportActionLabel,
        'No audit events available for export.',
      );
    });
  });
}

EmployeeDocumentLifecycleAuditProfile buildProfile(
  List<EmployeeDocumentLifecycleAuditEntry> entries,
) {
  return EmployeeDocumentLifecycleAuditProfile(
    employeeId: '3',
    employeeName: 'Aisha Rahman',
    asOfDate: DateTime(2026, 6, 1),
    entries: entries,
  );
}

EmployeeDocumentLifecycleAuditEntry buildEntry({
  required String id,
  required EmployeeDocumentLifecycleAuditEventType type,
  String detail = 'Payroll evidence lifecycle action.',
  DateTime? occurredAt,
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
    detail: detail,
    correlationId: 'EDR-3-001',
    occurredAt: occurredAt ?? DateTime(2026, 5, 30),
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_filter_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_models.dart';

void main() {
  group('EmployeeDocumentLifecycleAuditFilterQuery', () {
    test('filters document lifecycle events by audit group', () {
      final entries = [
        buildEntry(
          type: EmployeeDocumentLifecycleAuditEventType.requestCreated,
          subjectId: 'EDR-3-001',
        ),
        buildEntry(
          type: EmployeeDocumentLifecycleAuditEventType.requestIssued,
          subjectId: 'EDR-3-001',
        ),
        buildEntry(
          type: EmployeeDocumentLifecycleAuditEventType.vaultFulfilled,
          subjectId: 'EDV-3-004',
          correlationId: 'EDR-3-001',
        ),
        buildEntry(
          type: EmployeeDocumentLifecycleAuditEventType.vaultUploaded,
          subjectId: 'EDV-3-005',
          correlationId: '',
        ),
      ];

      expect(
        const EmployeeDocumentLifecycleAuditFilterQuery(
          group: EmployeeDocumentLifecycleAuditFilterGroup.request,
        ).applyTo(entries),
        hasLength(2),
      );
      expect(
        const EmployeeDocumentLifecycleAuditFilterQuery(
          group: EmployeeDocumentLifecycleAuditFilterGroup.vault,
        ).applyTo(entries),
        hasLength(1),
      );
      expect(
        const EmployeeDocumentLifecycleAuditFilterQuery(
          group: EmployeeDocumentLifecycleAuditFilterGroup.fulfillment,
        ).applyTo(entries),
        hasLength(1),
      );
      expect(
        const EmployeeDocumentLifecycleAuditFilterQuery(
          group: EmployeeDocumentLifecycleAuditFilterGroup.linked,
        ).applyTo(entries),
        hasLength(3),
      );
    });

    test('searches document lifecycle event metadata case-insensitively', () {
      final entries = [
        buildEntry(
          type: EmployeeDocumentLifecycleAuditEventType.requestCreated,
          subjectId: 'EDR-3-001',
          detail: 'Payroll evidence requested through employee portal.',
        ),
        buildEntry(
          type: EmployeeDocumentLifecycleAuditEventType.vaultFulfilled,
          subjectId: 'EDV-3-004',
          detail: 'Fulfilled from linked request EDR-3-001.',
          correlationId: 'EDR-3-001',
        ),
        buildEntry(
          type: EmployeeDocumentLifecycleAuditEventType.vaultUploaded,
          subjectId: 'EDV-3-005',
          title: 'Signed handbook acknowledgement',
          detail: 'Uploaded by People Operations.',
          correlationId: '',
        ),
      ];

      expect(
        const EmployeeDocumentLifecycleAuditFilterQuery(
          searchText: 'PAYROLL',
        ).applyTo(entries),
        hasLength(2),
      );
      expect(
        const EmployeeDocumentLifecycleAuditFilterQuery(
          searchText: 'edv-3-005',
        ).applyTo(entries).single.title,
        'Signed handbook acknowledgement',
      );
      expect(
        const EmployeeDocumentLifecycleAuditFilterQuery(
          group: EmployeeDocumentLifecycleAuditFilterGroup.linked,
          searchText: 'edr-3-001',
        ).applyTo(entries),
        hasLength(2),
      );
    });
  });
}

EmployeeDocumentLifecycleAuditEntry buildEntry({
  required EmployeeDocumentLifecycleAuditEventType type,
  required String subjectId,
  String title = 'Payroll and tax evidence',
  String detail = 'Payroll document lifecycle action.',
  String correlationId = 'EDR-3-001',
}) {
  return EmployeeDocumentLifecycleAuditEntry(
    id: 'AUD-$subjectId-${type.name}',
    employeeId: '3',
    employeeName: 'Aisha Rahman',
    type: type,
    subjectId: subjectId,
    title: title,
    actor: 'People Operations',
    owner: 'Aisha Rahman',
    detail: detail,
    correlationId: correlationId,
    occurredAt: DateTime(2026, 5, 30),
  );
}

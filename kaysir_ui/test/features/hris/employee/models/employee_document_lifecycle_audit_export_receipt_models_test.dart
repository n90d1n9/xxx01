import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_export_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_export_receipt_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_filter_models.dart';

void main() {
  group('EmployeeDocumentLifecycleAuditExportReceiptProfile', () {
    test('summarizes full and scoped lifecycle audit export receipts', () {
      final profile = EmployeeDocumentLifecycleAuditExportReceiptProfile(
        employeeId: '3',
        employeeName: 'Aisha Rahman',
        asOfDate: DateTime(2026, 6, 1),
        receipts: [
          buildReceipt(
            id: 'EDLER-3-001',
            group: EmployeeDocumentLifecycleAuditFilterGroup.all,
            rowCount: 3,
          ),
          buildReceipt(
            id: 'EDLER-3-002',
            group: EmployeeDocumentLifecycleAuditFilterGroup.fulfillment,
            searchText: 'payroll',
            rowCount: 1,
            copiedAt: DateTime(2026, 6, 1, 12, 15),
          ),
        ],
      );

      expect(profile.totalCount, 2);
      expect(profile.fullCount, 1);
      expect(profile.scopedCount, 1);
      expect(profile.totalRows, 4);
      expect(profile.latestReceipt?.id, 'EDLER-3-002');
      expect(
        profile.latestReceipt?.filterLabel,
        'Fulfilled matching "payroll"',
      );
      expect(
        profile.nextAction,
        'Latest receipt: Copy CSV by People Operations - 1 event.',
      );
    });
  });
}

EmployeeDocumentLifecycleAuditExportReceipt buildReceipt({
  required String id,
  required EmployeeDocumentLifecycleAuditFilterGroup group,
  required int rowCount,
  String searchText = '',
  DateTime? copiedAt,
}) {
  return EmployeeDocumentLifecycleAuditExportReceipt(
    id: id,
    employeeId: '3',
    employeeName: 'Aisha Rahman',
    status: EmployeeDocumentLifecycleAuditExportReceiptStatus.copied,
    exportStatus:
        group == EmployeeDocumentLifecycleAuditFilterGroup.all &&
                searchText.isEmpty
            ? EmployeeDocumentLifecycleAuditExportStatus.ready
            : EmployeeDocumentLifecycleAuditExportStatus.scoped,
    group: group,
    searchText: searchText,
    copiedBy: 'People Operations',
    fileName: 'aisha-rahman-document-lifecycle-audit-${group.name}.csv',
    rowCount: rowCount,
    totalCount: 3,
    generatedAt: DateTime(2026, 6, 1, 12),
    copiedAt: copiedAt ?? DateTime(2026, 6, 1, 12, 5),
  );
}

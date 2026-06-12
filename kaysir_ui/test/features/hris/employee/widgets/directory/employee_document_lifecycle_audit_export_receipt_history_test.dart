import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_export_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_export_receipt_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_filter_models.dart';
import 'package:kaysir/features/hris/employee/widgets/directory/employee_document_lifecycle_audit_export_receipt_history.dart';

void main() {
  testWidgets('document lifecycle audit export receipt history renders empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmployeeDocumentLifecycleAuditExportReceiptHistory(
            profile: _profile(const []),
          ),
        ),
      ),
    );

    expect(find.text('Lifecycle export receipt history'), findsOneWidget);
    expect(find.text('0 logged'), findsOneWidget);
    expect(find.text('No lifecycle audit export receipts yet'), findsOneWidget);
  });

  testWidgets('document lifecycle audit export receipt history renders latest', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EmployeeDocumentLifecycleAuditExportReceiptHistory(
              profile: _profile([
                _receipt(
                  id: 'EDLER-3-001',
                  group: EmployeeDocumentLifecycleAuditFilterGroup.all,
                  rowCount: 3,
                ),
                _receipt(
                  id: 'EDLER-3-002',
                  group: EmployeeDocumentLifecycleAuditFilterGroup.fulfillment,
                  searchText: 'payroll',
                  rowCount: 1,
                  copiedAt: DateTime(2026, 6, 1, 12, 15),
                ),
              ]),
            ),
          ),
        ),
      ),
    );

    expect(find.text('2 logged'), findsOneWidget);
    expect(
      find.text('Copy CSV by People Operations - 1 event'),
      findsOneWidget,
    );
    expect(find.text('Fulfilled matching "payroll"'), findsOneWidget);
    expect(
      find.text(
        'aisha-rahman-document-lifecycle-audit-fulfillment.csv - 1/3 lifecycle events',
      ),
      findsOneWidget,
    );
  });
}

EmployeeDocumentLifecycleAuditExportReceiptProfile _profile(
  List<EmployeeDocumentLifecycleAuditExportReceipt> receipts,
) {
  return EmployeeDocumentLifecycleAuditExportReceiptProfile(
    employeeId: '3',
    employeeName: 'Aisha Rahman',
    asOfDate: DateTime(2026, 6, 1),
    receipts: receipts,
  );
}

EmployeeDocumentLifecycleAuditExportReceipt _receipt({
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

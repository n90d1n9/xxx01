import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_export_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_filter_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_lifecycle_audit_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_document_vault_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_lifecycle_audit_export_receipt_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_lifecycle_audit_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_request_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_document_vault_coverage_provider.dart';

void main() {
  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
  }

  test('employee document lifecycle export receipt records copied exports', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final coverage =
        container.read(employeeDocumentVaultCoverageProvider('4'))!;
    final payrollGap = coverage.items.singleWhere(
      (item) => item.category == EmployeeDocumentVaultCategory.payrollTax,
    );
    final request = container
        .read(employeeDocumentRequestProfileProvider('4').notifier)
        .submitCoverageRequest(payrollGap);
    container
        .read(employeeDocumentLifecycleAuditProvider('4').notifier)
        .recordRequest(
          request: request,
          type: EmployeeDocumentLifecycleAuditEventType.requestCreated,
        );
    final audit = container.read(employeeDocumentLifecycleAuditProvider('4'))!;
    final notifier = container.read(
      employeeDocumentLifecycleAuditExportReceiptProvider('4').notifier,
    );

    final fullPreview = EmployeeDocumentLifecycleAuditExportPreview(
      profile: audit,
      entries: audit.sortedEntries,
      query: const EmployeeDocumentLifecycleAuditFilterQuery(),
      generatedAt: DateTime(2026, 5, 30, 10),
    );
    final firstReceipt = notifier.recordCopy(
      preview: fullPreview,
      copiedBy: 'HR Lead',
      copiedAt: DateTime(2026, 5, 30, 10, 15),
    );

    expect(firstReceipt.id, 'EDLER-4-001');
    expect(firstReceipt.copiedBy, 'HR Lead');
    expect(firstReceipt.isScoped, isFalse);

    const scopedQuery = EmployeeDocumentLifecycleAuditFilterQuery(
      group: EmployeeDocumentLifecycleAuditFilterGroup.request,
      searchText: 'payroll',
    );
    final scopedPreview = EmployeeDocumentLifecycleAuditExportPreview(
      profile: audit,
      entries: scopedQuery.applyTo(audit.sortedEntries),
      query: scopedQuery,
      generatedAt: DateTime(2026, 5, 30, 10),
    );
    notifier.recordCopy(
      preview: scopedPreview,
      copiedAt: DateTime(2026, 5, 30, 10, 30),
    );

    final receipts =
        container.read(
          employeeDocumentLifecycleAuditExportReceiptProvider('4'),
        )!;
    expect(receipts.totalCount, 2);
    expect(receipts.fullCount, 1);
    expect(receipts.scopedCount, 1);
    expect(receipts.totalRows, 2);
    expect(receipts.latestReceipt?.id, 'EDLER-4-002');
    expect(receipts.latestReceipt?.filterLabel, 'Requests matching "payroll"');
  });

  test('employee document lifecycle export receipt rejects empty exports', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final audit = container.read(employeeDocumentLifecycleAuditProvider('4'))!;
    final preview = EmployeeDocumentLifecycleAuditExportPreview(
      profile: audit,
      entries: const [],
      query: const EmployeeDocumentLifecycleAuditFilterQuery(
        searchText: 'missing',
      ),
      generatedAt: DateTime(2026, 5, 30, 10),
    );

    expect(
      () => container
          .read(
            employeeDocumentLifecycleAuditExportReceiptProvider('4').notifier,
          )
          .recordCopy(preview: preview),
      throwsStateError,
    );
  });

  test(
    'employee document lifecycle export receipt handles missing employee',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      expect(
        container.read(
          employeeDocumentLifecycleAuditExportReceiptProvider('missing'),
        ),
        isNull,
      );
    },
  );
}

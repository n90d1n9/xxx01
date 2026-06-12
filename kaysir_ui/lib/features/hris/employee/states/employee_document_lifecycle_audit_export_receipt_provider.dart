import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_document_lifecycle_audit_export_models.dart';
import '../models/employee_document_lifecycle_audit_export_receipt_models.dart';
import 'employee_document_lifecycle_audit_provider.dart';

/// Stores copy receipts for employee document lifecycle audit exports.
final employeeDocumentLifecycleAuditExportReceiptProvider =
    StateNotifierProvider.family<
      EmployeeDocumentLifecycleAuditExportReceiptNotifier,
      EmployeeDocumentLifecycleAuditExportReceiptProfile?,
      String
    >((ref, employeeId) {
      final auditProfile = ref.read(
        employeeDocumentLifecycleAuditProvider(employeeId),
      );
      if (auditProfile == null) {
        return EmployeeDocumentLifecycleAuditExportReceiptNotifier(null);
      }

      return EmployeeDocumentLifecycleAuditExportReceiptNotifier(
        EmployeeDocumentLifecycleAuditExportReceiptProfile(
          employeeId: auditProfile.employeeId,
          employeeName: auditProfile.employeeName,
          asOfDate: auditProfile.asOfDate,
          receipts: const [],
        ),
      );
    });

/// Mutates local receipt history when document lifecycle exports are copied.
class EmployeeDocumentLifecycleAuditExportReceiptNotifier
    extends StateNotifier<EmployeeDocumentLifecycleAuditExportReceiptProfile?> {
  EmployeeDocumentLifecycleAuditExportReceiptNotifier(super.state);

  EmployeeDocumentLifecycleAuditExportReceipt recordCopy({
    required EmployeeDocumentLifecycleAuditExportPreview preview,
    String copiedBy = 'People Operations',
    DateTime? copiedAt,
  }) {
    final profile = state;
    if (profile == null) {
      throw StateError('Document lifecycle audit export receipts unavailable');
    }
    if (!preview.isReady) {
      throw StateError('Document lifecycle audit export is not ready');
    }

    final receipt = EmployeeDocumentLifecycleAuditExportReceipt(
      id: _nextReceiptId(profile),
      employeeId: preview.profile.employeeId,
      employeeName: preview.profile.employeeName,
      status: EmployeeDocumentLifecycleAuditExportReceiptStatus.copied,
      exportStatus: preview.status,
      group: preview.query.group,
      searchText: preview.query.searchText,
      copiedBy: _actor(copiedBy),
      fileName: preview.fileName,
      rowCount: preview.rowCount,
      totalCount: preview.profile.totalCount,
      generatedAt: preview.generatedAt,
      copiedAt: copiedAt ?? profile.asOfDate,
    );

    state = profile.copyWith(receipts: [receipt, ...profile.receipts]);
    return receipt;
  }

  String _nextReceiptId(
    EmployeeDocumentLifecycleAuditExportReceiptProfile profile,
  ) {
    var index = profile.receipts.length + 1;
    while (true) {
      final id =
          'EDLER-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.receipts.any((receipt) => receipt.id == id)) {
        return id;
      }
      index++;
    }
  }

  String _actor(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'People Operations' : trimmed;
  }
}

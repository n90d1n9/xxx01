import 'employee_document_lifecycle_audit_export_models.dart';
import 'employee_document_lifecycle_audit_filter_models.dart';

/// Delivery state for a copied document lifecycle audit export.
enum EmployeeDocumentLifecycleAuditExportReceiptStatus {
  copied('Copied', 'Clipboard copy recorded');

  final String label;
  final String description;

  const EmployeeDocumentLifecycleAuditExportReceiptStatus(
    this.label,
    this.description,
  );
}

/// Immutable receipt proving one document lifecycle audit export was copied.
class EmployeeDocumentLifecycleAuditExportReceipt {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeDocumentLifecycleAuditExportReceiptStatus status;
  final EmployeeDocumentLifecycleAuditExportStatus exportStatus;
  final EmployeeDocumentLifecycleAuditFilterGroup group;
  final String searchText;
  final String copiedBy;
  final String fileName;
  final int rowCount;
  final int totalCount;
  final DateTime generatedAt;
  final DateTime copiedAt;

  const EmployeeDocumentLifecycleAuditExportReceipt({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.status,
    required this.exportStatus,
    required this.group,
    required this.searchText,
    required this.copiedBy,
    required this.fileName,
    required this.rowCount,
    required this.totalCount,
    required this.generatedAt,
    required this.copiedAt,
  });

  bool get isScoped {
    return group != EmployeeDocumentLifecycleAuditFilterGroup.all ||
        searchText.trim().isNotEmpty;
  }

  String get statusLabel => status.label;

  String get exportStatusLabel => exportStatus.label;

  String get scopeLabel => group.label;

  String get rowCountLabel => '$rowCount event${rowCount == 1 ? '' : 's'}';

  String get filterLabel {
    final search = searchText.trim();
    if (search.isEmpty) return isScoped ? group.label : 'Full export';
    return '${group.label} matching "$search"';
  }

  String get summaryLabel {
    return 'Copy CSV by $copiedBy - $rowCountLabel';
  }

  String get packageLabel {
    return '$fileName - $rowCount/$totalCount lifecycle events';
  }

  String get copiedAtLabel => _formatTimestamp(copiedAt);

  String get generatedAtLabel => _formatTimestamp(generatedAt);
}

/// Per-employee history of copied document lifecycle audit exports.
class EmployeeDocumentLifecycleAuditExportReceiptProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeDocumentLifecycleAuditExportReceipt> receipts;

  const EmployeeDocumentLifecycleAuditExportReceiptProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.receipts,
  });

  EmployeeDocumentLifecycleAuditExportReceiptProfile copyWith({
    List<EmployeeDocumentLifecycleAuditExportReceipt>? receipts,
  }) {
    return EmployeeDocumentLifecycleAuditExportReceiptProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      receipts: receipts ?? this.receipts,
    );
  }

  List<EmployeeDocumentLifecycleAuditExportReceipt> get sortedReceipts {
    final sorted = [...receipts]..sort((a, b) {
      final dateCompare = b.copiedAt.compareTo(a.copiedAt);
      if (dateCompare != 0) return dateCompare;
      return b.id.compareTo(a.id);
    });
    return sorted;
  }

  List<EmployeeDocumentLifecycleAuditExportReceipt> get latestReceipts {
    return sortedReceipts.take(3).toList();
  }

  EmployeeDocumentLifecycleAuditExportReceipt? get latestReceipt {
    final latest = latestReceipts;
    return latest.isEmpty ? null : latest.first;
  }

  int get totalCount => receipts.length;

  int get fullCount => receipts.where((receipt) => !receipt.isScoped).length;

  int get scopedCount => receipts.where((receipt) => receipt.isScoped).length;

  int get totalRows {
    return receipts.fold(0, (total, receipt) => total + receipt.rowCount);
  }

  String get nextAction {
    final latest = latestReceipt;
    if (latest == null) {
      return 'Copied lifecycle audit exports will be logged here.';
    }
    return 'Latest receipt: ${latest.summaryLabel}.';
  }
}

String _formatTimestamp(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.year}-$month-$day $hour:$minute';
}

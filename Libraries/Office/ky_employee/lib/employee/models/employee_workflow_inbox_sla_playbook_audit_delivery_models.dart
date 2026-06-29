import 'employee_workflow_inbox_sla_playbook_audit_export_access_models.dart';
import 'employee_workflow_inbox_sla_playbook_audit_export_models.dart';

/// Delivery state for a copied workflow inbox SLA playbook audit package.
enum EmployeeWorkflowInboxSlaPlaybookAuditDeliveryStatus {
  copied('Copied', 'Clipboard copy recorded');

  final String label;
  final String description;

  const EmployeeWorkflowInboxSlaPlaybookAuditDeliveryStatus(
    this.label,
    this.description,
  );
}

/// Immutable receipt proving one playbook audit package was copied for use.
class EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt {
  final String id;
  final String employeeId;
  final String employeeName;
  final EmployeeWorkflowInboxSlaPlaybookAuditExportRole role;
  final EmployeeWorkflowInboxSlaPlaybookAuditExportAction action;
  final EmployeeWorkflowInboxSlaPlaybookAuditExportScope scope;
  final EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction redaction;
  final EmployeeWorkflowInboxSlaPlaybookAuditDeliveryStatus status;
  final String fileName;
  final int rowCount;
  final DateTime generatedAt;
  final DateTime deliveredAt;

  const EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.role,
    required this.action,
    required this.scope,
    required this.redaction,
    required this.status,
    required this.fileName,
    required this.rowCount,
    required this.generatedAt,
    required this.deliveredAt,
  });

  String get roleLabel => role.shortLabel;

  String get actionLabel => action.label;

  String get scopeLabel => scope.label;

  String get redactionLabel => redaction.label;

  String get statusLabel => status.label;

  String get rowCountLabel => '$rowCount event${rowCount == 1 ? '' : 's'}';

  bool get isRedacted {
    return redaction !=
        EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.none;
  }

  bool get isCsv {
    return action == EmployeeWorkflowInboxSlaPlaybookAuditExportAction.copyCsv;
  }

  String get summaryLabel {
    return '$actionLabel by ${role.label} - $rowCountLabel';
  }

  String get packageLabel {
    return '$fileName - ${redaction.shortLabel} evidence';
  }

  String get deliveredAtLabel => _formatTimestamp(deliveredAt);

  String get generatedAtLabel => _formatTimestamp(generatedAt);
}

/// Per-employee history of copied workflow inbox SLA playbook audit packages.
class EmployeeWorkflowInboxSlaPlaybookAuditDeliveryProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt> deliveries;

  const EmployeeWorkflowInboxSlaPlaybookAuditDeliveryProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.deliveries,
  });

  EmployeeWorkflowInboxSlaPlaybookAuditDeliveryProfile copyWith({
    List<EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt>? deliveries,
  }) {
    return EmployeeWorkflowInboxSlaPlaybookAuditDeliveryProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      deliveries: deliveries ?? this.deliveries,
    );
  }

  List<EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt>
  get sortedDeliveries {
    final sorted = [...deliveries]..sort((a, b) {
      final dateCompare = b.deliveredAt.compareTo(a.deliveredAt);
      if (dateCompare != 0) return dateCompare;
      return b.id.compareTo(a.id);
    });
    return sorted;
  }

  List<EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt> get latest {
    return sortedDeliveries.take(3).toList();
  }

  EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt? get latestReceipt {
    final receipts = latest;
    return receipts.isEmpty ? null : receipts.first;
  }

  int get totalCount => deliveries.length;

  int get csvCount => deliveries.where((delivery) => delivery.isCsv).length;

  int get textCount => totalCount - csvCount;

  int get redactedCount {
    return deliveries.where((delivery) => delivery.isRedacted).length;
  }

  String get nextAction {
    final latest = latestReceipt;
    if (latest == null) {
      return 'Copied playbook audit packages will be logged here.';
    }
    return 'Latest delivery: ${latest.summaryLabel}.';
  }
}

String _formatTimestamp(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.year}-$month-$day $hour:$minute';
}

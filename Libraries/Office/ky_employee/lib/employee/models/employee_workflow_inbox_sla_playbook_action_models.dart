import 'employee_workflow_inbox_models.dart';
import 'employee_workflow_inbox_sla_playbook_models.dart';

/// Primary command available for an SLA recovery playbook step.
enum EmployeeWorkflowInboxSlaPlaybookActionType {
  markEscalated('Mark escalated'),
  assignBackup('Assign backup'),
  startRecovery('Start recovery'),
  confirmProgress('Confirm progress');

  final String label;

  const EmployeeWorkflowInboxSlaPlaybookActionType(this.label);
}

/// Audit event kind for workflow inbox SLA playbook receipts.
enum EmployeeWorkflowInboxSlaPlaybookActionReceiptKind {
  action('Action'),
  reasonCorrection('Reason correction');

  final String label;

  const EmployeeWorkflowInboxSlaPlaybookActionReceiptKind(this.label);
}

/// Immutable receipt written when a workflow inbox SLA playbook action runs.
class EmployeeWorkflowInboxSlaPlaybookActionReceipt {
  final String id;
  final EmployeeWorkflowInboxSlaPlaybookActionReceiptKind receiptKind;
  final String employeeId;
  final String employeeName;
  final String stepId;
  final String stepTitle;
  final EmployeeWorkflowInboxSlaPlaybookStepType stepType;
  final EmployeeWorkflowInboxSlaPlaybookActionType actionType;
  final String actor;
  final String owner;
  final int itemCount;
  final List<EmployeeWorkflowInboxSource> sources;
  final String reason;
  final String previousReason;
  final String? correctedReceiptId;
  final DateTime decidedAt;

  const EmployeeWorkflowInboxSlaPlaybookActionReceipt({
    required this.id,
    this.receiptKind = EmployeeWorkflowInboxSlaPlaybookActionReceiptKind.action,
    required this.employeeId,
    required this.employeeName,
    required this.stepId,
    required this.stepTitle,
    required this.stepType,
    required this.actionType,
    required this.actor,
    required this.owner,
    required this.itemCount,
    required this.sources,
    this.reason = '',
    this.previousReason = '',
    this.correctedReceiptId,
    required this.decidedAt,
  });

  bool get isCorrection =>
      receiptKind ==
      EmployeeWorkflowInboxSlaPlaybookActionReceiptKind.reasonCorrection;

  String get actionLabel {
    return isCorrection ? receiptKind.label : actionType.label;
  }

  String get sourceLabel {
    if (sources.isEmpty) return 'No source';
    if (sources.length == 1) return sources.first.label;
    return '${sources.length} sources';
  }

  String get itemCountLabel {
    return '$itemCount item${itemCount == 1 ? '' : 's'}';
  }

  bool get hasReason => reason.trim().isNotEmpty;

  String get reasonLabel {
    final normalized = reason.trim();
    return normalized.isEmpty ? 'No reason provided' : normalized;
  }

  bool get hasPreviousReason => previousReason.trim().isNotEmpty;

  String get previousReasonLabel {
    final normalized = previousReason.trim();
    return normalized.isEmpty ? 'No previous reason' : normalized;
  }

  String get summaryLabel {
    if (isCorrection) {
      return 'Reason correction recorded for ${stepType.label.toLowerCase()}.';
    }
    return '${actionType.label} recorded for ${stepType.label.toLowerCase()}.';
  }
}

/// Per-employee receipt stream for workflow inbox SLA playbook actions.
class EmployeeWorkflowInboxSlaPlaybookActionProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeWorkflowInboxSlaPlaybookActionReceipt> receipts;

  const EmployeeWorkflowInboxSlaPlaybookActionProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.receipts,
  });

  EmployeeWorkflowInboxSlaPlaybookActionProfile copyWith({
    List<EmployeeWorkflowInboxSlaPlaybookActionReceipt>? receipts,
  }) {
    return EmployeeWorkflowInboxSlaPlaybookActionProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      receipts: receipts ?? this.receipts,
    );
  }

  List<EmployeeWorkflowInboxSlaPlaybookActionReceipt> get sortedReceipts {
    final sorted = [...receipts]..sort((a, b) {
      final dateCompare = b.decidedAt.compareTo(a.decidedAt);
      if (dateCompare != 0) return dateCompare;
      return b.id.compareTo(a.id);
    });
    return sorted;
  }

  List<EmployeeWorkflowInboxSlaPlaybookActionReceipt> get latestReceipts {
    return sortedReceipts.take(3).toList();
  }

  List<EmployeeWorkflowInboxSlaPlaybookActionType> get actionTypes {
    final actions =
        receipts.map((receipt) => receipt.actionType).toSet().toList()
          ..sort((a, b) => a.index.compareTo(b.index));
    return actions;
  }

  int get totalCount => receipts.length;

  bool get hasReceipts => receipts.isNotEmpty;

  int get correctionCount {
    return receipts.where((receipt) => receipt.isCorrection).length;
  }

  int get reasonedCount {
    return receipts.where((receipt) => receipt.hasReason).length;
  }

  String get reasonCoverageLabel {
    if (totalCount == 0) return 'No reasons';
    return '$reasonedCount/$totalCount with reason';
  }

  int get escalationCount {
    return receipts
        .where(
          (receipt) =>
              receipt.actionType ==
              EmployeeWorkflowInboxSlaPlaybookActionType.markEscalated,
        )
        .length;
  }

  List<String> get ownerNames {
    final owners =
        receipts
            .map((receipt) => receipt.owner.trim())
            .where((owner) => owner.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return owners;
  }

  int get ownerCount => ownerNames.length;

  String get ownerCoverageLabel {
    if (ownerCount == 0) return 'No owners';
    if (ownerCount == 1) return ownerNames.first;
    return '$ownerCount owners';
  }

  String get latestActionLabel {
    final sorted = sortedReceipts;
    final latestReceipt = sorted.isEmpty ? null : sorted.first;
    if (latestReceipt == null) return 'No playbook audit events yet.';
    return '${latestReceipt.actionLabel} by ${latestReceipt.actor}.';
  }

  EmployeeWorkflowInboxSlaPlaybookActionReceipt? latestForStep(String stepId) {
    for (final receipt in sortedReceipts) {
      if (receipt.stepId == stepId) return receipt;
    }
    return null;
  }

  List<EmployeeWorkflowInboxSlaPlaybookActionReceipt> receiptsForFilter(
    EmployeeWorkflowInboxSlaPlaybookActionAuditFilter filter,
  ) {
    return sortedReceipts.where(filter.matches).toList();
  }

  String get nextAction {
    if (totalCount == 0) return 'Run a playbook action to start recovery.';
    return '$totalCount playbook action${totalCount == 1 ? '' : 's'} recorded.';
  }

  String get auditSummary {
    if (totalCount == 0) return 'No playbook audit events yet.';
    final eventLabel = '$totalCount event${totalCount == 1 ? '' : 's'}';
    final escalationLabel =
        escalationCount == 0
            ? 'no escalations'
            : '$escalationCount escalation${escalationCount == 1 ? '' : 's'}';
    return '$eventLabel logged across $ownerCoverageLabel with $escalationLabel.';
  }
}

/// Filter value used to inspect workflow inbox SLA playbook audit history.
class EmployeeWorkflowInboxSlaPlaybookActionAuditFilter {
  final EmployeeWorkflowInboxSlaPlaybookActionType? actionType;
  final String? owner;

  const EmployeeWorkflowInboxSlaPlaybookActionAuditFilter({
    this.actionType,
    this.owner,
  });

  static const all = EmployeeWorkflowInboxSlaPlaybookActionAuditFilter();

  bool get isActive => actionType != null || _normalizedOwner.isNotEmpty;

  String get actionLabel => actionType?.label ?? 'All actions';

  String get ownerLabel => _normalizedOwner.isEmpty ? 'All owners' : owner!;

  EmployeeWorkflowInboxSlaPlaybookActionAuditFilter withActionType(
    EmployeeWorkflowInboxSlaPlaybookActionType? value,
  ) {
    return EmployeeWorkflowInboxSlaPlaybookActionAuditFilter(
      actionType: value,
      owner: owner,
    );
  }

  EmployeeWorkflowInboxSlaPlaybookActionAuditFilter withOwner(String? value) {
    final normalized = value?.trim() ?? '';
    return EmployeeWorkflowInboxSlaPlaybookActionAuditFilter(
      actionType: actionType,
      owner: normalized.isEmpty ? null : normalized,
    );
  }

  EmployeeWorkflowInboxSlaPlaybookActionAuditFilter clear() => all;

  bool matches(EmployeeWorkflowInboxSlaPlaybookActionReceipt receipt) {
    if (actionType != null && receipt.actionType != actionType) return false;
    final selectedOwner = _normalizedOwner;
    if (selectedOwner.isEmpty) return true;
    return receipt.owner.trim().toLowerCase() == selectedOwner.toLowerCase();
  }

  String get _normalizedOwner => owner?.trim() ?? '';
}

EmployeeWorkflowInboxSlaPlaybookActionType
employeeWorkflowInboxSlaPlaybookActionForStep(
  EmployeeWorkflowInboxSlaPlaybookStep step,
) {
  return switch (step.type) {
    EmployeeWorkflowInboxSlaPlaybookStepType.leadershipEscalation ||
    EmployeeWorkflowInboxSlaPlaybookStepType.managerEscalation =>
      EmployeeWorkflowInboxSlaPlaybookActionType.markEscalated,
    EmployeeWorkflowInboxSlaPlaybookStepType.ownerRebalance =>
      EmployeeWorkflowInboxSlaPlaybookActionType.assignBackup,
    EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance ||
    EmployeeWorkflowInboxSlaPlaybookStepType.overdueRecovery =>
      EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery,
    EmployeeWorkflowInboxSlaPlaybookStepType.dueSoonWatch =>
      EmployeeWorkflowInboxSlaPlaybookActionType.confirmProgress,
  };
}

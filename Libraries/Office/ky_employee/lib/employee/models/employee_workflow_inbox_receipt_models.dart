import 'employee_next_action_models.dart';
import 'employee_workflow_inbox_models.dart';

/// Immutable audit receipt written after an HR workflow inbox action runs.
class EmployeeWorkflowInboxActionReceipt {
  final String id;
  final String employeeId;
  final String employeeName;
  final String workflowItemId;
  final String sourceRecordId;
  final String title;
  final EmployeeWorkflowInboxSource source;
  final EmployeeWorkflowInboxAction action;
  final EmployeeNextActionArea area;
  final String actor;
  final String owner;
  final String previousStatus;
  final DateTime decidedAt;

  const EmployeeWorkflowInboxActionReceipt({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.workflowItemId,
    required this.sourceRecordId,
    required this.title,
    required this.source,
    required this.action,
    required this.area,
    required this.actor,
    required this.owner,
    required this.previousStatus,
    required this.decidedAt,
  });

  String get actionLabel => action.label;

  String get sourceLabel => source.label;

  bool get isPayroll => area == EmployeeNextActionArea.pay;

  bool get isGovernedAction {
    return action == EmployeeWorkflowInboxAction.approve ||
        action == EmployeeWorkflowInboxAction.apply ||
        action == EmployeeWorkflowInboxAction.activate ||
        action == EmployeeWorkflowInboxAction.schedule;
  }

  String get summaryLabel {
    return '${action.label} completed from ${source.label}.';
  }

  String get ownershipLabel {
    if (actor == owner) return actor;
    return '$actor for $owner';
  }
}

/// Per-employee receipt stream for HR workflow inbox actions.
class EmployeeWorkflowInboxReceiptProfile {
  final String employeeId;
  final String employeeName;
  final DateTime asOfDate;
  final List<EmployeeWorkflowInboxActionReceipt> receipts;

  const EmployeeWorkflowInboxReceiptProfile({
    required this.employeeId,
    required this.employeeName,
    required this.asOfDate,
    required this.receipts,
  });

  EmployeeWorkflowInboxReceiptProfile copyWith({
    List<EmployeeWorkflowInboxActionReceipt>? receipts,
  }) {
    return EmployeeWorkflowInboxReceiptProfile(
      employeeId: employeeId,
      employeeName: employeeName,
      asOfDate: asOfDate,
      receipts: receipts ?? this.receipts,
    );
  }

  List<EmployeeWorkflowInboxActionReceipt> get sortedReceipts {
    final sorted = [...receipts]..sort((a, b) {
      final dateCompare = b.decidedAt.compareTo(a.decidedAt);
      if (dateCompare != 0) return dateCompare;
      return b.id.compareTo(a.id);
    });
    return sorted;
  }

  List<EmployeeWorkflowInboxActionReceipt> get latestReceipts {
    return sortedReceipts.take(3).toList();
  }

  EmployeeWorkflowInboxActionReceipt? get latestReceipt {
    final receipts = latestReceipts;
    return receipts.isEmpty ? null : receipts.first;
  }

  int get totalCount => receipts.length;

  int get governedCount {
    return receipts.where((receipt) => receipt.isGovernedAction).length;
  }

  int get payrollCount {
    return receipts.where((receipt) => receipt.isPayroll).length;
  }

  int get sourceCount {
    return receipts.map((receipt) => receipt.source).toSet().length;
  }

  String get nextAction {
    final latest = latestReceipt;
    if (latest == null) {
      return 'Inbox action receipts will appear after HR work is completed.';
    }
    return 'Latest receipt: ${latest.actionLabel} ${latest.title}.';
  }
}

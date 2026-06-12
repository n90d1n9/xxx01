/// Domain-neutral finance categories used by project budget and expense records.
enum ProjectFinanceCategory {
  labor,
  material,
  vendor,
  technology,
  logistics,
  governance,
  training,
  reserve,
  pettyCash,
  other,
}

/// Lifecycle status for project finance ledger records.
enum ProjectFinanceRecordStatus {
  planned,
  submitted,
  approved,
  paid,
  reconciled,
  blocked,
}

/// Planned budget line with committed and spent values for one project category.
class ProjectBudgetLine {
  const ProjectBudgetLine({
    required this.id,
    required this.projectId,
    required this.category,
    required this.title,
    required this.owner,
    required this.plannedAmount,
    required this.committedAmount,
    required this.spentAmount,
  });

  final String id;
  final String projectId;
  final ProjectFinanceCategory category;
  final String title;
  final String owner;
  final double plannedAmount;
  final double committedAmount;
  final double spentAmount;

  double get remainingAmount => plannedAmount - spentAmount;
  double get utilization =>
      plannedAmount <= 0 ? 0 : (spentAmount / plannedAmount).clamp(0, 2);
}

/// Expense request raised against a project budget category.
class ProjectExpenseRequest {
  const ProjectExpenseRequest({
    required this.id,
    required this.projectId,
    required this.category,
    required this.title,
    required this.requestedBy,
    required this.requestedAmount,
    required this.status,
    required this.evidenceLabel,
  });

  final String id;
  final String projectId;
  final ProjectFinanceCategory category;
  final String title;
  final String requestedBy;
  final double requestedAmount;
  final ProjectFinanceRecordStatus status;
  final String evidenceLabel;

  bool get isOpen =>
      status == ProjectFinanceRecordStatus.submitted ||
      status == ProjectFinanceRecordStatus.approved ||
      status == ProjectFinanceRecordStatus.blocked;
}

/// Petty-cash or project-float entry that must be paid and reconciled.
class ProjectPettyCashEntry {
  const ProjectPettyCashEntry({
    required this.id,
    required this.projectId,
    required this.title,
    required this.custodian,
    required this.amount,
    required this.status,
    required this.reconciliationDueDate,
  });

  final String id;
  final String projectId;
  final String title;
  final String custodian;
  final double amount;
  final ProjectFinanceRecordStatus status;
  final DateTime reconciliationDueDate;

  bool get isOpen => status != ProjectFinanceRecordStatus.reconciled;
}

/// Approval record for project spend authority and budget exceptions.
class ProjectApprovalRecord {
  const ProjectApprovalRecord({
    required this.id,
    required this.projectId,
    required this.title,
    required this.approver,
    required this.amount,
    required this.status,
    required this.thresholdLabel,
  });

  final String id;
  final String projectId;
  final String title;
  final String approver;
  final double amount;
  final ProjectFinanceRecordStatus status;
  final String thresholdLabel;

  bool get isOpen =>
      status == ProjectFinanceRecordStatus.submitted ||
      status == ProjectFinanceRecordStatus.blocked;
}

/// Reconciliation evidence required to close project finance activity.
class ProjectReconciliationEvidence {
  const ProjectReconciliationEvidence({
    required this.id,
    required this.projectId,
    required this.title,
    required this.owner,
    required this.status,
    required this.evidenceLabel,
  });

  final String id;
  final String projectId;
  final String title;
  final String owner;
  final ProjectFinanceRecordStatus status;
  final String evidenceLabel;

  bool get isOpen => status != ProjectFinanceRecordStatus.reconciled;
}

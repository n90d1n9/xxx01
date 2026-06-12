import 'package:flutter/material.dart';

import '../models/project_finance_ledger.dart';
import 'project_finance_ledger_summary_service.dart';

/// Filter lens for browsing project finance ledger records.
enum ProjectFinanceLedgerRecordLens {
  all,
  budget,
  expense,
  pettyCash,
  approval,
  evidence,
  openItems,
}

/// Record family used to normalize ledger rows from multiple finance sources.
enum ProjectFinanceLedgerRecordKind {
  budget,
  expense,
  pettyCash,
  approval,
  evidence,
}

/// UI-ready ledger row for budget, expense, cash, approval, and evidence work.
class ProjectFinanceLedgerRecordRow {
  const ProjectFinanceLedgerRecordRow({
    required this.id,
    required this.kind,
    required this.title,
    required this.ownerLabel,
    required this.owner,
    required this.amount,
    required this.status,
    required this.detail,
    required this.isOpen,
    this.category,
    this.dueDate,
  });

  final String id;
  final ProjectFinanceLedgerRecordKind kind;
  final String title;
  final String ownerLabel;
  final String owner;
  final double amount;
  final ProjectFinanceRecordStatus status;
  final String detail;
  final bool isOpen;
  final ProjectFinanceCategory? category;
  final DateTime? dueDate;

  bool get isBlocked => status == ProjectFinanceRecordStatus.blocked;
  String get amountLabel => _money(amount);

  String get ownerText => '$ownerLabel: $owner';

  String get dueDateLabel {
    final date = dueDate;
    if (date == null) return '';
    return 'Due ${_dateLabel(date)}';
  }
}

/// Project finance ledger records flattened for filtering and operational use.
class ProjectFinanceLedgerRecordsView {
  const ProjectFinanceLedgerRecordsView({
    required this.projectId,
    required this.rows,
  });

  final String projectId;
  final List<ProjectFinanceLedgerRecordRow> rows;

  int get rowCount => rows.length;
  int get openCount => rows.where((row) => row.isOpen).length;
  int get blockedCount => rows.where((row) => row.isBlocked).length;

  ProjectFinanceLedgerRecordRow? get priorityRow {
    if (rows.isEmpty) return null;
    return rows.first;
  }

  List<ProjectFinanceLedgerRecordRow> rowsFor(
    ProjectFinanceLedgerRecordLens lens,
  ) {
    return rows.where(lens.matches).toList(growable: false);
  }

  int countFor(ProjectFinanceLedgerRecordLens lens) => rowsFor(lens).length;
}

/// Builds a filterable records view from a project finance ledger summary.
ProjectFinanceLedgerRecordsView buildProjectFinanceLedgerRecordsView(
  ProjectFinanceLedgerSummary summary,
) {
  final rows = [
    for (final line in summary.budgetLines) _budgetLineRow(line),
    for (final request in summary.expenseRequests) _expenseRequestRow(request),
    for (final entry in summary.pettyCashEntries) _pettyCashRow(entry),
    for (final approval in summary.approvalRecords) _approvalRow(approval),
    for (final evidence in summary.reconciliationEvidence)
      _reconciliationEvidenceRow(evidence),
  ]..sort(_compareRows);

  return ProjectFinanceLedgerRecordsView(
    projectId: summary.projectId,
    rows: List.unmodifiable(rows),
  );
}

ProjectFinanceLedgerRecordRow _budgetLineRow(ProjectBudgetLine line) {
  return ProjectFinanceLedgerRecordRow(
    id: line.id,
    kind: ProjectFinanceLedgerRecordKind.budget,
    category: line.category,
    title: line.title,
    ownerLabel: 'Owner',
    owner: line.owner,
    amount: line.plannedAmount,
    status: ProjectFinanceRecordStatus.planned,
    detail:
        '${line.category.label} budget - ${_money(line.committedAmount)} committed - ${_money(line.spentAmount)} spent - ${(line.utilization * 100).round()}% used.',
    isOpen: false,
  );
}

ProjectFinanceLedgerRecordRow _expenseRequestRow(
  ProjectExpenseRequest request,
) {
  return ProjectFinanceLedgerRecordRow(
    id: request.id,
    kind: ProjectFinanceLedgerRecordKind.expense,
    category: request.category,
    title: request.title,
    ownerLabel: 'Requester',
    owner: request.requestedBy,
    amount: request.requestedAmount,
    status: request.status,
    detail: '${request.category.label} request - ${request.evidenceLabel}.',
    isOpen: request.isOpen,
  );
}

ProjectFinanceLedgerRecordRow _pettyCashRow(ProjectPettyCashEntry entry) {
  return ProjectFinanceLedgerRecordRow(
    id: entry.id,
    kind: ProjectFinanceLedgerRecordKind.pettyCash,
    category: ProjectFinanceCategory.pettyCash,
    title: entry.title,
    ownerLabel: 'Custodian',
    owner: entry.custodian,
    amount: entry.amount,
    status: entry.status,
    detail:
        'Project float - reconciliation due ${_dateLabel(entry.reconciliationDueDate)}.',
    isOpen: entry.isOpen,
    dueDate: entry.reconciliationDueDate,
  );
}

ProjectFinanceLedgerRecordRow _approvalRow(ProjectApprovalRecord approval) {
  return ProjectFinanceLedgerRecordRow(
    id: approval.id,
    kind: ProjectFinanceLedgerRecordKind.approval,
    title: approval.title,
    ownerLabel: 'Approver',
    owner: approval.approver,
    amount: approval.amount,
    status: approval.status,
    detail: approval.thresholdLabel,
    isOpen: approval.isOpen,
  );
}

ProjectFinanceLedgerRecordRow _reconciliationEvidenceRow(
  ProjectReconciliationEvidence evidence,
) {
  return ProjectFinanceLedgerRecordRow(
    id: evidence.id,
    kind: ProjectFinanceLedgerRecordKind.evidence,
    title: evidence.title,
    ownerLabel: 'Owner',
    owner: evidence.owner,
    amount: 0,
    status: evidence.status,
    detail: evidence.evidenceLabel,
    isOpen: evidence.isOpen,
  );
}

int _compareRows(
  ProjectFinanceLedgerRecordRow left,
  ProjectFinanceLedgerRecordRow right,
) {
  final priorityComparison = _rowPriority(left).compareTo(_rowPriority(right));
  if (priorityComparison != 0) return priorityComparison;

  final leftDate = left.dueDate;
  final rightDate = right.dueDate;
  if (leftDate != null && rightDate != null) {
    final dateComparison = leftDate.compareTo(rightDate);
    if (dateComparison != 0) return dateComparison;
  } else if (leftDate != null) {
    return -1;
  } else if (rightDate != null) {
    return 1;
  }

  return right.amount.compareTo(left.amount);
}

int _rowPriority(ProjectFinanceLedgerRecordRow row) {
  if (row.isBlocked) return 0;
  if (row.isOpen) return 1;
  if (row.kind == ProjectFinanceLedgerRecordKind.budget) return 2;
  return 3;
}

String _money(double value) {
  if (value <= 0) return '-';
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}B';
  }
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}K';
  }
  return value.toStringAsFixed(0);
}

String _dateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

extension ProjectFinanceLedgerRecordLensPresentation
    on ProjectFinanceLedgerRecordLens {
  /// User-facing label for a project finance ledger record lens.
  String get label {
    switch (this) {
      case ProjectFinanceLedgerRecordLens.all:
        return 'All';
      case ProjectFinanceLedgerRecordLens.budget:
        return 'Budget';
      case ProjectFinanceLedgerRecordLens.expense:
        return 'Expenses';
      case ProjectFinanceLedgerRecordLens.pettyCash:
        return 'Petty Cash';
      case ProjectFinanceLedgerRecordLens.approval:
        return 'Approvals';
      case ProjectFinanceLedgerRecordLens.evidence:
        return 'Evidence';
      case ProjectFinanceLedgerRecordLens.openItems:
        return 'Open';
    }
  }

  /// Icon for a project finance ledger record lens.
  IconData get icon {
    switch (this) {
      case ProjectFinanceLedgerRecordLens.all:
        return Icons.view_list_outlined;
      case ProjectFinanceLedgerRecordLens.budget:
        return Icons.account_balance_wallet_outlined;
      case ProjectFinanceLedgerRecordLens.expense:
        return Icons.request_quote_outlined;
      case ProjectFinanceLedgerRecordLens.pettyCash:
        return Icons.payments_outlined;
      case ProjectFinanceLedgerRecordLens.approval:
        return Icons.approval_outlined;
      case ProjectFinanceLedgerRecordLens.evidence:
        return Icons.fact_check_outlined;
      case ProjectFinanceLedgerRecordLens.openItems:
        return Icons.pending_actions_outlined;
    }
  }

  /// Whether this lens should include the given normalized ledger row.
  bool matches(ProjectFinanceLedgerRecordRow row) {
    switch (this) {
      case ProjectFinanceLedgerRecordLens.all:
        return true;
      case ProjectFinanceLedgerRecordLens.budget:
        return row.kind == ProjectFinanceLedgerRecordKind.budget;
      case ProjectFinanceLedgerRecordLens.expense:
        return row.kind == ProjectFinanceLedgerRecordKind.expense;
      case ProjectFinanceLedgerRecordLens.pettyCash:
        return row.kind == ProjectFinanceLedgerRecordKind.pettyCash;
      case ProjectFinanceLedgerRecordLens.approval:
        return row.kind == ProjectFinanceLedgerRecordKind.approval;
      case ProjectFinanceLedgerRecordLens.evidence:
        return row.kind == ProjectFinanceLedgerRecordKind.evidence;
      case ProjectFinanceLedgerRecordLens.openItems:
        return row.isOpen;
    }
  }
}

extension ProjectFinanceLedgerRecordKindPresentation
    on ProjectFinanceLedgerRecordKind {
  /// User-facing label for a project finance ledger record kind.
  String get label {
    switch (this) {
      case ProjectFinanceLedgerRecordKind.budget:
        return 'Budget Line';
      case ProjectFinanceLedgerRecordKind.expense:
        return 'Expense';
      case ProjectFinanceLedgerRecordKind.pettyCash:
        return 'Petty Cash';
      case ProjectFinanceLedgerRecordKind.approval:
        return 'Approval';
      case ProjectFinanceLedgerRecordKind.evidence:
        return 'Evidence';
    }
  }

  /// Icon for a project finance ledger record kind.
  IconData get icon {
    switch (this) {
      case ProjectFinanceLedgerRecordKind.budget:
        return Icons.account_balance_wallet_outlined;
      case ProjectFinanceLedgerRecordKind.expense:
        return Icons.request_quote_outlined;
      case ProjectFinanceLedgerRecordKind.pettyCash:
        return Icons.payments_outlined;
      case ProjectFinanceLedgerRecordKind.approval:
        return Icons.approval_outlined;
      case ProjectFinanceLedgerRecordKind.evidence:
        return Icons.fact_check_outlined;
    }
  }
}

extension ProjectFinanceRecordStatusPresentation on ProjectFinanceRecordStatus {
  /// User-facing label for a project finance record status.
  String get label {
    switch (this) {
      case ProjectFinanceRecordStatus.planned:
        return 'Planned';
      case ProjectFinanceRecordStatus.submitted:
        return 'Submitted';
      case ProjectFinanceRecordStatus.approved:
        return 'Approved';
      case ProjectFinanceRecordStatus.paid:
        return 'Paid';
      case ProjectFinanceRecordStatus.reconciled:
        return 'Reconciled';
      case ProjectFinanceRecordStatus.blocked:
        return 'Blocked';
    }
  }

  /// Icon for a project finance record status.
  IconData get icon {
    switch (this) {
      case ProjectFinanceRecordStatus.planned:
        return Icons.playlist_add_check_outlined;
      case ProjectFinanceRecordStatus.submitted:
        return Icons.outbox_outlined;
      case ProjectFinanceRecordStatus.approved:
        return Icons.approval_outlined;
      case ProjectFinanceRecordStatus.paid:
        return Icons.payments_outlined;
      case ProjectFinanceRecordStatus.reconciled:
        return Icons.verified_outlined;
      case ProjectFinanceRecordStatus.blocked:
        return Icons.block_outlined;
    }
  }

  /// Color for a project finance record status.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectFinanceRecordStatus.planned:
        return colorScheme.primary;
      case ProjectFinanceRecordStatus.submitted:
        return Colors.orange.shade700;
      case ProjectFinanceRecordStatus.approved:
      case ProjectFinanceRecordStatus.paid:
      case ProjectFinanceRecordStatus.reconciled:
        return Colors.green.shade700;
      case ProjectFinanceRecordStatus.blocked:
        return colorScheme.error;
    }
  }
}

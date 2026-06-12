import 'package:flutter/material.dart';

import '../models/project_finance_ledger.dart';
import 'project_budget_change_workspace_service.dart';
import 'project_finance_reconciliation_service.dart';
import 'project_finance_workspace_service.dart';
import 'project_spend_authority_service.dart';

/// Approval readiness level for a project operational approval queue.
enum ProjectApprovalWorkspaceLevel { ready, review, blocked }

/// Approval source family normalized across finance and governance workflows.
enum ProjectApprovalWorkspaceKind {
  spendAuthority,
  expenseApproval,
  pettyCashApproval,
  budgetChange,
  evidenceSignOff,
}

/// UI-ready approval queue item built from reusable project finance signals.
class ProjectApprovalWorkspaceItem {
  const ProjectApprovalWorkspaceItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.kind,
    required this.level,
    required this.icon,
    required this.amount,
    required this.ownerLabel,
    required this.approverLabel,
    required this.evidenceLabel,
    required this.actionLabel,
    required this.sourceLabel,
  });

  final String id;
  final String title;
  final String detail;
  final ProjectApprovalWorkspaceKind kind;
  final ProjectApprovalWorkspaceLevel level;
  final IconData icon;
  final double amount;
  final String ownerLabel;
  final String approverLabel;
  final String evidenceLabel;
  final String actionLabel;
  final String sourceLabel;

  bool get isReady => level == ProjectApprovalWorkspaceLevel.ready;
  bool get isBlocked => level == ProjectApprovalWorkspaceLevel.blocked;
  String get amountLabel => _money(amount);
}

/// Aggregated approval workspace summary for one selected project.
class ProjectApprovalWorkspaceSummary {
  const ProjectApprovalWorkspaceSummary({
    required this.projectId,
    required this.projectName,
    required this.businessDomain,
    required this.items,
  });

  final String projectId;
  final String projectName;
  final String businessDomain;
  final List<ProjectApprovalWorkspaceItem> items;

  int get itemCount => items.length;
  int get readyCount => items.where((item) => item.isReady).length;
  int get reviewCount =>
      items
          .where((item) => item.level == ProjectApprovalWorkspaceLevel.review)
          .length;
  int get blockedCount => items.where((item) => item.isBlocked).length;
  int get approverCount =>
      items
          .map((item) => item.approverLabel.trim())
          .where((label) => label.isNotEmpty)
          .toSet()
          .length;
  double get totalAmount => items.fold(0, (sum, item) => sum + item.amount);
  String get totalAmountLabel => _money(totalAmount);

  ProjectApprovalWorkspaceLevel get level {
    if (blockedCount > 0) return ProjectApprovalWorkspaceLevel.blocked;
    if (reviewCount > 0) return ProjectApprovalWorkspaceLevel.review;
    return ProjectApprovalWorkspaceLevel.ready;
  }

  ProjectApprovalWorkspaceItem? get primaryItem {
    if (items.isEmpty) return null;
    final sorted = [...items]..sort(_compareItems);
    return sorted.first;
  }

  String get title {
    switch (level) {
      case ProjectApprovalWorkspaceLevel.ready:
        return 'Approvals clear';
      case ProjectApprovalWorkspaceLevel.review:
        return 'Approvals need review';
      case ProjectApprovalWorkspaceLevel.blocked:
        return 'Approval route blocked';
    }
  }

  String get detail {
    final primary = primaryItem;
    if (primary == null) {
      return 'No approvals are configured for $businessDomain.';
    }

    return '$readyCount of $itemCount approvals ready - next: ${primary.title}.';
  }
}

/// Builds a single approval queue from finance, budget, and evidence signals.
ProjectApprovalWorkspaceSummary buildProjectApprovalWorkspaceSummary(
  ProjectFinanceWorkspaceSummary summary,
) {
  final budgetChanges = buildProjectBudgetChangeWorkspaceSummary(summary);
  final items = <ProjectApprovalWorkspaceItem>[
    for (final approval in summary.financeLedger.approvalRecords)
      _approvalRecordItem(approval),
    for (final rule in summary.spendAuthority.rules) _spendAuthorityItem(rule),
    for (final request in budgetChanges.requests)
      if (!request.isReady) _budgetChangeItem(request),
    for (final item in summary.financeReconciliation.items)
      if (item.needsAction) _reconciliationItem(summary.project.id, item),
  ]..sort(_compareItems);

  return ProjectApprovalWorkspaceSummary(
    projectId: summary.project.id,
    projectName: summary.project.name,
    businessDomain: summary.project.businessDomain,
    items: List.unmodifiable(items),
  );
}

ProjectApprovalWorkspaceItem _approvalRecordItem(
  ProjectApprovalRecord approval,
) {
  return ProjectApprovalWorkspaceItem(
    id: '${approval.id}-approval-queue',
    title: approval.title,
    detail:
        '${approval.approver} owns ${_money(approval.amount)} approval under ${approval.thresholdLabel.toLowerCase()}.',
    kind: ProjectApprovalWorkspaceKind.expenseApproval,
    level: _fromRecordStatus(approval.status),
    icon: Icons.approval_outlined,
    amount: approval.amount,
    ownerLabel: approval.thresholdLabel,
    approverLabel: approval.approver,
    evidenceLabel: approval.thresholdLabel,
    actionLabel: _recordActionLabel(approval.status),
    sourceLabel: 'Ledger approval',
  );
}

ProjectApprovalWorkspaceItem _spendAuthorityItem(
  ProjectSpendAuthorityRule rule,
) {
  return ProjectApprovalWorkspaceItem(
    id: '${rule.id}-approval-queue',
    title: rule.title,
    detail: rule.detail,
    kind: _kindFromAuthorityBand(rule.band),
    level: _fromAuthorityLevel(rule.level),
    icon: rule.icon,
    amount: 0,
    ownerLabel: rule.band.label,
    approverLabel: rule.approverLabel,
    evidenceLabel: rule.evidenceLabel,
    actionLabel: _authorityActionLabel(rule.level),
    sourceLabel: 'Spend authority',
  );
}

ProjectApprovalWorkspaceItem _budgetChangeItem(
  ProjectBudgetChangeRequest request,
) {
  return ProjectApprovalWorkspaceItem(
    id: '${request.id}-approval-queue',
    title: request.title,
    detail: request.detail,
    kind: ProjectApprovalWorkspaceKind.budgetChange,
    level: _fromBudgetChangeLevel(request.level),
    icon: request.icon,
    amount: request.requestedAmount,
    ownerLabel: request.ownerLabel,
    approverLabel: request.approvalLabel,
    evidenceLabel: request.evidenceLabel,
    actionLabel: request.isBlocked ? 'Resolve change' : 'Review change',
    sourceLabel: _budgetChangeKindLabel(request.kind),
  );
}

ProjectApprovalWorkspaceItem _reconciliationItem(
  String projectId,
  ProjectFinanceReconciliationItem item,
) {
  return ProjectApprovalWorkspaceItem(
    id: '$projectId-${item.id}-approval-queue',
    title: item.title,
    detail: item.detail,
    kind: ProjectApprovalWorkspaceKind.evidenceSignOff,
    level: _fromReconciliationLevel(item.level),
    icon: item.icon,
    amount: 0,
    ownerLabel: item.ownerLabel,
    approverLabel: item.ownerLabel,
    evidenceLabel: item.evidenceLabel,
    actionLabel:
        item.level == ProjectFinanceReconciliationLevel.blocked
            ? 'Resolve evidence'
            : 'Validate proof',
    sourceLabel: item.kind.label,
  );
}

ProjectApprovalWorkspaceLevel _fromRecordStatus(
  ProjectFinanceRecordStatus status,
) {
  switch (status) {
    case ProjectFinanceRecordStatus.blocked:
      return ProjectApprovalWorkspaceLevel.blocked;
    case ProjectFinanceRecordStatus.planned:
    case ProjectFinanceRecordStatus.submitted:
      return ProjectApprovalWorkspaceLevel.review;
    case ProjectFinanceRecordStatus.approved:
    case ProjectFinanceRecordStatus.paid:
    case ProjectFinanceRecordStatus.reconciled:
      return ProjectApprovalWorkspaceLevel.ready;
  }
}

ProjectApprovalWorkspaceLevel _fromAuthorityLevel(
  ProjectSpendAuthorityLevel level,
) {
  switch (level) {
    case ProjectSpendAuthorityLevel.delegated:
      return ProjectApprovalWorkspaceLevel.ready;
    case ProjectSpendAuthorityLevel.guarded:
      return ProjectApprovalWorkspaceLevel.review;
    case ProjectSpendAuthorityLevel.escalation:
      return ProjectApprovalWorkspaceLevel.blocked;
  }
}

ProjectApprovalWorkspaceLevel _fromBudgetChangeLevel(
  ProjectBudgetChangeLevel level,
) {
  switch (level) {
    case ProjectBudgetChangeLevel.ready:
      return ProjectApprovalWorkspaceLevel.ready;
    case ProjectBudgetChangeLevel.review:
      return ProjectApprovalWorkspaceLevel.review;
    case ProjectBudgetChangeLevel.blocked:
      return ProjectApprovalWorkspaceLevel.blocked;
  }
}

ProjectApprovalWorkspaceLevel _fromReconciliationLevel(
  ProjectFinanceReconciliationLevel level,
) {
  switch (level) {
    case ProjectFinanceReconciliationLevel.clean:
      return ProjectApprovalWorkspaceLevel.ready;
    case ProjectFinanceReconciliationLevel.needsEvidence:
      return ProjectApprovalWorkspaceLevel.review;
    case ProjectFinanceReconciliationLevel.blocked:
      return ProjectApprovalWorkspaceLevel.blocked;
  }
}

ProjectApprovalWorkspaceKind _kindFromAuthorityBand(
  ProjectSpendAuthorityBand band,
) {
  switch (band) {
    case ProjectSpendAuthorityBand.pettyCash:
      return ProjectApprovalWorkspaceKind.pettyCashApproval;
    case ProjectSpendAuthorityBand.reimbursement:
    case ProjectSpendAuthorityBand.vendorCommitment:
      return ProjectApprovalWorkspaceKind.spendAuthority;
    case ProjectSpendAuthorityBand.budgetException:
      return ProjectApprovalWorkspaceKind.budgetChange;
  }
}

String _recordActionLabel(ProjectFinanceRecordStatus status) {
  switch (status) {
    case ProjectFinanceRecordStatus.planned:
      return 'Plan approval';
    case ProjectFinanceRecordStatus.submitted:
      return 'Review request';
    case ProjectFinanceRecordStatus.approved:
      return 'Archive approval';
    case ProjectFinanceRecordStatus.paid:
      return 'Link payout';
    case ProjectFinanceRecordStatus.reconciled:
      return 'Closed';
    case ProjectFinanceRecordStatus.blocked:
      return 'Resolve block';
  }
}

String _authorityActionLabel(ProjectSpendAuthorityLevel level) {
  switch (level) {
    case ProjectSpendAuthorityLevel.delegated:
      return 'Ready to use';
    case ProjectSpendAuthorityLevel.guarded:
      return 'Complete setup';
    case ProjectSpendAuthorityLevel.escalation:
      return 'Escalate approval';
  }
}

String _budgetChangeKindLabel(ProjectBudgetChangeKind kind) {
  switch (kind) {
    case ProjectBudgetChangeKind.varianceRecovery:
      return 'Variance Recovery';
    case ProjectBudgetChangeKind.costReforecast:
      return 'Cost Reforecast';
    case ProjectBudgetChangeKind.contingencyRelease:
      return 'Contingency Release';
    case ProjectBudgetChangeKind.evidenceChange:
      return 'Evidence Change';
    case ProjectBudgetChangeKind.baselineLog:
      return 'Baseline Log';
  }
}

int _compareItems(
  ProjectApprovalWorkspaceItem left,
  ProjectApprovalWorkspaceItem right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;

  final amountCompare = right.amount.compareTo(left.amount);
  if (amountCompare != 0) return amountCompare;

  final kindCompare = left.kind.index.compareTo(right.kind.index);
  if (kindCompare != 0) return kindCompare;

  return left.title.compareTo(right.title);
}

int _levelRank(ProjectApprovalWorkspaceLevel level) {
  switch (level) {
    case ProjectApprovalWorkspaceLevel.blocked:
      return 0;
    case ProjectApprovalWorkspaceLevel.review:
      return 1;
    case ProjectApprovalWorkspaceLevel.ready:
      return 2;
  }
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

extension ProjectApprovalWorkspaceLevelPresentation
    on ProjectApprovalWorkspaceLevel {
  /// User-facing label for an approval workspace readiness level.
  String get label {
    switch (this) {
      case ProjectApprovalWorkspaceLevel.ready:
        return 'Ready';
      case ProjectApprovalWorkspaceLevel.review:
        return 'Review';
      case ProjectApprovalWorkspaceLevel.blocked:
        return 'Blocked';
    }
  }

  /// Icon for an approval workspace readiness level.
  IconData get icon {
    switch (this) {
      case ProjectApprovalWorkspaceLevel.ready:
        return Icons.verified_user_outlined;
      case ProjectApprovalWorkspaceLevel.review:
        return Icons.rate_review_outlined;
      case ProjectApprovalWorkspaceLevel.blocked:
        return Icons.block_outlined;
    }
  }

  /// Color for an approval workspace readiness level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectApprovalWorkspaceLevel.ready:
        return Colors.green.shade700;
      case ProjectApprovalWorkspaceLevel.review:
        return Colors.orange.shade700;
      case ProjectApprovalWorkspaceLevel.blocked:
        return colorScheme.error;
    }
  }
}

extension ProjectApprovalWorkspaceKindPresentation
    on ProjectApprovalWorkspaceKind {
  /// User-facing label for an approval workspace source kind.
  String get label {
    switch (this) {
      case ProjectApprovalWorkspaceKind.spendAuthority:
        return 'Spend Authority';
      case ProjectApprovalWorkspaceKind.expenseApproval:
        return 'Expense Approval';
      case ProjectApprovalWorkspaceKind.pettyCashApproval:
        return 'Petty Cash';
      case ProjectApprovalWorkspaceKind.budgetChange:
        return 'Budget Change';
      case ProjectApprovalWorkspaceKind.evidenceSignOff:
        return 'Evidence Sign-Off';
    }
  }
}

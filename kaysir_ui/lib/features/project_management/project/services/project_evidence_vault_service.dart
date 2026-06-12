import 'package:flutter/material.dart';

import '../models/project_finance_ledger.dart';
import '../models/project_portfolio_item.dart';
import 'project_finance_ledger_summary_service.dart';
import 'project_finance_reconciliation_service.dart';
import 'project_finance_workspace_service.dart';

/// Evidence vault readiness level for project proof and closeout records.
enum ProjectEvidenceVaultLevel { ready, review, blocked }

/// Source family for evidence stored in the project evidence vault.
enum ProjectEvidenceVaultKind {
  expenseProof,
  pettyCashReceipt,
  approvalTrail,
  reconciliation,
  milestoneProof,
}

/// UI-ready evidence record normalized from finance and delivery signals.
class ProjectEvidenceVaultRecord {
  const ProjectEvidenceVaultRecord({
    required this.id,
    required this.title,
    required this.detail,
    required this.kind,
    required this.level,
    required this.icon,
    required this.ownerLabel,
    required this.evidenceLabel,
    required this.sourceLabel,
  });

  final String id;
  final String title;
  final String detail;
  final ProjectEvidenceVaultKind kind;
  final ProjectEvidenceVaultLevel level;
  final IconData icon;
  final String ownerLabel;
  final String evidenceLabel;
  final String sourceLabel;

  bool get isReady => level == ProjectEvidenceVaultLevel.ready;
  bool get isBlocked => level == ProjectEvidenceVaultLevel.blocked;
}

/// Project evidence vault summary for records, receipts, approvals, and proof.
class ProjectEvidenceVaultSummary {
  const ProjectEvidenceVaultSummary({
    required this.projectId,
    required this.projectName,
    required this.businessDomain,
    required this.records,
  });

  final String projectId;
  final String projectName;
  final String businessDomain;
  final List<ProjectEvidenceVaultRecord> records;

  int get recordCount => records.length;
  int get readyCount => records.where((record) => record.isReady).length;
  int get reviewCount =>
      records
          .where((record) => record.level == ProjectEvidenceVaultLevel.review)
          .length;
  int get blockedCount => records.where((record) => record.isBlocked).length;
  int get ownerCount =>
      records.map((record) => record.ownerLabel).toSet().length;
  int get readinessPercent =>
      recordCount == 0 ? 0 : ((readyCount / recordCount) * 100).round();

  ProjectEvidenceVaultLevel get level {
    if (blockedCount > 0) return ProjectEvidenceVaultLevel.blocked;
    if (reviewCount > 0) return ProjectEvidenceVaultLevel.review;
    return ProjectEvidenceVaultLevel.ready;
  }

  ProjectEvidenceVaultRecord? get primaryRecord {
    if (records.isEmpty) return null;
    final sorted = [...records]..sort(_compareRecords);
    return sorted.first;
  }

  String get title {
    switch (level) {
      case ProjectEvidenceVaultLevel.ready:
        return 'Evidence vault ready';
      case ProjectEvidenceVaultLevel.review:
        return 'Evidence vault needs review';
      case ProjectEvidenceVaultLevel.blocked:
        return 'Evidence vault blocked';
    }
  }

  String get detail {
    final primary = primaryRecord;
    if (primary == null) {
      return 'No evidence records are configured for $businessDomain.';
    }

    return '$readyCount of $recordCount records ready - next: ${primary.title}.';
  }
}

/// Builds a project evidence vault from finance, approval, and milestone proof.
ProjectEvidenceVaultSummary buildProjectEvidenceVaultSummary(
  ProjectFinanceWorkspaceSummary summary, {
  DateTime? today,
}) {
  final asOfDate = DateUtils.dateOnly(today ?? DateTime.now());
  final records = <ProjectEvidenceVaultRecord>[
    for (final expense in summary.financeLedger.expenseRequests)
      _expenseEvidenceRecord(expense),
    for (final entry in summary.financeLedger.pettyCashEntries)
      _pettyCashEvidenceRecord(entry, asOfDate),
    for (final approval in summary.financeLedger.approvalRecords)
      _approvalEvidenceRecord(approval),
    for (final evidence in summary.financeLedger.reconciliationEvidence)
      _ledgerEvidenceRecord(evidence),
    for (final item in summary.financeReconciliation.items)
      _reconciliationRecord(summary.project.id, item),
    for (final milestone in summary.project.milestones)
      _milestoneEvidenceRecord(summary.project.id, milestone, asOfDate),
  ]..sort(_compareRecords);

  return ProjectEvidenceVaultSummary(
    projectId: summary.project.id,
    projectName: summary.project.name,
    businessDomain: summary.project.businessDomain,
    records: List.unmodifiable(records),
  );
}

ProjectEvidenceVaultRecord _expenseEvidenceRecord(
  ProjectExpenseRequest expense,
) {
  return ProjectEvidenceVaultRecord(
    id: '${expense.id}-evidence',
    title: expense.title,
    detail:
        '${expense.requestedBy} submitted ${expense.category.label.toLowerCase()} spend proof for ${_money(expense.requestedAmount)}.',
    kind: ProjectEvidenceVaultKind.expenseProof,
    level: _fromRecordStatus(expense.status),
    icon: Icons.request_quote_outlined,
    ownerLabel: expense.requestedBy,
    evidenceLabel: expense.evidenceLabel,
    sourceLabel: 'Expense request',
  );
}

ProjectEvidenceVaultRecord _pettyCashEvidenceRecord(
  ProjectPettyCashEntry entry,
  DateTime asOfDate,
) {
  final dueDate = DateUtils.dateOnly(entry.reconciliationDueDate);
  final overdue = entry.isOpen && dueDate.isBefore(asOfDate);

  return ProjectEvidenceVaultRecord(
    id: '${entry.id}-receipt',
    title: entry.title,
    detail:
        overdue
            ? 'Receipt bundle is overdue for reconciliation.'
            : 'Receipt bundle is due ${_dateLabel(entry.reconciliationDueDate)}.',
    kind: ProjectEvidenceVaultKind.pettyCashReceipt,
    level:
        overdue
            ? ProjectEvidenceVaultLevel.blocked
            : _fromRecordStatus(entry.status),
    icon: Icons.payments_outlined,
    ownerLabel: entry.custodian,
    evidenceLabel: 'Receipt, purpose, custodian, reconciliation date',
    sourceLabel: 'Petty cash',
  );
}

ProjectEvidenceVaultRecord _approvalEvidenceRecord(
  ProjectApprovalRecord approval,
) {
  return ProjectEvidenceVaultRecord(
    id: '${approval.id}-approval-proof',
    title: approval.title,
    detail:
        '${approval.approver} approval evidence for ${_money(approval.amount)} under ${approval.thresholdLabel.toLowerCase()}.',
    kind: ProjectEvidenceVaultKind.approvalTrail,
    level: _fromRecordStatus(approval.status),
    icon: Icons.approval_outlined,
    ownerLabel: approval.approver,
    evidenceLabel: approval.thresholdLabel,
    sourceLabel: 'Approval trail',
  );
}

ProjectEvidenceVaultRecord _ledgerEvidenceRecord(
  ProjectReconciliationEvidence evidence,
) {
  return ProjectEvidenceVaultRecord(
    id: '${evidence.id}-vault',
    title: evidence.title,
    detail: '${evidence.owner} owns ${evidence.evidenceLabel.toLowerCase()}.',
    kind: ProjectEvidenceVaultKind.reconciliation,
    level: _fromRecordStatus(evidence.status),
    icon: Icons.fact_check_outlined,
    ownerLabel: evidence.owner,
    evidenceLabel: evidence.evidenceLabel,
    sourceLabel: 'Ledger evidence',
  );
}

ProjectEvidenceVaultRecord _reconciliationRecord(
  String projectId,
  ProjectFinanceReconciliationItem item,
) {
  return ProjectEvidenceVaultRecord(
    id: '$projectId-${item.id}-requirement',
    title: item.title,
    detail: item.detail,
    kind: ProjectEvidenceVaultKind.reconciliation,
    level: _fromReconciliationLevel(item.level),
    icon: item.icon,
    ownerLabel: item.ownerLabel,
    evidenceLabel: item.evidenceLabel,
    sourceLabel: item.kind.label,
  );
}

ProjectEvidenceVaultRecord _milestoneEvidenceRecord(
  String projectId,
  ProjectMilestone milestone,
  DateTime asOfDate,
) {
  final dueDate = DateUtils.dateOnly(milestone.dueDate);
  final overdue = !milestone.isComplete && dueDate.isBefore(asOfDate);

  return ProjectEvidenceVaultRecord(
    id: '$projectId-${_slug(milestone.label)}-milestone-proof',
    title: '${milestone.label} milestone proof',
    detail:
        milestone.isComplete
            ? 'Milestone is complete; archive acceptance proof for handoff.'
            : overdue
            ? 'Milestone is overdue; attach recovery note, owner, and new date.'
            : 'Milestone proof should be ready before ${_dateLabel(milestone.dueDate)}.',
    kind: ProjectEvidenceVaultKind.milestoneProof,
    level:
        milestone.isComplete
            ? ProjectEvidenceVaultLevel.ready
            : overdue
            ? ProjectEvidenceVaultLevel.blocked
            : ProjectEvidenceVaultLevel.review,
    icon: Icons.flag_outlined,
    ownerLabel: 'Delivery owner',
    evidenceLabel: 'Acceptance note, owner, date, handoff proof',
    sourceLabel: 'Milestone',
  );
}

ProjectEvidenceVaultLevel _fromRecordStatus(ProjectFinanceRecordStatus status) {
  switch (status) {
    case ProjectFinanceRecordStatus.reconciled:
      return ProjectEvidenceVaultLevel.ready;
    case ProjectFinanceRecordStatus.blocked:
      return ProjectEvidenceVaultLevel.blocked;
    case ProjectFinanceRecordStatus.planned:
    case ProjectFinanceRecordStatus.submitted:
    case ProjectFinanceRecordStatus.approved:
    case ProjectFinanceRecordStatus.paid:
      return ProjectEvidenceVaultLevel.review;
  }
}

ProjectEvidenceVaultLevel _fromReconciliationLevel(
  ProjectFinanceReconciliationLevel level,
) {
  switch (level) {
    case ProjectFinanceReconciliationLevel.clean:
      return ProjectEvidenceVaultLevel.ready;
    case ProjectFinanceReconciliationLevel.needsEvidence:
      return ProjectEvidenceVaultLevel.review;
    case ProjectFinanceReconciliationLevel.blocked:
      return ProjectEvidenceVaultLevel.blocked;
  }
}

int _compareRecords(
  ProjectEvidenceVaultRecord left,
  ProjectEvidenceVaultRecord right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;
  return left.kind.index.compareTo(right.kind.index);
}

int _levelRank(ProjectEvidenceVaultLevel level) {
  switch (level) {
    case ProjectEvidenceVaultLevel.blocked:
      return 0;
    case ProjectEvidenceVaultLevel.review:
      return 1;
    case ProjectEvidenceVaultLevel.ready:
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

String _slug(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

extension ProjectEvidenceVaultLevelPresentation on ProjectEvidenceVaultLevel {
  /// User-facing label for an evidence vault level.
  String get label {
    switch (this) {
      case ProjectEvidenceVaultLevel.ready:
        return 'Ready';
      case ProjectEvidenceVaultLevel.review:
        return 'Review';
      case ProjectEvidenceVaultLevel.blocked:
        return 'Blocked';
    }
  }

  /// Icon for an evidence vault level.
  IconData get icon {
    switch (this) {
      case ProjectEvidenceVaultLevel.ready:
        return Icons.verified_outlined;
      case ProjectEvidenceVaultLevel.review:
        return Icons.rate_review_outlined;
      case ProjectEvidenceVaultLevel.blocked:
        return Icons.block_outlined;
    }
  }

  /// Color for an evidence vault level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectEvidenceVaultLevel.ready:
        return Colors.green.shade700;
      case ProjectEvidenceVaultLevel.review:
        return Colors.orange.shade700;
      case ProjectEvidenceVaultLevel.blocked:
        return colorScheme.error;
    }
  }
}

extension ProjectEvidenceVaultKindPresentation on ProjectEvidenceVaultKind {
  /// User-facing label for an evidence vault source kind.
  String get label {
    switch (this) {
      case ProjectEvidenceVaultKind.expenseProof:
        return 'Expense Proof';
      case ProjectEvidenceVaultKind.pettyCashReceipt:
        return 'Petty Cash';
      case ProjectEvidenceVaultKind.approvalTrail:
        return 'Approval';
      case ProjectEvidenceVaultKind.reconciliation:
        return 'Reconciliation';
      case ProjectEvidenceVaultKind.milestoneProof:
        return 'Milestone';
    }
  }
}

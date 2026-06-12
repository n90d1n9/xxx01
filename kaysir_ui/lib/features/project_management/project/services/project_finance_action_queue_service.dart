import 'package:flutter/material.dart';

import '../models/project_finance_ledger.dart';
import 'project_finance_ledger_records_service.dart';
import 'project_finance_ledger_summary_service.dart';

/// Severity for actionable project finance follow-up work.
enum ProjectFinanceActionSeverity { routine, watch, critical }

/// Action item derived from ledger records and budget guardrails.
class ProjectFinanceActionItem {
  const ProjectFinanceActionItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.owner,
    required this.amount,
    required this.severity,
    required this.sourceKind,
    required this.sourceStatus,
    required this.ctaLabel,
    this.dueDate,
  });

  final String id;
  final String title;
  final String detail;
  final String owner;
  final double amount;
  final ProjectFinanceActionSeverity severity;
  final ProjectFinanceLedgerRecordKind sourceKind;
  final ProjectFinanceRecordStatus sourceStatus;
  final String ctaLabel;
  final DateTime? dueDate;

  String get amountLabel => _money(amount);
  String get dueDateLabel {
    final date = dueDate;
    if (date == null) return '';
    return 'Due ${_dateLabel(date)}';
  }
}

/// Prioritized finance action queue for project budget and ledger operations.
class ProjectFinanceActionQueue {
  const ProjectFinanceActionQueue({
    required this.projectId,
    required this.actions,
  });

  final String projectId;
  final List<ProjectFinanceActionItem> actions;

  bool get hasActions => actions.isNotEmpty;
  int get actionCount => actions.length;
  int get criticalCount =>
      actions
          .where(
            (action) =>
                action.severity == ProjectFinanceActionSeverity.critical,
          )
          .length;
  int get watchCount =>
      actions
          .where(
            (action) => action.severity == ProjectFinanceActionSeverity.watch,
          )
          .length;
  int get routineCount =>
      actions
          .where(
            (action) => action.severity == ProjectFinanceActionSeverity.routine,
          )
          .length;
  int get ownerCount => actions.map((action) => action.owner).toSet().length;

  ProjectFinanceActionItem? get primaryAction {
    if (actions.isEmpty) return null;
    return actions.first;
  }

  String get title {
    if (!hasActions) return 'Finance actions clear';
    if (criticalCount > 0) return 'Finance blocks need action';
    if (watchCount > 0) return 'Finance follow-up ready';
    return 'Finance queue ready';
  }

  String get detail {
    if (!hasActions) {
      return 'No blocked approvals, unreconciled cash, or submitted evidence needs action right now.';
    }

    final primary = primaryAction!;
    return '$actionCount actions across $ownerCount owners - next: ${primary.title}.';
  }
}

/// Builds prioritized project finance actions from ledger rows and guardrails.
ProjectFinanceActionQueue buildProjectFinanceActionQueue(
  ProjectFinanceLedgerSummary summary,
) {
  final recordsView = buildProjectFinanceLedgerRecordsView(summary);
  final actions = <ProjectFinanceActionItem>[];
  for (final row in recordsView.rows) {
    final action = _actionForRow(row);
    if (action != null) actions.add(action);
  }
  for (final line in summary.budgetLines) {
    final action = _actionForBudgetLine(line);
    if (action != null) actions.add(action);
  }
  actions.sort(_compareActions);

  return ProjectFinanceActionQueue(
    projectId: summary.projectId,
    actions: List.unmodifiable(actions),
  );
}

ProjectFinanceActionItem? _actionForRow(ProjectFinanceLedgerRecordRow row) {
  if (row.status == ProjectFinanceRecordStatus.blocked) {
    return ProjectFinanceActionItem(
      id: 'unblock-${row.id}',
      title: 'Unblock ${row.kind.label.toLowerCase()}: ${row.title}',
      detail:
          '${row.ownerText} needs exception resolution before the ledger can close. ${row.detail}',
      owner: row.owner,
      amount: row.amount,
      severity: ProjectFinanceActionSeverity.critical,
      sourceKind: row.kind,
      sourceStatus: row.status,
      ctaLabel: 'Resolve block',
      dueDate: row.dueDate,
    );
  }

  if (row.kind == ProjectFinanceLedgerRecordKind.pettyCash &&
      row.status == ProjectFinanceRecordStatus.paid) {
    return ProjectFinanceActionItem(
      id: 'reconcile-${row.id}',
      title: 'Reconcile project float: ${row.title}',
      detail:
          '${row.ownerText} should attach receipt proof and close the float before ${row.dueDateLabel.toLowerCase()}.',
      owner: row.owner,
      amount: row.amount,
      severity: ProjectFinanceActionSeverity.watch,
      sourceKind: row.kind,
      sourceStatus: row.status,
      ctaLabel: 'Reconcile cash',
      dueDate: row.dueDate,
    );
  }

  if (row.status == ProjectFinanceRecordStatus.submitted) {
    return ProjectFinanceActionItem(
      id: 'review-${row.id}',
      title: 'Review ${row.kind.label.toLowerCase()}: ${row.title}',
      detail:
          '${row.ownerText} has submitted a finance record that needs validation. ${row.detail}',
      owner: row.owner,
      amount: row.amount,
      severity: ProjectFinanceActionSeverity.watch,
      sourceKind: row.kind,
      sourceStatus: row.status,
      ctaLabel: 'Review record',
      dueDate: row.dueDate,
    );
  }

  if (row.kind == ProjectFinanceLedgerRecordKind.expense &&
      row.status == ProjectFinanceRecordStatus.approved) {
    return ProjectFinanceActionItem(
      id: 'pay-${row.id}',
      title: 'Prepare payment proof: ${row.title}',
      detail:
          '${row.ownerText} has an approved expense ready for payment proof and receipt matching. ${row.detail}',
      owner: row.owner,
      amount: row.amount,
      severity: ProjectFinanceActionSeverity.routine,
      sourceKind: row.kind,
      sourceStatus: row.status,
      ctaLabel: 'Prepare proof',
      dueDate: row.dueDate,
    );
  }

  return null;
}

ProjectFinanceActionItem? _actionForBudgetLine(ProjectBudgetLine line) {
  if (line.utilization < 0.85) return null;

  final severity =
      line.utilization >= 0.95
          ? ProjectFinanceActionSeverity.critical
          : ProjectFinanceActionSeverity.watch;

  return ProjectFinanceActionItem(
    id: 'guardrail-${line.id}',
    title: 'Review budget guardrail: ${line.title}',
    detail:
        '${line.owner} owns a ${line.category.label.toLowerCase()} line at ${(line.utilization * 100).round()}% utilization with ${_money(line.remainingAmount)} remaining.',
    owner: line.owner,
    amount: line.remainingAmount,
    severity: severity,
    sourceKind: ProjectFinanceLedgerRecordKind.budget,
    sourceStatus: ProjectFinanceRecordStatus.planned,
    ctaLabel: 'Review runway',
  );
}

int _compareActions(
  ProjectFinanceActionItem left,
  ProjectFinanceActionItem right,
) {
  final severityComparison = _severityRank(
    left.severity,
  ).compareTo(_severityRank(right.severity));
  if (severityComparison != 0) return severityComparison;

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

int _severityRank(ProjectFinanceActionSeverity severity) {
  switch (severity) {
    case ProjectFinanceActionSeverity.critical:
      return 0;
    case ProjectFinanceActionSeverity.watch:
      return 1;
    case ProjectFinanceActionSeverity.routine:
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

extension ProjectFinanceActionSeverityPresentation
    on ProjectFinanceActionSeverity {
  /// User-facing label for a project finance action severity.
  String get label {
    switch (this) {
      case ProjectFinanceActionSeverity.routine:
        return 'Routine';
      case ProjectFinanceActionSeverity.watch:
        return 'Watch';
      case ProjectFinanceActionSeverity.critical:
        return 'Critical';
    }
  }

  /// Icon for a project finance action severity.
  IconData get icon {
    switch (this) {
      case ProjectFinanceActionSeverity.routine:
        return Icons.task_alt_outlined;
      case ProjectFinanceActionSeverity.watch:
        return Icons.pending_actions_outlined;
      case ProjectFinanceActionSeverity.critical:
        return Icons.priority_high_rounded;
    }
  }

  /// Color for a project finance action severity.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectFinanceActionSeverity.routine:
        return Colors.green.shade700;
      case ProjectFinanceActionSeverity.watch:
        return Colors.orange.shade700;
      case ProjectFinanceActionSeverity.critical:
        return colorScheme.error;
    }
  }
}

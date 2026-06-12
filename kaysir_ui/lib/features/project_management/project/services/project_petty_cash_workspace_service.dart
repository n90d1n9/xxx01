import 'package:flutter/material.dart';

import '../models/project_finance_ledger.dart';
import 'project_expense_intake_service.dart';
import 'project_finance_reconciliation_service.dart';
import 'project_finance_workspace_service.dart';
import 'project_spend_authority_service.dart';

/// Petty-cash readiness level for project float operations.
enum ProjectPettyCashWorkspaceLevel { ready, review, blocked }

/// Type of control check needed before petty cash can operate safely.
enum ProjectPettyCashControlKind { intake, authority, evidence }

/// UI-ready petty-cash entry with action and reconciliation context.
class ProjectPettyCashEntryView {
  const ProjectPettyCashEntryView({
    required this.id,
    required this.title,
    required this.custodian,
    required this.amount,
    required this.status,
    required this.reconciliationDueDate,
    required this.level,
    required this.actionLabel,
    required this.evidenceLabel,
    required this.approvalLabel,
    required this.detail,
  });

  final String id;
  final String title;
  final String custodian;
  final double amount;
  final ProjectFinanceRecordStatus status;
  final DateTime reconciliationDueDate;
  final ProjectPettyCashWorkspaceLevel level;
  final String actionLabel;
  final String evidenceLabel;
  final String approvalLabel;
  final String detail;

  bool get isOpen => status != ProjectFinanceRecordStatus.reconciled;
  bool get isBlocked => level == ProjectPettyCashWorkspaceLevel.blocked;
  bool get isReady => level == ProjectPettyCashWorkspaceLevel.ready;
  String get amountLabel => _money(amount);
  String get dueDateLabel => _dateLabel(reconciliationDueDate);
}

/// Petty-cash control check derived from intake, authority, and evidence rules.
class ProjectPettyCashControlCheck {
  const ProjectPettyCashControlCheck({
    required this.kind,
    required this.title,
    required this.detail,
    required this.ownerLabel,
    required this.level,
    required this.icon,
  });

  final ProjectPettyCashControlKind kind;
  final String title;
  final String detail;
  final String ownerLabel;
  final ProjectPettyCashWorkspaceLevel level;
  final IconData icon;

  bool get isReady => level == ProjectPettyCashWorkspaceLevel.ready;
  bool get isBlocked => level == ProjectPettyCashWorkspaceLevel.blocked;
}

/// Operational petty-cash workspace summary for one project.
class ProjectPettyCashWorkspaceSummary {
  const ProjectPettyCashWorkspaceSummary({
    required this.projectId,
    required this.projectName,
    required this.businessDomain,
    required this.entries,
    required this.controls,
    required this.today,
  });

  final String projectId;
  final String projectName;
  final String businessDomain;
  final List<ProjectPettyCashEntryView> entries;
  final List<ProjectPettyCashControlCheck> controls;
  final DateTime today;

  int get entryCount => entries.length;
  int get openCount => entries.where((entry) => entry.isOpen).length;
  int get blockedCount => entries.where((entry) => entry.isBlocked).length;
  int get readyControlCount =>
      controls.where((control) => control.isReady).length;
  int get blockedControlCount =>
      controls.where((control) => control.isBlocked).length;
  int get dueSoonCount =>
      entries
          .where(
            (entry) =>
                entry.isOpen &&
                !entry.reconciliationDueDate.isBefore(today) &&
                entry.reconciliationDueDate.difference(today).inDays <= 14,
          )
          .length;
  int get overdueCount =>
      entries
          .where(
            (entry) =>
                entry.isOpen && entry.reconciliationDueDate.isBefore(today),
          )
          .length;
  double get totalFloatAmount =>
      entries.fold(0, (sum, entry) => sum + entry.amount);
  double get openFloatAmount => entries
      .where((entry) => entry.isOpen)
      .fold(0, (sum, entry) => sum + entry.amount);
  String get totalFloatAmountLabel => _money(totalFloatAmount);
  String get openFloatAmountLabel => _money(openFloatAmount);
  int get custodianCount =>
      entries.map((entry) => entry.custodian).toSet().length;

  ProjectPettyCashWorkspaceLevel get level {
    if (blockedCount > 0 || blockedControlCount > 0) {
      return ProjectPettyCashWorkspaceLevel.blocked;
    }
    if (openCount > 0 || readyControlCount < controls.length) {
      return ProjectPettyCashWorkspaceLevel.review;
    }
    return ProjectPettyCashWorkspaceLevel.ready;
  }

  ProjectPettyCashEntryView? get primaryEntry {
    if (entries.isEmpty) return null;
    final sorted = [...entries]..sort(_compareEntries);
    return sorted.first;
  }

  ProjectPettyCashControlCheck? get primaryControl {
    if (controls.isEmpty) return null;
    final sorted = [...controls]..sort(_compareControls);
    return sorted.first;
  }

  String get title {
    switch (level) {
      case ProjectPettyCashWorkspaceLevel.ready:
        return 'Petty cash ready';
      case ProjectPettyCashWorkspaceLevel.review:
        return 'Petty cash reconciliation active';
      case ProjectPettyCashWorkspaceLevel.blocked:
        return 'Petty cash blocked';
    }
  }

  String get detail {
    final primary = primaryEntry;
    if (primary != null && primary.isOpen) {
      return '$openCount open floats across $custodianCount custodians - next: ${primary.actionLabel} for ${primary.title}.';
    }

    final control = primaryControl;
    if (control != null && !control.isReady) {
      return '$readyControlCount of ${controls.length} controls ready - next: ${control.title}.';
    }

    return 'All petty-cash entries are reconciled for $businessDomain.';
  }
}

/// Builds a petty-cash workspace from reusable project finance summaries.
ProjectPettyCashWorkspaceSummary buildProjectPettyCashWorkspaceSummary(
  ProjectFinanceWorkspaceSummary summary, {
  DateTime? today,
}) {
  final asOfDate = DateUtils.dateOnly(today ?? DateTime.now());
  final route = _pettyCashRoute(summary.expenseIntake);
  final authority = _pettyCashAuthority(summary.spendAuthority);
  final evidence = _pettyCashEvidence(summary.financeReconciliation);
  final entries =
      summary.financeLedger.pettyCashEntries
          .map(
            (entry) => _entryView(
              entry: entry,
              route: route,
              authority: authority,
              asOfDate: asOfDate,
            ),
          )
          .toList()
        ..sort(_compareEntries);
  final controls = [
    _intakeControl(route),
    _authorityControl(authority),
    _evidenceControl(evidence),
  ]..sort(_compareControls);

  return ProjectPettyCashWorkspaceSummary(
    projectId: summary.project.id,
    projectName: summary.project.name,
    businessDomain: summary.project.businessDomain,
    entries: List.unmodifiable(entries),
    controls: List.unmodifiable(controls),
    today: asOfDate,
  );
}

ProjectPettyCashEntryView _entryView({
  required ProjectPettyCashEntry entry,
  required ProjectExpenseIntakeRoute? route,
  required ProjectSpendAuthorityRule? authority,
  required DateTime asOfDate,
}) {
  final overdue =
      entry.status != ProjectFinanceRecordStatus.reconciled &&
      entry.reconciliationDueDate.isBefore(asOfDate);
  final dueSoon =
      entry.status != ProjectFinanceRecordStatus.reconciled &&
      !entry.reconciliationDueDate.isBefore(asOfDate) &&
      entry.reconciliationDueDate.difference(asOfDate).inDays <= 14;

  return ProjectPettyCashEntryView(
    id: entry.id,
    title: entry.title,
    custodian: entry.custodian,
    amount: entry.amount,
    status: entry.status,
    reconciliationDueDate: entry.reconciliationDueDate,
    level: _entryLevel(entry),
    actionLabel: _actionLabel(entry.status),
    evidenceLabel:
        route?.evidenceLabel ??
        authority?.evidenceLabel ??
        'Receipt, purpose, custodian, reconciliation date',
    approvalLabel:
        authority?.approverLabel ?? route?.approvalLabel ?? 'Approver',
    detail:
        overdue
            ? 'Reconciliation is overdue and should be closed before more float is released.'
            : dueSoon
            ? 'Reconciliation is due soon; prepare receipts, purpose, and custodian confirmation.'
            : 'Float can proceed with the configured evidence and approval route.',
  );
}

ProjectPettyCashControlCheck _intakeControl(ProjectExpenseIntakeRoute? route) {
  final level = _fromIntakeLevel(route?.level);

  return ProjectPettyCashControlCheck(
    kind: ProjectPettyCashControlKind.intake,
    title: route?.title ?? 'Configure project float intake',
    detail:
        route?.detail ??
        'Define limit, custodian, evidence, and reconciliation cadence before petty cash opens.',
    ownerLabel: route?.approvalLabel ?? 'Finance owner',
    level: level,
    icon: Icons.payments_outlined,
  );
}

ProjectPettyCashControlCheck _authorityControl(
  ProjectSpendAuthorityRule? authority,
) {
  final level = _fromAuthorityLevel(authority?.level);

  return ProjectPettyCashControlCheck(
    kind: ProjectPettyCashControlKind.authority,
    title: authority?.title ?? 'Define petty cash authority',
    detail:
        authority?.detail ??
        'Set float threshold, approver, and release route before field cash is delegated.',
    ownerLabel: authority?.approverLabel ?? 'Approver route',
    level: level,
    icon: Icons.verified_user_outlined,
  );
}

ProjectPettyCashControlCheck _evidenceControl(
  ProjectFinanceReconciliationItem? evidence,
) {
  final level = _fromEvidenceLevel(evidence?.level);

  return ProjectPettyCashControlCheck(
    kind: ProjectPettyCashControlKind.evidence,
    title: evidence?.title ?? 'Prepare petty cash evidence',
    detail:
        evidence?.detail ??
        'Receipts, custodian ownership, approval trail, and reconciliation cadence are needed before closeout.',
    ownerLabel: evidence?.ownerLabel ?? 'Evidence owner',
    level: level,
    icon: Icons.fact_check_outlined,
  );
}

ProjectExpenseIntakeRoute? _pettyCashRoute(
  ProjectExpenseIntakeSummary summary,
) {
  for (final route in summary.routes) {
    if (route.kind == ProjectExpenseIntakeKind.pettyCash) return route;
  }
  return null;
}

ProjectSpendAuthorityRule? _pettyCashAuthority(
  ProjectSpendAuthoritySummary summary,
) {
  for (final rule in summary.rules) {
    if (rule.band == ProjectSpendAuthorityBand.pettyCash) return rule;
  }
  return null;
}

ProjectFinanceReconciliationItem? _pettyCashEvidence(
  ProjectFinanceReconciliationSummary summary,
) {
  for (final item in summary.items) {
    if (item.kind == ProjectFinanceReconciliationKind.pettyCash) return item;
  }
  return null;
}

ProjectPettyCashWorkspaceLevel _entryLevel(ProjectPettyCashEntry entry) {
  if (entry.status == ProjectFinanceRecordStatus.blocked) {
    return ProjectPettyCashWorkspaceLevel.blocked;
  }
  if (entry.status == ProjectFinanceRecordStatus.reconciled) {
    return ProjectPettyCashWorkspaceLevel.ready;
  }
  return ProjectPettyCashWorkspaceLevel.review;
}

String _actionLabel(ProjectFinanceRecordStatus status) {
  switch (status) {
    case ProjectFinanceRecordStatus.planned:
      return 'Prepare float';
    case ProjectFinanceRecordStatus.submitted:
      return 'Review request';
    case ProjectFinanceRecordStatus.approved:
      return 'Release float';
    case ProjectFinanceRecordStatus.paid:
      return 'Attach receipts';
    case ProjectFinanceRecordStatus.reconciled:
      return 'Archive proof';
    case ProjectFinanceRecordStatus.blocked:
      return 'Resolve block';
  }
}

ProjectPettyCashWorkspaceLevel _fromIntakeLevel(
  ProjectExpenseIntakeLevel? level,
) {
  switch (level) {
    case ProjectExpenseIntakeLevel.ready:
      return ProjectPettyCashWorkspaceLevel.ready;
    case ProjectExpenseIntakeLevel.setupNeeded:
      return ProjectPettyCashWorkspaceLevel.review;
    case ProjectExpenseIntakeLevel.approvalRequired:
    case null:
      return ProjectPettyCashWorkspaceLevel.blocked;
  }
}

ProjectPettyCashWorkspaceLevel _fromAuthorityLevel(
  ProjectSpendAuthorityLevel? level,
) {
  switch (level) {
    case ProjectSpendAuthorityLevel.delegated:
      return ProjectPettyCashWorkspaceLevel.ready;
    case ProjectSpendAuthorityLevel.guarded:
      return ProjectPettyCashWorkspaceLevel.review;
    case ProjectSpendAuthorityLevel.escalation:
    case null:
      return ProjectPettyCashWorkspaceLevel.blocked;
  }
}

ProjectPettyCashWorkspaceLevel _fromEvidenceLevel(
  ProjectFinanceReconciliationLevel? level,
) {
  switch (level) {
    case ProjectFinanceReconciliationLevel.clean:
      return ProjectPettyCashWorkspaceLevel.ready;
    case ProjectFinanceReconciliationLevel.needsEvidence:
      return ProjectPettyCashWorkspaceLevel.review;
    case ProjectFinanceReconciliationLevel.blocked:
    case null:
      return ProjectPettyCashWorkspaceLevel.blocked;
  }
}

int _compareEntries(
  ProjectPettyCashEntryView left,
  ProjectPettyCashEntryView right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;
  final dateCompare = left.reconciliationDueDate.compareTo(
    right.reconciliationDueDate,
  );
  if (dateCompare != 0) return dateCompare;
  return right.amount.compareTo(left.amount);
}

int _compareControls(
  ProjectPettyCashControlCheck left,
  ProjectPettyCashControlCheck right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;
  return left.kind.index.compareTo(right.kind.index);
}

int _levelRank(ProjectPettyCashWorkspaceLevel level) {
  switch (level) {
    case ProjectPettyCashWorkspaceLevel.blocked:
      return 0;
    case ProjectPettyCashWorkspaceLevel.review:
      return 1;
    case ProjectPettyCashWorkspaceLevel.ready:
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

extension ProjectPettyCashWorkspaceLevelPresentation
    on ProjectPettyCashWorkspaceLevel {
  /// User-facing label for a petty-cash workspace level.
  String get label {
    switch (this) {
      case ProjectPettyCashWorkspaceLevel.ready:
        return 'Ready';
      case ProjectPettyCashWorkspaceLevel.review:
        return 'Review';
      case ProjectPettyCashWorkspaceLevel.blocked:
        return 'Blocked';
    }
  }

  /// Icon for a petty-cash workspace level.
  IconData get icon {
    switch (this) {
      case ProjectPettyCashWorkspaceLevel.ready:
        return Icons.verified_outlined;
      case ProjectPettyCashWorkspaceLevel.review:
        return Icons.pending_actions_outlined;
      case ProjectPettyCashWorkspaceLevel.blocked:
        return Icons.block_outlined;
    }
  }

  /// Color for a petty-cash workspace level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectPettyCashWorkspaceLevel.ready:
        return Colors.green.shade700;
      case ProjectPettyCashWorkspaceLevel.review:
        return Colors.orange.shade700;
      case ProjectPettyCashWorkspaceLevel.blocked:
        return colorScheme.error;
    }
  }
}

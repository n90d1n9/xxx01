import 'package:flutter/material.dart';

import 'project_cash_flow_forecast_service.dart';
import 'project_finance_action_queue_service.dart';
import 'project_finance_ledger_records_service.dart';
import 'project_finance_reconciliation_service.dart';
import 'project_finance_workspace_service.dart';

/// Finance closeout readiness level for project handoff and closure.
enum ProjectFinanceCloseoutLevel { ready, attention, blocked }

/// Finance closeout checklist area.
enum ProjectFinanceCloseoutCheckKind {
  ledger,
  actions,
  reconciliation,
  budgetRunway,
  spendAuthority,
  cashFlow,
}

/// One finance closeout checklist item derived from project finance signals.
class ProjectFinanceCloseoutCheck {
  const ProjectFinanceCloseoutCheck({
    required this.kind,
    required this.title,
    required this.detail,
    required this.ownerLabel,
    required this.level,
    required this.icon,
  });

  final ProjectFinanceCloseoutCheckKind kind;
  final String title;
  final String detail;
  final String ownerLabel;
  final ProjectFinanceCloseoutLevel level;
  final IconData icon;

  bool get isReady => level == ProjectFinanceCloseoutLevel.ready;
  bool get isBlocked => level == ProjectFinanceCloseoutLevel.blocked;
  bool get needsAttention => level != ProjectFinanceCloseoutLevel.ready;
}

/// Closeout readiness rollup for one project finance workspace.
class ProjectFinanceCloseoutSummary {
  const ProjectFinanceCloseoutSummary({
    required this.projectId,
    required this.projectName,
    required this.checks,
  });

  final String projectId;
  final String projectName;
  final List<ProjectFinanceCloseoutCheck> checks;

  int get checkCount => checks.length;
  int get readyCount => checks.where((check) => check.isReady).length;
  int get attentionCount =>
      checks
          .where(
            (check) => check.level == ProjectFinanceCloseoutLevel.attention,
          )
          .length;
  int get blockedCount => checks.where((check) => check.isBlocked).length;
  int get completionPercent =>
      checkCount == 0 ? 0 : ((readyCount / checkCount) * 100).round();

  ProjectFinanceCloseoutLevel get level {
    if (blockedCount > 0) return ProjectFinanceCloseoutLevel.blocked;
    if (attentionCount > 0) return ProjectFinanceCloseoutLevel.attention;
    return ProjectFinanceCloseoutLevel.ready;
  }

  ProjectFinanceCloseoutCheck? get primaryCheck {
    if (checks.isEmpty) return null;
    final sorted = [...checks]..sort(_compareChecks);
    return sorted.first;
  }

  String get title {
    switch (level) {
      case ProjectFinanceCloseoutLevel.ready:
        return 'Finance closeout ready';
      case ProjectFinanceCloseoutLevel.attention:
        return 'Finance closeout needs attention';
      case ProjectFinanceCloseoutLevel.blocked:
        return 'Finance closeout blocked';
    }
  }

  String get detail {
    final primary = primaryCheck;
    if (primary == null) return 'No finance closeout checks are configured.';
    return '$readyCount of $checkCount checks ready - next: ${primary.title}.';
  }
}

/// Builds a project finance closeout checklist from workspace signals.
ProjectFinanceCloseoutSummary buildProjectFinanceCloseoutSummary(
  ProjectFinanceWorkspaceSummary summary,
) {
  final actionQueue = buildProjectFinanceActionQueue(summary.financeLedger);
  final recordsView = buildProjectFinanceLedgerRecordsView(
    summary.financeLedger,
  );

  final checks = [
    _ledgerCheck(recordsView),
    _actionsCheck(actionQueue),
    _reconciliationCheck(summary.financeReconciliation),
    _budgetRunwayCheck(summary),
    _spendAuthorityCheck(summary),
    _cashFlowCheck(summary),
  ]..sort(_compareChecks);

  return ProjectFinanceCloseoutSummary(
    projectId: summary.project.id,
    projectName: summary.project.name,
    checks: List.unmodifiable(checks),
  );
}

ProjectFinanceCloseoutCheck _ledgerCheck(
  ProjectFinanceLedgerRecordsView recordsView,
) {
  final level =
      recordsView.blockedCount > 0
          ? ProjectFinanceCloseoutLevel.blocked
          : recordsView.openCount > 0
          ? ProjectFinanceCloseoutLevel.attention
          : ProjectFinanceCloseoutLevel.ready;

  return ProjectFinanceCloseoutCheck(
    kind: ProjectFinanceCloseoutCheckKind.ledger,
    title: 'Ledger records',
    detail:
        '${recordsView.openCount} open records and ${recordsView.blockedCount} blocked records must be resolved before closeout.',
    ownerLabel: 'Finance owner',
    level: level,
    icon: Icons.receipt_long_outlined,
  );
}

ProjectFinanceCloseoutCheck _actionsCheck(
  ProjectFinanceActionQueue actionQueue,
) {
  final level =
      actionQueue.criticalCount > 0
          ? ProjectFinanceCloseoutLevel.blocked
          : actionQueue.actionCount > 0
          ? ProjectFinanceCloseoutLevel.attention
          : ProjectFinanceCloseoutLevel.ready;

  return ProjectFinanceCloseoutCheck(
    kind: ProjectFinanceCloseoutCheckKind.actions,
    title: 'Finance action queue',
    detail:
        '${actionQueue.actionCount} actions remain, including ${actionQueue.criticalCount} critical actions.',
    ownerLabel: 'Action owners',
    level: level,
    icon: Icons.pending_actions_outlined,
  );
}

ProjectFinanceCloseoutCheck _reconciliationCheck(
  ProjectFinanceReconciliationSummary reconciliation,
) {
  final level =
      reconciliation.blockedCount > 0
          ? ProjectFinanceCloseoutLevel.blocked
          : reconciliation.actionCount > 0
          ? ProjectFinanceCloseoutLevel.attention
          : ProjectFinanceCloseoutLevel.ready;

  return ProjectFinanceCloseoutCheck(
    kind: ProjectFinanceCloseoutCheckKind.reconciliation,
    title: 'Reconciliation evidence',
    detail:
        '${reconciliation.cleanCount} of ${reconciliation.itemCount} evidence checks are clean.',
    ownerLabel: 'Evidence owners',
    level: level,
    icon: Icons.fact_check_outlined,
  );
}

ProjectFinanceCloseoutCheck _budgetRunwayCheck(
  ProjectFinanceWorkspaceSummary summary,
) {
  final remainingBudget = summary.budgetOverview.remainingBudgetPercent;
  final projectedAtCompletion =
      summary.cashFlowForecast.projectedAtCompletionPercent;
  final level =
      projectedAtCompletion >= 120 || remainingBudget <= 5
          ? ProjectFinanceCloseoutLevel.blocked
          : projectedAtCompletion > 105 || remainingBudget < 15
          ? ProjectFinanceCloseoutLevel.attention
          : ProjectFinanceCloseoutLevel.ready;

  return ProjectFinanceCloseoutCheck(
    kind: ProjectFinanceCloseoutCheckKind.budgetRunway,
    title: 'Budget runway',
    detail:
        '$remainingBudget% budget remains and projected completion is $projectedAtCompletion%.',
    ownerLabel: 'Budget owner',
    level: level,
    icon: Icons.savings_outlined,
  );
}

ProjectFinanceCloseoutCheck _spendAuthorityCheck(
  ProjectFinanceWorkspaceSummary summary,
) {
  final authority = summary.spendAuthority;
  final level =
      authority.escalationCount > 0
          ? ProjectFinanceCloseoutLevel.blocked
          : authority.guardedCount > 0
          ? ProjectFinanceCloseoutLevel.attention
          : ProjectFinanceCloseoutLevel.ready;

  return ProjectFinanceCloseoutCheck(
    kind: ProjectFinanceCloseoutCheckKind.spendAuthority,
    title: 'Spend authority',
    detail:
        '${authority.delegatedCount} delegated rules, ${authority.guardedCount} guarded rules, and ${authority.escalationCount} escalations.',
    ownerLabel: 'Approver route',
    level: level,
    icon: Icons.verified_user_outlined,
  );
}

ProjectFinanceCloseoutCheck _cashFlowCheck(
  ProjectFinanceWorkspaceSummary summary,
) {
  final cashFlow = summary.cashFlowForecast;
  final level =
      cashFlow.level == ProjectCashFlowForecastLevel.constrained
          ? ProjectFinanceCloseoutLevel.blocked
          : cashFlow.level == ProjectCashFlowForecastLevel.watch ||
              cashFlow.constrainedWindowCount > 0
          ? ProjectFinanceCloseoutLevel.attention
          : ProjectFinanceCloseoutLevel.ready;

  return ProjectFinanceCloseoutCheck(
    kind: ProjectFinanceCloseoutCheckKind.cashFlow,
    title: 'Cash-flow gates',
    detail:
        '${cashFlow.constrainedWindowCount} funding windows need attention before closeout.',
    ownerLabel: 'Funding owner',
    level: level,
    icon: Icons.query_stats_outlined,
  );
}

int _compareChecks(
  ProjectFinanceCloseoutCheck left,
  ProjectFinanceCloseoutCheck right,
) {
  final levelComparison = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelComparison != 0) return levelComparison;
  return left.kind.index.compareTo(right.kind.index);
}

int _levelRank(ProjectFinanceCloseoutLevel level) {
  switch (level) {
    case ProjectFinanceCloseoutLevel.blocked:
      return 0;
    case ProjectFinanceCloseoutLevel.attention:
      return 1;
    case ProjectFinanceCloseoutLevel.ready:
      return 2;
  }
}

extension ProjectFinanceCloseoutLevelPresentation
    on ProjectFinanceCloseoutLevel {
  /// User-facing label for a finance closeout level.
  String get label {
    switch (this) {
      case ProjectFinanceCloseoutLevel.ready:
        return 'Ready';
      case ProjectFinanceCloseoutLevel.attention:
        return 'Attention';
      case ProjectFinanceCloseoutLevel.blocked:
        return 'Blocked';
    }
  }

  /// Icon for a finance closeout level.
  IconData get icon {
    switch (this) {
      case ProjectFinanceCloseoutLevel.ready:
        return Icons.verified_outlined;
      case ProjectFinanceCloseoutLevel.attention:
        return Icons.pending_actions_outlined;
      case ProjectFinanceCloseoutLevel.blocked:
        return Icons.priority_high_rounded;
    }
  }

  /// Color for a finance closeout level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectFinanceCloseoutLevel.ready:
        return Colors.green.shade700;
      case ProjectFinanceCloseoutLevel.attention:
        return Colors.orange.shade700;
      case ProjectFinanceCloseoutLevel.blocked:
        return colorScheme.error;
    }
  }
}

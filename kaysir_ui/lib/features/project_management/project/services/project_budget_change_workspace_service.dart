import 'package:flutter/material.dart';

import 'project_budget_pulse_service.dart';
import 'project_cash_flow_forecast_service.dart';
import 'project_finance_ledger_summary_service.dart';
import 'project_finance_workspace_service.dart';
import 'project_spend_authority_service.dart';

/// Readiness level for project budget change requests.
enum ProjectBudgetChangeLevel { ready, review, blocked }

/// Type of project budget change or variation request.
enum ProjectBudgetChangeKind {
  varianceRecovery,
  costReforecast,
  contingencyRelease,
  evidenceChange,
  baselineLog,
}

/// UI-ready project budget change request candidate.
class ProjectBudgetChangeRequest {
  const ProjectBudgetChangeRequest({
    required this.id,
    required this.title,
    required this.detail,
    required this.kind,
    required this.level,
    required this.icon,
    required this.requestedAmount,
    required this.ownerLabel,
    required this.approvalLabel,
    required this.evidenceLabel,
    required this.impactLabel,
  });

  final String id;
  final String title;
  final String detail;
  final ProjectBudgetChangeKind kind;
  final ProjectBudgetChangeLevel level;
  final IconData icon;
  final double requestedAmount;
  final String ownerLabel;
  final String approvalLabel;
  final String evidenceLabel;
  final String impactLabel;

  bool get isReady => level == ProjectBudgetChangeLevel.ready;
  bool get isBlocked => level == ProjectBudgetChangeLevel.blocked;
  String get requestedAmountLabel => _money(requestedAmount);
}

/// Budget-change workspace summary for project variations and approvals.
class ProjectBudgetChangeWorkspaceSummary {
  const ProjectBudgetChangeWorkspaceSummary({
    required this.projectId,
    required this.projectName,
    required this.businessDomain,
    required this.requests,
  });

  final String projectId;
  final String projectName;
  final String businessDomain;
  final List<ProjectBudgetChangeRequest> requests;

  int get requestCount => requests.length;
  int get readyCount => requests.where((request) => request.isReady).length;
  int get reviewCount =>
      requests
          .where((request) => request.level == ProjectBudgetChangeLevel.review)
          .length;
  int get blockedCount => requests.where((request) => request.isBlocked).length;
  double get requestedAmountTotal =>
      requests.fold(0, (sum, request) => sum + request.requestedAmount);
  String get requestedAmountTotalLabel => _money(requestedAmountTotal);

  ProjectBudgetChangeLevel get level {
    if (blockedCount > 0) return ProjectBudgetChangeLevel.blocked;
    if (reviewCount > 0) return ProjectBudgetChangeLevel.review;
    return ProjectBudgetChangeLevel.ready;
  }

  ProjectBudgetChangeRequest? get primaryRequest {
    if (requests.isEmpty) return null;
    final sorted = [...requests]..sort(_compareRequests);
    return sorted.first;
  }

  String get title {
    switch (level) {
      case ProjectBudgetChangeLevel.ready:
        return 'Budget changes controlled';
      case ProjectBudgetChangeLevel.review:
        return 'Budget changes need review';
      case ProjectBudgetChangeLevel.blocked:
        return 'Budget change approval blocked';
    }
  }

  String get detail {
    final primary = primaryRequest;
    if (primary == null) {
      return 'No budget change requests are needed for $businessDomain.';
    }
    return '$requestCount requests totaling $requestedAmountTotalLabel - next: ${primary.title}.';
  }
}

/// Builds budget change requests from project finance workspace signals.
ProjectBudgetChangeWorkspaceSummary buildProjectBudgetChangeWorkspaceSummary(
  ProjectFinanceWorkspaceSummary summary,
) {
  final requests = <ProjectBudgetChangeRequest>[_baselineLogRequest(summary)];
  final varianceRequest = _varianceRecoveryRequest(summary);
  if (varianceRequest != null) requests.add(varianceRequest);
  final reforecastRequest = _costReforecastRequest(summary);
  if (reforecastRequest != null) requests.add(reforecastRequest);
  final contingencyRequest = _contingencyReleaseRequest(summary);
  if (contingencyRequest != null) requests.add(contingencyRequest);
  final evidenceRequest = _evidenceChangeRequest(summary);
  if (evidenceRequest != null) requests.add(evidenceRequest);

  requests.sort(_compareRequests);

  return ProjectBudgetChangeWorkspaceSummary(
    projectId: summary.project.id,
    projectName: summary.project.name,
    businessDomain: summary.project.businessDomain,
    requests: List.unmodifiable(requests),
  );
}

ProjectBudgetChangeRequest _baselineLogRequest(
  ProjectFinanceWorkspaceSummary summary,
) {
  final authority = _budgetAuthority(summary.spendAuthority);

  return ProjectBudgetChangeRequest(
    id: '${summary.project.id}-baseline-change-log',
    title: 'Maintain budget change log',
    detail:
        'Keep scope, timing, supplier, and funding movements attached to a decision note before baseline changes are accepted.',
    kind: ProjectBudgetChangeKind.baselineLog,
    level: ProjectBudgetChangeLevel.ready,
    icon: Icons.rule_folder_outlined,
    requestedAmount: 0,
    ownerLabel: summary.project.owner,
    approvalLabel: authority?.approverLabel ?? _sponsorOrOwner(summary),
    evidenceLabel: 'Decision note, reason, owner, impact, approval date',
    impactLabel: '${summary.budgetOverview.varianceLabel} budget gap',
  );
}

ProjectBudgetChangeRequest? _varianceRecoveryRequest(
  ProjectFinanceWorkspaceSummary summary,
) {
  final budget = summary.budgetOverview;
  if (budget.state != ProjectBudgetPulseState.critical &&
      budget.state != ProjectBudgetPulseState.pressure) {
    return null;
  }

  final level =
      budget.state == ProjectBudgetPulseState.critical
          ? ProjectBudgetChangeLevel.blocked
          : ProjectBudgetChangeLevel.review;
  final amount = _varianceAmount(summary.financeLedger, budget.variance);
  final authority = _budgetAuthority(summary.spendAuthority);

  return ProjectBudgetChangeRequest(
    id: '${summary.project.id}-budget-variance-recovery',
    title: 'Budget variance recovery request',
    detail:
        '${budget.detail} Capture recovery amount, scope tradeoff, and sponsor decision before new spend is released.',
    kind: ProjectBudgetChangeKind.varianceRecovery,
    level: level,
    icon: Icons.account_balance_wallet_outlined,
    requestedAmount: amount,
    ownerLabel: summary.project.owner,
    approvalLabel: authority?.approverLabel ?? _sponsorOrOwner(summary),
    evidenceLabel:
        authority?.evidenceLabel ??
        'Variance reason, tradeoff, funding source, sponsor note',
    impactLabel: '${budget.varianceLabel} spend/progress drift',
  );
}

ProjectBudgetChangeRequest? _costReforecastRequest(
  ProjectFinanceWorkspaceSummary summary,
) {
  final line = summary.financeLedger.highestUtilizationLine;
  if (line == null || line.utilization < 0.85) return null;

  final level =
      line.utilization >= 0.95
          ? ProjectBudgetChangeLevel.blocked
          : ProjectBudgetChangeLevel.review;
  final authority = _budgetAuthority(summary.spendAuthority);

  return ProjectBudgetChangeRequest(
    id: '${summary.project.id}-${line.id}-reforecast',
    title: 'Reforecast ${line.title.toLowerCase()}',
    detail:
        '${line.owner} owns ${line.category.label.toLowerCase()} spend at ${(line.utilization * 100).round()}% utilization with ${_money(line.remainingAmount)} remaining.',
    kind: ProjectBudgetChangeKind.costReforecast,
    level: level,
    icon: line.category.icon,
    requestedAmount: line.remainingAmount < 0 ? line.remainingAmount.abs() : 0,
    ownerLabel: line.owner,
    approvalLabel: authority?.approverLabel ?? _sponsorOrOwner(summary),
    evidenceLabel: 'Updated estimate, committed amount, spend proof',
    impactLabel: '${(line.utilization * 100).round()}% category utilization',
  );
}

ProjectBudgetChangeRequest? _contingencyReleaseRequest(
  ProjectFinanceWorkspaceSummary summary,
) {
  final forecast = summary.cashFlowForecast;
  final shouldRelease =
      forecast.level != ProjectCashFlowForecastLevel.healthy ||
      summary.budgetOverview.remainingBudgetPercent < 15;
  if (!shouldRelease) return null;

  final level =
      forecast.level == ProjectCashFlowForecastLevel.constrained
          ? ProjectBudgetChangeLevel.blocked
          : ProjectBudgetChangeLevel.review;
  final amount =
      summary.financeLedger.plannedAmount *
      (summary.costStructure.contingencySharePercent / 100);

  return ProjectBudgetChangeRequest(
    id: '${summary.project.id}-contingency-release',
    title: 'Contingency release request',
    detail:
        '${forecast.detail} Ask for controlled contingency only after scope, timing, and evidence are clear.',
    kind: ProjectBudgetChangeKind.contingencyRelease,
    level: level,
    icon: Icons.savings_outlined,
    requestedAmount: amount,
    ownerLabel: 'Funding owner',
    approvalLabel: _sponsorOrOwner(summary),
    evidenceLabel: 'Funding gate, reserve reason, release condition',
    impactLabel: '${forecast.remainingBudgetPercent}% runway remaining',
  );
}

ProjectBudgetChangeRequest? _evidenceChangeRequest(
  ProjectFinanceWorkspaceSummary summary,
) {
  final reconciliation = summary.financeReconciliation;
  if (reconciliation.actionCount == 0) return null;

  final item = reconciliation.primaryItem;
  final level =
      reconciliation.blockedCount > 0
          ? ProjectBudgetChangeLevel.blocked
          : ProjectBudgetChangeLevel.review;

  return ProjectBudgetChangeRequest(
    id: '${summary.project.id}-evidence-bound-change',
    title: 'Evidence-bound budget change',
    detail:
        '${reconciliation.cleanCount} of ${reconciliation.itemCount} evidence checks are clean. Resolve ${item.title.toLowerCase()} before budget change approval.',
    kind: ProjectBudgetChangeKind.evidenceChange,
    level: level,
    icon: Icons.fact_check_outlined,
    requestedAmount: 0,
    ownerLabel: item.ownerLabel,
    approvalLabel: _sponsorOrOwner(summary),
    evidenceLabel: item.evidenceLabel,
    impactLabel: '${reconciliation.actionCount} evidence actions',
  );
}

ProjectSpendAuthorityRule? _budgetAuthority(
  ProjectSpendAuthoritySummary summary,
) {
  for (final rule in summary.rules) {
    if (rule.band == ProjectSpendAuthorityBand.budgetException) return rule;
  }
  for (final rule in summary.rules) {
    if (rule.level == ProjectSpendAuthorityLevel.escalation) return rule;
  }
  return summary.rules.isEmpty ? null : summary.rules.first;
}

double _varianceAmount(ProjectFinanceLedgerSummary ledger, double variance) {
  final amount = ledger.plannedAmount * variance.clamp(0.05, 0.35);
  return amount.isFinite ? amount : 0;
}

String _sponsorOrOwner(ProjectFinanceWorkspaceSummary summary) {
  final sponsor = summary.project.sponsor.trim();
  return sponsor.isEmpty ? summary.project.owner : sponsor;
}

int _compareRequests(
  ProjectBudgetChangeRequest left,
  ProjectBudgetChangeRequest right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;
  final amountCompare = right.requestedAmount.compareTo(left.requestedAmount);
  if (amountCompare != 0) return amountCompare;
  return left.kind.index.compareTo(right.kind.index);
}

int _levelRank(ProjectBudgetChangeLevel level) {
  switch (level) {
    case ProjectBudgetChangeLevel.blocked:
      return 0;
    case ProjectBudgetChangeLevel.review:
      return 1;
    case ProjectBudgetChangeLevel.ready:
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

extension ProjectBudgetChangeLevelPresentation on ProjectBudgetChangeLevel {
  /// User-facing label for a budget change level.
  String get label {
    switch (this) {
      case ProjectBudgetChangeLevel.ready:
        return 'Ready';
      case ProjectBudgetChangeLevel.review:
        return 'Review';
      case ProjectBudgetChangeLevel.blocked:
        return 'Blocked';
    }
  }

  /// Icon for a budget change level.
  IconData get icon {
    switch (this) {
      case ProjectBudgetChangeLevel.ready:
        return Icons.verified_outlined;
      case ProjectBudgetChangeLevel.review:
        return Icons.rate_review_outlined;
      case ProjectBudgetChangeLevel.blocked:
        return Icons.block_outlined;
    }
  }

  /// Color for a budget change level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectBudgetChangeLevel.ready:
        return Colors.green.shade700;
      case ProjectBudgetChangeLevel.review:
        return Colors.orange.shade700;
      case ProjectBudgetChangeLevel.blocked:
        return colorScheme.error;
    }
  }
}

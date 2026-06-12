import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';
import 'project_budget_pulse_service.dart';
import 'project_cash_flow_forecast_service.dart';
import 'project_finance_control_service.dart';
import 'project_finance_reconciliation_service.dart';
import 'project_finance_workspace_service.dart';
import 'project_spend_authority_service.dart';

/// Risk and issue readiness level for project recovery triage.
enum ProjectRiskIssueLevel { stable, watch, critical }

/// Risk and issue source family normalized across project operations.
enum ProjectRiskIssueKind {
  blocker,
  deliveryRisk,
  milestone,
  budget,
  financeControl,
  authority,
  cashFlow,
  evidence,
}

/// UI-ready project risk or issue item with action and ownership context.
class ProjectRiskIssueItem {
  const ProjectRiskIssueItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.kind,
    required this.level,
    required this.icon,
    required this.ownerLabel,
    required this.evidenceLabel,
    required this.actionLabel,
    required this.sourceLabel,
  });

  final String id;
  final String title;
  final String detail;
  final ProjectRiskIssueKind kind;
  final ProjectRiskIssueLevel level;
  final IconData icon;
  final String ownerLabel;
  final String evidenceLabel;
  final String actionLabel;
  final String sourceLabel;

  bool get isActive => level != ProjectRiskIssueLevel.stable;
  bool get isCritical => level == ProjectRiskIssueLevel.critical;
}

/// Aggregated project risk and issue workspace for a selected project.
class ProjectRiskIssueWorkspaceSummary {
  const ProjectRiskIssueWorkspaceSummary({
    required this.projectId,
    required this.projectName,
    required this.businessDomain,
    required this.items,
  });

  final String projectId;
  final String projectName;
  final String businessDomain;
  final List<ProjectRiskIssueItem> items;

  int get itemCount => items.length;
  int get activeCount => items.where((item) => item.isActive).length;
  int get criticalCount => items.where((item) => item.isCritical).length;
  int get watchCount =>
      items.where((item) => item.level == ProjectRiskIssueLevel.watch).length;
  int get stableCount =>
      items.where((item) => item.level == ProjectRiskIssueLevel.stable).length;
  int get ownerCount =>
      items
          .map((item) => item.ownerLabel.trim())
          .where((label) => label.isNotEmpty)
          .toSet()
          .length;
  int get exposureScore =>
      items.fold(0, (sum, item) => sum + item.level.exposureWeight);

  ProjectRiskIssueLevel get level {
    if (criticalCount > 0) return ProjectRiskIssueLevel.critical;
    if (watchCount > 0) return ProjectRiskIssueLevel.watch;
    return ProjectRiskIssueLevel.stable;
  }

  ProjectRiskIssueItem? get primaryItem {
    if (items.isEmpty) return null;
    final sorted = [...items]..sort(_compareItems);
    return sorted.first;
  }

  String get title {
    switch (level) {
      case ProjectRiskIssueLevel.stable:
        return 'Risk and issues stable';
      case ProjectRiskIssueLevel.watch:
        return 'Risk and issues need review';
      case ProjectRiskIssueLevel.critical:
        return 'Risk and issues critical';
    }
  }

  String get detail {
    final primary = primaryItem;
    if (primary == null) {
      return 'No active risks or issues are configured for $businessDomain.';
    }

    return '$activeCount active issues across $ownerCount owners - next: ${primary.title}.';
  }
}

/// Builds a risk and issue board from project, budget, and finance signals.
ProjectRiskIssueWorkspaceSummary buildProjectRiskIssueWorkspaceSummary(
  ProjectFinanceWorkspaceSummary summary, {
  DateTime? today,
}) {
  final asOfDate = DateUtils.dateOnly(today ?? DateTime.now());
  final items = <ProjectRiskIssueItem>[
    if (summary.project.health != ProjectHealth.onTrack)
      _projectHealthItem(summary.project),
    for (final risk in summary.project.risks)
      if (risk.severity != ProjectHealth.onTrack)
        _deliveryRiskItem(summary.project, risk),
    for (final milestone in summary.project.milestones)
      if (!milestone.isComplete &&
          _milestoneLevel(milestone, asOfDate) != ProjectRiskIssueLevel.stable)
        _milestoneItem(summary.project, milestone, asOfDate),
    if (summary.budgetOverview.state == ProjectBudgetPulseState.critical ||
        summary.budgetOverview.state == ProjectBudgetPulseState.pressure)
      _budgetItem(summary),
    for (final signal in summary.financeControls.signals)
      if (signal.needsAction) _financeControlItem(summary.project, signal),
    if (summary.spendAuthority.level != ProjectSpendAuthorityLevel.delegated)
      _authorityItem(summary),
    if (summary.cashFlowForecast.level != ProjectCashFlowForecastLevel.healthy)
      _cashFlowItem(summary),
    for (final item in summary.financeReconciliation.items)
      if (item.needsAction) _evidenceItem(summary.project, item),
  ]..sort(_compareItems);

  return ProjectRiskIssueWorkspaceSummary(
    projectId: summary.project.id,
    projectName: summary.project.name,
    businessDomain: summary.project.businessDomain,
    items: List.unmodifiable(items),
  );
}

ProjectRiskIssueItem _projectHealthItem(ProjectPortfolioItem project) {
  final level = _fromProjectHealth(project.health);

  return ProjectRiskIssueItem(
    id: '${project.id}-project-health-issue',
    title:
        project.health == ProjectHealth.blocked
            ? 'Project delivery blocked'
            : 'Project delivery at risk',
    detail:
        '${project.name} needs recovery ownership before the next commitment moves.',
    kind: ProjectRiskIssueKind.blocker,
    level: level,
    icon: project.health.icon,
    ownerLabel: project.owner,
    evidenceLabel: 'Recovery owner, unblock decision, target date',
    actionLabel: _actionLabel(
      level,
      critical: 'Escalate recovery',
      watch: 'Set mitigation',
      stable: 'Monitor delivery',
    ),
    sourceLabel: 'Project health',
  );
}

ProjectRiskIssueItem _deliveryRiskItem(
  ProjectPortfolioItem project,
  ProjectDeliveryRisk risk,
) {
  final level = _fromProjectHealth(risk.severity);

  return ProjectRiskIssueItem(
    id: '${project.id}-risk-${_slug(risk.title)}',
    title: risk.title,
    detail: risk.detail,
    kind: ProjectRiskIssueKind.deliveryRisk,
    level: level,
    icon: risk.severity.icon,
    ownerLabel: project.owner,
    evidenceLabel: 'Mitigation owner, decision path, due date',
    actionLabel: _actionLabel(
      level,
      critical: 'Escalate risk',
      watch: 'Review risk',
      stable: 'Monitor risk',
    ),
    sourceLabel: 'Delivery risk',
  );
}

ProjectRiskIssueItem _milestoneItem(
  ProjectPortfolioItem project,
  ProjectMilestone milestone,
  DateTime asOfDate,
) {
  final level = _milestoneLevel(milestone, asOfDate);
  final dueDate = DateUtils.dateOnly(milestone.dueDate);
  final dueInDays = dueDate.difference(asOfDate).inDays;

  return ProjectRiskIssueItem(
    id: '${project.id}-milestone-${_slug(milestone.label)}-issue',
    title: '${milestone.label} milestone',
    detail:
        dueInDays < 0
            ? '${milestone.label} is ${_pluralDays(dueInDays.abs())} overdue.'
            : '${milestone.label} is due in ${_pluralDays(dueInDays)}.',
    kind: ProjectRiskIssueKind.milestone,
    level: level,
    icon: Icons.flag_outlined,
    ownerLabel: project.owner,
    evidenceLabel: 'Milestone proof, acceptance owner, recovery date',
    actionLabel: _actionLabel(
      level,
      critical: 'Recover milestone',
      watch: 'Prepare milestone',
      stable: 'Track milestone',
    ),
    sourceLabel: 'Milestone',
  );
}

ProjectRiskIssueItem _budgetItem(ProjectFinanceWorkspaceSummary summary) {
  final overview = summary.budgetOverview;
  final level =
      overview.state == ProjectBudgetPulseState.critical
          ? ProjectRiskIssueLevel.critical
          : ProjectRiskIssueLevel.watch;

  return ProjectRiskIssueItem(
    id: '${summary.project.id}-budget-risk-issue',
    title: overview.paceLabel,
    detail: overview.detail,
    kind: ProjectRiskIssueKind.budget,
    level: level,
    icon: overview.state.icon,
    ownerLabel: _sponsorOrOwner(summary),
    evidenceLabel: 'Budget variance, tradeoff, funding source, approval',
    actionLabel: _actionLabel(
      level,
      critical: 'Recover budget',
      watch: 'Review budget',
      stable: 'Monitor budget',
    ),
    sourceLabel: 'Budget overview',
  );
}

ProjectRiskIssueItem _financeControlItem(
  ProjectPortfolioItem project,
  ProjectFinanceControlSignal signal,
) {
  final level = _fromFinanceControlLevel(signal.level);

  return ProjectRiskIssueItem(
    id: '${project.id}-finance-control-${_slug(signal.title)}',
    title: signal.title,
    detail: signal.detail,
    kind: ProjectRiskIssueKind.financeControl,
    level: level,
    icon: signal.icon,
    ownerLabel: project.owner,
    evidenceLabel: 'Control owner, rule, threshold, evidence requirement',
    actionLabel: _actionLabel(
      level,
      critical: 'Fix control',
      watch: 'Set control',
      stable: 'Monitor control',
    ),
    sourceLabel: 'Finance controls',
  );
}

ProjectRiskIssueItem _authorityItem(ProjectFinanceWorkspaceSummary summary) {
  final authority = summary.spendAuthority;
  final level = _fromAuthorityLevel(authority.level);

  return ProjectRiskIssueItem(
    id: '${summary.project.id}-authority-risk-issue',
    title: authority.title,
    detail: authority.detail,
    kind: ProjectRiskIssueKind.authority,
    level: level,
    icon: authority.level.icon,
    ownerLabel: _sponsorOrOwner(summary),
    evidenceLabel: 'Authority matrix, approver, threshold, escalation route',
    actionLabel: _actionLabel(
      level,
      critical: 'Escalate authority',
      watch: 'Complete authority',
      stable: 'Use authority',
    ),
    sourceLabel: 'Spend authority',
  );
}

ProjectRiskIssueItem _cashFlowItem(ProjectFinanceWorkspaceSummary summary) {
  final forecast = summary.cashFlowForecast;
  final level = _fromCashFlowLevel(forecast.level);

  return ProjectRiskIssueItem(
    id: '${summary.project.id}-cash-flow-risk-issue',
    title: forecast.title,
    detail: forecast.detail,
    kind: ProjectRiskIssueKind.cashFlow,
    level: level,
    icon: forecast.level.icon,
    ownerLabel: _sponsorOrOwner(summary),
    evidenceLabel: 'Release gate, reserve reason, authority, funding note',
    actionLabel: _actionLabel(
      level,
      critical: 'Hold funding',
      watch: 'Review funding',
      stable: 'Release funding',
    ),
    sourceLabel: 'Cash flow',
  );
}

ProjectRiskIssueItem _evidenceItem(
  ProjectPortfolioItem project,
  ProjectFinanceReconciliationItem item,
) {
  final level = _fromReconciliationLevel(item.level);

  return ProjectRiskIssueItem(
    id: '${project.id}-${item.id}-evidence-risk-issue',
    title: item.title,
    detail: item.detail,
    kind: ProjectRiskIssueKind.evidence,
    level: level,
    icon: item.icon,
    ownerLabel: item.ownerLabel,
    evidenceLabel: item.evidenceLabel,
    actionLabel: _actionLabel(
      level,
      critical: 'Resolve evidence',
      watch: 'Validate evidence',
      stable: 'Archive evidence',
    ),
    sourceLabel: item.kind.label,
  );
}

ProjectRiskIssueLevel _milestoneLevel(
  ProjectMilestone milestone,
  DateTime asOfDate,
) {
  final dueDate = DateUtils.dateOnly(milestone.dueDate);
  final dueInDays = dueDate.difference(asOfDate).inDays;
  if (dueInDays < 0) return ProjectRiskIssueLevel.critical;
  if (dueInDays <= 14) return ProjectRiskIssueLevel.watch;
  return ProjectRiskIssueLevel.stable;
}

ProjectRiskIssueLevel _fromProjectHealth(ProjectHealth health) {
  switch (health) {
    case ProjectHealth.onTrack:
      return ProjectRiskIssueLevel.stable;
    case ProjectHealth.atRisk:
      return ProjectRiskIssueLevel.watch;
    case ProjectHealth.blocked:
      return ProjectRiskIssueLevel.critical;
  }
}

ProjectRiskIssueLevel _fromFinanceControlLevel(
  ProjectFinanceControlLevel level,
) {
  switch (level) {
    case ProjectFinanceControlLevel.stable:
      return ProjectRiskIssueLevel.stable;
    case ProjectFinanceControlLevel.watch:
      return ProjectRiskIssueLevel.watch;
    case ProjectFinanceControlLevel.actionRequired:
      return ProjectRiskIssueLevel.critical;
  }
}

ProjectRiskIssueLevel _fromAuthorityLevel(ProjectSpendAuthorityLevel level) {
  switch (level) {
    case ProjectSpendAuthorityLevel.delegated:
      return ProjectRiskIssueLevel.stable;
    case ProjectSpendAuthorityLevel.guarded:
      return ProjectRiskIssueLevel.watch;
    case ProjectSpendAuthorityLevel.escalation:
      return ProjectRiskIssueLevel.critical;
  }
}

ProjectRiskIssueLevel _fromCashFlowLevel(ProjectCashFlowForecastLevel level) {
  switch (level) {
    case ProjectCashFlowForecastLevel.healthy:
      return ProjectRiskIssueLevel.stable;
    case ProjectCashFlowForecastLevel.watch:
      return ProjectRiskIssueLevel.watch;
    case ProjectCashFlowForecastLevel.constrained:
      return ProjectRiskIssueLevel.critical;
  }
}

ProjectRiskIssueLevel _fromReconciliationLevel(
  ProjectFinanceReconciliationLevel level,
) {
  switch (level) {
    case ProjectFinanceReconciliationLevel.clean:
      return ProjectRiskIssueLevel.stable;
    case ProjectFinanceReconciliationLevel.needsEvidence:
      return ProjectRiskIssueLevel.watch;
    case ProjectFinanceReconciliationLevel.blocked:
      return ProjectRiskIssueLevel.critical;
  }
}

String _actionLabel(
  ProjectRiskIssueLevel level, {
  required String critical,
  required String watch,
  required String stable,
}) {
  switch (level) {
    case ProjectRiskIssueLevel.critical:
      return critical;
    case ProjectRiskIssueLevel.watch:
      return watch;
    case ProjectRiskIssueLevel.stable:
      return stable;
  }
}

String _sponsorOrOwner(ProjectFinanceWorkspaceSummary summary) {
  final sponsor = summary.project.sponsor.trim();
  return sponsor.isEmpty ? summary.project.owner : sponsor;
}

int _compareItems(ProjectRiskIssueItem left, ProjectRiskIssueItem right) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;

  final kindCompare = left.kind.index.compareTo(right.kind.index);
  if (kindCompare != 0) return kindCompare;

  return left.title.compareTo(right.title);
}

int _levelRank(ProjectRiskIssueLevel level) {
  switch (level) {
    case ProjectRiskIssueLevel.critical:
      return 0;
    case ProjectRiskIssueLevel.watch:
      return 1;
    case ProjectRiskIssueLevel.stable:
      return 2;
  }
}

String _pluralDays(int days) => '$days day${days == 1 ? '' : 's'}';

String _slug(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

extension ProjectRiskIssueLevelPresentation on ProjectRiskIssueLevel {
  /// User-facing label for a risk and issue level.
  String get label {
    switch (this) {
      case ProjectRiskIssueLevel.stable:
        return 'Stable';
      case ProjectRiskIssueLevel.watch:
        return 'Watch';
      case ProjectRiskIssueLevel.critical:
        return 'Critical';
    }
  }

  /// Icon for a risk and issue level.
  IconData get icon {
    switch (this) {
      case ProjectRiskIssueLevel.stable:
        return Icons.verified_outlined;
      case ProjectRiskIssueLevel.watch:
        return Icons.visibility_outlined;
      case ProjectRiskIssueLevel.critical:
        return Icons.priority_high_rounded;
    }
  }

  /// Numeric exposure weight used by risk summaries.
  int get exposureWeight {
    switch (this) {
      case ProjectRiskIssueLevel.stable:
        return 1;
      case ProjectRiskIssueLevel.watch:
        return 2;
      case ProjectRiskIssueLevel.critical:
        return 3;
    }
  }

  /// Color for a risk and issue level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectRiskIssueLevel.stable:
        return Colors.green.shade700;
      case ProjectRiskIssueLevel.watch:
        return Colors.orange.shade700;
      case ProjectRiskIssueLevel.critical:
        return colorScheme.error;
    }
  }
}

extension ProjectRiskIssueKindPresentation on ProjectRiskIssueKind {
  /// User-facing label for a risk and issue source kind.
  String get label {
    switch (this) {
      case ProjectRiskIssueKind.blocker:
        return 'Blocker';
      case ProjectRiskIssueKind.deliveryRisk:
        return 'Delivery Risk';
      case ProjectRiskIssueKind.milestone:
        return 'Milestone';
      case ProjectRiskIssueKind.budget:
        return 'Budget';
      case ProjectRiskIssueKind.financeControl:
        return 'Finance Control';
      case ProjectRiskIssueKind.authority:
        return 'Authority';
      case ProjectRiskIssueKind.cashFlow:
        return 'Cash Flow';
      case ProjectRiskIssueKind.evidence:
        return 'Evidence';
    }
  }
}

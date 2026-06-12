import 'package:flutter/material.dart';

import 'project_cash_flow_forecast_service.dart';
import 'project_finance_workspace_service.dart';
import 'project_spend_authority_service.dart';

/// Funding release readiness level for project cash movement gates.
enum ProjectFundingReleaseLevel { ready, review, blocked }

/// Funding release source used across project cash-flow workflows.
enum ProjectFundingReleaseKind {
  activeFunding,
  milestoneGate,
  completionRunway,
  reserveGuardrail,
  authorityGate,
}

/// UI-ready funding release gate built from forecast and authority signals.
class ProjectFundingReleaseStep {
  const ProjectFundingReleaseStep({
    required this.id,
    required this.title,
    required this.detail,
    required this.kind,
    required this.level,
    required this.icon,
    required this.amount,
    required this.releaseShare,
    required this.gateLabel,
    required this.ownerLabel,
    required this.evidenceLabel,
    required this.actionLabel,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String title;
  final String detail;
  final ProjectFundingReleaseKind kind;
  final ProjectFundingReleaseLevel level;
  final IconData icon;
  final double amount;
  final double releaseShare;
  final String gateLabel;
  final String ownerLabel;
  final String evidenceLabel;
  final String actionLabel;
  final DateTime startDate;
  final DateTime endDate;

  bool get isReady => level == ProjectFundingReleaseLevel.ready;
  bool get isBlocked => level == ProjectFundingReleaseLevel.blocked;
  int get releaseSharePercent => (releaseShare * 100).round();
  String get amountLabel => _money(amount);
  String get releaseShareLabel =>
      releaseShare <= 0 ? '-' : '$releaseSharePercent%';
  String get dateRangeLabel =>
      '${_dateLabel(startDate)} - ${_dateLabel(endDate)}';
}

/// Aggregated funding release workspace for one selected project.
class ProjectFundingReleaseSummary {
  const ProjectFundingReleaseSummary({
    required this.projectId,
    required this.projectName,
    required this.businessDomain,
    required this.totalBudget,
    required this.steps,
  });

  final String projectId;
  final String projectName;
  final String businessDomain;
  final double totalBudget;
  final List<ProjectFundingReleaseStep> steps;

  int get stepCount => steps.length;
  int get readyCount => steps.where((step) => step.isReady).length;
  int get reviewCount =>
      steps
          .where((step) => step.level == ProjectFundingReleaseLevel.review)
          .length;
  int get blockedCount => steps.where((step) => step.isBlocked).length;
  double get releaseAmount => steps.fold(0, (sum, step) => sum + step.amount);
  double get attentionAmount => steps
      .where((step) => !step.isReady)
      .fold(0, (sum, step) => sum + step.amount);
  String get releaseAmountLabel => _money(releaseAmount);
  String get attentionAmountLabel => _money(attentionAmount);

  ProjectFundingReleaseLevel get level {
    if (blockedCount > 0) return ProjectFundingReleaseLevel.blocked;
    if (reviewCount > 0) return ProjectFundingReleaseLevel.review;
    return ProjectFundingReleaseLevel.ready;
  }

  ProjectFundingReleaseStep? get primaryStep {
    if (steps.isEmpty) return null;
    final sorted = [...steps]..sort(_compareSteps);
    return sorted.first;
  }

  String get title {
    switch (level) {
      case ProjectFundingReleaseLevel.ready:
        return 'Funding releases ready';
      case ProjectFundingReleaseLevel.review:
        return 'Funding releases need review';
      case ProjectFundingReleaseLevel.blocked:
        return 'Funding releases blocked';
    }
  }

  String get detail {
    final primary = primaryStep;
    if (primary == null) {
      return 'No funding release gates are configured for $businessDomain.';
    }

    return '$readyCount of $stepCount release gates ready - next: ${primary.title}.';
  }
}

/// Builds release-gate decisions from project cash-flow and authority context.
ProjectFundingReleaseSummary buildProjectFundingReleaseSummary(
  ProjectFinanceWorkspaceSummary summary,
) {
  final forecast = summary.cashFlowForecast;
  final totalBudget = summary.financeLedger.plannedAmount;
  final steps = <ProjectFundingReleaseStep>[
    for (final window in forecast.windows)
      _windowStep(
        window: window,
        totalBudget: totalBudget,
        ownerLabel: _sponsorOrOwner(summary),
      ),
    if (summary.spendAuthority.level != ProjectSpendAuthorityLevel.delegated)
      _authorityStep(summary),
  ]..sort(_compareSteps);

  return ProjectFundingReleaseSummary(
    projectId: summary.project.id,
    projectName: summary.project.name,
    businessDomain: summary.project.businessDomain,
    totalBudget: totalBudget,
    steps: List.unmodifiable(steps),
  );
}

ProjectFundingReleaseStep _windowStep({
  required ProjectCashFlowWindow window,
  required double totalBudget,
  required String ownerLabel,
}) {
  final level = _fromForecastLevel(window.level);
  final kind = _fromWindowKind(window.kind);

  return ProjectFundingReleaseStep(
    id: '${window.id}-funding-release',
    title: window.title,
    detail: window.detail,
    kind: kind,
    level: level,
    icon: window.icon,
    amount: totalBudget * window.releaseShare,
    releaseShare: window.releaseShare,
    gateLabel: window.gateLabel,
    ownerLabel: ownerLabel,
    evidenceLabel: _windowEvidenceLabel(window.kind),
    actionLabel: _windowActionLabel(kind, level),
    startDate: window.startDate,
    endDate: window.endDate,
  );
}

ProjectFundingReleaseStep _authorityStep(
  ProjectFinanceWorkspaceSummary summary,
) {
  final authority = summary.spendAuthority;
  final level = _fromAuthorityLevel(authority.level);

  return ProjectFundingReleaseStep(
    id: '${summary.project.id}-funding-authority-release',
    title: authority.title,
    detail: authority.detail,
    kind: ProjectFundingReleaseKind.authorityGate,
    level: level,
    icon: authority.level.icon,
    amount: 0,
    releaseShare: 0,
    gateLabel: 'Authority',
    ownerLabel: _sponsorOrOwner(summary),
    evidenceLabel: 'Delegation rule, approval threshold, release owner',
    actionLabel:
        level == ProjectFundingReleaseLevel.blocked
            ? 'Escalate authority'
            : 'Complete authority',
    startDate: summary.cashFlowForecast.asOfDate,
    endDate: summary.project.endDate,
  );
}

ProjectFundingReleaseKind _fromWindowKind(ProjectCashFlowWindowKind kind) {
  switch (kind) {
    case ProjectCashFlowWindowKind.active:
      return ProjectFundingReleaseKind.activeFunding;
    case ProjectCashFlowWindowKind.milestone:
      return ProjectFundingReleaseKind.milestoneGate;
    case ProjectCashFlowWindowKind.completion:
      return ProjectFundingReleaseKind.completionRunway;
    case ProjectCashFlowWindowKind.reserve:
      return ProjectFundingReleaseKind.reserveGuardrail;
  }
}

ProjectFundingReleaseLevel _fromForecastLevel(
  ProjectCashFlowForecastLevel level,
) {
  switch (level) {
    case ProjectCashFlowForecastLevel.healthy:
      return ProjectFundingReleaseLevel.ready;
    case ProjectCashFlowForecastLevel.watch:
      return ProjectFundingReleaseLevel.review;
    case ProjectCashFlowForecastLevel.constrained:
      return ProjectFundingReleaseLevel.blocked;
  }
}

ProjectFundingReleaseLevel _fromAuthorityLevel(
  ProjectSpendAuthorityLevel level,
) {
  switch (level) {
    case ProjectSpendAuthorityLevel.delegated:
      return ProjectFundingReleaseLevel.ready;
    case ProjectSpendAuthorityLevel.guarded:
      return ProjectFundingReleaseLevel.review;
    case ProjectSpendAuthorityLevel.escalation:
      return ProjectFundingReleaseLevel.blocked;
  }
}

String _windowEvidenceLabel(ProjectCashFlowWindowKind kind) {
  switch (kind) {
    case ProjectCashFlowWindowKind.active:
      return 'Spend evidence, approval route, budget owner confirmation';
    case ProjectCashFlowWindowKind.milestone:
      return 'Milestone acceptance, sponsor note, release checklist';
    case ProjectCashFlowWindowKind.completion:
      return 'Handoff evidence, final commitments, closeout owner';
    case ProjectCashFlowWindowKind.reserve:
      return 'Reserve reason, release condition, sponsor approval';
  }
}

String _windowActionLabel(
  ProjectFundingReleaseKind kind,
  ProjectFundingReleaseLevel level,
) {
  switch (level) {
    case ProjectFundingReleaseLevel.ready:
      return 'Release window';
    case ProjectFundingReleaseLevel.review:
      return 'Review gate';
    case ProjectFundingReleaseLevel.blocked:
      return kind == ProjectFundingReleaseKind.reserveGuardrail
          ? 'Hold reserve'
          : 'Hold release';
  }
}

String _sponsorOrOwner(ProjectFinanceWorkspaceSummary summary) {
  final sponsor = summary.project.sponsor.trim();
  return sponsor.isEmpty ? summary.project.owner : sponsor;
}

int _compareSteps(
  ProjectFundingReleaseStep left,
  ProjectFundingReleaseStep right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;

  final dateCompare = left.startDate.compareTo(right.startDate);
  if (dateCompare != 0) return dateCompare;

  final amountCompare = right.amount.compareTo(left.amount);
  if (amountCompare != 0) return amountCompare;

  return left.kind.index.compareTo(right.kind.index);
}

int _levelRank(ProjectFundingReleaseLevel level) {
  switch (level) {
    case ProjectFundingReleaseLevel.blocked:
      return 0;
    case ProjectFundingReleaseLevel.review:
      return 1;
    case ProjectFundingReleaseLevel.ready:
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

extension ProjectFundingReleaseLevelPresentation on ProjectFundingReleaseLevel {
  /// User-facing label for a funding release readiness level.
  String get label {
    switch (this) {
      case ProjectFundingReleaseLevel.ready:
        return 'Ready';
      case ProjectFundingReleaseLevel.review:
        return 'Review';
      case ProjectFundingReleaseLevel.blocked:
        return 'Blocked';
    }
  }

  /// Icon for a funding release readiness level.
  IconData get icon {
    switch (this) {
      case ProjectFundingReleaseLevel.ready:
        return Icons.verified_outlined;
      case ProjectFundingReleaseLevel.review:
        return Icons.visibility_outlined;
      case ProjectFundingReleaseLevel.blocked:
        return Icons.block_outlined;
    }
  }

  /// Color for a funding release readiness level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectFundingReleaseLevel.ready:
        return Colors.green.shade700;
      case ProjectFundingReleaseLevel.review:
        return Colors.orange.shade700;
      case ProjectFundingReleaseLevel.blocked:
        return colorScheme.error;
    }
  }
}

extension ProjectFundingReleaseKindPresentation on ProjectFundingReleaseKind {
  /// User-facing label for a funding release source kind.
  String get label {
    switch (this) {
      case ProjectFundingReleaseKind.activeFunding:
        return 'Active Funding';
      case ProjectFundingReleaseKind.milestoneGate:
        return 'Milestone Gate';
      case ProjectFundingReleaseKind.completionRunway:
        return 'Completion';
      case ProjectFundingReleaseKind.reserveGuardrail:
        return 'Reserve';
      case ProjectFundingReleaseKind.authorityGate:
        return 'Authority';
    }
  }
}

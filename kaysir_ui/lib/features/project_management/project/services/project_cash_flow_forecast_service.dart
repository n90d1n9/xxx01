import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/project_portfolio_item.dart';
import 'project_cost_structure_service.dart';
import 'project_spend_authority_service.dart';

/// Cash-flow forecast health for a project funding plan.
enum ProjectCashFlowForecastLevel { healthy, watch, constrained }

/// Forecast window type used to phase budget releases across delivery.
enum ProjectCashFlowWindowKind { active, milestone, completion, reserve }

/// One forecasted funding release or reserve window for a project.
class ProjectCashFlowWindow {
  const ProjectCashFlowWindow({
    required this.id,
    required this.title,
    required this.detail,
    required this.kind,
    required this.level,
    required this.icon,
    required this.startDate,
    required this.endDate,
    required this.releaseShare,
    required this.gateLabel,
  });

  final String id;
  final String title;
  final String detail;
  final ProjectCashFlowWindowKind kind;
  final ProjectCashFlowForecastLevel level;
  final IconData icon;
  final DateTime startDate;
  final DateTime endDate;
  final double releaseShare;
  final String gateLabel;

  int get releaseSharePercent => (releaseShare * 100).round();
  bool get needsAttention => level != ProjectCashFlowForecastLevel.healthy;
}

/// Project cash-flow forecast summary for detail screens and future ledgers.
class ProjectCashFlowForecastSummary {
  const ProjectCashFlowForecastSummary({
    required this.projectId,
    required this.projectName,
    required this.asOfDate,
    required this.budgetUsed,
    required this.projectedAtCompletion,
    required this.costStructure,
    required this.spendAuthority,
    required this.windows,
  });

  final String projectId;
  final String projectName;
  final DateTime asOfDate;
  final double budgetUsed;
  final double projectedAtCompletion;
  final ProjectCostStructureSummary costStructure;
  final ProjectSpendAuthoritySummary spendAuthority;
  final List<ProjectCashFlowWindow> windows;

  int get budgetUsedPercent => (budgetUsed * 100).round();
  int get remainingBudgetPercent =>
      ((1 - budgetUsed).clamp(0, 1) * 100).round();
  int get projectedAtCompletionPercent => (projectedAtCompletion * 100).round();
  int get windowCount => windows.length;
  int get constrainedWindowCount =>
      windows.where((window) => window.needsAttention).length;

  ProjectCashFlowWindow get nextWindow {
    final sorted = [...windows]..sort(_compareWindows);
    return sorted.first;
  }

  ProjectCashFlowForecastLevel get level {
    if (projectedAtCompletion >= 1.2 ||
        spendAuthority.escalationCount > 0 ||
        windows.any(
          (window) => window.level == ProjectCashFlowForecastLevel.constrained,
        )) {
      return ProjectCashFlowForecastLevel.constrained;
    }
    if (projectedAtCompletion >= 1.05 ||
        spendAuthority.guardedCount > 0 ||
        costStructure.watchCount > 0) {
      return ProjectCashFlowForecastLevel.watch;
    }
    return ProjectCashFlowForecastLevel.healthy;
  }

  String get title {
    switch (level) {
      case ProjectCashFlowForecastLevel.healthy:
        return 'Cash flow forecast healthy';
      case ProjectCashFlowForecastLevel.watch:
        return 'Cash flow needs watch';
      case ProjectCashFlowForecastLevel.constrained:
        return 'Cash flow constrained';
    }
  }

  String get detail {
    return '$remainingBudgetPercent% budget runway remains - projected at $projectedAtCompletionPercent% by completion - next gate: ${nextWindow.gateLabel}.';
  }
}

/// Builds project cash-flow forecast windows from budget, cost, and authority data.
ProjectCashFlowForecastSummary buildProjectCashFlowForecastSummary(
  ProjectPortfolioItem project, {
  ProjectCostStructureSummary? costStructure,
  ProjectSpendAuthoritySummary? spendAuthority,
  DateTime? today,
}) {
  final asOfDate = DateUtils.dateOnly(today ?? DateTime.now());
  final cost = costStructure ?? buildProjectCostStructureSummary(project);
  final authority =
      spendAuthority ?? buildProjectSpendAuthoritySummary(project);
  final projectedAtCompletion = _projectedAtCompletion(project);
  final windows = _forecastWindows(
    project: project,
    costStructure: cost,
    spendAuthority: authority,
    projectedAtCompletion: projectedAtCompletion,
    asOfDate: asOfDate,
  );

  return ProjectCashFlowForecastSummary(
    projectId: project.id,
    projectName: project.name,
    asOfDate: asOfDate,
    budgetUsed: project.budgetUsed,
    projectedAtCompletion: projectedAtCompletion,
    costStructure: cost,
    spendAuthority: authority,
    windows: List.unmodifiable(windows),
  );
}

extension ProjectCashFlowForecastLevelPresentation
    on ProjectCashFlowForecastLevel {
  /// User-facing label for a cash-flow forecast level.
  String get label {
    switch (this) {
      case ProjectCashFlowForecastLevel.healthy:
        return 'Healthy';
      case ProjectCashFlowForecastLevel.watch:
        return 'Watch';
      case ProjectCashFlowForecastLevel.constrained:
        return 'Constrained';
    }
  }

  /// Icon for a cash-flow forecast level.
  IconData get icon {
    switch (this) {
      case ProjectCashFlowForecastLevel.healthy:
        return Icons.trending_up_rounded;
      case ProjectCashFlowForecastLevel.watch:
        return Icons.visibility_outlined;
      case ProjectCashFlowForecastLevel.constrained:
        return Icons.priority_high_rounded;
    }
  }

  /// Color for a cash-flow forecast level.
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectCashFlowForecastLevel.healthy:
        return Colors.green.shade700;
      case ProjectCashFlowForecastLevel.watch:
        return Colors.orange.shade700;
      case ProjectCashFlowForecastLevel.constrained:
        return colorScheme.error;
    }
  }
}

extension ProjectCashFlowWindowKindPresentation on ProjectCashFlowWindowKind {
  /// User-facing label for a forecast window kind.
  String get label {
    switch (this) {
      case ProjectCashFlowWindowKind.active:
        return 'Active Window';
      case ProjectCashFlowWindowKind.milestone:
        return 'Milestone Gate';
      case ProjectCashFlowWindowKind.completion:
        return 'Completion Runway';
      case ProjectCashFlowWindowKind.reserve:
        return 'Reserve';
    }
  }
}

List<ProjectCashFlowWindow> _forecastWindows({
  required ProjectPortfolioItem project,
  required ProjectCostStructureSummary costStructure,
  required ProjectSpendAuthoritySummary spendAuthority,
  required double projectedAtCompletion,
  required DateTime asOfDate,
}) {
  final nextMilestone = _nextMilestone(project, asOfDate);
  final projectEndDate = DateUtils.dateOnly(project.endDate);
  final nextGateDate = DateUtils.dateOnly(
    nextMilestone?.dueDate ?? projectEndDate,
  );
  final remainingShare = (1 - project.budgetUsed).clamp(0, 1).toDouble();
  final reserveShare =
      (costStructure.contingencySharePercent / 100).clamp(0.0, 1.0).toDouble();
  final activeShare =
      math
          .min(remainingShare, math.max(0.08, remainingShare * 0.35))
          .toDouble();
  final milestoneShare =
      math
          .min(
            math.max(0.0, remainingShare - activeShare),
            nextMilestone == null ? 0.0 : math.max(0.1, remainingShare * 0.3),
          )
          .toDouble();
  final completionShare =
      math.max(0.0, remainingShare - activeShare - milestoneShare).toDouble();

  return [
    ProjectCashFlowWindow(
      id: '${project.id}-active-cash-flow',
      title: 'Active funding window',
      detail:
          'Release near-term budget only after current spend evidence and authority checks are complete.',
      kind: ProjectCashFlowWindowKind.active,
      level: _activeWindowLevel(spendAuthority, projectedAtCompletion),
      icon: Icons.payments_outlined,
      startDate: asOfDate,
      endDate: nextGateDate,
      releaseShare: activeShare,
      gateLabel: nextMilestone?.label ?? 'Project completion',
    ),
    if (nextMilestone != null)
      ProjectCashFlowWindow(
        id: '${project.id}-milestone-cash-flow',
        title: '${nextMilestone.label} release gate',
        detail:
            'Hold the next release until milestone acceptance, proof, and approval route are clear.',
        kind: ProjectCashFlowWindowKind.milestone,
        level: _milestoneWindowLevel(
          milestone: nextMilestone,
          asOfDate: asOfDate,
          spendAuthority: spendAuthority,
        ),
        icon: Icons.flag_outlined,
        startDate: nextGateDate,
        endDate: _windowEnd(nextGateDate, projectEndDate, days: 14),
        releaseShare: milestoneShare,
        gateLabel: nextMilestone.label,
      ),
    ProjectCashFlowWindow(
      id: '${project.id}-completion-cash-flow',
      title: 'Completion runway',
      detail:
          'Protect remaining budget for final delivery, handoff, and acceptance evidence.',
      kind: ProjectCashFlowWindowKind.completion,
      level: _completionWindowLevel(projectedAtCompletion, spendAuthority),
      icon: Icons.route_outlined,
      startDate: _windowEnd(nextGateDate, projectEndDate, days: 15),
      endDate: projectEndDate,
      releaseShare: completionShare,
      gateLabel: 'Completion',
    ),
    ProjectCashFlowWindow(
      id: '${project.id}-reserve-cash-flow',
      title: 'Reserve guardrail',
      detail:
          'Keep contingency visible for scope movement, supplier changes, or sponsor-approved exceptions.',
      kind: ProjectCashFlowWindowKind.reserve,
      level: _reserveWindowLevel(
        remainingShare: remainingShare,
        reserveShare: reserveShare,
        projectedAtCompletion: projectedAtCompletion,
      ),
      icon: Icons.savings_outlined,
      startDate: asOfDate,
      endDate: projectEndDate,
      releaseShare: reserveShare,
      gateLabel: 'Reserve',
    ),
  ]..sort(_compareWindows);
}

ProjectMilestone? _nextMilestone(
  ProjectPortfolioItem project,
  DateTime asOfDate,
) {
  final incomplete =
      project.milestones.where((milestone) => !milestone.isComplete).toList()
        ..sort((left, right) => left.dueDate.compareTo(right.dueDate));
  if (incomplete.isEmpty) return null;

  for (final milestone in incomplete) {
    if (!DateUtils.dateOnly(milestone.dueDate).isBefore(asOfDate)) {
      return milestone;
    }
  }
  return incomplete.first;
}

ProjectCashFlowForecastLevel _activeWindowLevel(
  ProjectSpendAuthoritySummary spendAuthority,
  double projectedAtCompletion,
) {
  if (spendAuthority.escalationCount > 0 || projectedAtCompletion >= 1.2) {
    return ProjectCashFlowForecastLevel.constrained;
  }
  if (spendAuthority.guardedCount > 0 || projectedAtCompletion >= 1.05) {
    return ProjectCashFlowForecastLevel.watch;
  }
  return ProjectCashFlowForecastLevel.healthy;
}

ProjectCashFlowForecastLevel _milestoneWindowLevel({
  required ProjectMilestone milestone,
  required DateTime asOfDate,
  required ProjectSpendAuthoritySummary spendAuthority,
}) {
  final milestoneDate = DateUtils.dateOnly(milestone.dueDate);
  if (milestoneDate.isBefore(asOfDate) || spendAuthority.escalationCount > 0) {
    return ProjectCashFlowForecastLevel.constrained;
  }
  if (spendAuthority.guardedCount > 0) {
    return ProjectCashFlowForecastLevel.watch;
  }
  return ProjectCashFlowForecastLevel.healthy;
}

ProjectCashFlowForecastLevel _completionWindowLevel(
  double projectedAtCompletion,
  ProjectSpendAuthoritySummary spendAuthority,
) {
  if (projectedAtCompletion >= 1.2 || spendAuthority.escalationCount > 0) {
    return ProjectCashFlowForecastLevel.constrained;
  }
  if (projectedAtCompletion >= 1.05 || spendAuthority.guardedCount > 0) {
    return ProjectCashFlowForecastLevel.watch;
  }
  return ProjectCashFlowForecastLevel.healthy;
}

ProjectCashFlowForecastLevel _reserveWindowLevel({
  required double remainingShare,
  required double reserveShare,
  required double projectedAtCompletion,
}) {
  if (remainingShare < reserveShare || projectedAtCompletion >= 1.2) {
    return ProjectCashFlowForecastLevel.constrained;
  }
  if (remainingShare < reserveShare * 1.5 || projectedAtCompletion >= 1.05) {
    return ProjectCashFlowForecastLevel.watch;
  }
  return ProjectCashFlowForecastLevel.healthy;
}

double _projectedAtCompletion(ProjectPortfolioItem project) {
  final effectiveProgress = math.max(project.progress, 0.1);
  return (project.budgetUsed / effectiveProgress).clamp(0, 2).toDouble();
}

DateTime _windowEnd(
  DateTime startDate,
  DateTime projectEndDate, {
  required int days,
}) {
  final candidate = startDate.add(Duration(days: days));
  return candidate.isAfter(projectEndDate) ? projectEndDate : candidate;
}

int _compareWindows(ProjectCashFlowWindow left, ProjectCashFlowWindow right) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;
  return _kindRank(left.kind).compareTo(_kindRank(right.kind));
}

int _levelRank(ProjectCashFlowForecastLevel level) {
  switch (level) {
    case ProjectCashFlowForecastLevel.constrained:
      return 0;
    case ProjectCashFlowForecastLevel.watch:
      return 1;
    case ProjectCashFlowForecastLevel.healthy:
      return 2;
  }
}

int _kindRank(ProjectCashFlowWindowKind kind) {
  switch (kind) {
    case ProjectCashFlowWindowKind.active:
      return 0;
    case ProjectCashFlowWindowKind.milestone:
      return 1;
    case ProjectCashFlowWindowKind.completion:
      return 2;
    case ProjectCashFlowWindowKind.reserve:
      return 3;
  }
}

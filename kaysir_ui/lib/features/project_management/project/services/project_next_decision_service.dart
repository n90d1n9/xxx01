import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../models/project_portfolio_item.dart';
import 'project_readiness_score_service.dart';
import 'project_timeline_health_service.dart';

enum ProjectNextDecisionLevel { critical, warning, action, healthy }

enum ProjectNextDecisionKind {
  timeline,
  readiness,
  risk,
  budget,
  milestone,
  cadence,
}

class ProjectNextDecision {
  const ProjectNextDecision({
    required this.title,
    required this.detail,
    required this.level,
    required this.kind,
    required this.icon,
    this.task,
  });

  final String title;
  final String detail;
  final ProjectNextDecisionLevel level;
  final ProjectNextDecisionKind kind;
  final IconData icon;
  final gantt.GanttTask? task;
}

class ProjectNextDecisionSummary {
  const ProjectNextDecisionSummary({
    required this.project,
    required this.decisions,
    required this.level,
    required this.readinessScore,
    required this.timelineIssueCount,
    required this.briefText,
  });

  final ProjectPortfolioItem project;
  final List<ProjectNextDecision> decisions;
  final ProjectNextDecisionLevel level;
  final int readinessScore;
  final int timelineIssueCount;
  final String briefText;

  ProjectNextDecision get primaryDecision => decisions.first;

  int get criticalCount =>
      decisions
          .where(
            (decision) => decision.level == ProjectNextDecisionLevel.critical,
          )
          .length;
  int get warningCount =>
      decisions
          .where(
            (decision) => decision.level == ProjectNextDecisionLevel.warning,
          )
          .length;
  int get actionCount =>
      decisions
          .where(
            (decision) => decision.level == ProjectNextDecisionLevel.action,
          )
          .length;
  int get healthyCount =>
      decisions
          .where(
            (decision) => decision.level == ProjectNextDecisionLevel.healthy,
          )
          .length;
}

extension ProjectNextDecisionLevelPresentation on ProjectNextDecisionLevel {
  String get label {
    switch (this) {
      case ProjectNextDecisionLevel.critical:
        return 'Critical';
      case ProjectNextDecisionLevel.warning:
        return 'Watch';
      case ProjectNextDecisionLevel.action:
        return 'Next';
      case ProjectNextDecisionLevel.healthy:
        return 'Healthy';
    }
  }

  String get summaryLabel {
    switch (this) {
      case ProjectNextDecisionLevel.critical:
        return 'Decision Needed';
      case ProjectNextDecisionLevel.warning:
        return 'Needs Guardrail';
      case ProjectNextDecisionLevel.action:
        return 'Next Step';
      case ProjectNextDecisionLevel.healthy:
        return 'Steady';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectNextDecisionLevel.critical:
        return Icons.priority_high_rounded;
      case ProjectNextDecisionLevel.warning:
        return Icons.visibility_outlined;
      case ProjectNextDecisionLevel.action:
        return Icons.task_alt_outlined;
      case ProjectNextDecisionLevel.healthy:
        return Icons.check_circle_outline;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectNextDecisionLevel.critical:
        return colorScheme.error;
      case ProjectNextDecisionLevel.warning:
        return Colors.orange.shade700;
      case ProjectNextDecisionLevel.action:
        return colorScheme.primary;
      case ProjectNextDecisionLevel.healthy:
        return Colors.green.shade700;
    }
  }
}

extension ProjectNextDecisionKindPresentation on ProjectNextDecisionKind {
  String get label {
    switch (this) {
      case ProjectNextDecisionKind.timeline:
        return 'Timeline';
      case ProjectNextDecisionKind.readiness:
        return 'Readiness';
      case ProjectNextDecisionKind.risk:
        return 'Risk';
      case ProjectNextDecisionKind.budget:
        return 'Budget';
      case ProjectNextDecisionKind.milestone:
        return 'Milestone';
      case ProjectNextDecisionKind.cadence:
        return 'Cadence';
    }
  }
}

ProjectNextDecisionSummary buildProjectNextDecisionSummary({
  required ProjectPortfolioItem project,
  required List<gantt.GanttTask> timelineTasks,
  List<gantt.GanttTask>? dependencyTasks,
  DateTime? today,
  int limit = 5,
}) {
  final readiness = buildProjectReadinessScoreSummary(
    project: project,
    timelineTasks: timelineTasks,
    today: today,
  );
  final timeline = buildProjectTimelineHealthRollup(
    tasks: timelineTasks,
    dependencyTasks: dependencyTasks,
    today: today,
  );
  final decisions = <ProjectNextDecision>[];

  final timelineIssue = _primaryTimelineIssue(timeline.issues);
  if (timelineIssue != null) {
    decisions.add(_timelineDecision(timelineIssue, timeline));
  }

  final readinessFactor = _primaryReadinessFactor(
    readiness.factors,
    timeline: timeline,
  );
  if (readinessFactor != null) {
    decisions.add(_readinessDecision(readinessFactor));
  }

  final activeRisk = _primaryRisk(project.risks);
  if (activeRisk != null) {
    decisions.add(_riskDecision(activeRisk));
  }

  final budgetGap = project.budgetUsed - project.progress;
  if (budgetGap >= 0.15) {
    decisions.add(_budgetDecision(project, budgetGap));
  }

  final milestoneDecision = _milestoneDecision(project, today: today);
  if (milestoneDecision != null) decisions.add(milestoneDecision);

  if (decisions.isEmpty) {
    decisions.add(
      const ProjectNextDecision(
        title: 'Keep delivery cadence',
        detail:
            'Readiness, budget, risks, and timeline signals are aligned enough to keep the current plan.',
        level: ProjectNextDecisionLevel.healthy,
        kind: ProjectNextDecisionKind.cadence,
        icon: Icons.check_circle_outline,
      ),
    );
  }

  final visibleDecisions = List<ProjectNextDecision>.unmodifiable(
    decisions.take(limit),
  );
  final summaryLevel = _summaryLevel(visibleDecisions);

  return ProjectNextDecisionSummary(
    project: project,
    decisions: visibleDecisions,
    level: summaryLevel,
    readinessScore: readiness.score,
    timelineIssueCount: timeline.issues.length,
    briefText: _decisionBriefText(
      project: project,
      decisions: visibleDecisions,
      level: summaryLevel,
      readinessScore: readiness.score,
      timelineIssueCount: timeline.issues.length,
    ),
  );
}

ProjectTimelineHealthIssue? _primaryTimelineIssue(
  List<ProjectTimelineHealthIssue> issues,
) {
  return issues.firstWhereOrNull(
        (issue) => issue.kind != ProjectTimelineHealthIssueKind.active,
      ) ??
      issues.firstOrNull;
}

ProjectNextDecision _timelineDecision(
  ProjectTimelineHealthIssue issue,
  ProjectTimelineHealthRollup timeline,
) {
  switch (issue.kind) {
    case ProjectTimelineHealthIssueKind.dependencyBlock:
      return ProjectNextDecision(
        title: 'Clear dependency block',
        detail: '${issue.title}: ${issue.detail}',
        level: ProjectNextDecisionLevel.critical,
        kind: ProjectNextDecisionKind.timeline,
        icon: Icons.block_outlined,
        task: issue.task,
      );
    case ProjectTimelineHealthIssueKind.overdue:
      return ProjectNextDecision(
        title: 'Approve timeline recovery',
        detail:
            '${timeline.overdueCount} overdue task${timeline.overdueCount == 1 ? '' : 's'} need replanning, starting with ${issue.title}.',
        level: ProjectNextDecisionLevel.critical,
        kind: ProjectNextDecisionKind.timeline,
        icon: Icons.event_busy_outlined,
        task: issue.task,
      );
    case ProjectTimelineHealthIssueKind.dueSoon:
      return ProjectNextDecision(
        title: 'Confirm near-term capacity',
        detail: '${issue.title}: ${issue.detail}',
        level: ProjectNextDecisionLevel.warning,
        kind: ProjectNextDecisionKind.timeline,
        icon: Icons.upcoming_outlined,
        task: issue.task,
      );
    case ProjectTimelineHealthIssueKind.active:
      return ProjectNextDecision(
        title: 'Protect active work',
        detail: '${issue.title}: ${issue.detail}',
        level: ProjectNextDecisionLevel.action,
        kind: ProjectNextDecisionKind.timeline,
        icon: Icons.play_circle_outline_rounded,
        task: issue.task,
      );
  }
}

ProjectReadinessFactor? _primaryReadinessFactor(
  List<ProjectReadinessFactor> factors, {
  required ProjectTimelineHealthRollup timeline,
}) {
  final criticalFactors = factors.where(
    (factor) => factor.level == ProjectReadinessFactorLevel.critical,
  );
  final nonScheduleCritical = criticalFactors.firstWhereOrNull(
    (factor) => factor.title != 'Schedule recovery',
  );

  if (nonScheduleCritical != null) return nonScheduleCritical;

  if (timeline.overdueCount == 0) {
    final scheduleCritical = criticalFactors.firstWhereOrNull(
      (factor) => factor.title == 'Schedule recovery',
    );
    if (scheduleCritical != null) return scheduleCritical;
  }

  return factors.firstWhereOrNull(
    (factor) => factor.level == ProjectReadinessFactorLevel.warning,
  );
}

ProjectNextDecision _readinessDecision(ProjectReadinessFactor factor) {
  return ProjectNextDecision(
    title:
        factor.level == ProjectReadinessFactorLevel.critical
            ? 'Assign readiness owner'
            : 'Confirm readiness guardrail',
    detail: '${factor.title}: ${factor.detail}',
    level:
        factor.level == ProjectReadinessFactorLevel.critical
            ? ProjectNextDecisionLevel.critical
            : ProjectNextDecisionLevel.warning,
    kind: ProjectNextDecisionKind.readiness,
    icon: factor.icon,
  );
}

ProjectDeliveryRisk? _primaryRisk(List<ProjectDeliveryRisk> risks) {
  final activeRisks =
      risks.where((risk) => risk.severity != ProjectHealth.onTrack).toList();
  activeRisks.sort((left, right) {
    final severityComparison = _healthRank(
      left.severity,
    ).compareTo(_healthRank(right.severity));
    if (severityComparison != 0) return severityComparison;

    return left.title.compareTo(right.title);
  });

  return activeRisks.firstOrNull;
}

ProjectNextDecision _riskDecision(ProjectDeliveryRisk risk) {
  final isBlocked = risk.severity == ProjectHealth.blocked;

  return ProjectNextDecision(
    title: isBlocked ? 'Escalate delivery risk' : 'Confirm mitigation path',
    detail: '${risk.title}: ${risk.detail}',
    level:
        isBlocked
            ? ProjectNextDecisionLevel.critical
            : ProjectNextDecisionLevel.warning,
    kind: ProjectNextDecisionKind.risk,
    icon: risk.severity.icon,
  );
}

ProjectNextDecision _budgetDecision(
  ProjectPortfolioItem project,
  double budgetGap,
) {
  return ProjectNextDecision(
    title:
        budgetGap >= 0.25 ? 'Reset budget baseline' : 'Review budget baseline',
    detail:
        '${(project.budgetUsed * 100).round()}% budget used against ${(project.progress * 100).round()}% progress.',
    level:
        budgetGap >= 0.25
            ? ProjectNextDecisionLevel.critical
            : ProjectNextDecisionLevel.warning,
    kind: ProjectNextDecisionKind.budget,
    icon: Icons.account_balance_wallet_outlined,
  );
}

ProjectNextDecision? _milestoneDecision(
  ProjectPortfolioItem project, {
  DateTime? today,
}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final milestone =
      (project.milestones.where((milestone) => !milestone.isComplete).toList()
            ..sort((left, right) => left.dueDate.compareTo(right.dueDate)))
          .firstOrNull;

  if (milestone == null) return null;

  final days = DateUtils.dateOnly(milestone.dueDate).difference(asOf).inDays;
  if (days > 7) return null;

  return ProjectNextDecision(
    title: days < 0 ? 'Recover milestone gate' : 'Confirm milestone gate',
    detail:
        days < 0
            ? '${milestone.label} is ${_pluralDays(days.abs())} overdue.'
            : days == 0
            ? '${milestone.label} is due today.'
            : '${milestone.label} is due in ${_pluralDays(days)}.',
    level:
        days < 0
            ? ProjectNextDecisionLevel.critical
            : ProjectNextDecisionLevel.warning,
    kind: ProjectNextDecisionKind.milestone,
    icon: Icons.flag_outlined,
  );
}

ProjectNextDecisionLevel _summaryLevel(List<ProjectNextDecision> decisions) {
  if (decisions.any(
    (decision) => decision.level == ProjectNextDecisionLevel.critical,
  )) {
    return ProjectNextDecisionLevel.critical;
  }
  if (decisions.any(
    (decision) => decision.level == ProjectNextDecisionLevel.warning,
  )) {
    return ProjectNextDecisionLevel.warning;
  }
  if (decisions.any(
    (decision) => decision.level == ProjectNextDecisionLevel.action,
  )) {
    return ProjectNextDecisionLevel.action;
  }
  return ProjectNextDecisionLevel.healthy;
}

String _decisionBriefText({
  required ProjectPortfolioItem project,
  required List<ProjectNextDecision> decisions,
  required ProjectNextDecisionLevel level,
  required int readinessScore,
  required int timelineIssueCount,
}) {
  final primaryDecision = decisions.first;

  return [
    '${project.name} decision brief',
    'Status: ${level.summaryLabel}',
    'Readiness: $readinessScore/100',
    'Timeline signals: $timelineIssueCount',
    '',
    'Primary decision',
    '- ${primaryDecision.title}: ${primaryDecision.detail}',
    '',
    'Decision signals',
    for (final decision in decisions)
      '- [${decision.level.label} / ${decision.kind.label}] ${decision.title}: ${decision.detail}',
  ].join('\n');
}

int _healthRank(ProjectHealth health) {
  switch (health) {
    case ProjectHealth.blocked:
      return 0;
    case ProjectHealth.atRisk:
      return 1;
    case ProjectHealth.onTrack:
      return 2;
  }
}

String _pluralDays(int days) => '$days day${days == 1 ? '' : 's'}';

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;

    return iterator.current;
  }

  T? firstWhereOrNull(bool Function(T item) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}

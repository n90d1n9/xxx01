import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../../gantt/services/gantt_schedule_health_service.dart';
import '../models/project_portfolio_item.dart';

enum ProjectReadinessLevel { blocked, constrained, ready, strong }

enum ProjectReadinessFactorLevel { critical, warning, positive }

class ProjectReadinessFactor {
  const ProjectReadinessFactor({
    required this.title,
    required this.detail,
    required this.level,
    required this.icon,
    required this.scoreImpact,
  });

  final String title;
  final String detail;
  final ProjectReadinessFactorLevel level;
  final IconData icon;
  final int scoreImpact;
}

class ProjectReadinessScoreSummary {
  const ProjectReadinessScoreSummary({
    required this.project,
    required this.factors,
    required this.score,
    required this.level,
  });

  final ProjectPortfolioItem project;
  final List<ProjectReadinessFactor> factors;
  final int score;
  final ProjectReadinessLevel level;

  int get criticalCount =>
      factors
          .where(
            (factor) => factor.level == ProjectReadinessFactorLevel.critical,
          )
          .length;
  int get warningCount =>
      factors
          .where(
            (factor) => factor.level == ProjectReadinessFactorLevel.warning,
          )
          .length;
  int get positiveCount =>
      factors
          .where(
            (factor) => factor.level == ProjectReadinessFactorLevel.positive,
          )
          .length;
}

extension ProjectReadinessLevelPresentation on ProjectReadinessLevel {
  String get label {
    switch (this) {
      case ProjectReadinessLevel.blocked:
        return 'Blocked';
      case ProjectReadinessLevel.constrained:
        return 'Constrained';
      case ProjectReadinessLevel.ready:
        return 'Ready';
      case ProjectReadinessLevel.strong:
        return 'Strong';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectReadinessLevel.blocked:
        return Icons.block_outlined;
      case ProjectReadinessLevel.constrained:
        return Icons.warning_amber_rounded;
      case ProjectReadinessLevel.ready:
        return Icons.task_alt_outlined;
      case ProjectReadinessLevel.strong:
        return Icons.verified_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectReadinessLevel.blocked:
        return colorScheme.error;
      case ProjectReadinessLevel.constrained:
        return Colors.orange.shade700;
      case ProjectReadinessLevel.ready:
        return colorScheme.primary;
      case ProjectReadinessLevel.strong:
        return Colors.green.shade700;
    }
  }
}

extension ProjectReadinessFactorLevelPresentation
    on ProjectReadinessFactorLevel {
  String get label {
    switch (this) {
      case ProjectReadinessFactorLevel.critical:
        return 'Critical';
      case ProjectReadinessFactorLevel.warning:
        return 'Watch';
      case ProjectReadinessFactorLevel.positive:
        return 'Stable';
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectReadinessFactorLevel.critical:
        return colorScheme.error;
      case ProjectReadinessFactorLevel.warning:
        return Colors.orange.shade700;
      case ProjectReadinessFactorLevel.positive:
        return Colors.green.shade700;
    }
  }
}

ProjectReadinessScoreSummary buildProjectReadinessScoreSummary({
  required ProjectPortfolioItem project,
  required List<gantt.GanttTask> timelineTasks,
  DateTime? today,
}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final tasks = _flattenTasks(timelineTasks);
  final factors = <ProjectReadinessFactor>[];

  if (project.health == ProjectHealth.blocked) {
    factors.add(
      const ProjectReadinessFactor(
        title: 'Delivery blocker',
        detail:
            'Project health is blocked and needs ownership before recovery.',
        level: ProjectReadinessFactorLevel.critical,
        icon: Icons.block_outlined,
        scoreImpact: -30,
      ),
    );
  } else if (project.health == ProjectHealth.atRisk) {
    factors.add(
      const ProjectReadinessFactor(
        title: 'Delivery risk',
        detail: 'Project health is at risk and needs closer steering.',
        level: ProjectReadinessFactorLevel.warning,
        icon: Icons.warning_amber_rounded,
        scoreImpact: -14,
      ),
    );
  }

  final activeRisks =
      project.risks
          .where((risk) => risk.severity != ProjectHealth.onTrack)
          .toList();
  final blockedRisks =
      activeRisks
          .where((risk) => risk.severity == ProjectHealth.blocked)
          .length;
  final warningRisks =
      activeRisks.where((risk) => risk.severity == ProjectHealth.atRisk).length;
  if (blockedRisks > 0) {
    factors.add(
      ProjectReadinessFactor(
        title: 'Critical risk exposure',
        detail:
            '$blockedRisks blocker risk${blockedRisks == 1 ? '' : 's'} must be resolved.',
        level: ProjectReadinessFactorLevel.critical,
        icon: Icons.priority_high_rounded,
        scoreImpact: -20,
      ),
    );
  }
  if (warningRisks > 0) {
    factors.add(
      ProjectReadinessFactor(
        title: 'Risk mitigation needed',
        detail:
            '$warningRisks warning risk${warningRisks == 1 ? '' : 's'} need mitigation.',
        level: ProjectReadinessFactorLevel.warning,
        icon: Icons.health_and_safety_outlined,
        scoreImpact: -8,
      ),
    );
  }

  final overdueTasks =
      tasks
          .where(
            (task) =>
                ganttScheduleHealthFor(task, today: asOf) ==
                GanttScheduleHealth.overdue,
          )
          .toList();
  if (overdueTasks.isNotEmpty) {
    factors.add(
      ProjectReadinessFactor(
        title: 'Schedule recovery',
        detail:
            '${overdueTasks.length} overdue task${overdueTasks.length == 1 ? '' : 's'}, starting with ${overdueTasks.first.title}.',
        level: ProjectReadinessFactorLevel.critical,
        icon: Icons.event_busy_outlined,
        scoreImpact: -18,
      ),
    );
  }

  final nextMilestone = _nextOpenMilestone(project.milestones);
  if (nextMilestone != null) {
    final days =
        DateUtils.dateOnly(nextMilestone.dueDate).difference(asOf).inDays;
    if (days < 0) {
      factors.add(
        ProjectReadinessFactor(
          title: 'Milestone recovery',
          detail:
              '${nextMilestone.label} is ${_pluralDays(days.abs())} overdue.',
          level: ProjectReadinessFactorLevel.critical,
          icon: Icons.flag_outlined,
          scoreImpact: -12,
        ),
      );
    } else if (days <= 7) {
      factors.add(
        ProjectReadinessFactor(
          title: 'Milestone readiness',
          detail: '${nextMilestone.label} is due in ${_pluralDays(days)}.',
          level: ProjectReadinessFactorLevel.warning,
          icon: Icons.flag_outlined,
          scoreImpact: -6,
        ),
      );
    }
  }

  final budgetGap = project.budgetUsed - project.progress;
  if (budgetGap >= 0.25) {
    factors.add(
      ProjectReadinessFactor(
        title: 'Budget pressure',
        detail:
            '${(project.budgetUsed * 100).round()}% budget used against ${(project.progress * 100).round()}% progress.',
        level: ProjectReadinessFactorLevel.critical,
        icon: Icons.account_balance_wallet_outlined,
        scoreImpact: -16,
      ),
    );
  } else if (budgetGap >= 0.15) {
    factors.add(
      ProjectReadinessFactor(
        title: 'Budget watch',
        detail:
            '${(project.budgetUsed * 100).round()}% budget used against ${(project.progress * 100).round()}% progress.',
        level: ProjectReadinessFactorLevel.warning,
        icon: Icons.account_balance_wallet_outlined,
        scoreImpact: -9,
      ),
    );
  }

  if (project.team.isEmpty) {
    factors.add(
      const ProjectReadinessFactor(
        title: 'Team coverage',
        detail: 'No team members are assigned to this project.',
        level: ProjectReadinessFactorLevel.warning,
        icon: Icons.groups_outlined,
        scoreImpact: -8,
      ),
    );
  } else if (project.health == ProjectHealth.onTrack &&
      overdueTasks.isEmpty &&
      activeRisks.isEmpty &&
      budgetGap < 0.15) {
    factors.add(
      const ProjectReadinessFactor(
        title: 'Delivery cadence',
        detail: 'Team, budget, risks, and schedule are aligned.',
        level: ProjectReadinessFactorLevel.positive,
        icon: Icons.check_circle_outline,
        scoreImpact: 0,
      ),
    );
  }

  final score =
      (100 + factors.fold<int>(0, (sum, factor) => sum + factor.scoreImpact))
          .clamp(0, 100)
          .toInt();

  return ProjectReadinessScoreSummary(
    project: project,
    factors: List.unmodifiable(factors),
    score: score,
    level: _readinessLevel(project: project, score: score),
  );
}

ProjectReadinessLevel _readinessLevel({
  required ProjectPortfolioItem project,
  required int score,
}) {
  if (project.health == ProjectHealth.blocked || score < 55) {
    return ProjectReadinessLevel.blocked;
  }
  if (project.health == ProjectHealth.atRisk || score < 75) {
    return ProjectReadinessLevel.constrained;
  }
  if (score < 90) return ProjectReadinessLevel.ready;
  return ProjectReadinessLevel.strong;
}

List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
    ],
  ];
}

ProjectMilestone? _nextOpenMilestone(List<ProjectMilestone> milestones) {
  final openMilestones =
      milestones.where((milestone) => !milestone.isComplete).toList()
        ..sort((left, right) => left.dueDate.compareTo(right.dueDate));

  return openMilestones.isEmpty ? null : openMilestones.first;
}

String _pluralDays(int days) => '$days day${days == 1 ? '' : 's'}';

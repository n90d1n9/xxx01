import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../../gantt/services/gantt_schedule_health_service.dart';
import '../models/project_portfolio_item.dart';

enum ProjectAttentionLevel { critical, warning, neutral, positive }

class ProjectAttentionInsight {
  const ProjectAttentionInsight({
    required this.title,
    required this.detail,
    required this.level,
    required this.icon,
  });

  final String title;
  final String detail;
  final ProjectAttentionLevel level;
  final IconData icon;
}

extension ProjectAttentionLevelPresentation on ProjectAttentionLevel {
  String get label {
    switch (this) {
      case ProjectAttentionLevel.critical:
        return 'Critical';
      case ProjectAttentionLevel.warning:
        return 'Watch';
      case ProjectAttentionLevel.neutral:
        return 'Next';
      case ProjectAttentionLevel.positive:
        return 'Healthy';
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectAttentionLevel.critical:
        return colorScheme.error;
      case ProjectAttentionLevel.warning:
        return Colors.orange.shade700;
      case ProjectAttentionLevel.neutral:
        return colorScheme.primary;
      case ProjectAttentionLevel.positive:
        return Colors.green.shade700;
    }
  }
}

List<ProjectAttentionInsight> buildProjectAttentionInsights({
  required ProjectPortfolioItem project,
  required List<gantt.GanttTask> timelineTasks,
  DateTime? today,
  int limit = 4,
}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final tasks = _flattenTasks(timelineTasks);
  final insights = <ProjectAttentionInsight>[];

  final blockedRisk = _firstRiskWithSeverity(project, ProjectHealth.blocked);
  if (project.health == ProjectHealth.blocked || blockedRisk != null) {
    insights.add(
      ProjectAttentionInsight(
        title: 'Unblock delivery path',
        detail:
            blockedRisk == null
                ? 'Resolve the blocker before planning a schedule recovery.'
                : '${blockedRisk.title}: ${blockedRisk.detail}',
        level: ProjectAttentionLevel.critical,
        icon: Icons.block_outlined,
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
    insights.add(
      ProjectAttentionInsight(
        title: 'Recover overdue timeline',
        detail:
            '${overdueTasks.length} task${overdueTasks.length == 1 ? '' : 's'} need recovery, starting with ${overdueTasks.first.title}.',
        level: ProjectAttentionLevel.critical,
        icon: Icons.event_busy_outlined,
      ),
    );
  } else {
    final dueSoonTasks =
        tasks
            .where(
              (task) =>
                  ganttScheduleHealthFor(task, today: asOf) ==
                  GanttScheduleHealth.dueSoon,
            )
            .toList();
    final activeTasks =
        tasks
            .where(
              (task) =>
                  ganttScheduleHealthFor(task, today: asOf) ==
                  GanttScheduleHealth.active,
            )
            .toList();

    if (dueSoonTasks.isNotEmpty) {
      insights.add(
        ProjectAttentionInsight(
          title: 'Prepare upcoming work',
          detail:
              '${dueSoonTasks.first.title} starts soon; confirm owners, dependencies, and readiness.',
          level: ProjectAttentionLevel.warning,
          icon: Icons.upcoming_outlined,
        ),
      );
    } else if (activeTasks.isNotEmpty) {
      insights.add(
        ProjectAttentionInsight(
          title: 'Protect active work',
          detail:
              '${activeTasks.length} active task${activeTasks.length == 1 ? '' : 's'} should stay staffed through the current window.',
          level: ProjectAttentionLevel.neutral,
          icon: Icons.play_circle_outline_rounded,
        ),
      );
    }
  }

  final atRiskRisk = _firstRiskWithSeverity(project, ProjectHealth.atRisk);
  if (atRiskRisk != null && blockedRisk == null) {
    insights.add(
      ProjectAttentionInsight(
        title: 'Reduce delivery risk',
        detail: '${atRiskRisk.title}: ${atRiskRisk.detail}',
        level: ProjectAttentionLevel.warning,
        icon: Icons.warning_amber_rounded,
      ),
    );
  }

  final nextMilestone = _nextOpenMilestone(project.milestones);
  if (nextMilestone != null) {
    final days =
        DateUtils.dateOnly(nextMilestone.dueDate).difference(asOf).inDays;
    insights.add(
      ProjectAttentionInsight(
        title:
            days < 0
                ? 'Recover overdue milestone'
                : days == 0
                ? 'Milestone due today'
                : 'Next milestone',
        detail: '${nextMilestone.label} ${_relativeDateLabel(days, asOf)}.',
        level:
            days < 0
                ? ProjectAttentionLevel.critical
                : days <= 7
                ? ProjectAttentionLevel.warning
                : ProjectAttentionLevel.neutral,
        icon: Icons.flag_outlined,
      ),
    );
  }

  final budgetGap = project.budgetUsed - project.progress;
  if (budgetGap >= 0.15) {
    insights.add(
      ProjectAttentionInsight(
        title: 'Rebalance spend',
        detail:
            'Budget usage is ${(project.budgetUsed * 100).round()}% against ${(project.progress * 100).round()}% progress.',
        level: ProjectAttentionLevel.warning,
        icon: Icons.account_balance_wallet_outlined,
      ),
    );
  } else if (project.health == ProjectHealth.onTrack &&
      insights.length < limit) {
    insights.add(
      ProjectAttentionInsight(
        title: 'Delivery rhythm is steady',
        detail:
            'Progress and budget are aligned enough to keep the current cadence.',
        level: ProjectAttentionLevel.positive,
        icon: Icons.check_circle_outline,
      ),
    );
  }

  if (insights.isEmpty) {
    insights.add(
      const ProjectAttentionInsight(
        title: 'Delivery looks steady',
        detail: 'No immediate attention signal is active for this project.',
        level: ProjectAttentionLevel.positive,
        icon: Icons.check_circle_outline,
      ),
    );
  }

  return List.unmodifiable(insights.take(limit));
}

List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
    ],
  ];
}

ProjectDeliveryRisk? _firstRiskWithSeverity(
  ProjectPortfolioItem project,
  ProjectHealth severity,
) {
  for (final risk in project.risks) {
    if (risk.severity == severity) return risk;
  }
  return null;
}

ProjectMilestone? _nextOpenMilestone(List<ProjectMilestone> milestones) {
  final openMilestones =
      milestones.where((milestone) => !milestone.isComplete).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  return openMilestones.isEmpty ? null : openMilestones.first;
}

String _relativeDateLabel(int days, DateTime asOf) {
  if (days < 0) return '${_pluralDays(days.abs())} overdue';
  if (days == 0) return 'is due today';
  if (days <= 7) return 'is due in ${_pluralDays(days)}';

  final date = DateUtils.dateOnly(asOf).add(Duration(days: days));
  return 'is due ${DateFormat('MMM d').format(date)}';
}

String _pluralDays(int days) => '$days day${days == 1 ? '' : 's'}';

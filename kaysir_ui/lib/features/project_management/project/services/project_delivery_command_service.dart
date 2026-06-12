import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../../gantt/services/gantt_dependency_service.dart';
import '../../gantt/services/gantt_schedule_health_service.dart';
import '../models/project_portfolio_item.dart';

enum ProjectDeliveryCommandLevel { critical, warning, watch }

enum ProjectDeliveryCommandKind {
  projectBlocked,
  risk,
  milestone,
  schedule,
  dependency,
  budget,
}

class ProjectDeliveryCommand {
  const ProjectDeliveryCommand({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.title,
    required this.detail,
    required this.level,
    required this.kind,
    required this.icon,
    this.taskId,
  });

  final String id;
  final String projectId;
  final String projectName;
  final String title;
  final String detail;
  final ProjectDeliveryCommandLevel level;
  final ProjectDeliveryCommandKind kind;
  final IconData icon;
  final String? taskId;

  bool get hasTaskFocus => taskId != null && taskId!.trim().isNotEmpty;
}

class ProjectDeliveryCommandSummary {
  const ProjectDeliveryCommandSummary({required this.commands});

  final List<ProjectDeliveryCommand> commands;

  int get totalCount => commands.length;
  int get criticalCount =>
      commands
          .where(
            (command) => command.level == ProjectDeliveryCommandLevel.critical,
          )
          .length;
  int get warningCount =>
      commands
          .where(
            (command) => command.level == ProjectDeliveryCommandLevel.warning,
          )
          .length;
  int get dependencyCount =>
      commands
          .where(
            (command) => command.kind == ProjectDeliveryCommandKind.dependency,
          )
          .length;
  int get projectCount =>
      commands.map((command) => command.projectId).toSet().length;
}

class ProjectDeliveryCommandFilter {
  const ProjectDeliveryCommandFilter({this.level, this.kind});

  static const empty = ProjectDeliveryCommandFilter();

  final ProjectDeliveryCommandLevel? level;
  final ProjectDeliveryCommandKind? kind;

  bool get hasActiveFilters => level != null || kind != null;

  ProjectDeliveryCommandFilter withLevel(ProjectDeliveryCommandLevel? value) {
    return ProjectDeliveryCommandFilter(level: value, kind: kind);
  }

  ProjectDeliveryCommandFilter withKind(ProjectDeliveryCommandKind? value) {
    return ProjectDeliveryCommandFilter(level: level, kind: value);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectDeliveryCommandFilter &&
        other.level == level &&
        other.kind == kind;
  }

  @override
  int get hashCode => Object.hash(level, kind);
}

extension ProjectDeliveryCommandLevelPresentation
    on ProjectDeliveryCommandLevel {
  String get label {
    switch (this) {
      case ProjectDeliveryCommandLevel.critical:
        return 'Critical';
      case ProjectDeliveryCommandLevel.warning:
        return 'Warning';
      case ProjectDeliveryCommandLevel.watch:
        return 'Watch';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectDeliveryCommandLevel.critical:
        return Icons.priority_high_rounded;
      case ProjectDeliveryCommandLevel.warning:
        return Icons.warning_amber_rounded;
      case ProjectDeliveryCommandLevel.watch:
        return Icons.visibility_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectDeliveryCommandLevel.critical:
        return colorScheme.error;
      case ProjectDeliveryCommandLevel.warning:
        return Colors.orange.shade700;
      case ProjectDeliveryCommandLevel.watch:
        return colorScheme.primary;
    }
  }
}

extension ProjectDeliveryCommandKindPresentation on ProjectDeliveryCommandKind {
  String get label {
    switch (this) {
      case ProjectDeliveryCommandKind.projectBlocked:
        return 'Blockers';
      case ProjectDeliveryCommandKind.risk:
        return 'Risks';
      case ProjectDeliveryCommandKind.milestone:
        return 'Milestones';
      case ProjectDeliveryCommandKind.schedule:
        return 'Schedule';
      case ProjectDeliveryCommandKind.dependency:
        return 'Dependencies';
      case ProjectDeliveryCommandKind.budget:
        return 'Budget';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectDeliveryCommandKind.projectBlocked:
        return Icons.block_outlined;
      case ProjectDeliveryCommandKind.risk:
        return Icons.health_and_safety_outlined;
      case ProjectDeliveryCommandKind.milestone:
        return Icons.flag_outlined;
      case ProjectDeliveryCommandKind.schedule:
        return Icons.event_busy_outlined;
      case ProjectDeliveryCommandKind.dependency:
        return Icons.link_rounded;
      case ProjectDeliveryCommandKind.budget:
        return Icons.account_balance_wallet_outlined;
    }
  }
}

ProjectDeliveryCommandSummary buildProjectDeliveryCommandSummary({
  required List<ProjectPortfolioItem> projects,
  required List<gantt.GanttTask> tasks,
  DateTime? today,
}) {
  final commands = buildProjectDeliveryCommands(
    projects: projects,
    tasks: tasks,
    today: today,
  );

  return ProjectDeliveryCommandSummary(commands: commands);
}

List<ProjectDeliveryCommand> buildProjectDeliveryCommands({
  required List<ProjectPortfolioItem> projects,
  required List<gantt.GanttTask> tasks,
  DateTime? today,
}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final flatTasks = _flattenTasks(tasks);
  final commands = <ProjectDeliveryCommand>[];

  for (final project in projects) {
    final projectTasks = _tasksForProject(project, flatTasks);

    if (project.health == ProjectHealth.blocked) {
      commands.add(
        ProjectDeliveryCommand(
          id: '${project.id}-project-blocked',
          projectId: project.id,
          projectName: project.name,
          title: 'Project is blocked',
          detail:
              '${project.name} needs unblock ownership before delivery can recover.',
          level: ProjectDeliveryCommandLevel.critical,
          kind: ProjectDeliveryCommandKind.projectBlocked,
          icon: Icons.block_outlined,
        ),
      );
    }

    commands.addAll(_riskCommands(project));
    commands.addAll(_milestoneCommands(project, today: asOf));
    commands.addAll(
      _taskCommands(project, projectTasks, flatTasks, today: asOf),
    );
    commands.addAll(_budgetCommands(project));
  }

  commands.sort(_compareCommands);
  return List.unmodifiable(commands);
}

List<ProjectDeliveryCommand> filterProjectDeliveryCommands({
  required List<ProjectDeliveryCommand> commands,
  ProjectDeliveryCommandLevel? level,
  ProjectDeliveryCommandKind? kind,
  ProjectDeliveryCommandFilter filter = ProjectDeliveryCommandFilter.empty,
}) {
  final effectiveLevel = level ?? filter.level;
  final effectiveKind = kind ?? filter.kind;

  return List.unmodifiable(
    commands.where((command) {
      final matchesLevel =
          effectiveLevel == null || command.level == effectiveLevel;
      final matchesKind =
          effectiveKind == null || command.kind == effectiveKind;
      return matchesLevel && matchesKind;
    }),
  );
}

List<ProjectDeliveryCommand> _riskCommands(ProjectPortfolioItem project) {
  return [
    for (final risk in project.risks)
      if (risk.severity != ProjectHealth.onTrack)
        ProjectDeliveryCommand(
          id: '${project.id}-risk-${_slug(risk.title)}',
          projectId: project.id,
          projectName: project.name,
          title: risk.title,
          detail: risk.detail,
          level:
              risk.severity == ProjectHealth.blocked
                  ? ProjectDeliveryCommandLevel.critical
                  : ProjectDeliveryCommandLevel.warning,
          kind: ProjectDeliveryCommandKind.risk,
          icon: risk.severity.icon,
        ),
  ];
}

List<ProjectDeliveryCommand> _milestoneCommands(
  ProjectPortfolioItem project, {
  required DateTime today,
}) {
  final commands = <ProjectDeliveryCommand>[];

  for (final milestone in project.milestones) {
    if (milestone.isComplete) continue;

    final dueDate = DateUtils.dateOnly(milestone.dueDate);
    final dueInDays = dueDate.difference(today).inDays;
    if (dueInDays > 30) continue;

    commands.add(
      ProjectDeliveryCommand(
        id: '${project.id}-milestone-${_slug(milestone.label)}',
        projectId: project.id,
        projectName: project.name,
        title: '${milestone.label} milestone',
        detail:
            dueInDays < 0
                ? '${milestone.label} is ${dueInDays.abs()} day${dueInDays.abs() == 1 ? '' : 's'} overdue.'
                : dueInDays == 0
                ? '${milestone.label} is due today.'
                : '${milestone.label} is due in $dueInDays day${dueInDays == 1 ? '' : 's'}.',
        level:
            dueInDays < 0
                ? ProjectDeliveryCommandLevel.critical
                : ProjectDeliveryCommandLevel.watch,
        kind: ProjectDeliveryCommandKind.milestone,
        icon: Icons.flag_outlined,
      ),
    );
  }

  return commands;
}

List<ProjectDeliveryCommand> _taskCommands(
  ProjectPortfolioItem project,
  List<gantt.GanttTask> projectTasks,
  List<gantt.GanttTask> dependencyTasks, {
  required DateTime today,
}) {
  final commands = <ProjectDeliveryCommand>[];

  for (final task in projectTasks) {
    final scheduleHealth = ganttScheduleHealthFor(task, today: today);
    if (scheduleHealth == GanttScheduleHealth.overdue ||
        scheduleHealth == GanttScheduleHealth.dueSoon) {
      commands.add(
        ProjectDeliveryCommand(
          id: '${project.id}-task-${task.id}-schedule',
          projectId: project.id,
          projectName: project.name,
          taskId: task.id,
          title: '${task.title} schedule',
          detail: ganttScheduleHealthDetail(task, today: today),
          level:
              scheduleHealth == GanttScheduleHealth.overdue
                  ? ProjectDeliveryCommandLevel.critical
                  : ProjectDeliveryCommandLevel.watch,
          kind: ProjectDeliveryCommandKind.schedule,
          icon: scheduleHealth.icon,
        ),
      );
    }

    final dependencyInsight = ganttDependencyInsightFor(
      task,
      dependencyTasks,
      today: today,
    );
    if (dependencyInsight.health == GanttDependencyHealth.blocked ||
        dependencyInsight.health == GanttDependencyHealth.missing) {
      commands.add(
        ProjectDeliveryCommand(
          id: '${project.id}-task-${task.id}-dependency',
          projectId: project.id,
          projectName: project.name,
          taskId: task.id,
          title: '${task.title} dependency',
          detail: dependencyInsight.detail,
          level: ProjectDeliveryCommandLevel.critical,
          kind: ProjectDeliveryCommandKind.dependency,
          icon: dependencyInsight.health.icon,
        ),
      );
    } else if (dependencyInsight.health == GanttDependencyHealth.waiting) {
      commands.add(
        ProjectDeliveryCommand(
          id: '${project.id}-task-${task.id}-dependency',
          projectId: project.id,
          projectName: project.name,
          taskId: task.id,
          title: '${task.title} dependency',
          detail: dependencyInsight.detail,
          level: ProjectDeliveryCommandLevel.warning,
          kind: ProjectDeliveryCommandKind.dependency,
          icon: dependencyInsight.health.icon,
        ),
      );
    }
  }

  return commands;
}

List<ProjectDeliveryCommand> _budgetCommands(ProjectPortfolioItem project) {
  final budgetGap = project.budgetUsed - project.progress;
  if (budgetGap < 0.15) return const [];

  return [
    ProjectDeliveryCommand(
      id: '${project.id}-budget-pressure',
      projectId: project.id,
      projectName: project.name,
      title: 'Budget pressure',
      detail:
          '${(project.budgetUsed * 100).round()}% budget used against ${(project.progress * 100).round()}% progress.',
      level:
          budgetGap >= 0.25
              ? ProjectDeliveryCommandLevel.critical
              : ProjectDeliveryCommandLevel.warning,
      kind: ProjectDeliveryCommandKind.budget,
      icon: Icons.account_balance_wallet_outlined,
    ),
  ];
}

List<gantt.GanttTask> _tasksForProject(
  ProjectPortfolioItem project,
  List<gantt.GanttTask> tasks,
) {
  final taskIds = project.timelineTaskIds.toSet();

  return tasks.where((task) {
    return task.projectId == project.id || taskIds.contains(task.id);
  }).toList();
}

int _compareCommands(
  ProjectDeliveryCommand left,
  ProjectDeliveryCommand right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;

  final kindCompare = _kindRank(left.kind).compareTo(_kindRank(right.kind));
  if (kindCompare != 0) return kindCompare;

  return left.projectName.compareTo(right.projectName);
}

int _levelRank(ProjectDeliveryCommandLevel level) {
  switch (level) {
    case ProjectDeliveryCommandLevel.critical:
      return 0;
    case ProjectDeliveryCommandLevel.warning:
      return 1;
    case ProjectDeliveryCommandLevel.watch:
      return 2;
  }
}

int _kindRank(ProjectDeliveryCommandKind kind) {
  switch (kind) {
    case ProjectDeliveryCommandKind.projectBlocked:
      return 0;
    case ProjectDeliveryCommandKind.dependency:
      return 1;
    case ProjectDeliveryCommandKind.risk:
      return 2;
    case ProjectDeliveryCommandKind.budget:
      return 3;
    case ProjectDeliveryCommandKind.schedule:
      return 4;
    case ProjectDeliveryCommandKind.milestone:
      return 5;
  }
}

String _slug(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
    ],
  ];
}

import 'package:flutter/material.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../../gantt/services/gantt_dependency_service.dart';
import '../../gantt/services/gantt_schedule_health_service.dart';

enum ProjectTimelineHealthSignal {
  empty,
  blocked,
  overdue,
  active,
  planned,
  complete,
}

enum ProjectTimelineHealthIssueKind {
  dependencyBlock,
  overdue,
  dueSoon,
  active,
}

class ProjectTimelineHealthIssue {
  const ProjectTimelineHealthIssue({
    required this.kind,
    required this.task,
    required this.title,
    required this.detail,
  });

  final ProjectTimelineHealthIssueKind kind;
  final gantt.GanttTask task;
  final String title;
  final String detail;
}

class ProjectTimelineHealthRollup {
  const ProjectTimelineHealthRollup({
    required this.totalTasks,
    required this.completeCount,
    required this.overdueCount,
    required this.activeCount,
    required this.dueSoonCount,
    required this.dependencyBlockCount,
    required this.averageProgress,
    required this.signal,
    this.issues = const [],
  });

  final int totalTasks;
  final int completeCount;
  final int overdueCount;
  final int activeCount;
  final int dueSoonCount;
  final int dependencyBlockCount;
  final double averageProgress;
  final ProjectTimelineHealthSignal signal;
  final List<ProjectTimelineHealthIssue> issues;

  int get scheduleAlertCount => overdueCount + dueSoonCount;
  bool get hasAttention => overdueCount > 0 || dependencyBlockCount > 0;
}

extension ProjectTimelineHealthIssueKindPresentation
    on ProjectTimelineHealthIssueKind {
  String get label {
    switch (this) {
      case ProjectTimelineHealthIssueKind.dependencyBlock:
        return 'Blocked';
      case ProjectTimelineHealthIssueKind.overdue:
        return 'Overdue';
      case ProjectTimelineHealthIssueKind.dueSoon:
        return 'Due Soon';
      case ProjectTimelineHealthIssueKind.active:
        return 'Active';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectTimelineHealthIssueKind.dependencyBlock:
        return Icons.block_outlined;
      case ProjectTimelineHealthIssueKind.overdue:
        return Icons.event_busy_outlined;
      case ProjectTimelineHealthIssueKind.dueSoon:
        return Icons.upcoming_outlined;
      case ProjectTimelineHealthIssueKind.active:
        return Icons.play_circle_outline_rounded;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectTimelineHealthIssueKind.dependencyBlock:
      case ProjectTimelineHealthIssueKind.overdue:
        return colorScheme.error;
      case ProjectTimelineHealthIssueKind.dueSoon:
        return Colors.orange.shade700;
      case ProjectTimelineHealthIssueKind.active:
        return colorScheme.primary;
    }
  }
}

extension ProjectTimelineHealthSignalPresentation
    on ProjectTimelineHealthSignal {
  String get label {
    switch (this) {
      case ProjectTimelineHealthSignal.empty:
        return 'No Tasks';
      case ProjectTimelineHealthSignal.blocked:
        return 'Blocked';
      case ProjectTimelineHealthSignal.overdue:
        return 'Overdue';
      case ProjectTimelineHealthSignal.active:
        return 'Active';
      case ProjectTimelineHealthSignal.planned:
        return 'Planned';
      case ProjectTimelineHealthSignal.complete:
        return 'Complete';
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectTimelineHealthSignal.empty:
        return Icons.timeline_outlined;
      case ProjectTimelineHealthSignal.blocked:
        return Icons.block_outlined;
      case ProjectTimelineHealthSignal.overdue:
        return Icons.event_busy_outlined;
      case ProjectTimelineHealthSignal.active:
        return Icons.play_circle_outline_rounded;
      case ProjectTimelineHealthSignal.planned:
        return Icons.event_available_outlined;
      case ProjectTimelineHealthSignal.complete:
        return Icons.check_circle_outline;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ProjectTimelineHealthSignal.empty:
        return colorScheme.onSurfaceVariant;
      case ProjectTimelineHealthSignal.blocked:
      case ProjectTimelineHealthSignal.overdue:
        return colorScheme.error;
      case ProjectTimelineHealthSignal.active:
        return colorScheme.primary;
      case ProjectTimelineHealthSignal.planned:
        return Colors.indigo.shade600;
      case ProjectTimelineHealthSignal.complete:
        return Colors.green.shade700;
    }
  }
}

ProjectTimelineHealthRollup buildProjectTimelineHealthRollup({
  required List<gantt.GanttTask> tasks,
  List<gantt.GanttTask>? dependencyTasks,
  DateTime? today,
}) {
  final flatTasks = _flattenTasks(tasks);
  final dependencySource = dependencyTasks ?? tasks;

  if (flatTasks.isEmpty) {
    return const ProjectTimelineHealthRollup(
      totalTasks: 0,
      completeCount: 0,
      overdueCount: 0,
      activeCount: 0,
      dueSoonCount: 0,
      dependencyBlockCount: 0,
      averageProgress: 0,
      signal: ProjectTimelineHealthSignal.empty,
    );
  }

  var completeCount = 0;
  var overdueCount = 0;
  var activeCount = 0;
  var dueSoonCount = 0;
  var dependencyBlockCount = 0;
  var progressTotal = 0.0;
  final issues = <ProjectTimelineHealthIssue>[];

  for (final task in flatTasks) {
    progressTotal += task.progress;
    final scheduleHealth = ganttScheduleHealthFor(task, today: today);

    switch (scheduleHealth) {
      case GanttScheduleHealth.complete:
        completeCount++;
        break;
      case GanttScheduleHealth.overdue:
        overdueCount++;
        break;
      case GanttScheduleHealth.active:
        activeCount++;
        break;
      case GanttScheduleHealth.dueSoon:
        dueSoonCount++;
        break;
      case GanttScheduleHealth.scheduled:
        break;
    }

    final dependencyInsight = ganttDependencyInsightFor(
      task,
      dependencySource,
      today: today,
    );
    if (dependencyInsight.isAlert) {
      dependencyBlockCount++;
      issues.add(
        ProjectTimelineHealthIssue(
          kind: ProjectTimelineHealthIssueKind.dependencyBlock,
          task: task,
          title: task.title,
          detail: dependencyInsight.detail,
        ),
      );
      continue;
    }

    final issue = _scheduleIssueFor(task, scheduleHealth, today: today);
    if (issue != null) issues.add(issue);
  }

  final signal = _timelineSignal(
    totalTasks: flatTasks.length,
    completeCount: completeCount,
    overdueCount: overdueCount,
    activeCount: activeCount,
    dependencyBlockCount: dependencyBlockCount,
  );
  issues.sort(_compareTimelineHealthIssues);

  return ProjectTimelineHealthRollup(
    totalTasks: flatTasks.length,
    completeCount: completeCount,
    overdueCount: overdueCount,
    activeCount: activeCount,
    dueSoonCount: dueSoonCount,
    dependencyBlockCount: dependencyBlockCount,
    averageProgress: progressTotal / flatTasks.length,
    signal: signal,
    issues: List.unmodifiable(issues),
  );
}

ProjectTimelineHealthIssue? _scheduleIssueFor(
  gantt.GanttTask task,
  GanttScheduleHealth scheduleHealth, {
  DateTime? today,
}) {
  switch (scheduleHealth) {
    case GanttScheduleHealth.overdue:
      return ProjectTimelineHealthIssue(
        kind: ProjectTimelineHealthIssueKind.overdue,
        task: task,
        title: task.title,
        detail: '${ganttScheduleHealthDetail(task, today: today)}.',
      );
    case GanttScheduleHealth.dueSoon:
      return ProjectTimelineHealthIssue(
        kind: ProjectTimelineHealthIssueKind.dueSoon,
        task: task,
        title: task.title,
        detail: '${ganttScheduleHealthDetail(task, today: today)}.',
      );
    case GanttScheduleHealth.active:
      return ProjectTimelineHealthIssue(
        kind: ProjectTimelineHealthIssueKind.active,
        task: task,
        title: task.title,
        detail: '${ganttScheduleHealthDetail(task, today: today)}.',
      );
    case GanttScheduleHealth.complete:
    case GanttScheduleHealth.scheduled:
      return null;
  }
}

int _compareTimelineHealthIssues(
  ProjectTimelineHealthIssue left,
  ProjectTimelineHealthIssue right,
) {
  final rankComparison = _issueKindRank(
    left.kind,
  ).compareTo(_issueKindRank(right.kind));
  if (rankComparison != 0) return rankComparison;

  final dateComparison = _issueSortDate(left).compareTo(_issueSortDate(right));
  if (dateComparison != 0) return dateComparison;

  return left.title.compareTo(right.title);
}

int _issueKindRank(ProjectTimelineHealthIssueKind kind) {
  switch (kind) {
    case ProjectTimelineHealthIssueKind.dependencyBlock:
      return 0;
    case ProjectTimelineHealthIssueKind.overdue:
      return 1;
    case ProjectTimelineHealthIssueKind.dueSoon:
      return 2;
    case ProjectTimelineHealthIssueKind.active:
      return 3;
  }
}

DateTime _issueSortDate(ProjectTimelineHealthIssue issue) {
  switch (issue.kind) {
    case ProjectTimelineHealthIssueKind.dependencyBlock:
    case ProjectTimelineHealthIssueKind.dueSoon:
    case ProjectTimelineHealthIssueKind.active:
      return issue.task.startDate;
    case ProjectTimelineHealthIssueKind.overdue:
      return issue.task.endDate;
  }
}

ProjectTimelineHealthSignal _timelineSignal({
  required int totalTasks,
  required int completeCount,
  required int overdueCount,
  required int activeCount,
  required int dependencyBlockCount,
}) {
  if (dependencyBlockCount > 0) return ProjectTimelineHealthSignal.blocked;
  if (overdueCount > 0) return ProjectTimelineHealthSignal.overdue;
  if (completeCount == totalTasks) return ProjectTimelineHealthSignal.complete;
  if (activeCount > 0) return ProjectTimelineHealthSignal.active;
  return ProjectTimelineHealthSignal.planned;
}

List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
    ],
  ];
}

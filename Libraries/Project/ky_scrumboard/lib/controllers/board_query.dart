import '../models/scrum_assignee_load.dart';
import '../models/scrum_board_config.dart';
import '../models/scrum_board_filter.dart';
import '../models/scrum_board_insight.dart';
import '../models/scrum_board_summary.dart';
import '../models/scrum_task.dart';
import '../models/scrum_task_priority.dart';
import '../models/scrum_task_status.dart';
import '../models/scrum_workflow_policy.dart';
import 'task_ordering.dart';

/// Read-only board task query for metrics, filtering, and flow insights.
class BoardTaskQuery {
  const BoardTaskQuery({required List<ScrumTask> tasks, required this.config})
    : _tasks = tasks;

  final List<ScrumTask> _tasks;
  final ScrumBoardConfig config;

  ScrumWorkflowPolicy get _policy => config.policy;

  /// Summarizes task volume, completion, and story-point progress.
  ScrumBoardSummary get summary {
    final tasksByStatus = {
      for (final status in ScrumTaskStatus.values) status: countFor(status),
    };
    final completedTasks = countFor(ScrumTaskStatus.done);
    final totalStoryPoints = _tasks.fold<int>(
      0,
      (total, task) => total + task.storyPoints,
    );
    final completedStoryPoints = _tasks
        .where((task) => task.status == ScrumTaskStatus.done)
        .fold<int>(0, (total, task) => total + task.storyPoints);
    final activeStoryPoints = _tasks
        .where((task) => task.status != ScrumTaskStatus.done)
        .fold<int>(0, (total, task) => total + task.storyPoints);

    return ScrumBoardSummary(
      totalTasks: _tasks.length,
      completedTasks: completedTasks,
      activeTasks: _tasks.length - completedTasks,
      totalStoryPoints: totalStoryPoints,
      completedStoryPoints: completedStoryPoints,
      activeStoryPoints: activeStoryPoints,
      tasksByStatus: tasksByStatus,
    );
  }

  /// Returns tasks in a lane after applying optional query and facets.
  List<ScrumTask> tasksFor(
    ScrumTaskStatus status, {
    String query = '',
    ScrumBoardFilter filter = const ScrumBoardFilter(),
  }) {
    final effectiveFilter = query.trim().isEmpty
        ? filter
        : filter.copyWith(query: query);
    final filtered = _tasks.where((task) {
      if (task.status != status) return false;
      return effectiveFilter.matches(task, includeStatus: false);
    }).toList();

    filtered.sort((a, b) => compareTasks(a, b, effectiveFilter.sort));
    return filtered;
  }

  /// Returns all tasks matching the filter.
  List<ScrumTask> filteredTasks(ScrumBoardFilter filter) {
    final filtered = _tasks.where(filter.matches).toList();
    filtered.sort((a, b) => compareTasks(a, b, filter.sort));
    return filtered;
  }

  /// Returns unique assignee names in case-insensitive alphabetical order.
  List<String> assignees() {
    final assignees = <String>{};
    for (final task in _tasks) {
      final assignee = task.assignee.trim();
      if (assignee.isNotEmpty) assignees.add(assignee);
    }

    return assignees.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  /// Counts tasks in a lane.
  int countFor(ScrumTaskStatus status) {
    return _tasks.where((task) => task.status == status).length;
  }

  /// Sums story points in a lane.
  int storyPointsFor(ScrumTaskStatus status) {
    return _tasks
        .where((task) => task.status == status)
        .fold<int>(0, (total, task) => total + task.storyPoints);
  }

  /// Builds prioritized workflow and delivery insights for the board.
  List<ScrumBoardInsight> insights({DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final insights = <ScrumBoardInsight>[];
    final summary = this.summary;
    final sprint = config.sprint;
    final policy = _policy;

    if (sprint != null) {
      final capacity = sprint.capacityStoryPoints;
      if (capacity != null &&
          capacity > 0 &&
          summary.totalStoryPoints > capacity) {
        insights.add(
          ScrumBoardInsight(
            key: 'sprint-capacity',
            title: 'Sprint is over capacity',
            description:
                '${summary.totalStoryPoints} story points are committed against $capacity capacity.',
            severity: ScrumBoardInsightSeverity.warning,
          ),
        );
      }

      final velocityTarget = sprint.velocityTargetStoryPoints;
      if (velocityTarget != null &&
          velocityTarget > 0 &&
          summary.completedStoryPoints >= velocityTarget) {
        insights.add(
          ScrumBoardInsight(
            key: 'velocity-target-met',
            title: 'Velocity target reached',
            description:
                '${summary.completedStoryPoints} story points are done against a $velocityTarget point target.',
            severity: ScrumBoardInsightSeverity.positive,
          ),
        );
      }

      if (sprint.isPastAt(currentTime) && summary.activeStoryPoints > 0) {
        insights.add(
          ScrumBoardInsight(
            key: 'sprint-overrun',
            title: 'Sprint window has ended',
            description:
                '${summary.activeStoryPoints} story points remain active after ${_formatDate(sprint.endAt)}.',
            severity: ScrumBoardInsightSeverity.critical,
          ),
        );
      } else if (sprint.isActiveAt(currentTime) &&
          sprint.daysRemainingAt(currentTime) <= policy.dueSoonDays &&
          summary.activeStoryPoints > 0) {
        insights.add(
          ScrumBoardInsight(
            key: 'sprint-ending-soon',
            title: 'Sprint is ending soon',
            description:
                '${summary.activeStoryPoints} story points remain with ${sprint.daysRemainingAt(currentTime)} days left.',
            severity: ScrumBoardInsightSeverity.warning,
          ),
        );
      }
    }

    for (final status in ScrumTaskStatus.values) {
      final count = countFor(status);
      final limit = policy.limitFor(status);
      if (limit == null || count <= limit) continue;

      insights.add(
        ScrumBoardInsight(
          key: 'wip-${status.name}',
          title: '${config.labelFor(status)} WIP is high',
          description: '$count tasks are active against a limit of $limit.',
          severity: ScrumBoardInsightSeverity.warning,
          relatedStatus: status,
        ),
      );
    }

    final overdueTasks = _tasks
        .where((task) => task.isOverdueAt(currentTime))
        .toList(growable: false);
    if (overdueTasks.isNotEmpty) {
      insights.add(
        ScrumBoardInsight(
          key: 'overdue',
          title: 'Overdue work needs attention',
          description:
              '${overdueTasks.length} active tasks are past their due date.',
          severity: ScrumBoardInsightSeverity.critical,
        ),
      );
    }

    final dueSoonTasks = _tasks
        .where((task) => task.isDueSoonAt(currentTime, policy.dueSoonDays))
        .toList(growable: false);
    if (dueSoonTasks.isNotEmpty) {
      insights.add(
        ScrumBoardInsight(
          key: 'due-soon',
          title: 'Upcoming delivery pressure',
          description:
              '${dueSoonTasks.length} active tasks are due in ${policy.dueSoonDays} days.',
          severity: ScrumBoardInsightSeverity.info,
        ),
      );
    }

    final criticalOpenTasks = _tasks.where(
      (task) => !task.isDone && task.priority == ScrumTaskPriority.critical,
    );
    if (criticalOpenTasks.isNotEmpty) {
      insights.add(
        ScrumBoardInsight(
          key: 'critical-open',
          title: 'Critical work is still open',
          description:
              '${criticalOpenTasks.length} critical tasks remain outside Done.',
          severity: ScrumBoardInsightSeverity.warning,
        ),
      );
    }

    final agedReviewTasks = _tasks.where((task) {
      if (task.status != ScrumTaskStatus.review) return false;
      return currentTime.difference(task.createdAt).inDays >=
          policy.reviewAgeWarningDays;
    });
    if (agedReviewTasks.isNotEmpty) {
      insights.add(
        ScrumBoardInsight(
          key: 'aged-review',
          title: 'Review lane is aging',
          description:
              '${agedReviewTasks.length} review tasks have waited ${policy.reviewAgeWarningDays}+ days.',
          severity: ScrumBoardInsightSeverity.warning,
          relatedStatus: ScrumTaskStatus.review,
        ),
      );
    }

    if (insights.isEmpty) {
      insights.add(
        const ScrumBoardInsight(
          key: 'balanced-flow',
          title: 'Flow is balanced',
          description: 'No WIP, due date, or priority pressure detected.',
          severity: ScrumBoardInsightSeverity.positive,
        ),
      );
    }

    insights.sort(
      (a, b) => _severityRank(b.severity) - _severityRank(a.severity),
    );
    return insights;
  }

  /// Aggregates active workload by assignee.
  List<ScrumAssigneeLoad> assigneeLoads() {
    final loadsByAssignee = <String, _MutableAssigneeLoad>{};

    for (final task in _tasks.where((task) => !task.isDone)) {
      final key = task.assignee.trim().isEmpty ? 'Unassigned' : task.assignee;
      final load = loadsByAssignee.putIfAbsent(
        key,
        () => _MutableAssigneeLoad(assignee: key),
      );
      load
        ..activeTasks += 1
        ..activeStoryPoints += task.storyPoints;
      if (task.priority == ScrumTaskPriority.critical) {
        load.criticalTasks += 1;
      }
    }

    final loads = loadsByAssignee.values
        .map(
          (load) => ScrumAssigneeLoad(
            assignee: load.assignee,
            activeTasks: load.activeTasks,
            activeStoryPoints: load.activeStoryPoints,
            criticalTasks: load.criticalTasks,
          ),
        )
        .toList();

    loads.sort((a, b) => b.activeStoryPoints.compareTo(a.activeStoryPoints));
    return loads;
  }
}

String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

int _severityRank(ScrumBoardInsightSeverity severity) {
  switch (severity) {
    case ScrumBoardInsightSeverity.positive:
      return 0;
    case ScrumBoardInsightSeverity.info:
      return 1;
    case ScrumBoardInsightSeverity.warning:
      return 2;
    case ScrumBoardInsightSeverity.critical:
      return 3;
  }
}

/// Mutable accumulator for workload aggregation.
class _MutableAssigneeLoad {
  _MutableAssigneeLoad({required this.assignee});

  final String assignee;
  int activeTasks = 0;
  int activeStoryPoints = 0;
  int criticalTasks = 0;
}

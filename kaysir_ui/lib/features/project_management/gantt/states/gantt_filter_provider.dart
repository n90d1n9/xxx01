import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_saved_view_service.dart';

enum GanttTaskStatusFilter { all, notStarted, inProgress, complete }

extension GanttTaskStatusFilterPresentation on GanttTaskStatusFilter {
  String get label {
    switch (this) {
      case GanttTaskStatusFilter.all:
        return 'All Status';
      case GanttTaskStatusFilter.notStarted:
        return 'Not Started';
      case GanttTaskStatusFilter.inProgress:
        return 'In Progress';
      case GanttTaskStatusFilter.complete:
        return 'Complete';
    }
  }

  IconData get icon {
    switch (this) {
      case GanttTaskStatusFilter.all:
        return Icons.filter_list_rounded;
      case GanttTaskStatusFilter.notStarted:
        return Icons.radio_button_unchecked_rounded;
      case GanttTaskStatusFilter.inProgress:
        return Icons.pending_actions_outlined;
      case GanttTaskStatusFilter.complete:
        return Icons.check_circle_outline;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case GanttTaskStatusFilter.all:
        return colorScheme.primary;
      case GanttTaskStatusFilter.notStarted:
        return colorScheme.onSurfaceVariant;
      case GanttTaskStatusFilter.inProgress:
        return colorScheme.primary;
      case GanttTaskStatusFilter.complete:
        return Colors.green.shade700;
    }
  }
}

final ganttProjectFilterProvider = StateProvider<String?>((ref) => null);

final ganttTaskStatusFilterProvider = StateProvider<GanttTaskStatusFilter>(
  (ref) => GanttTaskStatusFilter.all,
);

final ganttTimelineViewProvider = StateProvider<GanttTimelineViewPreset>(
  (ref) => GanttTimelineViewPreset.all,
);

final ganttBranchFocusTaskIdProvider = StateProvider<String?>((ref) => null);

final ganttCollapsedTaskIdsProvider = StateProvider<Set<String>>(
  (ref) => const <String>{},
);

final ganttVisibleBranchTaskIdsProvider = Provider<Set<String>>((ref) {
  return ganttBranchTaskIds(ref.watch(operationalGanttTasksProvider));
});

final operationalGanttTasksProvider = Provider<List<gantt.GanttTask>>((ref) {
  final tasks = ref.watch(gantt.tasksProvider);

  return filterGanttTasks(
    tasks: tasks,
    dependencyTasks: tasks,
    query: ref.watch(gantt.searchQueryProvider),
    projectId: ref.watch(ganttProjectFilterProvider),
    branchFocusTaskId: ref.watch(ganttBranchFocusTaskIdProvider),
    statusFilter: ref.watch(ganttTaskStatusFilterProvider),
    viewPreset: ref.watch(ganttTimelineViewProvider),
  );
});

final selectedOperationalGanttTaskProvider = Provider<gantt.GanttTask?>((ref) {
  final selectedTaskId = ref.watch(gantt.selectedTaskProvider);
  if (selectedTaskId == null) return null;

  return findGanttTaskById(
    flattenGanttTaskTree(ref.watch(operationalGanttTasksProvider)),
    selectedTaskId,
  );
});

final ganttTaskTitlesByIdProvider = Provider<Map<String, String>>((ref) {
  return {
    for (final task in flattenGanttTaskTree(ref.watch(gantt.tasksProvider)))
      task.id: task.title,
  };
});

List<gantt.GanttTask> filterGanttTasks({
  required List<gantt.GanttTask> tasks,
  List<gantt.GanttTask>? dependencyTasks,
  String query = '',
  String? projectId,
  String? branchFocusTaskId,
  GanttTaskStatusFilter statusFilter = GanttTaskStatusFilter.all,
  GanttTimelineViewPreset viewPreset = GanttTimelineViewPreset.all,
  DateTime? today,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final dependencyPool = dependencyTasks ?? tasks;
  final scopedTasks = _branchFocusScope(tasks, branchFocusTaskId);

  return [
    for (final task in scopedTasks)
      ..._filterTaskBranch(
        task,
        query: normalizedQuery,
        projectId: projectId,
        statusFilter: statusFilter,
        viewPreset: viewPreset,
        dependencyTasks: dependencyPool,
        today: today,
      ),
  ];
}

List<gantt.GanttTask> flattenGanttTaskTree(List<gantt.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ...flattenGanttTaskTree(task.subtasks),
    ],
  ];
}

Set<String> ganttBranchTaskIds(List<gantt.GanttTask> tasks) {
  return {
    for (final task in tasks) ...[
      if (task.subtasks.isNotEmpty) task.id,
      ...ganttBranchTaskIds(task.subtasks),
    ],
  };
}

GanttTaskStatusFilter ganttTaskStatusFor(gantt.GanttTask task) {
  if (task.progress >= 1) return GanttTaskStatusFilter.complete;
  if (task.progress <= 0) return GanttTaskStatusFilter.notStarted;
  return GanttTaskStatusFilter.inProgress;
}

gantt.GanttTask? findGanttTaskById(List<gantt.GanttTask> tasks, String taskId) {
  for (final task in tasks) {
    if (task.id == taskId) return task;
  }

  return null;
}

List<gantt.GanttTask> _branchFocusScope(
  List<gantt.GanttTask> tasks,
  String? branchFocusTaskId,
) {
  final taskId = branchFocusTaskId?.trim();
  if (taskId == null || taskId.isEmpty) return tasks;

  for (final task in tasks) {
    if (task.id == taskId) return [task];

    final focusedSubtree = _branchFocusScope(task.subtasks, taskId);
    if (focusedSubtree.isNotEmpty) return focusedSubtree;
  }

  return const [];
}

List<gantt.GanttTask> _filterTaskBranch(
  gantt.GanttTask task, {
  required String query,
  required String? projectId,
  required GanttTaskStatusFilter statusFilter,
  required GanttTimelineViewPreset viewPreset,
  required List<gantt.GanttTask> dependencyTasks,
  required DateTime? today,
}) {
  final filteredSubtasks = [
    for (final subtask in task.subtasks)
      ..._filterTaskBranch(
        subtask,
        query: query,
        projectId: projectId,
        statusFilter: statusFilter,
        viewPreset: viewPreset,
        dependencyTasks: dependencyTasks,
        today: today,
      ),
  ];
  final matchesSelf =
      _matchesQuery(task, query) &&
      _matchesProject(task, projectId) &&
      _matchesStatus(task, statusFilter) &&
      ganttTaskMatchesTimelineView(
        task,
        viewPreset,
        dependencyTasks,
        today: today,
      );

  if (matchesSelf) {
    return [_copyTask(task, subtasks: filteredSubtasks)];
  }

  return filteredSubtasks;
}

bool _matchesQuery(gantt.GanttTask task, String query) {
  if (query.isEmpty) return true;
  return task.title.toLowerCase().contains(query) ||
      (task.dependsOn?.toLowerCase().contains(query) ?? false);
}

bool _matchesProject(gantt.GanttTask task, String? projectId) {
  return projectId == null || task.projectId == projectId;
}

bool _matchesStatus(gantt.GanttTask task, GanttTaskStatusFilter statusFilter) {
  return statusFilter == GanttTaskStatusFilter.all ||
      ganttTaskStatusFor(task) == statusFilter;
}

gantt.GanttTask _copyTask(
  gantt.GanttTask task, {
  required List<gantt.GanttTask> subtasks,
}) {
  return gantt.GanttTask(
    id: task.id,
    title: task.title,
    startDate: task.startDate,
    endDate: task.endDate,
    progress: task.progress,
    color: task.color,
    kind: task.kind,
    subtasks: subtasks,
    dependsOn: task.dependsOn,
    projectId: task.projectId,
  );
}

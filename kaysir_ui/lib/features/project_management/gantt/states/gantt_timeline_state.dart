import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ky_gantt/ky_gantt.dart';

import '../services/gantt_task_dependency_option_service.dart';

enum ViewMode { day, week, month, quarter }

enum GanttTaskEditKind {
  details,
  progress,
  taskType,
  startDate,
  endDate,
  milestoneDate,
  dependency,
  undo,
}

class GanttTaskEditActivity {
  const GanttTaskEditActivity({
    required this.taskId,
    required this.taskTitle,
    required this.kind,
    required this.label,
    required this.timestamp,
  });

  final String taskId;
  final String taskTitle;
  final GanttTaskEditKind kind;
  final String label;
  final DateTime timestamp;
}

final dateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return DateTimeRange(
    start: today.subtract(const Duration(days: 7)),
    end: today.add(const Duration(days: 30)),
  );
});

final tasksProvider = StateNotifierProvider<TasksNotifier, List<GanttTask>>((
  ref,
) {
  return TasksNotifier();
});

final recentTaskEditsProvider = Provider<List<GanttTaskEditActivity>>((ref) {
  ref.watch(tasksProvider);
  return ref.read(tasksProvider.notifier).recentEdits;
});

final filteredTasksProvider = Provider<List<GanttTask>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();

  if (searchQuery.isEmpty) return tasks;

  return [
    for (final task in tasks)
      if (task.title.toLowerCase().contains(searchQuery)) task,
  ];
});

final selectedTaskProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final zoomLevelProvider = StateProvider<double>((ref) => 1);
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.week);

class TasksNotifier extends StateNotifier<List<GanttTask>> {
  TasksNotifier() : super(_generateSampleTasks());

  static const _maxRecentEdits = 6;

  GanttTask? _lastUndoSnapshot;
  var _recentEdits = <GanttTaskEditActivity>[];

  List<GanttTaskEditActivity> get recentEdits =>
      List.unmodifiable(_recentEdits);

  bool canUndoTask(String? taskId) {
    return taskId != null &&
        _lastUndoSnapshot?.id == taskId &&
        _taskExists(state, taskId);
  }

  bool get canUndoLastEdit {
    final snapshot = _lastUndoSnapshot;
    return snapshot != null && _taskExists(state, snapshot.id);
  }

  void addTask(GanttTask task) {
    state = [...state, task];
  }

  void updateTask(GanttTask updatedTask) {
    final snapshot = _rememberUndoSnapshot(updatedTask.id);
    state = _replaceTask(state, updatedTask.id, (_) => updatedTask);
    _recordEdit(
      snapshot ?? updatedTask,
      kind: GanttTaskEditKind.details,
      label: 'Updated task details',
    );
  }

  void deleteTask(String taskId) {
    final nextState = _removeTask(state, taskId);
    _pruneTaskStateSideEffects(nextState);
    state = nextState;
  }

  void updateTaskProgress(String taskId, double progress) {
    final clampedProgress = progress.clamp(0, 1).toDouble();
    final snapshot = _rememberUndoSnapshot(taskId);
    state = _replaceTask(
      state,
      taskId,
      (task) => task.copyWith(progress: clampedProgress),
    );
    _recordEdit(
      snapshot,
      kind: GanttTaskEditKind.progress,
      label: 'Progress changed to ${(clampedProgress * 100).round()}%',
    );
  }

  void updateTaskKind(String taskId, GanttTaskKind kind) {
    final snapshot = _rememberUndoSnapshot(taskId);
    state = _replaceTask(state, taskId, (task) {
      if (kind == GanttTaskKind.milestone) {
        final milestoneDate = DateUtils.dateOnly(task.startDate);
        return task.copyWith(
          kind: kind,
          startDate: milestoneDate,
          endDate: milestoneDate,
        );
      }

      return task.copyWith(kind: kind);
    });
    _recordEdit(
      snapshot,
      kind: GanttTaskEditKind.taskType,
      label:
          kind == GanttTaskKind.milestone
              ? 'Changed to milestone'
              : 'Changed to task',
    );
  }

  void updateTaskStartDate(String taskId, DateTime date) {
    final startDate = DateUtils.dateOnly(date);

    final snapshot = _rememberUndoSnapshot(taskId);
    state = _replaceTask(state, taskId, (task) {
      if (task.isMilestone) {
        return task.copyWith(startDate: startDate, endDate: startDate);
      }

      final endDate = DateUtils.dateOnly(task.endDate);
      return task.copyWith(
        startDate: startDate,
        endDate: endDate.isBefore(startDate) ? startDate : endDate,
      );
    });
    _recordEdit(
      snapshot,
      kind: GanttTaskEditKind.startDate,
      label: 'Start date changed',
    );
  }

  void updateTaskEndDate(String taskId, DateTime date) {
    final endDate = DateUtils.dateOnly(date);

    final snapshot = _rememberUndoSnapshot(taskId);
    state = _replaceTask(state, taskId, (task) {
      if (task.isMilestone) {
        return task.copyWith(startDate: endDate, endDate: endDate);
      }

      final startDate = DateUtils.dateOnly(task.startDate);
      return task.copyWith(
        startDate: startDate.isAfter(endDate) ? endDate : startDate,
        endDate: endDate,
      );
    });
    _recordEdit(
      snapshot,
      kind: GanttTaskEditKind.endDate,
      label: 'End date changed',
    );
  }

  void updateTaskDateRange(
    String taskId, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final normalizedStart = DateUtils.dateOnly(startDate);
    final normalizedEnd = DateUtils.dateOnly(endDate);
    final orderedStart =
        normalizedStart.isAfter(normalizedEnd)
            ? normalizedEnd
            : normalizedStart;
    final orderedEnd =
        normalizedStart.isAfter(normalizedEnd)
            ? normalizedStart
            : normalizedEnd;

    final snapshot = _rememberUndoSnapshot(taskId);
    state = _replaceTask(state, taskId, (task) {
      if (task.isMilestone) {
        return task.copyWith(startDate: orderedStart, endDate: orderedStart);
      }

      return task.copyWith(startDate: orderedStart, endDate: orderedEnd);
    });

    final editKind = _dateRangeEditKind(
      snapshot,
      startDate: orderedStart,
      endDate: orderedEnd,
    );
    _recordEdit(
      snapshot,
      kind: editKind,
      label: _dateRangeEditLabel(
        snapshot,
        startDate: orderedStart,
        endDate: orderedEnd,
      ),
    );
  }

  GanttTaskEditKind _dateRangeEditKind(
    GanttTask? snapshot, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (snapshot == null) return GanttTaskEditKind.startDate;

    final startDelta =
        startDate.difference(DateUtils.dateOnly(snapshot.startDate)).inDays;
    final endDelta =
        endDate.difference(DateUtils.dateOnly(snapshot.endDate)).inDays;
    if (startDelta == 0 && endDelta != 0) return GanttTaskEditKind.endDate;
    return GanttTaskEditKind.startDate;
  }

  String _dateRangeEditLabel(
    GanttTask? snapshot, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (snapshot == null) return 'Schedule adjusted';

    final startDelta =
        startDate.difference(DateUtils.dateOnly(snapshot.startDate)).inDays;
    final endDelta =
        endDate.difference(DateUtils.dateOnly(snapshot.endDate)).inDays;

    if (startDelta != 0 && startDelta == endDelta) {
      return 'Schedule moved ${_formatDayDelta(startDelta)}';
    }
    if (startDelta != 0 && endDelta == 0) {
      return 'Start resized ${_formatDayDelta(startDelta)}';
    }
    if (startDelta == 0 && endDelta != 0) {
      return 'Finish resized ${_formatDayDelta(endDelta)}';
    }
    if (startDelta == 0 && endDelta == 0) return 'Schedule adjusted';

    return 'Schedule adjusted';
  }

  String _formatDayDelta(int days) {
    return '${days > 0 ? '+' : ''}${days}d';
  }

  void updateMilestoneDate(String taskId, DateTime date) {
    final milestoneDate = DateUtils.dateOnly(date);

    final snapshot = _rememberUndoSnapshot(taskId);
    state = _replaceTask(
      state,
      taskId,
      (task) =>
          task.isMilestone
              ? task.copyWith(startDate: milestoneDate, endDate: milestoneDate)
              : task,
    );
    _recordEdit(
      snapshot,
      kind: GanttTaskEditKind.milestoneDate,
      label: 'Milestone date changed',
    );
  }

  void updateTaskDependency(String taskId, String? dependencyId) {
    final normalizedDependencyId = dependencyId?.trim();
    final nextDependencyId =
        normalizedDependencyId == null || normalizedDependencyId.isEmpty
            ? null
            : normalizedDependencyId;
    final task = _findTaskById(_flattenTasks(state), taskId);

    if (task == null) return;
    if (nextDependencyId != null &&
        !buildGanttTaskDependencyOptions(
          task: task,
          dependencyTasks: state,
        ).candidates.any((candidate) => candidate.id == nextDependencyId)) {
      return;
    }

    final snapshot = _rememberUndoSnapshot(taskId);
    state = _replaceTask(
      state,
      taskId,
      (task) => _copyTaskWithDependency(task, nextDependencyId),
    );
    _recordEdit(
      snapshot,
      kind: GanttTaskEditKind.dependency,
      label:
          nextDependencyId == null
              ? 'Removed predecessor'
              : 'Changed predecessor',
    );
  }

  bool undoLastTaskEdit() {
    final snapshot = _lastUndoSnapshot;
    if (snapshot == null || !_taskExists(state, snapshot.id)) {
      _lastUndoSnapshot = null;
      return false;
    }

    _lastUndoSnapshot = null;
    state = _replaceTask(state, snapshot.id, (_) => snapshot);
    _recordEdit(
      snapshot,
      kind: GanttTaskEditKind.undo,
      label: 'Reverted last edit',
    );
    return true;
  }

  GanttTask? _rememberUndoSnapshot(String taskId) {
    final task = _findTaskById(_flattenTasks(state), taskId);
    if (task == null) return null;

    _lastUndoSnapshot = task;
    return task;
  }

  void _recordEdit(
    GanttTask? task, {
    required GanttTaskEditKind kind,
    required String label,
  }) {
    if (task == null) return;

    _recentEdits =
        [
          GanttTaskEditActivity(
            taskId: task.id,
            taskTitle: task.title,
            kind: kind,
            label: label,
            timestamp: DateTime.now(),
          ),
          ..._recentEdits,
        ].take(_maxRecentEdits).toList();
  }

  void _pruneTaskStateSideEffects(List<GanttTask> tasks) {
    final taskIds = {for (final task in _flattenTasks(tasks)) task.id};

    _recentEdits =
        [
          for (final activity in _recentEdits)
            if (taskIds.contains(activity.taskId)) activity,
        ].toList();

    if (_lastUndoSnapshot != null && !taskIds.contains(_lastUndoSnapshot!.id)) {
      _lastUndoSnapshot = null;
    }
  }

  static List<GanttTask> _generateSampleTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      GanttTask(
        id: '1',
        title: 'Project Planning',
        startDate: today.subtract(const Duration(days: 5)),
        endDate: today.add(const Duration(days: 2)),
        progress: 0.8,
        color: Colors.blue,
        projectId: 'retail-modernization',
        subtasks: [
          GanttTask(
            id: '1.1',
            title: 'Requirements Gathering',
            startDate: today.subtract(const Duration(days: 5)),
            endDate: today.subtract(const Duration(days: 2)),
            progress: 1,
            color: Colors.blueAccent,
            projectId: 'retail-modernization',
          ),
          GanttTask(
            id: '1.2',
            title: 'Resource Allocation',
            startDate: today.subtract(const Duration(days: 1)),
            endDate: today.add(const Duration(days: 2)),
            progress: 0.6,
            color: Colors.lightBlue,
            projectId: 'retail-modernization',
          ),
        ],
      ),
      GanttTask(
        id: '2',
        title: 'Design Phase',
        startDate: today.add(const Duration(days: 3)),
        endDate: today.add(const Duration(days: 10)),
        progress: 0.2,
        color: Colors.green,
        dependsOn: '1',
        projectId: 'warehouse-automation',
      ),
      GanttTask(
        id: '3',
        title: 'Development',
        startDate: today.add(const Duration(days: 11)),
        endDate: today.add(const Duration(days: 25)),
        color: Colors.orange,
        dependsOn: '2',
        projectId: 'mobile-field-app',
      ),
      GanttTask(
        id: '4',
        title: 'Testing',
        startDate: today.add(const Duration(days: 25)),
        endDate: today.add(const Duration(days: 30)),
        color: Colors.purple,
        dependsOn: '3',
        projectId: 'finance-close-suite',
      ),
      GanttTask(
        id: '5',
        title: 'Launch Readiness',
        startDate: today.add(const Duration(days: 30)),
        endDate: today.add(const Duration(days: 30)),
        color: Colors.deepPurple,
        kind: GanttTaskKind.milestone,
        dependsOn: '4',
        projectId: 'finance-close-suite',
      ),
    ];
  }
}

List<GanttTask> _replaceTask(
  List<GanttTask> tasks,
  String taskId,
  GanttTask Function(GanttTask task) transform,
) {
  return [
    for (final task in tasks)
      if (task.id == taskId)
        transform(task)
      else
        task.copyWith(subtasks: _replaceTask(task.subtasks, taskId, transform)),
  ];
}

List<GanttTask> _removeTask(List<GanttTask> tasks, String taskId) {
  return [
    for (final task in tasks)
      if (task.id != taskId)
        task.copyWith(subtasks: _removeTask(task.subtasks, taskId)),
  ];
}

GanttTask _copyTaskWithDependency(GanttTask task, String? dependsOn) {
  return GanttTask(
    id: task.id,
    title: task.title,
    startDate: task.startDate,
    endDate: task.endDate,
    progress: task.progress,
    color: task.color,
    kind: task.kind,
    subtasks: task.subtasks,
    dependsOn: dependsOn,
    projectId: task.projectId,
  );
}

bool _taskExists(List<GanttTask> tasks, String taskId) {
  return _flattenTasks(tasks).any((task) => task.id == taskId);
}

GanttTask? _findTaskById(List<GanttTask> tasks, String taskId) {
  for (final task in tasks) {
    if (task.id == taskId) return task;
  }

  return null;
}

List<GanttTask> _flattenTasks(List<GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
    ],
  ];
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../utils/date_utils.dart';
import '../utils/critical_path.dart';

// ─── Task Repository (Notifier) ───────────────────────────────────────────────

class TasksNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() => _sampleTasks();

  // ── CRUD ─────────────────────────────────────────────────────────────────

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task updated) {
    state = [
      for (final t in state)
        if (t.id == updated.id) updated else t,
    ];
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void reorderTask(String taskId, String? newParentId) {
    state = [
      for (final t in state)
        if (t.id == taskId) t.copyWith(parentId: newParentId) else t,
    ];
  }

  // ── Drag to reschedule ────────────────────────────────────────────────────

  void rescheduleTask(String taskId, DateTime newStart) {
    final task = state.firstWhere((t) => t.id == taskId);
    final duration = task.endDate.difference(task.startDate);
    final newEnd = newStart.add(duration);
    updateTask(task.copyWith(
      startDate: newStart,
      endDate: newEnd,
      updatedAt: DateTime.now(),
    ));
  }

  void resizeTaskEnd(String taskId, DateTime newEnd) {
    final task = state.firstWhere((t) => t.id == taskId);
    if (newEnd.isAfter(task.startDate)) {
      updateTask(task.copyWith(endDate: newEnd, updatedAt: DateTime.now()));
    }
  }

  void updateProgress(String taskId, double progress) {
    final task = state.firstWhere((t) => t.id == taskId);
    final clampedProgress = progress.clamp(0.0, 1.0);
    TaskStatus newStatus = task.status;
    if (clampedProgress >= 1.0) newStatus = TaskStatus.done;
    else if (clampedProgress > 0.0 && task.status == TaskStatus.todo) {
      newStatus = TaskStatus.inProgress;
    }
    updateTask(task.copyWith(
      progress: clampedProgress,
      status: newStatus,
      updatedAt: DateTime.now(),
    ));
  }

  void toggleExpanded(String taskId) {
    final task = state.firstWhere((t) => t.id == taskId);
    updateTask(task.copyWith(isExpanded: !task.isExpanded));
  }

  void addComment(String taskId, TaskComment comment) {
    final task = state.firstWhere((t) => t.id == taskId);
    updateTask(task.copyWith(
      comments: [...task.comments, comment],
      updatedAt: DateTime.now(),
    ));
  }

  void deleteComment(String taskId, String commentId) {
    final task = state.firstWhere((t) => t.id == taskId);
    updateTask(task.copyWith(
      comments: task.comments.where((c) => c.id != commentId).toList(),
      updatedAt: DateTime.now(),
    ));
  }

  // ── Sample data ───────────────────────────────────────────────────────────

  static List<Task> _sampleTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      Task(
        id: 't1',
        title: 'Project Kickoff & Planning',
        description: 'Define scope, objectives, and stakeholder alignment',
        startDate: today.subtract(const Duration(days: 5)),
        endDate: today.subtract(const Duration(days: 2)),
        status: TaskStatus.done,
        priority: TaskPriority.critical,
        progress: 1.0,
        color: const Color(0xFF6366F1),
        dependencyIds: const [],
        assignees: [
          const Assignee(id: 'a1', name: 'Alice Chen', avatarColor: Color(0xFF6366F1)),
          const Assignee(id: 'a2', name: 'Bob Smith', avatarColor: Color(0xFF10B981)),
        ],
        labels: const ['planning', 'kickoff'],
        createdAt: today.subtract(const Duration(days: 10)),
        updatedAt: today.subtract(const Duration(days: 2)),
      ),
      Task(
        id: 't2',
        title: 'Requirements Analysis',
        description: 'Gather and document functional requirements',
        startDate: today.subtract(const Duration(days: 3)),
        endDate: today.add(const Duration(days: 2)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progress: 0.65,
        color: const Color(0xFFF59E0B),
        dependencyIds: const ['t1'],
        assignees: [
          const Assignee(id: 'a1', name: 'Alice Chen', avatarColor: Color(0xFF6366F1)),
        ],
        labels: const ['analysis'],
        createdAt: today.subtract(const Duration(days: 10)),
        updatedAt: today,
      ),
      Task(
        id: 't3',
        title: 'UI/UX Design',
        description: 'Wireframes, prototypes, and design system',
        startDate: today.subtract(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 7)),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        progress: 0.3,
        color: const Color(0xFFEC4899),
        dependencyIds: const ['t1'],
        assignees: [
          const Assignee(id: 'a3', name: 'Carol Davis', avatarColor: Color(0xFFEC4899)),
        ],
        labels: const ['design', 'ux'],
        parentId: null,
        createdAt: today.subtract(const Duration(days: 10)),
        updatedAt: today,
      ),
      Task(
        id: 't3a',
        title: 'Wireframes',
        startDate: today.subtract(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 3)),
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        progress: 1.0,
        color: const Color(0xFFEC4899),
        dependencyIds: const [],
        assignees: [
          const Assignee(id: 'a3', name: 'Carol Davis', avatarColor: Color(0xFFEC4899)),
        ],
        labels: const ['design'],
        parentId: 't3',
        createdAt: today.subtract(const Duration(days: 10)),
        updatedAt: today,
      ),
      Task(
        id: 't3b',
        title: 'Design System',
        startDate: today.add(const Duration(days: 2)),
        endDate: today.add(const Duration(days: 7)),
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        progress: 0.0,
        color: const Color(0xFFEC4899),
        dependencyIds: const ['t3a'],
        assignees: [
          const Assignee(id: 'a3', name: 'Carol Davis', avatarColor: Color(0xFFEC4899)),
        ],
        labels: const ['design'],
        parentId: 't3',
        createdAt: today.subtract(const Duration(days: 10)),
        updatedAt: today,
      ),
      Task(
        id: 't4',
        title: 'Backend Architecture',
        description: 'Database schema, API design, microservices setup',
        startDate: today.add(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 10)),
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        progress: 0.0,
        color: const Color(0xFF3B82F6),
        dependencyIds: const ['t2'],
        assignees: [
          const Assignee(id: 'a2', name: 'Bob Smith', avatarColor: Color(0xFF10B981)),
          const Assignee(id: 'a4', name: 'Dan Lee', avatarColor: Color(0xFF3B82F6)),
        ],
        labels: const ['backend', 'architecture'],
        createdAt: today.subtract(const Duration(days: 10)),
        updatedAt: today,
      ),
      Task(
        id: 't5',
        title: 'Frontend Development',
        description: 'Implement UI components and integrate APIs',
        startDate: today.add(const Duration(days: 8)),
        endDate: today.add(const Duration(days: 22)),
        status: TaskStatus.backlog,
        priority: TaskPriority.high,
        progress: 0.0,
        color: const Color(0xFF06B6D4),
        dependencyIds: const ['t3', 't4'],
        assignees: [
          const Assignee(id: 'a3', name: 'Carol Davis', avatarColor: Color(0xFFEC4899)),
          const Assignee(id: 'a5', name: 'Eva Park', avatarColor: Color(0xFF06B6D4)),
        ],
        labels: const ['frontend'],
        createdAt: today.subtract(const Duration(days: 10)),
        updatedAt: today,
      ),
      Task(
        id: 't6',
        title: 'Integration Testing',
        startDate: today.add(const Duration(days: 20)),
        endDate: today.add(const Duration(days: 26)),
        status: TaskStatus.backlog,
        priority: TaskPriority.medium,
        progress: 0.0,
        color: const Color(0xFF8B5CF6),
        dependencyIds: const ['t5'],
        assignees: [
          const Assignee(id: 'a2', name: 'Bob Smith', avatarColor: Color(0xFF10B981)),
        ],
        labels: const ['testing', 'qa'],
        createdAt: today.subtract(const Duration(days: 10)),
        updatedAt: today,
      ),
      Task(
        id: 't7',
        title: '🚀 MVP Launch',
        description: 'Production deployment and go-live',
        startDate: today.add(const Duration(days: 27)),
        endDate: today.add(const Duration(days: 27)),
        status: TaskStatus.backlog,
        priority: TaskPriority.critical,
        progress: 0.0,
        color: const Color(0xFFEF4444),
        isMilestone: true,
        dependencyIds: const ['t6'],
        assignees: [
          const Assignee(id: 'a1', name: 'Alice Chen', avatarColor: Color(0xFF6366F1)),
        ],
        labels: const ['milestone', 'launch'],
        createdAt: today.subtract(const Duration(days: 10)),
        updatedAt: today,
      ),
    ];
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final tasksProvider = NotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);

// Selected task for detail panel
final selectedTaskIdProvider = StateProvider<String?>((ref) => null);

final selectedTaskProvider = Provider<Task?>((ref) {
  final id = ref.watch(selectedTaskIdProvider);
  if (id == null) return null;
  final tasks = ref.watch(tasksProvider);
  try {
    return tasks.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
});

// View settings
final viewSettingsProvider = StateProvider<GanttViewSettings>(
  (ref) => const GanttViewSettings(),
);

// Filter
final filterProvider = StateProvider<GanttFilter>(
  (ref) => const GanttFilter(),
);

// Hover state for interactive highlighting
final hoveredTaskIdProvider = StateProvider<String?>((ref) => null);

// Dragging state
final draggingTaskIdProvider = StateProvider<String?>((ref) => null);

// Sidebar collapse
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

// ─── Derived: filtered & visible tasks ───────────────────────────────────────

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(filterProvider);

  return tasks.where((task) {
    if (filter.searchQuery?.isNotEmpty ?? false) {
      final q = filter.searchQuery!.toLowerCase();
      if (!task.title.toLowerCase().contains(q) &&
          !(task.description?.toLowerCase().contains(q) ?? false)) {
        return false;
      }
    }
    if (filter.statuses.isNotEmpty && !filter.statuses.contains(task.status)) {
      return false;
    }
    if (filter.priorities.isNotEmpty &&
        !filter.priorities.contains(task.priority)) {
      return false;
    }
    if (filter.startDateFrom != null &&
        task.startDate.isBefore(filter.startDateFrom!)) {
      return false;
    }
    if (filter.startDateTo != null &&
        task.startDate.isAfter(filter.startDateTo!)) {
      return false;
    }
    if (filter.assigneeId != null &&
        !task.assignees.any((a) => a.id == filter.assigneeId)) {
      return false;
    }
    return true;
  }).toList();
});

// Flat ordered visible task list (respects tree expand/collapse)
final visibleTasksProvider = Provider<List<Task>>((ref) {
  final allTasks = ref.watch(filteredTasksProvider);
  return _buildVisibleList(allTasks);
});

List<Task> _buildVisibleList(List<Task> allTasks) {
  final taskMap = {for (final t in allTasks) t.id: t};
  final result = <Task>[];

  void addWithChildren(Task task) {
    result.add(task);
    if (task.isExpanded) {
      final children =
          allTasks.where((t) => t.parentId == task.id).toList();
      for (final child in children) {
        addWithChildren(child);
      }
    }
  }

  // Start with root tasks (no parentId or parentId not in allTasks)
  final roots = allTasks
      .where((t) => t.parentId == null || !taskMap.containsKey(t.parentId))
      .toList();
  for (final root in roots) {
    addWithChildren(root);
  }
  return result;
}

// Project date range
final projectDateRangeProvider = Provider<(DateTime, DateTime)>((ref) {
  final tasks = ref.watch(tasksProvider);
  if (tasks.isEmpty) {
    final now = DateTime.now();
    return (now, now.add(const Duration(days: 30)));
  }
  final start = tasks
      .map((t) => t.startDate)
      .reduce((a, b) => a.isBefore(b) ? a : b);
  final end = tasks
      .map((t) => t.endDate)
      .reduce((a, b) => a.isAfter(b) ? a : b);
  // Add padding
  return (
    start.subtract(const Duration(days: 7)),
    end.add(const Duration(days: 14))
  );
});

// Critical path
final criticalPathIdsProvider = Provider<Set<String>>((ref) {
  final settings = ref.watch(viewSettingsProvider);
  if (!settings.showCriticalPath) return {};
  final tasks = ref.watch(tasksProvider);
  return CriticalPathCalculator.calculate(tasks);
});

// Task depth in hierarchy
final taskDepthProvider = Provider.family<int, String>((ref, taskId) {
  final tasks = ref.watch(tasksProvider);
  return _calculateDepth(taskId, tasks, 0);
});

int _calculateDepth(String taskId, List<Task> tasks, int depth) {
  final task = tasks.firstWhere((t) => t.id == taskId, orElse: () => tasks.first);
  if (task.parentId == null) return depth;
  return _calculateDepth(task.parentId!, tasks, depth + 1);
}

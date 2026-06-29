import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../commands/gantt_commands.dart';
import '../models/task_model.dart';
import '../utils/critical_path.dart';
import '../utils/date_utils.dart';
import '../utils/sample_data.dart';

// ─── Tasks ────────────────────────────────────────────────────────────────────

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) => TasksNotifier());

class TasksNotifier extends StateNotifier<List<Task>> {
  final _history = CommandHistory();

  TasksNotifier() : super([]) {
    state = SampleDataGenerator.generate();
  }

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  void undo() {
    _history.undo(state);
    state = _history.currentState(state);
    state = WbsCalculator.assignWbsCodes(state);
  }

  void redo() {
    final next = _history.redo(state);
    if (next != null) {
      state = next;
      state = WbsCalculator.assignWbsCodes(state);
    }
  }

  void _execute(GanttCommand cmd) {
    _history.execute(cmd, state);
    state = cmd.apply(state);
    state = WbsCalculator.assignWbsCodes(state);
  }

  void addTask(Task task) => _execute(AddTaskCommand(task));
  void deleteTask(String id) => _execute(DeleteTaskCommand(id));
  void updateTask(Task task) => _execute(UpdateTaskCommand(task));

  void rescheduleTask(String id, DateTime newStart) {
    final task = state.firstWhere((t) => t.id == id);
    final diff = newStart.difference(task.startDate);
    _execute(RescheduleCommand(id: id, oldStart: task.startDate, oldEnd: task.endDate, newStart: newStart, newEnd: task.endDate.add(diff)));
  }

  void resizeTaskEnd(String id, DateTime newEnd) {
    final task = state.firstWhere((t) => t.id == id);
    if (newEnd.isAfter(task.startDate)) {
      _execute(UpdateTaskCommand(task.copyWith(endDate: newEnd, updatedAt: DateTime.now())));
    }
  }

  void toggleExpanded(String id) {
    state = state.map((t) => t.id == id ? t.copyWith(isExpanded: !t.isExpanded) : t).toList();
  }

  void addComment(String taskId, TaskComment comment) {
    state = state.map((t) => t.id == taskId ? t.copyWith(comments: [...t.comments, comment], updatedAt: DateTime.now()) : t).toList();
  }

  void deleteComment(String taskId, String commentId) {
    state = state.map((t) => t.id == taskId ? t.copyWith(comments: t.comments.where((c) => c.id != commentId).toList(), updatedAt: DateTime.now()) : t).toList();
  }

  void toggleChecklistItem(String taskId, String itemId) {
    state = state.map((t) => t.id == taskId
        ? t.copyWith(checklist: t.checklist.map((c) => c.id == itemId ? c.copyWith(isCompleted: !c.isCompleted) : c).toList(), updatedAt: DateTime.now())
        : t).toList();
  }

  void addChecklistItem(String taskId, String text) {
    state = state.map((t) => t.id == taskId
        ? t.copyWith(checklist: [...t.checklist, ChecklistItem(id: DateTime.now().millisecondsSinceEpoch.toString(), text: text)], updatedAt: DateTime.now())
        : t).toList();
  }

  void addTimeEntry(String taskId, TimeEntry entry) {
    state = state.map((t) => t.id == taskId
        ? t.copyWith(timeEntries: [...t.timeEntries, entry], actualHours: t.actualHours + entry.hours, updatedAt: DateTime.now())
        : t).toList();
  }

  void updateProgress(String id, double progress) {
    state = state.map((t) => t.id == id ? t.copyWith(progress: progress.clamp(0.0, 1.0), updatedAt: DateTime.now()) : t).toList();
  }

  void setBaseline(String label) {
    final now = DateTime.now();
    state = state.map((t) => t.copyWith(
      baseline: TaskBaseline(startDate: t.startDate, endDate: t.endDate, progress: t.progress, capturedAt: now, label: label),
      updatedAt: now,
    )).toList();
  }

  void duplicateTask(String id) {
    final orig = state.firstWhere((t) => t.id == id);
    final copy = orig.copyWith(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: '${orig.title} (copy)',
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
      comments: const [], timeEntries: const [], baseline: null,
    );
    _execute(AddTaskCommand(copy));
  }

  void splitTask(String id, DateTime splitDate) {
    final orig = state.firstWhere((t) => t.id == id);
    if (!splitDate.isAfter(orig.startDate) || !splitDate.isBefore(orig.endDate)) return;
    final now = DateTime.now();
    final part1 = orig.copyWith(endDate: splitDate.subtract(const Duration(days: 1)), updatedAt: now);
    final part2Id = 'task_${now.millisecondsSinceEpoch}';
    final part2 = orig.copyWith(
      id: part2Id, title: '${orig.title} (2)',
      startDate: splitDate, updatedAt: now,
      dependencies: [TaskDependency(predecessorId: orig.id)],
      comments: const [], timeEntries: const [], baseline: null,
    );
    state = state.map((t) => t.id == id ? part1 : t).toList()..add(part2);
    state = WbsCalculator.assignWbsCodes(state);
  }

  void reorderTask(String id, String? newParentId) {
    state = state.map((t) => t.id == id ? t.copyWith(parentId: newParentId, updatedAt: DateTime.now()) : t).toList();
    state = WbsCalculator.assignWbsCodes(state);
  }
}

// ─── View settings ────────────────────────────────────────────────────────────

final viewSettingsProvider = StateProvider<GanttViewSettings>((ref) => const GanttViewSettings());
final filterProvider = StateProvider<GanttFilter>((ref) => const GanttFilter());
final selectedTaskIdProvider = StateProvider<String?>((ref) => null);
final hoveredTaskIdProvider = StateProvider<String?>((ref) => null);
final draggingTaskIdProvider = StateProvider<String?>((ref) => null);
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
final analyticsOpenProvider = StateProvider<bool>((ref) => false);
final searchFocusRequestProvider = StateProvider<int>((ref) => 0);
final addTaskDialogRequestProvider = StateProvider<int>((ref) => 0);

// ─── Derived providers ────────────────────────────────────────────────────────

final selectedTaskProvider = Provider<Task?>((ref) {
  final id = ref.watch(selectedTaskIdProvider);
  if (id == null) return null;
  final tasks = ref.watch(tasksProvider);
  try { return tasks.firstWhere((t) => t.id == id); } catch (_) { return null; }
});

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(filterProvider);
  if (!filter.isActive) return tasks;
  return tasks.where((t) {
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      if (!t.title.toLowerCase().contains(q) && !(t.description?.toLowerCase().contains(q) ?? false)) return false;
    }
    if (filter.statuses.isNotEmpty && !filter.statuses.contains(t.status)) return false;
    if (filter.priorities.isNotEmpty && !filter.priorities.contains(t.priority)) return false;
    if (filter.assigneeId != null && !t.assignees.any((a) => a.id == filter.assigneeId)) return false;
    if (filter.riskLevels.isNotEmpty && !filter.riskLevels.contains(t.riskLevel)) return false;
    if (filter.labels.isNotEmpty && !filter.labels.any((l) => t.labels.contains(l))) return false;
    return true;
  }).toList();
});

final visibleTasksProvider = Provider<List<Task>>((ref) {
  final filtered = ref.watch(filteredTasksProvider);
  if (filtered.isEmpty) return filtered;
  final taskMap = {for (final t in filtered) t.id: t};
  final result = <Task>[];
  final visited = <String>{};

  void visit(Task t) {
    if (visited.contains(t.id)) return;
    visited.add(t.id);
    result.add(t);
    if (t.isExpanded) {
      for (final child in filtered.where((c) => c.parentId == t.id)) visit(child);
    }
  }
  for (final root in filtered.where((t) => t.parentId == null || !taskMap.containsKey(t.parentId))) visit(root);
  return result;
});

final projectDateRangeProvider = Provider<(DateTime, DateTime)>((ref) {
  final tasks = ref.watch(tasksProvider);
  if (tasks.isEmpty) {
    final now = DateTime.now();
    return (now, now.add(const Duration(days: 30)));
  }
  final starts = tasks.map((t) => t.startDate).toList()..sort();
  final ends = tasks.map((t) => t.endDate).toList()..sort();
  final buffer = const Duration(days: 7);
  return (starts.first.subtract(buffer), ends.last.add(buffer));
});

final criticalPathIdsProvider = Provider<Set<String>>((ref) {
  final settings = ref.watch(viewSettingsProvider);
  if (!settings.showCriticalPath) return {};
  final tasks = ref.watch(tasksProvider);
  return CriticalPathCalculator.calculate(tasks);
});

final allAssigneesProvider = Provider<List<Assignee>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final seen = <String>{};
  final result = <Assignee>[];
  for (final task in tasks) {
    for (final a in task.assignees) {
      if (seen.add(a.id)) result.add(a);
    }
  }
  return result;
});

final allLabelsProvider = Provider<Set<String>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return {for (final t in tasks) ...t.labels};
});

/// Returns: Map<dateOnly, Map<assigneeId, hoursOnThatDay>>
final resourceLoadProvider = Provider<Map<DateTime, Map<String, double>>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final result = <DateTime, Map<String, double>>{};

  for (final task in tasks) {
    if (task.assignees.isEmpty) continue;
    final days = GanttDateUtils.daysBetween(task.startDate, task.endDate) + 1;
    if (days <= 0) continue;
    final hoursPerDayPerAssignee = (task.estimatedHours / days) / task.assignees.length;
    for (int d = 0; d < days; d++) {
      final day = GanttDateUtils.dateOnly(task.startDate.add(Duration(days: d)));
      result.putIfAbsent(day, () => {});
      for (final a in task.assignees) {
        result[day]![a.id] = (result[day]![a.id] ?? 0) + hoursPerDayPerAssignee;
      }
    }
  }
  return result;
});

final taskDepthProvider = Provider.family<int, String>((ref, id) {
  final tasks = ref.watch(tasksProvider);
  int depth = 0;
  String? currentId = id;
  while (currentId != null && depth < 20) {
    final task = tasks.firstWhere((t) => t.id == currentId, orElse: () => tasks.first);
    if (task.parentId == null) break;
    depth++;
    currentId = task.parentId;
  }
  return depth;
});

import 'package:flutter_riverpod/legacy.dart';
import '../commands/gantt_commands.dart';
import '../models/task_model.dart';
import '../utils/critical_path.dart';
import '../utils/date_utils.dart';
import '../utils/sample_data.dart';
import '../utils/auto_scheduler.dart';
import '../utils/recurrence_engine.dart';
import '../utils/resource_leveler.dart';
import '../utils/task_validator.dart';

// ─── Tasks ────────────────────────────────────────────────────────────────────

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>(
    (ref) => TasksNotifier(ref));

class TasksNotifier extends StateNotifier<List<Task>> {
  final Ref _ref;
  final _history = CommandHistory();

  TasksNotifier(this._ref, {List<Task>? initialTasks}) : super([]) {
    state = initialTasks ?? SampleDataGenerator.generate();
  }

  /// Replaces state with persisted tasks (skips sample data seeding).
  void loadPersisted(List<Task> tasks) {
    if (tasks.isNotEmpty) state = tasks;
  }

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  void undo() {
    _history.undo(state);
    state = _history.currentState(state);
    state = WbsCalculator.assignWbsCodes(state);
    _ref.read(auditLogProvider.notifier)._add(AuditEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          taskId: '',
          taskTitle: 'Project',
          field: 'undo',
          commandDescription: 'Undo last action',
          timestamp: DateTime.now(),
        ));
  }

  void redo() {
    final next = _history.redo(state);
    if (next != null) {
      state = next;
      state = WbsCalculator.assignWbsCodes(state);
    }
  }

  void _execute(GanttCommand cmd, {bool skipAudit = false}) {
    _history.execute(cmd, state);
    state = cmd.apply(state);
    state = WbsCalculator.assignWbsCodes(state);
    state = RecurrenceEngine.expandAll(state);

    // Auto-schedule propagation if enabled
    if (_ref.read(viewSettingsProvider).autoScheduleEnabled) {
      if (cmd is RescheduleCommand) {
        state = AutoScheduler.propagate(state, cmd.id);
        state = WbsCalculator.assignWbsCodes(state);
      }
    }

    if (!skipAudit) _auditCommand(cmd);
  }

  void _auditCommand(GanttCommand cmd) {
    _ref.read(auditLogProvider.notifier)._add(AuditEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          taskId: '',
          taskTitle: 'Project',
          field: 'task',
          commandDescription: cmd.description,
          timestamp: DateTime.now(),
        ));
  }

  /// Validates [task] before adding. Returns the validation result so callers
  /// can surface errors in the UI. Throws nothing — UI decides what to show.
  TaskValidationResult addTask(Task task) {
    final result = TaskValidator.validate(task, existingTasks: state);
    if (result.isValid) _execute(AddTaskCommand(task));
    return result;
  }

  void deleteTask(String id) => _execute(DeleteTaskCommand(id));

  /// Validates [task] before updating. Returns validation result.
  TaskValidationResult updateTask(Task task) {
    final result = TaskValidator.validate(task,
        existingTasks: state.where((t) => t.id != task.id).toList());
    if (result.isValid) _execute(UpdateTaskCommand(task));
    return result;
  }

  void rescheduleTask(String id, DateTime newStart) {
    final task = state.firstWhere((t) => t.id == id);
    if (task.isLocked) return;
    final diff = newStart.difference(task.startDate);
    _execute(RescheduleCommand(
        id: id,
        oldStart: task.startDate,
        oldEnd: task.endDate,
        newStart: newStart,
        newEnd: task.endDate.add(diff)));
  }

  void resizeTaskEnd(String id, DateTime newEnd) {
    final task = state.firstWhere((t) => t.id == id);
    if (task.isLocked) return;
    if (newEnd.isBefore(task.startDate)) return; // guard: end must be >= start
    if (newEnd.isAfter(task.startDate)) {
      _execute(UpdateTaskCommand(
          task.copyWith(endDate: newEnd, updatedAt: DateTime.now())));
    }
  }

  void resizeTaskStart(String id, DateTime newStart) {
    final task = state.firstWhere((t) => t.id == id);
    if (task.isLocked) return;
    if (newStart.isBefore(task.endDate)) {
      _execute(UpdateTaskCommand(
          task.copyWith(startDate: newStart, updatedAt: DateTime.now())));
    }
  }

  void toggleExpanded(String id) {
    state = state
        .map((t) => t.id == id ? t.copyWith(isExpanded: !t.isExpanded) : t)
        .toList();
  }

  void toggleLock(String id) {
    state = state
        .map((t) => t.id == id
            ? t.copyWith(
                isLocked: !t.isLocked,
                lockedByUserId: t.isLocked ? null : 'current_user')
            : t)
        .toList();
  }

  void addComment(String taskId, TaskComment comment) {
    state = state
        .map((t) => t.id == taskId
            ? t.copyWith(
                comments: [...t.comments, comment], updatedAt: DateTime.now())
            : t)
        .toList();
  }

  void deleteComment(String taskId, String commentId) {
    state = state
        .map((t) => t.id == taskId
            ? t.copyWith(
                comments: t.comments.where((c) => c.id != commentId).toList(),
                updatedAt: DateTime.now())
            : t)
        .toList();
  }

  void toggleChecklistItem(String taskId, String itemId) {
    state = state
        .map((t) => t.id == taskId
            ? t.copyWith(
                checklist: t.checklist
                    .map((c) => c.id == itemId
                        ? c.copyWith(isCompleted: !c.isCompleted)
                        : c)
                    .toList(),
                updatedAt: DateTime.now())
            : t)
        .toList();
  }

  void addChecklistItem(String taskId, String text) {
    state = state
        .map((t) => t.id == taskId
            ? t.copyWith(checklist: [
                ...t.checklist,
                ChecklistItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text: text)
              ], updatedAt: DateTime.now())
            : t)
        .toList();
  }

  void addTimeEntry(String taskId, TimeEntry entry) {
    state = state
        .map((t) => t.id == taskId
            ? t.copyWith(
                timeEntries: [...t.timeEntries, entry],
                actualHours: t.actualHours + entry.hours,
                updatedAt: DateTime.now())
            : t)
        .toList();
  }

  void updateProgress(String id, double progress) {
    state = state
        .map((t) => t.id == id
            ? t.copyWith(
                progress: progress.clamp(0.0, 1.0), updatedAt: DateTime.now())
            : t)
        .toList();
  }

  void setBaseline(String label) {
    final now = DateTime.now();
    state = state
        .map((t) => t.copyWith(
              baseline: TaskBaseline(
                  startDate: t.startDate,
                  endDate: t.endDate,
                  progress: t.progress,
                  capturedAt: now,
                  label: label),
              updatedAt: now,
            ))
        .toList();
  }

  void setTaskConstraint(String id, TaskConstraint constraint, DateTime? date) {
    state = state
        .map((t) => t.id == id
            ? t.copyWith(
                constraint: constraint,
                constraintDate: date,
                updatedAt: DateTime.now())
            : t)
        .toList();
  }

  void setCustomField(String taskId, String fieldId, dynamic value) {
    state = state.map((t) {
      if (t.id != taskId) return t;
      final fields = Map<String, dynamic>.from(t.customFields);
      fields[fieldId] = value;
      return t.copyWith(customFields: fields, updatedAt: DateTime.now());
    }).toList();
  }

  void duplicateTask(String id) {
    final orig = state.firstWhere((t) => t.id == id);
    final copy = orig.copyWith(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: '${orig.title} (copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      comments: const [],
      timeEntries: const [],
      baseline: null,
    );
    _execute(AddTaskCommand(copy));
  }

  void splitTask(String id, DateTime splitDate) {
    final orig = state.firstWhere((t) => t.id == id);
    if (!splitDate.isAfter(orig.startDate) || !splitDate.isBefore(orig.endDate))
      return;
    final now = DateTime.now();
    final part1 = orig.copyWith(
        endDate: splitDate.subtract(const Duration(days: 1)), updatedAt: now);
    final part2Id = 'task_${now.millisecondsSinceEpoch}';
    final part2 = orig.copyWith(
      id: part2Id,
      title: '${orig.title} (2)',
      startDate: splitDate,
      updatedAt: now,
      dependencies: [TaskDependency(predecessorId: orig.id)],
      comments: const [],
      timeEntries: const [],
      baseline: null,
    );
    state = state.map((t) => t.id == id ? part1 : t).toList()..add(part2);
    state = WbsCalculator.assignWbsCodes(state);
  }

  void reorderTask(String id, String? newParentId) {
    state = state
        .map((t) => t.id == id
            ? t.copyWith(parentId: newParentId, updatedAt: DateTime.now())
            : t)
        .toList();
    state = WbsCalculator.assignWbsCodes(state);
  }

  void moveTaskToIndex(String id, String targetId) {
    final list = List<Task>.from(state);
    final fromIdx = list.indexWhere((t) => t.id == id);
    final toIdx = list.indexWhere((t) => t.id == targetId);
    if (fromIdx < 0 || toIdx < 0 || fromIdx == toIdx) return;
    final item = list.removeAt(fromIdx);
    list.insert(toIdx, item);
    state = WbsCalculator.assignWbsCodes(list);
  }

  /// Apply resource leveling to the current task list
  void levelResources() {
    final assignees = _ref.read(allAssigneesProvider);
    final criticalIds = _ref.read(criticalPathIdsProvider);
    final result =
        ResourceLeveler.level(state, assignees, criticalIds: criticalIds);
    if (result.shiftsApplied > 0) {
      final prevState = List<Task>.from(state);
      state = WbsCalculator.assignWbsCodes(result.tasks);
      _history.execute(
        _LevelResourcesCommand(before: prevState, after: state),
        prevState,
      );
      _ref.read(auditLogProvider.notifier)._add(AuditEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            taskId: '',
            taskTitle: 'Project',
            field: 'schedule',
            newValue:
                '${result.shiftsApplied} tasks shifted, +${result.daysExtended}d',
            commandDescription: 'Resource Leveling applied',
            timestamp: DateTime.now(),
          ));
    }
  }

  /// Save a named project snapshot
  void saveSnapshot(String label, {String? notes}) {
    _ref.read(snapshotsProvider.notifier).save(
          ProjectSnapshot(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            label: label,
            capturedAt: DateTime.now(),
            tasks: List.from(state),
            notes: notes,
          ),
        );
  }

  /// Restore tasks from a snapshot
  void restoreSnapshot(ProjectSnapshot snapshot) {
    final prevState = List<Task>.from(state);
    state = WbsCalculator.assignWbsCodes(List.from(snapshot.tasks));
    _history.execute(
      _LevelResourcesCommand(before: prevState, after: state),
      prevState,
    );
  }
}

// Simple command to wrap resource leveling / snapshot restore for undo
class _LevelResourcesCommand extends GanttCommand {
  final List<Task> before;
  final List<Task> after;
  const _LevelResourcesCommand({required this.before, required this.after});

  @override
  List<Task> apply(List<Task> _) => after;

  @override
  GanttCommand inverse(List<Task> _) =>
      _LevelResourcesCommand(before: after, after: before);

  @override
  String get description => 'Resource Leveling';
}

// ─── Audit Log ────────────────────────────────────────────────────────────────

final auditLogProvider =
    StateNotifierProvider<AuditLogNotifier, List<AuditEntry>>(
        (_) => AuditLogNotifier());

class AuditLogNotifier extends StateNotifier<List<AuditEntry>> {
  AuditLogNotifier() : super([]);

  void _add(AuditEntry entry) {
    state = [entry, ...state.take(499)]; // cap at 500 entries
  }

  void clear() => state = [];
}

// ─── Snapshots ────────────────────────────────────────────────────────────────

final snapshotsProvider =
    StateNotifierProvider<SnapshotsNotifier, List<ProjectSnapshot>>(
        (_) => SnapshotsNotifier());

class SnapshotsNotifier extends StateNotifier<List<ProjectSnapshot>> {
  SnapshotsNotifier() : super([]);

  void save(ProjectSnapshot snap) {
    state = [snap, ...state];
  }

  void delete(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

// ─── Custom Field Definitions ─────────────────────────────────────────────────

final customFieldDefsProvider =
    StateNotifierProvider<CustomFieldDefsNotifier, List<CustomFieldDef>>(
        (_) => CustomFieldDefsNotifier());

class CustomFieldDefsNotifier extends StateNotifier<List<CustomFieldDef>> {
  CustomFieldDefsNotifier() : super(_defaults);

  static final _defaults = <CustomFieldDef>[
    const CustomFieldDef(
        id: 'cf_budget',
        name: 'Budget (\$)',
        type: CustomFieldType.number,
        showInSidebar: true,
        sidebarWidth: 90),
    const CustomFieldDef(
        id: 'cf_phase',
        name: 'Phase',
        type: CustomFieldType.select,
        options: ['Alpha', 'Beta', 'RC', 'GA'],
        showInSidebar: true,
        sidebarWidth: 80),
    const CustomFieldDef(
        id: 'cf_approved',
        name: 'Approved',
        type: CustomFieldType.boolean,
        showInSidebar: true,
        sidebarWidth: 70),
  ];

  void add(CustomFieldDef def) => state = [...state, def];
  void update(CustomFieldDef def) =>
      state = state.map((d) => d.id == def.id ? def : d).toList();
  void remove(String id) => state = state.where((d) => d.id != id).toList();
  void toggleSidebar(String id) => state = state
      .map((d) => d.id == id ? d.copyWith(showInSidebar: !d.showInSidebar) : d)
      .toList();
}

// ─── View settings ────────────────────────────────────────────────────────────

final viewSettingsProvider =
    StateProvider<GanttViewSettings>((ref) => const GanttViewSettings());
final filterProvider = StateProvider<GanttFilter>((ref) => const GanttFilter());
final selectedTaskIdProvider = StateProvider<String?>((ref) => null);
final hoveredTaskIdProvider = StateProvider<String?>((ref) => null);
final draggingTaskIdProvider = StateProvider<String?>((ref) => null);
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
final analyticsOpenProvider = StateProvider<bool>((ref) => false);
final auditPanelOpenProvider = StateProvider<bool>((ref) => false);
final snapshotPanelOpenProvider = StateProvider<bool>((ref) => false);
final searchFocusRequestProvider = StateProvider<int>((ref) => 0);
final addTaskDialogRequestProvider = StateProvider<int>((ref) => 0);
final scrollToTodayProvider = StateProvider<int>((ref) => 0);

// ─── Derived providers ────────────────────────────────────────────────────────

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

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(filterProvider);
  if (!filter.isActive) return tasks;
  return tasks.where((t) {
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      if (!t.title.toLowerCase().contains(q) &&
          !(t.description?.toLowerCase().contains(q) ?? false)) return false;
    }
    if (filter.statuses.isNotEmpty && !filter.statuses.contains(t.status))
      return false;
    if (filter.priorities.isNotEmpty && !filter.priorities.contains(t.priority))
      return false;
    if (filter.assigneeId != null &&
        !t.assignees.any((a) => a.id == filter.assigneeId)) return false;
    if (filter.riskLevels.isNotEmpty &&
        !filter.riskLevels.contains(t.riskLevel)) return false;
    if (filter.labels.isNotEmpty &&
        !filter.labels.any((l) => t.labels.contains(l))) return false;
    return true;
  }).toList();
});

/// Visible tasks — respects hierarchy expansion AND swimlane grouping.
/// When swimlaneGroupBy != none, injects virtual "group header" sentinels.
final visibleTasksProvider = Provider<List<Task>>((ref) {
  final filtered = ref.watch(filteredTasksProvider);
  final settings = ref.watch(viewSettingsProvider);
  if (filtered.isEmpty) return filtered;

  final taskMap = {for (final t in filtered) t.id: t};
  final result = <Task>[];
  final visited = <String>{};

  void visit(Task t) {
    if (visited.contains(t.id)) return;
    visited.add(t.id);
    result.add(t);
    if (t.isExpanded) {
      for (final child in filtered.where((c) => c.parentId == t.id))
        visit(child);
    }
  }

  if (settings.swimlaneGroupBy == SwimlanGroupBy.none) {
    for (final root in filtered
        .where((t) => t.parentId == null || !taskMap.containsKey(t.parentId))) {
      visit(root);
    }
    return result;
  }

  // Grouped mode: partition by group key, emit sentinel + rows
  final groups = <String, List<Task>>{};
  for (final t in filtered
      .where((t) => t.parentId == null || !taskMap.containsKey(t.parentId))) {
    final key = _swimlaneKey(t, settings.swimlaneGroupBy);
    groups.putIfAbsent(key, () => []).add(t);
  }

  final groupedResult = <Task>[];
  for (final entry in groups.entries) {
    // Sentinel task: isMilestone=false, very short, special label, no deps
    groupedResult.add(Task(
      id: '__group_${entry.key}',
      title: entry.key,
      startDate: DateTime(2000),
      endDate: DateTime(2000),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      customFields: {'__isGroupHeader': true},
    ));
    for (final t in entry.value) visit(t);
    groupedResult.addAll(result);
    result.clear();
    visited.clear();
  }
  return groupedResult;
});

String _swimlaneKey(Task t, SwimlanGroupBy by) => switch (by) {
      SwimlanGroupBy.none => '',
      SwimlanGroupBy.assignee =>
        t.assignees.isNotEmpty ? t.assignees.first.name : 'Unassigned',
      SwimlanGroupBy.status => t.status.label,
      SwimlanGroupBy.priority => t.priority.label,
      SwimlanGroupBy.label => t.labels.isNotEmpty ? t.labels.first : 'No Label',
    };

final projectDateRangeProvider = Provider<(DateTime, DateTime)>((ref) {
  final tasks =
      ref.watch(tasksProvider).where((t) => !_isGroupHeader(t)).toList();
  if (tasks.isEmpty) {
    final now = DateTime.now();
    return (now, now.add(const Duration(days: 30)));
  }
  final starts = tasks.map((t) => t.startDate).toList()..sort();
  final ends = tasks.map((t) => t.endDate).toList()..sort();
  const buffer = Duration(days: 7);
  return (starts.first.subtract(buffer), ends.last.add(buffer));
});

final criticalPathIdsProvider = Provider<Set<String>>((ref) {
  final settings = ref.watch(viewSettingsProvider);
  if (!settings.showCriticalPath) return {};
  final tasks =
      ref.watch(tasksProvider).where((t) => !_isGroupHeader(t)).toList();
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

final resourceLoadProvider =
    Provider<Map<DateTime, Map<String, double>>>((ref) {
  final tasks =
      ref.watch(tasksProvider).where((t) => !_isGroupHeader(t)).toList();
  final result = <DateTime, Map<String, double>>{};
  for (final task in tasks) {
    if (task.assignees.isEmpty) continue;
    final days = GanttDateUtils.daysBetween(task.startDate, task.endDate) + 1;
    if (days <= 0) continue;
    final hoursPerDayPerAssignee = task.estimatedHours > 0
        ? (task.estimatedHours / days) / task.assignees.length
        : 8.0 / task.assignees.length;
    for (int d = 0; d < days; d++) {
      final day =
          GanttDateUtils.dateOnly(task.startDate.add(Duration(days: d)));
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
    final task =
        tasks.firstWhere((t) => t.id == currentId, orElse: () => tasks.first);
    if (task.parentId == null) break;
    depth++;
    currentId = task.parentId;
  }
  return depth;
});

bool _isGroupHeader(Task t) => t.customFields['__isGroupHeader'] == true;

// ─── Multi-select ─────────────────────────────────────────────────────────────
final multiSelectProvider = StateProvider<Set<String>>((ref) => const {});

/// Used by sidebar to signal a row reorder drag
final rowReorderProvider = StateProvider<(String, String)?>((_) => null);

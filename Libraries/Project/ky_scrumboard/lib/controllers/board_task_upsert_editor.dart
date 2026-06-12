import '../models/scrum_activity.dart';
import '../models/scrum_task.dart';
import '../models/scrum_task_priority.dart';
import '../models/scrum_task_status.dart';
import 'board_activity_query.dart';
import 'board_task_order_editor.dart';

/// Applies task create and update mutations to a mutable board task list.
class BoardTaskUpsertEditor {
  const BoardTaskUpsertEditor({
    required List<ScrumTask> tasks,
    required BoardTaskOrderEditor orderEditor,
  }) : _tasks = tasks,
       _orderEditor = orderEditor;

  final List<ScrumTask> _tasks;
  final BoardTaskOrderEditor _orderEditor;

  /// Adds a new task or updates an existing task with the same id.
  BoardTaskUpsertApplication addOrUpdate(ScrumTask task) {
    final existingIndex = _tasks.indexWhere((item) => item.id == task.id);
    if (existingIndex >= 0) return _updateExisting(existingIndex, task);

    final orderedTask = _orderEditor.orderedForAppend(task, task.status);
    _tasks.add(orderedTask);

    return BoardTaskUpsertApplication(
      applied: true,
      created: true,
      changedTasks: [orderedTask],
      updatedTask: orderedTask,
      activityType: ScrumActivityType.taskCreated,
      toStatus: orderedTask.status,
    );
  }

  /// Updates an existing task and reports whether the task was found.
  BoardTaskUpsertApplication update(ScrumTask task) {
    final existingIndex = _tasks.indexWhere((item) => item.id == task.id);
    if (existingIndex < 0) return const BoardTaskUpsertApplication();
    return _updateExisting(existingIndex, task);
  }

  BoardTaskUpsertApplication _updateExisting(int index, ScrumTask task) {
    final previousTask = _tasks[index];
    _tasks[index] = _orderEditor.orderedForUpsert(task, previousTask);
    final updatedTask = _tasks[index];
    final changedTasks = <ScrumTask>[updatedTask];

    changedTasks.addAll(_orderEditor.normalizeStatus(previousTask.status));
    final statusChanged = previousTask.status != updatedTask.status;
    if (statusChanged) {
      changedTasks.addAll(_orderEditor.normalizeStatus(updatedTask.status));
    }

    final priorityChanged = previousTask.priority != updatedTask.priority;
    return BoardTaskUpsertApplication(
      applied: true,
      changedTasks: changedTasks,
      previousTask: previousTask,
      updatedTask: updatedTask,
      activityType: activityTypeForTaskUpdate(previousTask, updatedTask),
      fromStatus: statusChanged ? previousTask.status : null,
      toStatus: statusChanged ? updatedTask.status : null,
      fromPriority: priorityChanged ? previousTask.priority : null,
      toPriority: priorityChanged ? updatedTask.priority : null,
    );
  }
}

/// Result of applying a task create or update to mutable board state.
class BoardTaskUpsertApplication {
  const BoardTaskUpsertApplication({
    this.applied = false,
    this.created = false,
    this.changedTasks = const [],
    this.previousTask,
    this.updatedTask,
    this.activityType,
    this.fromStatus,
    this.toStatus,
    this.fromPriority,
    this.toPriority,
  });

  /// Whether the requested mutation found or created a target task.
  final bool applied;

  /// Whether the mutation created a new task rather than updating one.
  final bool created;

  /// Tasks whose persisted state should be written after the mutation.
  final List<ScrumTask> changedTasks;

  /// The task before update, when this was an update mutation.
  final ScrumTask? previousTask;

  /// The task after create or update.
  final ScrumTask? updatedTask;

  /// Activity type that should be recorded for this mutation.
  final ScrumActivityType? activityType;

  /// Previous status for activity metadata.
  final ScrumTaskStatus? fromStatus;

  /// New status for activity metadata.
  final ScrumTaskStatus? toStatus;

  /// Previous priority for activity metadata.
  final ScrumTaskPriority? fromPriority;

  /// New priority for activity metadata.
  final ScrumTaskPriority? toPriority;
}

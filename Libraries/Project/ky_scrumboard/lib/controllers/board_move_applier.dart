import '../models/scrum_activity.dart';
import '../models/scrum_board_config.dart';
import '../models/scrum_task.dart';
import '../models/scrum_task_move_result.dart';
import '../models/scrum_task_status.dart';
import 'board_task_order_editor.dart';
import 'task_ordering.dart';

/// Applies accepted task moves to board state and prepares activity metadata.
class BoardMoveApplier {
  const BoardMoveApplier({
    required List<ScrumTask> tasks,
    required this.config,
    required BoardTaskOrderEditor orderEditor,
  }) : _tasks = tasks,
       _orderEditor = orderEditor;

  final List<ScrumTask> _tasks;
  final ScrumBoardConfig config;
  final BoardTaskOrderEditor _orderEditor;

  /// Applies a validated move result to the mutable task list.
  BoardMoveApplication apply(
    ScrumTaskMoveResult validation, {
    String? beforeTaskId,
  }) {
    if (!validation.accepted || !validation.changed) {
      return BoardMoveApplication(result: validation);
    }

    final movingTask = taskById(validation.taskId);
    if (movingTask == null) {
      return BoardMoveApplication(
        result: ScrumTaskMoveResult.blocked(
          taskId: validation.taskId,
          toStatus: validation.toStatus,
          reason: ScrumTaskMoveBlockReason.taskNotFound,
          message: 'Task could not be found.',
        ),
      );
    }

    final targetStatus = validation.toStatus;
    final previousStatus = movingTask.status;
    final columnTasks = _orderEditor
        .tasksForStatus(targetStatus)
        .where((task) => task.id != validation.taskId)
        .toList(growable: true);
    final insertionIndex = insertionIndexFor(columnTasks, beforeTaskId);
    columnTasks.insert(
      insertionIndex,
      movingTask.copyWith(status: targetStatus),
    );

    final changedTasks = <ScrumTask>[];
    changedTasks.addAll(
      _orderEditor.applyOrderedColumn(targetStatus, columnTasks),
    );
    if (previousStatus != targetStatus) {
      changedTasks.addAll(_orderEditor.normalizeStatus(previousStatus));
    }

    if (changedTasks.isEmpty) {
      return BoardMoveApplication(
        result: ScrumTaskMoveResult.unchanged(
          taskId: validation.taskId,
          status: targetStatus,
        ),
      );
    }

    final updatedTask =
        taskById(validation.taskId) ??
        movingTask.copyWith(status: targetStatus);
    return BoardMoveApplication(
      result: validation,
      changedTasks: changedTasks,
      previousTask: movingTask,
      updatedTask: updatedTask,
      activityType: previousStatus == targetStatus
          ? ScrumActivityType.taskReordered
          : ScrumActivityType.taskMoved,
      note: placementNote(targetStatus, beforeTaskId: beforeTaskId),
    );
  }

  /// Finds a task by id in the backing task list.
  ScrumTask? taskById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  /// Builds human-readable placement context for activity history.
  String placementNote(ScrumTaskStatus status, {String? beforeTaskId}) {
    if (beforeTaskId == null) {
      return 'Placed at the end of ${config.labelFor(status)}.';
    }

    return "Placed before ${taskById(beforeTaskId)?.title ?? 'another task'}.";
  }
}

/// Result of applying a validated board move to mutable task state.
class BoardMoveApplication {
  const BoardMoveApplication({
    required this.result,
    this.changedTasks = const [],
    this.previousTask,
    this.updatedTask,
    this.activityType,
    this.note,
  });

  /// The final move result after applying state changes.
  final ScrumTaskMoveResult result;

  /// Tasks whose lane order or status changed during move application.
  final List<ScrumTask> changedTasks;

  /// The task before move application.
  final ScrumTask? previousTask;

  /// The task after move application.
  final ScrumTask? updatedTask;

  /// Activity type that should be recorded for this application.
  final ScrumActivityType? activityType;

  /// Optional human-readable placement note for activity history.
  final String? note;
}

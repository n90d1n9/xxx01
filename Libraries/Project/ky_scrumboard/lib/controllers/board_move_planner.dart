import '../models/scrum_board_config.dart';
import '../models/scrum_task.dart';
import '../models/scrum_task_move_preview.dart';
import '../models/scrum_task_move_result.dart';
import '../models/scrum_task_status.dart';
import '../models/scrum_workflow_policy.dart';
import 'board_task_batch.dart';

/// Read-only planner for validating task moves against board workflow policy.
class BoardMovePlanner {
  const BoardMovePlanner({required List<ScrumTask> tasks, required this.config})
    : _tasks = tasks;

  final List<ScrumTask> _tasks;
  final ScrumBoardConfig config;

  ScrumWorkflowPolicy get _policy => config.policy;

  /// Previews a batch move while projecting WIP capacity after each accepted task.
  ScrumTaskMovePreview previewTaskMoves(
    Iterable<String> ids,
    ScrumTaskStatus status,
  ) {
    final projectedCounts = {
      for (final status in ScrumTaskStatus.values) status: countFor(status),
    };
    final results = <ScrumTaskMoveResult>[];

    for (final id in BoardTaskBatch(ids).uniqueIds) {
      final task = taskById(id);
      if (task == null) {
        results.add(
          ScrumTaskMoveResult.blocked(
            taskId: id,
            toStatus: status,
            reason: ScrumTaskMoveBlockReason.taskNotFound,
            message: 'Task could not be found.',
          ),
        );
        continue;
      }

      if (task.status == status) {
        results.add(ScrumTaskMoveResult.unchanged(taskId: id, status: status));
        continue;
      }

      final currentTargetCount = projectedCounts[status] ?? countFor(status);
      final targetCount = _policy.projectedCountFor(status, currentTargetCount);
      final targetLimit = _policy.limitFor(status);
      final blocked =
          _policy.enforceWipLimits &&
          _policy.wouldExceedLimit(status, currentTargetCount);

      if (blocked) {
        results.add(
          ScrumTaskMoveResult.blocked(
            taskId: id,
            fromStatus: task.status,
            toStatus: status,
            reason: ScrumTaskMoveBlockReason.wipLimit,
            targetCount: targetCount,
            targetLimit: targetLimit,
            message: _wipLimitMessage(status, targetLimit),
          ),
        );
        continue;
      }

      results.add(
        ScrumTaskMoveResult.moved(
          taskId: id,
          fromStatus: task.status,
          toStatus: status,
          targetCount: targetCount,
          targetLimit: targetLimit,
        ),
      );
      projectedCounts[status] = targetCount;
      projectedCounts[task.status] = (projectedCounts[task.status] ?? 0) - 1;
    }

    return ScrumTaskMovePreview(toStatus: status, results: results);
  }

  /// Validates one task move against current WIP limits and task existence.
  ScrumTaskMoveResult validateTaskMove(
    String id,
    ScrumTaskStatus status, {
    String? beforeTaskId,
  }) {
    final movingTask = taskById(id);
    if (movingTask == null) {
      return ScrumTaskMoveResult.blocked(
        taskId: id,
        toStatus: status,
        reason: ScrumTaskMoveBlockReason.taskNotFound,
        message: 'Task could not be found.',
      );
    }

    if (movingTask.status == status && beforeTaskId == id) {
      return ScrumTaskMoveResult.unchanged(taskId: id, status: status);
    }

    final movingWithinStatus = movingTask.status == status;
    final statusCount = countFor(status);
    final targetCount = _policy.projectedCountFor(
      status,
      statusCount,
      movingWithinStatus: movingWithinStatus,
    );
    final targetLimit = _policy.limitFor(status);

    if (_policy.enforceWipLimits &&
        _policy.wouldExceedLimit(
          status,
          statusCount,
          movingWithinStatus: movingWithinStatus,
        )) {
      return ScrumTaskMoveResult.blocked(
        taskId: id,
        fromStatus: movingTask.status,
        toStatus: status,
        reason: ScrumTaskMoveBlockReason.wipLimit,
        targetCount: targetCount,
        targetLimit: targetLimit,
        message: _wipLimitMessage(status, targetLimit),
      );
    }

    return ScrumTaskMoveResult.moved(
      taskId: id,
      fromStatus: movingTask.status,
      toStatus: status,
      targetCount: targetCount,
      targetLimit: targetLimit,
    );
  }

  /// Finds a task by id in the planner snapshot.
  ScrumTask? taskById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  /// Counts tasks in a lane in the planner snapshot.
  int countFor(ScrumTaskStatus status) {
    return _tasks.where((task) => task.status == status).length;
  }

  String _wipLimitMessage(ScrumTaskStatus status, int? targetLimit) {
    return '${config.labelFor(status)} is at its WIP limit'
        '${targetLimit == null ? '.' : ' of $targetLimit tasks.'}';
  }
}

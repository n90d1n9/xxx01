import 'package:flutter/foundation.dart';

import 'scrum_task_status.dart';

enum ScrumTaskMoveBlockReason { taskNotFound, wipLimit }

@immutable
class ScrumTaskMoveResult {
  const ScrumTaskMoveResult({
    required this.taskId,
    required this.toStatus,
    required this.accepted,
    required this.changed,
    required this.message,
    this.fromStatus,
    this.blockReason,
    this.targetCount,
    this.targetLimit,
  });

  factory ScrumTaskMoveResult.moved({
    required String taskId,
    required ScrumTaskStatus fromStatus,
    required ScrumTaskStatus toStatus,
    required int targetCount,
    int? targetLimit,
  }) {
    return ScrumTaskMoveResult(
      taskId: taskId,
      fromStatus: fromStatus,
      toStatus: toStatus,
      accepted: true,
      changed: true,
      targetCount: targetCount,
      targetLimit: targetLimit,
      message: 'Task moved.',
    );
  }

  factory ScrumTaskMoveResult.unchanged({
    required String taskId,
    required ScrumTaskStatus status,
  }) {
    return ScrumTaskMoveResult(
      taskId: taskId,
      fromStatus: status,
      toStatus: status,
      accepted: true,
      changed: false,
      message: 'Task already matches this placement.',
    );
  }

  factory ScrumTaskMoveResult.blocked({
    required String taskId,
    required ScrumTaskStatus toStatus,
    required ScrumTaskMoveBlockReason reason,
    required String message,
    ScrumTaskStatus? fromStatus,
    int? targetCount,
    int? targetLimit,
  }) {
    return ScrumTaskMoveResult(
      taskId: taskId,
      fromStatus: fromStatus,
      toStatus: toStatus,
      accepted: false,
      changed: false,
      blockReason: reason,
      targetCount: targetCount,
      targetLimit: targetLimit,
      message: message,
    );
  }

  final String taskId;
  final ScrumTaskStatus? fromStatus;
  final ScrumTaskStatus toStatus;
  final bool accepted;
  final bool changed;
  final ScrumTaskMoveBlockReason? blockReason;
  final int? targetCount;
  final int? targetLimit;
  final String message;
}

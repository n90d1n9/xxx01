import 'package:flutter/foundation.dart';

import 'scrum_task_priority.dart';
import 'scrum_task_status.dart';

enum ScrumActivityType {
  taskCreated,
  taskUpdated,
  taskMoved,
  taskReordered,
  taskPriorityChanged,
  taskCommented,
  taskDeleted,
  boardReplaced,
}

@immutable
class ScrumActivity {
  const ScrumActivity({
    required this.id,
    required this.type,
    required this.createdAt,
    this.taskId,
    this.taskTitle,
    this.fromStatus,
    this.toStatus,
    this.fromPriority,
    this.toPriority,
    this.actor,
    this.note,
  });

  final String id;
  final ScrumActivityType type;
  final DateTime createdAt;
  final String? taskId;
  final String? taskTitle;
  final ScrumTaskStatus? fromStatus;
  final ScrumTaskStatus? toStatus;
  final ScrumTaskPriority? fromPriority;
  final ScrumTaskPriority? toPriority;
  final String? actor;
  final String? note;

  bool get isTaskScoped => taskId != null;

  bool get hasStatusChange => fromStatus != null || toStatus != null;

  bool get hasPriorityChange => fromPriority != null || toPriority != null;

  ScrumActivity copyWith({
    String? id,
    ScrumActivityType? type,
    DateTime? createdAt,
    String? taskId,
    String? taskTitle,
    ScrumTaskStatus? fromStatus,
    ScrumTaskStatus? toStatus,
    ScrumTaskPriority? fromPriority,
    ScrumTaskPriority? toPriority,
    String? actor,
    String? note,
  }) {
    return ScrumActivity(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      fromStatus: fromStatus ?? this.fromStatus,
      toStatus: toStatus ?? this.toStatus,
      fromPriority: fromPriority ?? this.fromPriority,
      toPriority: toPriority ?? this.toPriority,
      actor: actor ?? this.actor,
      note: note ?? this.note,
    );
  }
}

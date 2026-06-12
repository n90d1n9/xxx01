import '../models/scrum_activity.dart';
import '../models/scrum_task.dart';
import '../models/scrum_task_priority.dart';
import '../models/scrum_task_status.dart';

/// Records board activity entries with stable ids, actor, and task metadata.
class BoardActivityRecorder {
  BoardActivityRecorder({
    required List<ScrumActivity> activities,
    required DateTime Function() clock,
    this.actor,
  }) : _activities = activities,
       _clock = clock;

  final List<ScrumActivity> _activities;
  final DateTime Function() _clock;
  final String? actor;
  int _sequence = 0;

  /// Adds a new activity to the front of the activity timeline.
  ScrumActivity record(
    ScrumActivityType type, {
    ScrumTask? task,
    ScrumTask? previousTask,
    ScrumTaskStatus? fromStatus,
    ScrumTaskStatus? toStatus,
    ScrumTaskPriority? fromPriority,
    ScrumTaskPriority? toPriority,
    String? note,
  }) {
    final timestamp = _clock();
    final activity = ScrumActivity(
      id: 'activity-${timestamp.microsecondsSinceEpoch}-${_sequence++}',
      type: type,
      createdAt: timestamp,
      taskId: task?.id ?? previousTask?.id,
      taskTitle: task?.title ?? previousTask?.title,
      fromStatus: fromStatus,
      toStatus: toStatus,
      fromPriority: fromPriority,
      toPriority: toPriority,
      actor: actor,
      note: note,
    );

    _activities.insert(0, activity);
    return activity;
  }
}

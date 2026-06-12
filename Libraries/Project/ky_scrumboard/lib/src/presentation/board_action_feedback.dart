import '../../models/scrum_task_move_result.dart';
import '../../models/scrum_task_priority.dart';

/// Formats user-facing feedback for board actions and bulk workflows.
class BoardActionFeedback {
  const BoardActionFeedback();

  /// Message shown after deleting one or more tasks.
  String deletedTasks(int count) {
    if (count == 1) return '1 task deleted.';
    return '$count tasks deleted.';
  }

  /// Message shown after restoring one or more tasks.
  String restoredTasks(int count) {
    if (count == 1) return '1 task restored.';
    return '$count tasks restored.';
  }

  /// Message shown after moving tasks to a status.
  String movedTasks(int count, String statusLabel) {
    if (count == 1) return '1 task moved to $statusLabel.';
    return '$count tasks moved to $statusLabel.';
  }

  /// Message shown when one or more selected tasks were blocked from moving.
  String blockedMoveResults(Iterable<ScrumTaskMoveResult> results) {
    final blockedResults = results
        .where((result) => !result.accepted)
        .toList(growable: false);
    if (blockedResults.isEmpty) return '';

    final taskWord = blockedResults.length == 1 ? 'task' : 'tasks';
    return '${blockedResults.length} selected $taskWord could not move. '
        '${blockedResults.first.message}';
  }

  /// Message shown after changing a task priority.
  String priorityChanged(ScrumTaskPriority priority) {
    return 'Task priority changed to ${priority.label}.';
  }

  /// Message shown after adding a note to a task.
  String taskNoteAdded() {
    return 'Task note added.';
  }
}

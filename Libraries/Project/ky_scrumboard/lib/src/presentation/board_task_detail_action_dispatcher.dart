import 'dart:async';

import '../../models/scrum_task.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../widgets/scrum_task_detail_dialog.dart';

/// Routes task detail panel results to the board action handlers.
class BoardTaskDetailActionDispatcher {
  const BoardTaskDetailActionDispatcher({
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
    required this.onPriorityChanged,
    required this.onNoteAdded,
  });

  /// Called when the user asks to edit a task.
  final FutureOr<void> Function(ScrumTask task) onEdit;

  /// Called when the user asks to delete a task.
  final FutureOr<void> Function(ScrumTask task) onDelete;

  /// Called when the user asks to move a task to another status.
  final FutureOr<void> Function(ScrumTask task, ScrumTaskStatus status) onMove;

  /// Called when the user changes task priority.
  final FutureOr<void> Function(ScrumTask task, ScrumTaskPriority priority)
  onPriorityChanged;

  /// Called when the user adds a task note.
  final FutureOr<void> Function(ScrumTask task, String note) onNoteAdded;

  /// Dispatches a nullable task detail result to the matching board action.
  Future<void> dispatch(ScrumTask task, ScrumTaskDetailResult? result) async {
    if (result == null) return;

    switch (result.action) {
      case ScrumTaskDetailAction.edit:
        await onEdit(task);
        break;
      case ScrumTaskDetailAction.delete:
        await onDelete(task);
        break;
      case ScrumTaskDetailAction.move:
        final status = result.status;
        if (status != null) await onMove(task, status);
        break;
      case ScrumTaskDetailAction.priority:
        final priority = result.priority;
        if (priority != null) await onPriorityChanged(task, priority);
        break;
      case ScrumTaskDetailAction.note:
        final note = result.note;
        if (note != null) await onNoteAdded(task, note);
        break;
    }
  }
}

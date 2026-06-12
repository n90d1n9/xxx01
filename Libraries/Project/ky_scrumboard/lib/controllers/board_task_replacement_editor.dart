import '../models/scrum_activity.dart';
import '../models/scrum_task.dart';
import 'task_ordering.dart';

/// Replaces board tasks and prepares the activity context for board imports.
class BoardTaskReplacementEditor {
  const BoardTaskReplacementEditor({required List<ScrumTask> tasks})
    : _tasks = tasks;

  final List<ScrumTask> _tasks;

  /// Replaces the mutable board task list with normalized task ordering.
  BoardTaskReplacementApplication replace(Iterable<ScrumTask> tasks) {
    _tasks
      ..clear()
      ..addAll(normalizedTaskList(List<ScrumTask>.of(tasks)));

    return BoardTaskReplacementApplication(
      replacedTasks: List<ScrumTask>.unmodifiable(_tasks),
      note: '${_tasks.length} tasks loaded into the board.',
    );
  }
}

/// Result of applying a full board task replacement.
class BoardTaskReplacementApplication {
  const BoardTaskReplacementApplication({
    required this.replacedTasks,
    this.activityType = ScrumActivityType.boardReplaced,
    this.note = '',
  });

  /// Tasks that should be persisted after replacement.
  final List<ScrumTask> replacedTasks;

  /// Activity type to record for the replacement.
  final ScrumActivityType activityType;

  /// Human-readable activity note for the replacement.
  final String note;

  /// Number of tasks now present on the board.
  int get taskCount => replacedTasks.length;
}

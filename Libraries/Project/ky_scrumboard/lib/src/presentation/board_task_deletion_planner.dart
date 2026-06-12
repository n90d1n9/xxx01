import '../../models/scrum_task.dart';

/// Looks up a board task by id.
typedef BoardTaskLookup = ScrumTask? Function(String id);

/// Prepares task sets for delete confirmation and undo restore flows.
class BoardTaskDeletionPlanner {
  const BoardTaskDeletionPlanner({required this.taskById});

  /// Lookup used to compare captured tasks with current board state.
  final BoardTaskLookup taskById;

  /// Builds a confirmation plan from selected task ids that still exist.
  BoardTaskDeletionPlan planSelectedTasks(Iterable<String> taskIds) {
    final selectedTasks = <ScrumTask>[];
    for (final id in taskIds) {
      final task = taskById(id);
      if (task != null) selectedTasks.add(task);
    }

    return BoardTaskDeletionPlan(
      selectedTasks: List<ScrumTask>.unmodifiable(selectedTasks),
    );
  }

  /// Returns captured tasks that are currently missing and can be restored.
  List<ScrumTask> restorableTasks(Iterable<ScrumTask> tasks) {
    return [
      for (final task in tasks)
        if (taskById(task.id) == null) task,
    ];
  }
}

/// Delete confirmation state for selected board tasks.
class BoardTaskDeletionPlan {
  const BoardTaskDeletionPlan({this.selectedTasks = const []});

  /// Selected tasks that still exist on the board.
  final List<ScrumTask> selectedTasks;

  /// Whether the delete confirmation dialog should be shown.
  bool get canConfirm => selectedTasks.isNotEmpty;

  /// Number of selected tasks that can be deleted.
  int get taskCount => selectedTasks.length;
}

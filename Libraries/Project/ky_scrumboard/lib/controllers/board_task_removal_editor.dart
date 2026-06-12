import '../models/scrum_task.dart';
import '../models/scrum_task_status.dart';
import 'board_task_batch.dart';
import 'board_task_order_editor.dart';

/// Applies task deletion and restoration mutations to a board task list.
class BoardTaskRemovalEditor {
  const BoardTaskRemovalEditor({
    required List<ScrumTask> tasks,
    required BoardTaskOrderEditor orderEditor,
  }) : _tasks = tasks,
       _orderEditor = orderEditor;

  final List<ScrumTask> _tasks;
  final BoardTaskOrderEditor _orderEditor;

  /// Removes a task by id and returns the removed task context.
  BoardTaskDeleteApplication delete(String id) {
    final existingIndex = _tasks.indexWhere((task) => task.id == id);
    if (existingIndex < 0) return const BoardTaskDeleteApplication();

    return BoardTaskDeleteApplication(
      applied: true,
      removedTask: _tasks.removeAt(existingIndex),
    );
  }

  /// Restores missing tasks and normalizes affected lanes.
  BoardTaskRestoreApplication restore(Iterable<ScrumTask> tasks) {
    final restoredTasks = <ScrumTask>[];
    final affectedStatuses = <ScrumTaskStatus>{};

    for (final task in uniqueTasksById(tasks)) {
      if (_taskById(task.id) != null) continue;
      _tasks.add(task);
      restoredTasks.add(task);
      affectedStatuses.add(task.status);
    }

    if (restoredTasks.isEmpty) return const BoardTaskRestoreApplication();

    final changedTasks = <ScrumTask>[...restoredTasks];
    for (final status in affectedStatuses) {
      changedTasks.addAll(_orderEditor.normalizeStatus(status));
    }

    return BoardTaskRestoreApplication(
      applied: true,
      restoredTasks: restoredTasks,
      changedTasks: changedTasks,
    );
  }

  ScrumTask? _taskById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }
}

/// Result of applying a single task deletion.
class BoardTaskDeleteApplication {
  const BoardTaskDeleteApplication({this.applied = false, this.removedTask});

  /// Whether a task was found and removed.
  final bool applied;

  /// The task removed from the board.
  final ScrumTask? removedTask;
}

/// Result of applying one or more task restorations.
class BoardTaskRestoreApplication {
  const BoardTaskRestoreApplication({
    this.applied = false,
    this.restoredTasks = const [],
    this.changedTasks = const [],
  });

  /// Whether any tasks were restored.
  final bool applied;

  /// Restored tasks before any lane-order normalization.
  final List<ScrumTask> restoredTasks;

  /// Tasks whose persisted state should be written after restoration.
  final List<ScrumTask> changedTasks;

  /// Number of tasks restored.
  int get restoredCount => restoredTasks.length;
}

import '../models/scrum_task.dart';
import '../models/scrum_task_priority.dart';
import 'board_task_batch.dart';
import 'board_task_upsert_editor.dart';

/// Applies bulk task mutations while preserving per-task activity context.
class BoardTaskBulkEditor {
  const BoardTaskBulkEditor({
    required List<ScrumTask> tasks,
    required BoardTaskUpsertEditor upsertEditor,
  }) : _tasks = tasks,
       _upsertEditor = upsertEditor;

  final List<ScrumTask> _tasks;
  final BoardTaskUpsertEditor _upsertEditor;

  /// Updates selected tasks to the given priority as one batch.
  BoardTaskBulkPriorityApplication updatePriorities(
    Iterable<String> ids,
    ScrumTaskPriority priority,
  ) {
    final applications = <BoardTaskUpsertApplication>[];

    for (final id in BoardTaskBatch(ids).uniqueIds) {
      final task = _taskById(id);
      if (task == null || task.priority == priority) continue;

      final application = _upsertEditor.update(
        task.copyWith(priority: priority),
      );
      if (application.applied) applications.add(application);
    }

    return BoardTaskBulkPriorityApplication(applications: applications);
  }

  ScrumTask? _taskById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }
}

/// Result of applying a bulk task priority update.
class BoardTaskBulkPriorityApplication {
  const BoardTaskBulkPriorityApplication({this.applications = const []});

  /// Per-task update applications created by the bulk update.
  final List<BoardTaskUpsertApplication> applications;

  /// Whether any task priority changed.
  bool get applied => applications.isNotEmpty;

  /// Number of tasks updated by the batch.
  int get updatedCount => applications.length;

  /// Tasks whose persisted state should be written after the batch.
  List<ScrumTask> get changedTasks {
    return [
      for (final application in applications) ...application.changedTasks,
    ];
  }
}

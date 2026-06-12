import '../models/scrum_activity.dart';
import '../models/scrum_task.dart';

/// Prepares task note commands and the activity context they should record.
class BoardTaskNoteEditor {
  const BoardTaskNoteEditor({required List<ScrumTask> tasks}) : _tasks = tasks;

  final List<ScrumTask> _tasks;

  /// Validates a note for a task and returns the comment activity metadata.
  BoardTaskNoteApplication addNote(String id, String note) {
    final task = _taskById(id);
    final trimmedNote = note.trim();
    if (task == null || trimmedNote.isEmpty) {
      return const BoardTaskNoteApplication();
    }

    return BoardTaskNoteApplication(
      applied: true,
      task: task,
      note: trimmedNote,
      activityType: ScrumActivityType.taskCommented,
    );
  }

  ScrumTask? _taskById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }
}

/// Result of preparing a task note activity.
class BoardTaskNoteApplication {
  const BoardTaskNoteApplication({
    this.applied = false,
    this.task,
    this.note = '',
    this.activityType,
  });

  /// Whether the note references an existing task and has usable content.
  final bool applied;

  /// Task that should receive the note activity.
  final ScrumTask? task;

  /// Trimmed note text to store in the activity feed.
  final String note;

  /// Activity type to record for the note command.
  final ScrumActivityType? activityType;
}

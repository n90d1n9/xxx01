import '../models/task_model.dart';

// ─── Command interface ────────────────────────────────────────────────────────

abstract class GanttCommand {
  const GanttCommand();

  /// Apply this command to the given task list and return the new state.
  List<Task> apply(List<Task> tasks);

  /// Return the inverse command (for undo).
  GanttCommand inverse(List<Task> stateBefore);

  String get description;
}

// ─── Concrete commands ────────────────────────────────────────────────────────

class AddTaskCommand extends GanttCommand {
  final Task task;
  const AddTaskCommand(this.task);

  @override
  List<Task> apply(List<Task> tasks) => [...tasks, task];

  @override
  GanttCommand inverse(List<Task> _) => DeleteTaskCommand(task.id);

  @override
  String get description => 'Add "${task.title}"';
}

class DeleteTaskCommand extends GanttCommand {
  final String taskId;
  const DeleteTaskCommand(this.taskId);

  @override
  List<Task> apply(List<Task> tasks) => tasks.where((t) => t.id != taskId && t.parentId != taskId).toList();

  @override
  GanttCommand inverse(List<Task> before) {
    final task = before.firstWhere((t) => t.id == taskId, orElse: () => before.first);
    return AddTaskCommand(task);
  }

  @override
  String get description => 'Delete task';
}

class UpdateTaskCommand extends GanttCommand {
  final Task newTask;
  const UpdateTaskCommand(this.newTask);

  @override
  List<Task> apply(List<Task> tasks) => tasks.map((t) => t.id == newTask.id ? newTask : t).toList();

  @override
  GanttCommand inverse(List<Task> before) {
    final old = before.firstWhere((t) => t.id == newTask.id, orElse: () => newTask);
    return UpdateTaskCommand(old);
  }

  @override
  String get description => 'Update "${newTask.title}"';
}

class RescheduleCommand extends GanttCommand {
  final String id;
  final DateTime oldStart, oldEnd, newStart, newEnd;
  const RescheduleCommand({required this.id, required this.oldStart, required this.oldEnd, required this.newStart, required this.newEnd});

  @override
  List<Task> apply(List<Task> tasks) => tasks.map((t) => t.id == id ? t.copyWith(startDate: newStart, endDate: newEnd, updatedAt: DateTime.now()) : t).toList();

  @override
  GanttCommand inverse(List<Task> _) => RescheduleCommand(id: id, oldStart: newStart, oldEnd: newEnd, newStart: oldStart, newEnd: oldEnd);

  @override
  String get description => 'Reschedule task';
}

class BatchCommand extends GanttCommand {
  final List<GanttCommand> commands;
  const BatchCommand(this.commands);

  @override
  List<Task> apply(List<Task> tasks) => commands.fold(tasks, (t, cmd) => cmd.apply(t));

  @override
  GanttCommand inverse(List<Task> before) {
    final inverses = commands.reversed.map((c) => c.inverse(before)).toList();
    return BatchCommand(inverses);
  }

  @override
  String get description => 'Batch (${commands.length} operations)';
}

// ─── Command history ──────────────────────────────────────────────────────────

class CommandHistory {
  static const _maxHistory = 100;

  final _undoStack = <_HistoryEntry>[];
  final _redoStack = <_HistoryEntry>[];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  /// Execute a command. Saves the before-state for undo.
  void execute(GanttCommand cmd, List<Task> stateBefore) {
    _undoStack.add(_HistoryEntry(command: cmd, stateBefore: List.from(stateBefore)));
    if (_undoStack.length > _maxHistory) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  /// Undo: returns the state before the last command.
  List<Task> undo(List<Task> current) {
    if (_undoStack.isEmpty) return current;
    final entry = _undoStack.removeLast();
    _redoStack.add(_HistoryEntry(command: entry.command, stateBefore: List.from(current)));
    return entry.stateBefore;
  }

  List<Task> currentState(List<Task> current) => _undoStack.isEmpty ? current : _undoStack.last.stateBefore;

  /// Redo: re-applies the command.
  List<Task>? redo(List<Task> current) {
    if (_redoStack.isEmpty) return null;
    final entry = _redoStack.removeLast();
    _undoStack.add(_HistoryEntry(command: entry.command, stateBefore: List.from(current)));
    return entry.command.apply(current);
  }

  void clear() { _undoStack.clear(); _redoStack.clear(); }
}

class _HistoryEntry {
  final GanttCommand command;
  final List<Task> stateBefore;
  _HistoryEntry({required this.command, required this.stateBefore});
}

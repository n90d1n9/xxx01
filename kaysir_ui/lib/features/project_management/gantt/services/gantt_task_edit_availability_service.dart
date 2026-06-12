import '../gantt_dashboard.dart' as gantt;

/// Undo availability for the full-screen Gantt editing surfaces.
class GanttTaskEditAvailability {
  const GanttTaskEditAvailability({
    required this.canUndoLastTaskEdit,
    required this.canUndoSelectedTaskEdit,
  });

  final bool canUndoLastTaskEdit;
  final bool canUndoSelectedTaskEdit;
}

/// Derives edit affordance state from the task store and current selection.
class GanttTaskEditAvailabilityService {
  const GanttTaskEditAvailabilityService();

  GanttTaskEditAvailability availabilityFor({
    required gantt.TasksNotifier tasksNotifier,
    required gantt.GanttTask? selectedTask,
  }) {
    return GanttTaskEditAvailability(
      canUndoLastTaskEdit: tasksNotifier.canUndoLastEdit,
      canUndoSelectedTaskEdit: tasksNotifier.canUndoTask(selectedTask?.id),
    );
  }
}

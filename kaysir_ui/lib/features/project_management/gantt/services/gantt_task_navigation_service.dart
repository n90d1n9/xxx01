import '../gantt_dashboard.dart' as gantt;

/// Visible-task navigation metadata for the selected Gantt task.
class GanttTaskNavigationContext {
  const GanttTaskNavigationContext({
    required this.positionLabel,
    required this.previousTaskId,
    required this.nextTaskId,
    required this.previousTaskTitle,
    required this.nextTaskTitle,
  });

  static const empty = GanttTaskNavigationContext(
    positionLabel: null,
    previousTaskId: null,
    nextTaskId: null,
    previousTaskTitle: null,
    nextTaskTitle: null,
  );

  final String? positionLabel;
  final String? previousTaskId;
  final String? nextTaskId;
  final String? previousTaskTitle;
  final String? nextTaskTitle;
}

/// Callback bundle for moving between visible Gantt tasks.
class GanttTaskNavigationActions {
  const GanttTaskNavigationActions({
    required this.onPreviousTask,
    required this.onNextTask,
  });

  static const empty = GanttTaskNavigationActions(
    onPreviousTask: null,
    onNextTask: null,
  );

  final void Function()? onPreviousTask;
  final void Function()? onNextTask;
}

/// Builds previous and next task callbacks from a navigation context.
class GanttTaskNavigationActionService {
  const GanttTaskNavigationActionService();

  GanttTaskNavigationActions actionsFor({
    required GanttTaskNavigationContext context,
    required void Function(String taskId) onOpenTask,
  }) {
    final previousTaskId = context.previousTaskId;
    final nextTaskId = context.nextTaskId;

    if (previousTaskId == null && nextTaskId == null) {
      return GanttTaskNavigationActions.empty;
    }

    return GanttTaskNavigationActions(
      onPreviousTask: _callbackFor(previousTaskId, onOpenTask),
      onNextTask: _callbackFor(nextTaskId, onOpenTask),
    );
  }

  void Function()? _callbackFor(
    String? taskId,
    void Function(String taskId) onOpenTask,
  ) {
    if (taskId == null) return null;

    return () => onOpenTask(taskId);
  }
}

/// Builds visible-task navigation context for the selected Gantt task.
class GanttTaskNavigationService {
  const GanttTaskNavigationService();

  GanttTaskNavigationContext contextFor({
    required gantt.GanttTask? selectedTask,
    required List<gantt.GanttTask> visibleTasks,
    Map<String, String> taskTitlesById = const {},
  }) {
    if (selectedTask == null) return GanttTaskNavigationContext.empty;

    final flatTasks = _flattenTasks(visibleTasks);
    final selectedIndex = flatTasks.indexWhere(
      (task) => task.id == selectedTask.id,
    );
    if (selectedIndex < 0) return GanttTaskNavigationContext.empty;

    final previousTask =
        selectedIndex > 0 ? flatTasks[selectedIndex - 1] : null;
    final nextTask =
        selectedIndex < flatTasks.length - 1
            ? flatTasks[selectedIndex + 1]
            : null;

    return GanttTaskNavigationContext(
      positionLabel: '${selectedIndex + 1} of ${flatTasks.length} visible',
      previousTaskId: previousTask?.id,
      nextTaskId: nextTask?.id,
      previousTaskTitle: _titleFor(previousTask, taskTitlesById),
      nextTaskTitle: _titleFor(nextTask, taskTitlesById),
    );
  }

  String? _titleFor(gantt.GanttTask? task, Map<String, String> taskTitlesById) {
    if (task == null) return null;

    return taskTitlesById[task.id] ?? task.title;
  }

  List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
    return [
      for (final task in tasks) ...[
        task,
        if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
      ],
    ];
  }
}

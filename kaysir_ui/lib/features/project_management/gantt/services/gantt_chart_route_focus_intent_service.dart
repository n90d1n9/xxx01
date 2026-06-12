import '../gantt_dashboard.dart' as gantt;

/// Project focus decision derived from a Gantt chart route entry.
class GanttChartRouteProjectFocusIntentResult {
  const GanttChartRouteProjectFocusIntentResult({
    required this.projectId,
    required this.shouldResolveTaskSelection,
  });

  static const ignored = GanttChartRouteProjectFocusIntentResult(
    projectId: null,
    shouldResolveTaskSelection: false,
  );

  static const taskOnly = GanttChartRouteProjectFocusIntentResult(
    projectId: null,
    shouldResolveTaskSelection: true,
  );

  final String? projectId;
  final bool shouldResolveTaskSelection;
}

/// Task selection decision derived from a Gantt chart route entry.
class GanttChartRouteTaskSelectionIntentResult {
  const GanttChartRouteTaskSelectionIntentResult({
    required this.selectedTaskId,
  });

  static const ignored = GanttChartRouteTaskSelectionIntentResult(
    selectedTaskId: null,
  );

  final String? selectedTaskId;
}

/// Applies Gantt route focus intents through caller-owned state callbacks.
class GanttChartRouteFocusIntentDispatcher {
  const GanttChartRouteFocusIntentDispatcher();

  void dispatchProjectFocus({
    required GanttChartRouteProjectFocusIntentResult intent,
    required void Function(String projectId) onApplyProjectFocus,
    required void Function() onResolveTaskSelection,
  }) {
    final projectId = intent.projectId;
    if (projectId != null) {
      onApplyProjectFocus(projectId);
    }

    if (intent.shouldResolveTaskSelection) {
      onResolveTaskSelection();
    }
  }

  bool dispatchTaskSelection({
    required GanttChartRouteTaskSelectionIntentResult intent,
    required void Function(String taskId) onSelectTask,
  }) {
    final taskId = intent.selectedTaskId;
    if (taskId == null) return false;

    onSelectTask(taskId);
    return true;
  }
}

/// Centralizes initial project and task focus rules for Gantt chart routes.
class GanttChartRouteFocusIntentService {
  const GanttChartRouteFocusIntentService();

  GanttChartRouteProjectFocusIntentResult projectFocusFor({
    required String? projectId,
    required Iterable<String> availableProjectIds,
  }) {
    final normalizedProjectId = projectId?.trim();
    if (normalizedProjectId == null || normalizedProjectId.isEmpty) {
      return GanttChartRouteProjectFocusIntentResult.taskOnly;
    }

    if (!availableProjectIds.contains(normalizedProjectId)) {
      return GanttChartRouteProjectFocusIntentResult.ignored;
    }

    return GanttChartRouteProjectFocusIntentResult(
      projectId: normalizedProjectId,
      shouldResolveTaskSelection: true,
    );
  }

  GanttChartRouteTaskSelectionIntentResult taskSelectionFor({
    required String? taskId,
    required List<gantt.GanttTask> visibleTasks,
  }) {
    final normalizedTaskId = taskId?.trim();
    if (normalizedTaskId == null || normalizedTaskId.isEmpty) {
      return GanttChartRouteTaskSelectionIntentResult.ignored;
    }

    if (!_containsTaskId(visibleTasks, normalizedTaskId)) {
      return GanttChartRouteTaskSelectionIntentResult.ignored;
    }

    return GanttChartRouteTaskSelectionIntentResult(
      selectedTaskId: normalizedTaskId,
    );
  }

  bool _containsTaskId(List<gantt.GanttTask> tasks, String taskId) {
    return _flattenTasks(tasks).any((task) => task.id == taskId);
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

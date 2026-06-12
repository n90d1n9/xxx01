import '../gantt_dashboard.dart' as gantt;

/// Result for focusing a task branch in the full-screen Gantt chart.
class GanttChartBranchFocusIntentResult {
  const GanttChartBranchFocusIntentResult({
    required this.branchFocusTaskId,
    required this.collapsedTaskIds,
  });

  final String branchFocusTaskId;
  final Set<String> collapsedTaskIds;
}

/// Result for selecting a task from focus or recent-edit intents.
class GanttChartTaskSelectionIntentResult {
  const GanttChartTaskSelectionIntentResult({
    required this.selectedTaskId,
    required this.shouldClearTimelineFocus,
  });

  static const ignored = GanttChartTaskSelectionIntentResult(
    selectedTaskId: null,
    shouldClearTimelineFocus: false,
  );

  final String? selectedTaskId;
  final bool shouldClearTimelineFocus;
}

/// Applies task selection intent results through caller-owned state callbacks.
class GanttChartTaskSelectionIntentDispatcher {
  const GanttChartTaskSelectionIntentDispatcher();

  bool dispatch({
    required GanttChartTaskSelectionIntentResult intent,
    required void Function() onClearTimelineFocus,
    required void Function(String taskId) onSelectTask,
  }) {
    final taskId = intent.selectedTaskId;
    if (taskId == null) return false;

    if (intent.shouldClearTimelineFocus) {
      onClearTimelineFocus();
    }

    onSelectTask(taskId);
    return true;
  }
}

/// Applies task focus and tree expansion intents through caller-owned state callbacks.
class GanttChartTaskFocusIntentDispatcher {
  const GanttChartTaskFocusIntentDispatcher();

  void dispatchCollapsedTaskIds({
    required Set<String> collapsedTaskIds,
    required void Function(Set<String> collapsedTaskIds)
    onApplyCollapsedTaskIds,
  }) {
    onApplyCollapsedTaskIds(collapsedTaskIds);
  }

  void dispatchBranchFocus({
    required GanttChartBranchFocusIntentResult intent,
    required void Function(String taskId) onApplyBranchFocus,
    required void Function(Set<String> collapsedTaskIds)
    onApplyCollapsedTaskIds,
  }) {
    onApplyBranchFocus(intent.branchFocusTaskId);
    onApplyCollapsedTaskIds(intent.collapsedTaskIds);
  }
}

/// Centralizes task focus decisions for the full-screen Gantt chart.
class GanttChartTaskFocusIntentService {
  const GanttChartTaskFocusIntentService();

  Set<String> toggleCollapsedTask({
    required Set<String> collapsedTaskIds,
    required String taskId,
  }) {
    final normalizedTaskId = taskId.trim();
    if (normalizedTaskId.isEmpty) return collapsedTaskIds;

    final next = {...collapsedTaskIds};
    if (!next.add(normalizedTaskId)) {
      next.remove(normalizedTaskId);
    }

    return next;
  }

  GanttChartBranchFocusIntentResult focusBranch({
    required String taskId,
    required Set<String> collapsedTaskIds,
  }) {
    final normalizedTaskId = taskId.trim();
    final nextCollapsedTaskIds = {...collapsedTaskIds}
      ..remove(normalizedTaskId);

    return GanttChartBranchFocusIntentResult(
      branchFocusTaskId: normalizedTaskId,
      collapsedTaskIds: nextCollapsedTaskIds,
    );
  }

  GanttChartTaskSelectionIntentResult revealSelectedTask(
    String? selectedTaskId,
  ) {
    final normalizedTaskId = selectedTaskId?.trim();
    if (normalizedTaskId == null || normalizedTaskId.isEmpty) {
      return GanttChartTaskSelectionIntentResult.ignored;
    }

    return GanttChartTaskSelectionIntentResult(
      selectedTaskId: normalizedTaskId,
      shouldClearTimelineFocus: true,
    );
  }

  GanttChartTaskSelectionIntentResult selectRecentEditTask({
    required String taskId,
    required List<gantt.GanttTask> allTasks,
    required List<gantt.GanttTask> visibleTasks,
  }) {
    final normalizedTaskId = taskId.trim();
    if (normalizedTaskId.isEmpty) {
      return GanttChartTaskSelectionIntentResult.ignored;
    }

    final taskExists = _containsTaskId(allTasks, normalizedTaskId);
    if (!taskExists) return GanttChartTaskSelectionIntentResult.ignored;

    return GanttChartTaskSelectionIntentResult(
      selectedTaskId: normalizedTaskId,
      shouldClearTimelineFocus:
          !_containsTaskId(visibleTasks, normalizedTaskId),
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

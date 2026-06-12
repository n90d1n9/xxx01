import 'package:flutter/foundation.dart';

import '../gantt_dashboard.dart' as gantt;
import '../widgets/gantt_task_inspector_actions.dart';

/// Builds task inspector callbacks for editing, navigation, and selection.
class GanttTaskInspectorActionService {
  const GanttTaskInspectorActionService();

  GanttTaskInspectorActions actionsFor({
    required gantt.TasksNotifier tasksNotifier,
    required gantt.GanttTask selectedTask,
    required bool canUndoSelectedTaskEdit,
    required VoidCallback onClearSelection,
    required VoidCallback onFocusBranch,
    required ValueChanged<String> onTaskSelected,
    required ValueChanged<gantt.GanttTaskEditActivity> onRecentEditSelected,
    VoidCallback? onPreviousTask,
    VoidCallback? onNextTask,
    VoidCallback? onOpenProject,
  }) {
    return GanttTaskInspectorActions(
      onDismiss: onClearSelection,
      onClearSelection: onClearSelection,
      onPreviousTask: onPreviousTask,
      onNextTask: onNextTask,
      onFocusBranch: onFocusBranch,
      onRecentEditSelected: onRecentEditSelected,
      onUndoLastEdit:
          canUndoSelectedTaskEdit ? tasksNotifier.undoLastTaskEdit : null,
      onTaskKindChanged:
          (kind) => tasksNotifier.updateTaskKind(selectedTask.id, kind),
      onStartDateChanged:
          (date) => tasksNotifier.updateTaskStartDate(selectedTask.id, date),
      onEndDateChanged:
          (date) => tasksNotifier.updateTaskEndDate(selectedTask.id, date),
      onMilestoneDateChanged:
          (date) => tasksNotifier.updateMilestoneDate(selectedTask.id, date),
      onDependencyChanged:
          (dependencyId) =>
              tasksNotifier.updateTaskDependency(selectedTask.id, dependencyId),
      onProgressChanged:
          (progress) =>
              tasksNotifier.updateTaskProgress(selectedTask.id, progress),
      onTaskSelected: onTaskSelected,
      onOpenProject: onOpenProject,
    );
  }
}

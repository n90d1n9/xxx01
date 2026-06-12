import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_task_inspector_action_service.dart';

void main() {
  group('GanttTaskInspectorActionService', () {
    const service = GanttTaskInspectorActionService();

    test('wires inspector edit callbacks to the selected task notifier', () {
      final tasksNotifier = gantt.TasksNotifier();
      final selectedTask = tasksNotifier.state[1];
      final milestoneDate = DateTime(2026, 4, 9);

      final actions = service.actionsFor(
        tasksNotifier: tasksNotifier,
        selectedTask: selectedTask,
        canUndoSelectedTaskEdit: false,
        onClearSelection: () {},
        onFocusBranch: () {},
        onTaskSelected: (_) {},
        onRecentEditSelected: (_) {},
      );

      actions.onProgressChanged!(0.42);
      expect(_taskById(tasksNotifier, selectedTask.id).progress, 0.42);

      actions.onTaskKindChanged!(gantt.GanttTaskKind.milestone);
      expect(_taskById(tasksNotifier, selectedTask.id).isMilestone, isTrue);

      actions.onMilestoneDateChanged!(milestoneDate);
      final updatedTask = _taskById(tasksNotifier, selectedTask.id);
      expect(updatedTask.startDate, milestoneDate);
      expect(updatedTask.endDate, milestoneDate);

      actions.onDependencyChanged!(null);
      expect(_taskById(tasksNotifier, selectedTask.id).dependsOn, isNull);
    });

    test('only exposes undo when the selected task can be reverted', () {
      final tasksNotifier = gantt.TasksNotifier();
      final selectedTask = tasksNotifier.state[1];
      final originalProgress = selectedTask.progress;

      tasksNotifier.updateTaskProgress(selectedTask.id, 0.7);
      final actions = service.actionsFor(
        tasksNotifier: tasksNotifier,
        selectedTask: _taskById(tasksNotifier, selectedTask.id),
        canUndoSelectedTaskEdit: true,
        onClearSelection: () {},
        onFocusBranch: () {},
        onTaskSelected: (_) {},
        onRecentEditSelected: (_) {},
      );

      actions.onUndoLastEdit!();

      expect(
        _taskById(tasksNotifier, selectedTask.id).progress,
        originalProgress,
      );
    });

    test('forwards navigation, selection, project, and focus callbacks', () {
      final tasksNotifier = gantt.TasksNotifier();
      final selectedTask = tasksNotifier.state[1];
      final selectedActivity = gantt.GanttTaskEditActivity(
        taskId: selectedTask.id,
        taskTitle: selectedTask.title,
        kind: gantt.GanttTaskEditKind.progress,
        label: 'Progress changed',
        timestamp: DateTime(2026),
      );
      var clearSelectionCount = 0;
      var focusBranchCount = 0;
      var previousCount = 0;
      var nextCount = 0;
      var openProjectCount = 0;
      String? openedTaskId;
      gantt.GanttTaskEditActivity? openedActivity;

      final actions = service.actionsFor(
        tasksNotifier: tasksNotifier,
        selectedTask: selectedTask,
        canUndoSelectedTaskEdit: false,
        onClearSelection: () => clearSelectionCount++,
        onFocusBranch: () => focusBranchCount++,
        onPreviousTask: () => previousCount++,
        onNextTask: () => nextCount++,
        onOpenProject: () => openProjectCount++,
        onTaskSelected: (taskId) => openedTaskId = taskId,
        onRecentEditSelected: (activity) => openedActivity = activity,
      );

      actions.onDismiss();
      actions.onClearSelection();
      actions.onFocusBranch!();
      actions.onPreviousTask!();
      actions.onNextTask!();
      actions.onOpenProject!();
      actions.onTaskSelected!('release');
      actions.onRecentEditSelected!(selectedActivity);

      expect(clearSelectionCount, 2);
      expect(focusBranchCount, 1);
      expect(previousCount, 1);
      expect(nextCount, 1);
      expect(openProjectCount, 1);
      expect(openedTaskId, 'release');
      expect(openedActivity, same(selectedActivity));
      expect(actions.onUndoLastEdit, isNull);
    });
  });
}

gantt.GanttTask _taskById(gantt.TasksNotifier tasksNotifier, String taskId) {
  return _flattenTasks(
    tasksNotifier.state,
  ).firstWhere((task) => task.id == taskId);
}

List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
    ],
  ];
}

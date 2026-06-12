import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_task_edit_availability_service.dart';

void main() {
  group('GanttTaskEditAvailabilityService', () {
    const service = GanttTaskEditAvailabilityService();

    test('disables undo affordances before a task edit is recorded', () {
      final tasksNotifier = gantt.TasksNotifier();

      final availability = service.availabilityFor(
        tasksNotifier: tasksNotifier,
        selectedTask: tasksNotifier.state.first,
      );

      expect(availability.canUndoLastTaskEdit, isFalse);
      expect(availability.canUndoSelectedTaskEdit, isFalse);
    });

    test('enables selected undo only for the last edited task', () {
      final tasksNotifier = gantt.TasksNotifier();
      tasksNotifier.updateTaskProgress('2', 0.7);

      final editedTask = _taskById(tasksNotifier, '2');
      final otherTask = _taskById(tasksNotifier, '3');

      final editedAvailability = service.availabilityFor(
        tasksNotifier: tasksNotifier,
        selectedTask: editedTask,
      );
      final otherAvailability = service.availabilityFor(
        tasksNotifier: tasksNotifier,
        selectedTask: otherTask,
      );

      expect(editedAvailability.canUndoLastTaskEdit, isTrue);
      expect(editedAvailability.canUndoSelectedTaskEdit, isTrue);
      expect(otherAvailability.canUndoLastTaskEdit, isTrue);
      expect(otherAvailability.canUndoSelectedTaskEdit, isFalse);
    });

    test(
      'handles empty selected task state separately from last edit state',
      () {
        final tasksNotifier = gantt.TasksNotifier();
        tasksNotifier.updateTaskProgress('2', 0.7);

        final availability = service.availabilityFor(
          tasksNotifier: tasksNotifier,
          selectedTask: null,
        );

        expect(availability.canUndoLastTaskEdit, isTrue);
        expect(availability.canUndoSelectedTaskEdit, isFalse);
      },
    );
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

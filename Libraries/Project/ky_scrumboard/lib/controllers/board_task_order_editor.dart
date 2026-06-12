import '../models/scrum_task.dart';
import '../models/scrum_task_status.dart';
import 'task_ordering.dart';

/// Applies dense lane ordering updates to a mutable board task list.
class BoardTaskOrderEditor {
  const BoardTaskOrderEditor({required List<ScrumTask> tasks}) : _tasks = tasks;

  final List<ScrumTask> _tasks;

  /// Returns a task ordered at the end of a lane.
  ScrumTask orderedForAppend(ScrumTask task, ScrumTaskStatus status) {
    return task.copyWith(status: status, sortOrder: nextSortOrder(status));
  }

  /// Returns an upsert candidate with a valid lane order.
  ScrumTask orderedForUpsert(ScrumTask task, ScrumTask previousTask) {
    if (previousTask.status != task.status || task.sortOrder <= 0) {
      return orderedForAppend(task, task.status);
    }
    return task;
  }

  /// Rewrites one lane to dense sort orders and returns changed tasks.
  List<ScrumTask> normalizeStatus(ScrumTaskStatus status) {
    return applyOrderedColumn(status, tasksForStatus(status));
  }

  /// Applies the provided visual lane order to the backing task list.
  List<ScrumTask> applyOrderedColumn(
    ScrumTaskStatus status,
    List<ScrumTask> orderedTasks,
  ) {
    final changedTasks = <ScrumTask>[];

    for (var index = 0; index < orderedTasks.length; index += 1) {
      final task = orderedTasks[index];
      final nextTask = task.copyWith(
        status: status,
        sortOrder: (index + 1) * taskSortOrderStep,
      );
      final taskIndex = _tasks.indexWhere((item) => item.id == task.id);
      if (taskIndex < 0) continue;

      final currentTask = _tasks[taskIndex];
      if (currentTask.status == nextTask.status &&
          currentTask.sortOrder == nextTask.sortOrder) {
        continue;
      }

      _tasks[taskIndex] = nextTask;
      changedTasks.add(nextTask);
    }

    return changedTasks;
  }

  /// Returns the next sparse sort order for appending inside a lane.
  int nextSortOrder(ScrumTaskStatus status) {
    final orderedTasks = tasksForStatus(status);
    if (orderedTasks.isEmpty) return taskSortOrderStep;
    return orderedTasks.last.sortOrder + taskSortOrderStep;
  }

  /// Returns one lane in stable lane order.
  List<ScrumTask> tasksForStatus(ScrumTaskStatus status) {
    final tasks = _tasks
        .where((task) => task.status == status)
        .toList(growable: false);
    return tasks..sort(compareTaskOrder);
  }
}

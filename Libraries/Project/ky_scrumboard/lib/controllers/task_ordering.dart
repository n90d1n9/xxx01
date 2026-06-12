import '../models/scrum_task.dart';
import '../models/scrum_task_priority.dart';
import '../models/scrum_task_sort.dart';
import '../models/scrum_task_status.dart';

/// Sort-order spacing used when normalizing tasks inside a board lane.
const taskSortOrderStep = 1000;

/// Finds the insertion index for a task placed before another task.
int insertionIndexFor(List<ScrumTask> tasks, String? beforeTaskId) {
  if (beforeTaskId == null) return tasks.length;
  final beforeIndex = tasks.indexWhere((task) => task.id == beforeTaskId);
  if (beforeIndex < 0) return tasks.length;
  return beforeIndex;
}

/// Compares tasks by stable board-lane order.
int compareTaskOrder(ScrumTask a, ScrumTask b) {
  final orderA = a.sortOrder <= 0 ? 1 << 30 : a.sortOrder;
  final orderB = b.sortOrder <= 0 ? 1 << 30 : b.sortOrder;
  if (orderA != orderB) return orderA.compareTo(orderB);

  final createdComparison = b.createdAt.compareTo(a.createdAt);
  if (createdComparison != 0) return createdComparison;

  return a.id.compareTo(b.id);
}

/// Compares tasks using a selected board sort while preserving lane-order ties.
int compareTasks(ScrumTask a, ScrumTask b, ScrumTaskSort sort) {
  switch (sort) {
    case ScrumTaskSort.laneOrder:
      return compareTaskOrder(a, b);
    case ScrumTaskSort.priority:
      return _compareWithTieBreaker(
        _priorityRank(b.priority).compareTo(_priorityRank(a.priority)),
        a,
        b,
      );
    case ScrumTaskSort.dueDate:
      return _compareWithTieBreaker(_compareDueDate(a.dueAt, b.dueAt), a, b);
    case ScrumTaskSort.newest:
      return _compareWithTieBreaker(b.createdAt.compareTo(a.createdAt), a, b);
    case ScrumTaskSort.storyPoints:
      return _compareWithTieBreaker(
        b.storyPoints.compareTo(a.storyPoints),
        a,
        b,
      );
  }
}

/// Returns tasks with dense lane sort orders while preserving source order.
List<ScrumTask> normalizedTaskList(List<ScrumTask> tasks) {
  final indexedTasks = [
    for (var index = 0; index < tasks.length; index += 1)
      _IndexedTask(task: tasks[index], index: index),
  ];
  final normalizedTasksById = <String, ScrumTask>{};

  for (final status in ScrumTaskStatus.values) {
    final statusTasks = indexedTasks
        .where((indexedTask) => indexedTask.task.status == status)
        .toList();
    statusTasks.sort(_compareIndexedTaskOrder);

    for (var index = 0; index < statusTasks.length; index += 1) {
      final task = statusTasks[index].task;
      normalizedTasksById[task.id] = task.copyWith(
        sortOrder: (index + 1) * taskSortOrderStep,
      );
    }
  }

  return [for (final task in tasks) normalizedTasksById[task.id] ?? task];
}

int _compareWithTieBreaker(int comparison, ScrumTask a, ScrumTask b) {
  if (comparison != 0) return comparison;
  return compareTaskOrder(a, b);
}

int _compareDueDate(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

int _priorityRank(ScrumTaskPriority priority) {
  switch (priority) {
    case ScrumTaskPriority.low:
      return 0;
    case ScrumTaskPriority.medium:
      return 1;
    case ScrumTaskPriority.high:
      return 2;
    case ScrumTaskPriority.critical:
      return 3;
  }
}

int _compareIndexedTaskOrder(_IndexedTask a, _IndexedTask b) {
  final hasOrderA = a.task.sortOrder > 0;
  final hasOrderB = b.task.sortOrder > 0;

  if (hasOrderA && hasOrderB && a.task.sortOrder != b.task.sortOrder) {
    return a.task.sortOrder.compareTo(b.task.sortOrder);
  }
  if (hasOrderA != hasOrderB) return hasOrderA ? -1 : 1;

  return a.index.compareTo(b.index);
}

/// Source-index wrapper used while normalizing lane order.
class _IndexedTask {
  const _IndexedTask({required this.task, required this.index});

  final ScrumTask task;
  final int index;
}

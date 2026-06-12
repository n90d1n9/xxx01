import 'package:flutter_riverpod/legacy.dart';

import '../task/task.dart';

final taskListProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task task) {
    state = [
      for (final t in state)
        if (t.id == task.id) task else t
    ];
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
  }

  void moveTask(String taskId, TaskStatus newStatus) {
    state = [
      for (final task in state)
        if (task.id == taskId) task.copyWith(status: newStatus) else task
    ];
  }
}

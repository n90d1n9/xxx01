import 'package:flutter_riverpod/legacy.dart';

import 'task.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  void addTask(Task task) {
    state = [...state, task];
  }

  void removeTask(Task task) {
    state = state.where((t) => t.id != task.id).toList();
  }
}

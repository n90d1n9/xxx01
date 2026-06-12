// State Notifiers
import 'package:flutter_riverpod/legacy.dart';

import '../models/daily_task.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

final dailyTasksProvider =
    StateNotifierProvider<DailyTasksNotifier, List<DailyTask>>((ref) {
      return DailyTasksNotifier(ref.watch(storageProvider));
    });

class DailyTasksNotifier extends StateNotifier<List<DailyTask>> {
  final StorageService storage;

  DailyTasksNotifier(this.storage) : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    state = await storage.loadTasks();
  }

  Future<void> addTask(
    String title,
    TaskPriority priority,
    String? assignedTo,
  ) async {
    state = [
      ...state,
      DailyTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        completed: false,
        date: DateTime.now(),
        priority: priority,
        assignedTo: assignedTo,
      ),
    ];
    await storage.saveTasks(state);
  }

  Future<void> toggleTask(String id) async {
    state = [
      for (final task in state)
        if (task.id == id) task.copyWith(completed: !task.completed) else task,
    ];
    await storage.saveTasks(state);
  }

  Future<void> updateTask(DailyTask updatedTask) async {
    state = [
      for (final task in state)
        if (task.id == updatedTask.id) updatedTask else task,
    ];
    await storage.saveTasks(state);
  }

  Future<void> deleteTask(String id) async {
    state = state.where((task) => task.id != id).toList();
    await storage.saveTasks(state);
  }

  Future<void> clearCompleted() async {
    state = state.where((task) => !task.completed).toList();
    await storage.saveTasks(state);
  }
}

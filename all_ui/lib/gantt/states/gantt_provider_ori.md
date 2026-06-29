// Providers
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dummy.dart';
import '../models/gantt_task.dart';

final dateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 7)),
    end: DateTime(now.year, now.month, now.day).add(const Duration(days: 30)),
  );
});

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((
  ref,
) {
  return TasksNotifier();
});

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isEmpty) return tasks;

  return tasks
      .where(
        (task) => task.title.toLowerCase().contains(searchQuery.toLowerCase()),
      )
      .toList();
});

final selectedTaskProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final zoomLevelProvider = StateProvider<double>((ref) => 1.0);
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.week);

enum ViewMode { day, week, month, quarter }

// Notifiers
class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier() : super(_generateSampleTasks());

  static List<Task> _generateSampleTasks() {
    final now = DateTime.now();
    return dummytasks;
  }

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task updatedTask) {
    state =
        state
            .map((task) => task.id == updatedTask.id ? updatedTask : task)
            .toList();
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
  }

  void updateTaskProgress(String taskId, double progress) {
    state =
        state.map((task) {
          if (task.id == taskId) {
            return Task(
              id: task.id,
              title: task.title,
              startDate: task.startDate,
              endDate: task.endDate,
              progress: progress,
              color: task.color,
              subtasks: task.subtasks,
              dependsOn: task.dependsOn,
            );
          }
          return task;
        }).toList();
  }
}

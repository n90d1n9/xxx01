// Providers
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:queue_ui/gantt/states/task_state.dart';

import '../models/task.dart';
import '../models/task_visual.dart';
import '../utils/helper.dart';

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

final tasksProvider = StateNotifierProvider<TasksNotifier, TaskState>((ref) {
  return TasksNotifier();
});

// Notifiers
class TasksNotifier extends StateNotifier<TaskState> {
  TasksNotifier() : super(TaskState.initial());

  ViewMode get viewMode => state.viewMode;
  List<Task> get tasks => state.tasks;

  void setTasks(List<Task> tasks) {
    state = state.copyWith(tasks: tasks);
  }

  void setTaskVisuals(List<TaskVisual> taskVisuals) {
    state = state.copyWith(taskVisuals: taskVisuals);
  }

  void fromtasks(List<Task> tasks) {
    final newTasks =
        tasks.map((task) {
          print(' >>bar>>> ${getPosition(task.visualProperties.taskBarkey)}');
          return task.copyWith(
            visualProperties: TaskVisual(
              taskId: task.id,
              taskItemPosition: getPosition(task.visualProperties.taskItemkey),
              taskBarPosition: getPosition(task.visualProperties.taskBarkey),
              // taskItemSize:
              //    getRenderBox(task.visualProperties.taskItemkey).size,
              //  taskBarSize: getRenderBox(task.visualProperties.taskBarkey).size,
              progress: task.progress,
              color: task.color,
            ),
          );
        }).toList();
    state = state.copyWith(tasks: newTasks);
  }

  void updateTaskVisuals(List<TaskVisual> taskVisuals) {
    state = state.copyWith(taskVisuals: taskVisuals);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setZoomLevel(double zoomLevel) {
    state = state.copyWith(zoomLevel: zoomLevel);
  }

  void setViewMode(ViewMode viewMode) {
    state = state.copyWith(viewMode: viewMode);
  }

  void setSelectedTaskId(String? taskId) {
    state = state.copyWith(selectedTaskId: taskId);
  }

  void clearSelectedTaskId() {
    state = state.copyWith(dateRange: null, selectedTaskId: null);
  }

  List<Task> getFilteredTasks() {
    if (state.searchQuery == null || state.searchQuery!.isEmpty) {
      return state.tasks;
    }
    return state.tasks
        .where(
          (task) => task.title.toLowerCase().contains(
            state.searchQuery!.toLowerCase(),
          ),
        )
        .toList();
  }

  void setSelectedTask(Task task) {
    state = state.copyWith(selectedTask: task);
  }

  void setSelectedTasks(List<Task> tasks) {
    state = state.copyWith(selectedTasks: tasks);
  }

  void setFilteredTasks(List<Task> tasks) {
    state = state.copyWith(filteredTasks: tasks);
  }

  void setDateRange(DateTimeRange dateRange) {
    state = state.copyWith(dateRange: dateRange);
  }

  void addTask(Task task) {
    state = state.copyWith(tasks: [...state.tasks, task]);
  }

  void updateTask(Task updatedTask) {
    state = state.copyWith(
      tasks: state.tasks.where((task) => task.id != updatedTask.id).toList(),
    );
  }

  void selectTask(String taskId) {
    state = state.copyWith(selectedTaskId: taskId);
  }

  void deleteTask(String taskId) {
    state = state.copyWith(
      tasks: state.tasks.where((task) => task.id != taskId).toList(),
    );
  }

  void updateTaskProgress(String taskId, double progress) {
    state = state.copyWith(
      tasks: _updateTaskProgress(state.tasks, taskId, progress),
    );
  }

  List<Task> _updateTaskProgress(
    List<Task> state,
    String taskId,
    double progress,
  ) {
    return state.map((task) {
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

  void updateTasks(List<Task> updatedTasks) {
    state = state.copyWith(
      tasks:
          state.tasks.map((task) {
            final updatedTask = updatedTasks.firstWhere(
              (updatedTask) => updatedTask.id == task.id,
              orElse: () => task,
            );
            return updatedTask;
          }).toList(),
    );
  }
}

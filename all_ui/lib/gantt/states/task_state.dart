import 'package:flutter/material.dart';
import 'package:queue_ui/gantt/dummy.dart';

import '../models/task.dart';
import '../models/task_visual.dart';

enum ViewMode { day, week, month, quarter }

enum TaskAction { add, edit, delete }

class TaskState {
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final List<Task> selectedTasks;
  final Task? selectedTask;
  final DateTimeRange dateRange;
  final double zoomLevel;
  final ViewMode viewMode;
  final String? searchQuery;
  final String? selectedTaskId;
  final List<TaskVisual> taskVisuals;

  TaskState({
    required this.filteredTasks,
    required this.selectedTasks,
    required this.tasks,
    this.selectedTask,
    DateTimeRange? dateRange,
    this.zoomLevel = 1.0,
    required this.viewMode,
    this.searchQuery,
    this.selectedTaskId,
    this.taskVisuals = const [],
  }) : dateRange =
           dateRange ??
           DateTimeRange(
             start: DateTime.now().subtract(const Duration(days: 7)),
             end: DateTime.now().add(const Duration(days: 30)),
           );
  static TaskState initial() {
    return TaskState(
      tasks: dummytasks,
      filteredTasks: [],
      selectedTasks: [],
      taskVisuals: [],

      dateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now().add(const Duration(days: 30)),
      ),
      zoomLevel: 1.0,
      viewMode: ViewMode.week,
    );
  }

  TaskState copyWith({
    List<Task>? tasks,
    Task? selectedTask,
    DateTimeRange? dateRange,
    double? zoomLevel,
    ViewMode? viewMode,
    String? searchQuery,
    String? selectedTaskId,
    List<Task>? filteredTasks,
    List<Task>? selectedTasks,
    List<TaskVisual>? taskVisuals,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      selectedTask: selectedTask ?? this.selectedTask,
      dateRange: dateRange ?? this.dateRange,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTaskId: selectedTaskId ?? this.selectedTaskId,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      selectedTasks: selectedTasks ?? this.selectedTasks,
      taskVisuals: taskVisuals ?? this.taskVisuals,
    );
  }

  @override
  String toString() {
    return 'TaskState(tasks: $tasks, selectedTask: $selectedTask, dateRange: $dateRange, zoomLevel: $zoomLevel, viewMode: $viewMode, searchQuery: $searchQuery, selectedTaskId: $selectedTaskId , filteredTasks: $filteredTasks, selectedTasks: $selectedTasks, taskVisuals: $taskVisuals)';
  }
}

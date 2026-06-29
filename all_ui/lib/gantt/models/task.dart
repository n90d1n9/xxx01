import 'package:flutter/material.dart';

import 'task_visual.dart';

class Task {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final double progress;
  final Color color;
  final List<Task> subtasks;
  final String? dependsOn;
  final TaskVisual visualProperties;

  Task({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.progress = 0.0,
    this.color = Colors.blue,
    this.subtasks = const [],
    this.dependsOn,
    TaskVisual? visualProperties,
  }) : visualProperties = visualProperties ?? TaskVisual.empty();

  Task copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    double? progress,
    Color? color,
    List<Task>? subtasks,
    String? dependsOn,
    Size? size,
    Offset? barPosition,
    TaskVisual? visualProperties,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      color: color ?? this.color,
      subtasks: subtasks ?? this.subtasks,
      dependsOn: dependsOn ?? this.dependsOn,
      visualProperties: visualProperties ?? this.visualProperties,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, startDate: $startDate, endDate: $endDate, progress: $progress, color: $color, subtasks: $subtasks, dependsOn: $dependsOn, visualProperties: $visualProperties)';
  }
}

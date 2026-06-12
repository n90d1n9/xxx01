import 'package:flutter/material.dart';

enum GanttTaskKind { task, milestone }

class GanttTask {
  const GanttTask({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.progress = 0,
    this.color = Colors.blue,
    this.kind = GanttTaskKind.task,
    this.subtasks = const [],
    this.dependsOn,
    this.projectId,
  });

  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final double progress;
  final Color color;
  final GanttTaskKind kind;
  final List<GanttTask> subtasks;
  final String? dependsOn;
  final String? projectId;

  bool get isMilestone => kind == GanttTaskKind.milestone;

  int get durationDays {
    final days = DateUtils.dateOnly(endDate)
        .difference(DateUtils.dateOnly(startDate))
        .inDays;
    return days.abs() + 1;
  }

  GanttTask copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    double? progress,
    Color? color,
    GanttTaskKind? kind,
    List<GanttTask>? subtasks,
    String? dependsOn,
    String? projectId,
  }) {
    return GanttTask(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      color: color ?? this.color,
      kind: kind ?? this.kind,
      subtasks: subtasks ?? this.subtasks,
      dependsOn: dependsOn ?? this.dependsOn,
      projectId: projectId ?? this.projectId,
    );
  }
}

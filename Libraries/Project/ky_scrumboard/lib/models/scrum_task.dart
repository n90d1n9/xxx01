import 'package:flutter/material.dart';

import 'scrum_task_priority.dart';
import 'scrum_task_status.dart';

@immutable
class ScrumTask {
  const ScrumTask({
    required this.id,
    required this.title,
    required this.description,
    required this.assignee,
    required this.storyPoints,
    required this.createdAt,
    required this.status,
    this.sortOrder = 0,
    this.priority = ScrumTaskPriority.medium,
    this.label,
    this.dueAt,
    this.accentColor = const Color(0xFF2563EB),
  });

  final String id;
  final String title;
  final String description;
  final String assignee;
  final int storyPoints;
  final DateTime createdAt;
  final ScrumTaskStatus status;
  final int sortOrder;
  final ScrumTaskPriority priority;
  final String? label;
  final DateTime? dueAt;
  final Color accentColor;

  bool get isDone => status == ScrumTaskStatus.done;

  bool get isOverdue {
    return isOverdueAt(DateTime.now());
  }

  bool isOverdueAt(DateTime now) {
    final dueDate = dueAt;
    if (dueDate == null || isDone) return false;
    return now.isAfter(dueDate);
  }

  bool isDueSoonAt(DateTime now, int days) {
    final dueDate = dueAt;
    if (dueDate == null || isDone || isOverdueAt(now)) return false;
    return !dueDate.isAfter(now.add(Duration(days: days)));
  }

  ScrumTask copyWith({
    String? id,
    String? title,
    String? description,
    String? assignee,
    int? storyPoints,
    DateTime? createdAt,
    ScrumTaskStatus? status,
    int? sortOrder,
    ScrumTaskPriority? priority,
    String? label,
    DateTime? dueAt,
    Color? accentColor,
  }) {
    return ScrumTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      storyPoints: storyPoints ?? this.storyPoints,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      priority: priority ?? this.priority,
      label: label ?? this.label,
      dueAt: dueAt ?? this.dueAt,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

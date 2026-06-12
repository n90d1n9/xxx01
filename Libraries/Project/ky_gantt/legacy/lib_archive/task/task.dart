import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../attachment/attachment.dart';
import 'assignee.dart';
import 'task_style.dart';

//enum TaskStatus { backlog, todo, inProgress, review, done }
enum TaskStatus {
  notStarted,
  completed,
  onHold,
  cancelled,
  backlog,
  todo,
  inProgress,
  review,
  done;

  String get label => name.split(RegExp(r'(?=[A-Z])')).join(' ').toUpperCase();
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
  critical;

  String get label => name.toUpperCase();
  IconData get icon => {
        TaskPriority.low: Icons.arrow_downward,
        TaskPriority.medium: Icons.remove,
        TaskPriority.high: Icons.arrow_upward,
      }[this]!;
  Color get color => {
        TaskPriority.low: Colors.green,
        TaskPriority.medium: Colors.orange,
        TaskPriority.high: Colors.red,
      }[this]!;
}

class Task {
  final String? id;
  final String? name;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? duration;
  final double? progress;

  final bool? isExpanded;
  final TaskStyle? style;
  final TaskPriority? priority;
  final TaskStatus? status;
  final bool isMillestone;
  final DateTime? reminderDate;

  final String? parentId;
  final List<Task>? predecessors;
  final List<Task>? subTasks;
  final List<String> predecessorIds;

  final List<TaskAttachment>? attachments;
  final List<TaskComment>? comments;

  final Assignee? assignee;

  Task({
    this.style,
    this.status,
    this.assignee,
    this.id,
    this.name,
    this.duration,
    this.predecessors = const [],
    required this.title,
    this.startDate,
    this.endDate,
    this.attachments = const [],
    this.comments = const [],
    this.parentId,
    this.progress = 0.0,
    this.subTasks = const [],
    this.predecessorIds = const [],
    this.isExpanded = true,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.isMillestone = false,
    this.reminderDate,
  }) //: (id == id) ?? const Uuid().v4()

  /* : id = id ?? const Uuid().v4(),
        assignedTo = assignedTo ?? '',
        createdAt = createdAt ?? DateTime.now(),
        labels = labels ?? []; */

  ; // : id == id?? const Uuid().v4(), startDate =DateTime.now(), endDate = DateTime(2025);

  //get predecessorIds => [];

  toJson() {}
}

class Timeline {
  final bool showCriticalPath;
  final DateTime startDate;
  final DateTime endDate;
  final int tasksLength;
  //final List<Task>? tasks;
  Timeline({
    this.showCriticalPath = false,
    //this.startDate =  ,
    // this.endDate = DateTime(2025),
    this.tasksLength = 0,
    //this.tasks
  })  : startDate = DateTime.now(),
        endDate = DateTime(2025);
}

class TaskComment {
  final String? id;
  final String? author;
  final String? content;
  final DateTime? timestamp;

  TaskComment({this.author, this.content, this.timestamp, this.id});
}

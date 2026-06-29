import 'package:flutter/material.dart';

class Task {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final Color color;
  final List<Task> subTasks;
  final List<String> predecessors;

  Task({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.color,
    this.subTasks = const [],
    this.predecessors = const [],
  });
}

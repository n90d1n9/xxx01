import 'package:flutter/material.dart';

class GanttTask {
  final String id;
  final String name;
  final String section;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final Offset position;

  GanttTask({
    required this.id,
    required this.name,
    required this.section,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.position = Offset.zero,
  });

  Duration get duration => endDate.difference(startDate);

  GanttTask copyWith({
    String? id,
    String? name,
    String? section,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    Offset? position,
  }) {
    return GanttTask(
      id: id ?? this.id,
      name: name ?? this.name,
      section: section ?? this.section,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      position: position ?? this.position,
    );
  }

  @override
  String toString() {
    return 'GanttTask(id: $id, name: $name, section: $section, startDate: $startDate, endDate: $endDate, status: $status)';
  }
}

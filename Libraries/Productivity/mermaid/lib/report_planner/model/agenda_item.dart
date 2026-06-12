import 'package:flutter/material.dart';

import '../state/analytics_provider.dart';
import 'priority.dart';
import 'reminder_settings.dart';

class AgendaItem {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final String category;
  final bool isCompleted;
  final String? location;
  final List<String> tags;
  final Priority priority;
  final List<ReminderSetting> reminders;
  final RecurrencePattern? recurrence;
  final String? parentRecurringId;
  final List<String>? attachments;
  final bool isAllDay;

  AgendaItem({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.category,
    this.isCompleted = false,
    this.location,
    this.tags = const [],
    this.priority = Priority.medium,
    this.reminders = const [],
    this.recurrence,
    this.parentRecurringId,
    this.attachments,
    this.isAllDay = false,
  });

  AgendaItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    String? category,
    bool? isCompleted,
    String? location,
    List<String>? tags,
    Priority? priority,
    List<ReminderSetting>? reminders,
    RecurrencePattern? recurrence,
    String? parentRecurringId,
    List<String>? attachments,
    bool? isAllDay,
  }) {
    return AgendaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      reminders: reminders ?? this.reminders,
      recurrence: recurrence ?? this.recurrence,
      parentRecurringId: parentRecurringId ?? this.parentRecurringId,
      attachments: attachments ?? this.attachments,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color.value,
      'category': category,
      'isCompleted': isCompleted,
      'location': location,
      'tags': tags,
      'priority': priority.toString(),
      'reminders': reminders.map((r) => r.toJson()).toList(),
      'recurrence': recurrence?.toJson(),
      'parentRecurringId': parentRecurringId,
      'attachments': attachments,
      'isAllDay': isAllDay,
    };
  }

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    return AgendaItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      color: Color(json['color']),
      category: json['category'],
      isCompleted: json['isCompleted'] ?? false,
      location: json['location'],
      tags: List<String>.from(json['tags'] ?? []),
      priority: Priority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => Priority.medium,
      ),
      reminders:
          (json['reminders'] as List?)
              ?.map((r) => ReminderSetting.fromJson(r))
              .toList() ??
          [],
      recurrence: json['recurrence'] != null
          ? RecurrencePattern.fromJson(json['recurrence'])
          : null,
      parentRecurringId: json['parentRecurringId'],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      isAllDay: json['isAllDay'] ?? false,
    );
  }
}

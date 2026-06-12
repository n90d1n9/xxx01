import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'priority.dart';
import 'reminder_settings.dart';

class EventTemplate {
  final String id;
  final String name;
  final String description;
  final Duration defaultDuration;
  final String category;
  final Color color;
  final Priority priority;
  final List<ReminderSetting> reminders;
  final IconData icon;

  EventTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultDuration,
    required this.category,
    required this.color,
    required this.priority,
    required this.reminders,
    required this.icon,
  });

  AgendaItem createEvent(DateTime startTime) {
    return AgendaItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: name,
      description: description,
      startTime: startTime,
      endTime: startTime.add(defaultDuration),
      color: color,
      category: category,
      priority: priority,
      reminders: reminders,
    );
  }
}

// Predefined Templates
import 'package:flutter/material.dart';

import 'model/event_template.dart';
import 'model/priority.dart';
import 'model/reminder_settings.dart';

final eventTemplates = [
  EventTemplate(
    id: '1',
    name: 'Quick Meeting',
    description: 'Short sync meeting',
    defaultDuration: const Duration(minutes: 30),
    category: 'Meeting',
    color: Colors.blue,
    priority: Priority.medium,
    reminders: [ReminderSetting(minutesBefore: 5)],
    icon: Icons.group,
  ),
  EventTemplate(
    id: '2',
    name: 'Lunch Break',
    description: 'Take a break and eat',
    defaultDuration: const Duration(hours: 1),
    category: 'Personal',
    color: Colors.orange,
    priority: Priority.medium,
    reminders: [],
    icon: Icons.restaurant,
  ),
  EventTemplate(
    id: '3',
    name: 'Gym Workout',
    description: 'Exercise session',
    defaultDuration: const Duration(hours: 1, minutes: 30),
    category: 'Health',
    color: Colors.red,
    priority: Priority.medium,
    reminders: [ReminderSetting(minutesBefore: 30)],
    icon: Icons.fitness_center,
  ),
  EventTemplate(
    id: '4',
    name: 'Focus Time',
    description: 'Deep work session',
    defaultDuration: const Duration(hours: 2),
    category: 'Work',
    color: Colors.purple,
    priority: Priority.high,
    reminders: [ReminderSetting(minutesBefore: 10)],
    icon: Icons.psychology,
  ),
  EventTemplate(
    id: '5',
    name: 'Study Session',
    description: 'Learning time',
    defaultDuration: const Duration(hours: 1),
    category: 'Study',
    color: Colors.green,
    priority: Priority.high,
    reminders: [ReminderSetting(minutesBefore: 15)],
    icon: Icons.book,
  ),
];

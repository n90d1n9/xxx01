// Smart Event Parser
import 'package:flutter/widgets.dart';

import '../model/agenda_item.dart';
import '../model/category.dart';
import '../model/priority.dart';
import '../model/reminder_settings.dart';

class SmartEventParser {
  static AgendaItem? parseVoiceInput(String input) {
    try {
      // Basic natural language parsing
      final lowerInput = input.toLowerCase();

      // Extract title (everything before time-related words)
      String title = input;
      DateTime? startTime;
      DateTime? endTime;
      String category = 'Work';
      Priority priority = Priority.medium;

      // Time patterns
      final now = DateTime.now();

      // Parse "tomorrow at 3pm"
      if (lowerInput.contains('tomorrow')) {
        final tomorrow = now.add(const Duration(days: 1));
        final hourMatch = RegExp(
          r'(\d{1,2})\s*(am|pm)?',
        ).firstMatch(lowerInput);
        if (hourMatch != null) {
          int hour = int.parse(hourMatch.group(1)!);
          if (hourMatch.group(2) == 'pm' && hour != 12) hour += 12;
          if (hourMatch.group(2) == 'am' && hour == 12) hour = 0;
          startTime = DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            hour,
            0,
          );
        } else {
          startTime = DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            9,
            0,
          );
        }
      }
      // Parse "today at 3pm" or "at 3pm"
      else if (lowerInput.contains('today') || lowerInput.contains('at')) {
        final hourMatch = RegExp(
          r'(\d{1,2})\s*(am|pm)?',
        ).firstMatch(lowerInput);
        if (hourMatch != null) {
          int hour = int.parse(hourMatch.group(1)!);
          if (hourMatch.group(2) == 'pm' && hour != 12) hour += 12;
          if (hourMatch.group(2) == 'am' && hour == 12) hour = 0;
          startTime = DateTime(now.year, now.month, now.day, hour, 0);
        }
      }
      // Parse "in 2 hours"
      else if (lowerInput.contains('in') && lowerInput.contains('hour')) {
        final hourMatch = RegExp(r'in\s+(\d+)\s+hour').firstMatch(lowerInput);
        if (hourMatch != null) {
          final hours = int.parse(hourMatch.group(1)!);
          startTime = now.add(Duration(hours: hours));
        }
      }
      // Parse "in 30 minutes"
      else if (lowerInput.contains('in') && lowerInput.contains('minute')) {
        final minuteMatch = RegExp(
          r'in\s+(\d+)\s+minute',
        ).firstMatch(lowerInput);
        if (minuteMatch != null) {
          final minutes = int.parse(minuteMatch.group(1)!);
          startTime = now.add(Duration(minutes: minutes));
        }
      }

      // Default to now + 1 hour if no time found
      startTime ??= now.add(const Duration(hours: 1));
      endTime = startTime.add(const Duration(hours: 1));

      // Extract title (remove time phrases)
      title = input
          .replaceAll(
            RegExp(
              r'tomorrow|today|at|in|\d+\s*(am|pm|hour|minute)s?',
              caseSensitive: false,
            ),
            '',
          )
          .trim();

      if (title.isEmpty) title = 'New Event';

      // Detect category from keywords
      if (lowerInput.contains('meeting') || lowerInput.contains('call')) {
        category = 'Meeting';
      } else if (lowerInput.contains('gym') ||
          lowerInput.contains('workout') ||
          lowerInput.contains('exercise')) {
        category = 'Health';
      } else if (lowerInput.contains('lunch') ||
          lowerInput.contains('dinner') ||
          lowerInput.contains('breakfast')) {
        category = 'Personal';
      } else if (lowerInput.contains('study') ||
          lowerInput.contains('learn') ||
          lowerInput.contains('read')) {
        category = 'Study';
      }

      // Detect priority
      if (lowerInput.contains('urgent') ||
          lowerInput.contains('important') ||
          lowerInput.contains('asap')) {
        priority = Priority.urgent;
      } else if (lowerInput.contains('high priority')) {
        priority = Priority.high;
      }

      final color = categories.firstWhere((c) => c.name == category).color;

      return AgendaItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: 'Created via voice input',
        startTime: startTime,
        endTime: endTime,
        color: color,
        category: category,
        priority: priority,
        reminders: [ReminderSetting(minutesBefore: 15)],
      );
    } catch (e) {
      debugPrint('Parse error: $e');
      return null;
    }
  }
}

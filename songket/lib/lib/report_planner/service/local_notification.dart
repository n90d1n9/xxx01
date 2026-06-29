// Initialize notifications
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:intl/intl.dart';

import '../model/agenda_item.dart';
import '../model/priority.dart';

final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    fln.FlutterLocalNotificationsPlugin();

// AI Smart Scheduling Service
class AISchedulingService {
  // Analyze user's schedule patterns
  Map<String, dynamic> analyzeSchedulePatterns(List<AgendaItem> items) {
    final patterns = <String, dynamic>{};

    // Find most productive hours
    final hourlyActivity = <int, int>{};
    final hourlyCompletion = <int, double>{};

    for (final item in items) {
      final hour = item.startTime.hour;
      hourlyActivity[hour] = (hourlyActivity[hour] ?? 0) + 1;

      if (item.isCompleted) {
        hourlyCompletion[hour] = (hourlyCompletion[hour] ?? 0) + 1;
      }
    }

    // Calculate completion rates per hour
    final completionRates = <int, double>{};
    hourlyActivity.forEach((hour, count) {
      completionRates[hour] = (hourlyCompletion[hour] ?? 0) / count;
    });

    // Find best hours (highest completion rate with activity)
    final bestHours =
        completionRates.entries
            .where((e) => (hourlyActivity[e.key] ?? 0) >= 3)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    patterns['bestHours'] = bestHours.take(3).map((e) => e.key).toList();
    patterns['productiveTimeRange'] = bestHours.isNotEmpty
        ? '${bestHours.first.key}:00 - ${bestHours.first.key + 2}:00'
        : '9:00 - 11:00';

    // Detect common event durations
    final durations = items
        .map((i) => i.endTime.difference(i.startTime).inMinutes)
        .toList();
    final avgDuration = durations.isEmpty
        ? 60
        : durations.reduce((a, b) => a + b) ~/ durations.length;
    patterns['avgEventDuration'] = avgDuration;

    // Find busiest days
    final dayActivity = <int, int>{};
    for (final item in items) {
      final day = item.startTime.weekday;
      dayActivity[day] = (dayActivity[day] ?? 0) + 1;
    }

    final busiestDay = dayActivity.entries.isEmpty
        ? 1
        : dayActivity.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    patterns['busiestDay'] = DateFormat(
      'EEEE',
    ).format(DateTime(2024, 1, busiestDay));

    // Category preferences
    final categoryTime = <String, int>{};
    for (final item in items) {
      final duration = item.endTime.difference(item.startTime).inMinutes;
      categoryTime[item.category] =
          (categoryTime[item.category] ?? 0) + duration;
    }
    patterns['topCategory'] = categoryTime.entries.isEmpty
        ? 'Work'
        : categoryTime.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return patterns;
  }

  // Suggest optimal time for new event
  DateTime suggestOptimalTime(
    List<AgendaItem> existingItems,
    Duration eventDuration,
    DateTime preferredDate,
  ) {
    final patterns = analyzeSchedulePatterns(existingItems);
    final bestHours = patterns['bestHours'] as List<int>? ?? [9, 14, 16];

    // Get events on preferred date
    final dayItems = existingItems.where((item) {
      return item.startTime.year == preferredDate.year &&
          item.startTime.month == preferredDate.month &&
          item.startTime.day == preferredDate.day;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Try best hours first
    for (final hour in bestHours) {
      final proposedStart = DateTime(
        preferredDate.year,
        preferredDate.month,
        preferredDate.day,
        hour,
        0,
      );
      final proposedEnd = proposedStart.add(eventDuration);

      // Check if slot is free
      bool isFree = true;
      for (final existing in dayItems) {
        if ((proposedStart.isBefore(existing.endTime) &&
            proposedEnd.isAfter(existing.startTime))) {
          isFree = false;
          break;
        }
      }

      if (isFree) return proposedStart;
    }

    // Find any free slot
    if (dayItems.isEmpty) {
      return DateTime(
        preferredDate.year,
        preferredDate.month,
        preferredDate.day,
        9,
        0,
      );
    }

    // Try gaps between events
    for (int i = 0; i < dayItems.length - 1; i++) {
      final gapStart = dayItems[i].endTime;
      final gapEnd = dayItems[i + 1].startTime;
      final gapDuration = gapEnd.difference(gapStart);

      if (gapDuration >= eventDuration) {
        return gapStart;
      }
    }

    // Default: after last event
    return dayItems.last.endTime;
  }

  // Detect scheduling conflicts
  List<Map<String, dynamic>> detectConflicts(List<AgendaItem> items) {
    final conflicts = <Map<String, dynamic>>[];

    for (int i = 0; i < items.length; i++) {
      for (int j = i + 1; j < items.length; j++) {
        final item1 = items[i];
        final item2 = items[j];

        if (item1.startTime.isBefore(item2.endTime) &&
            item1.endTime.isAfter(item2.startTime)) {
          conflicts.add({
            'event1': item1,
            'event2': item2,
            'severity': _calculateConflictSeverity(item1, item2),
          });
        }
      }
    }

    return conflicts..sort((a, b) => b['severity'].compareTo(a['severity']));
  }

  int _calculateConflictSeverity(AgendaItem item1, AgendaItem item2) {
    int severity = 0;

    // Priority conflicts are more severe
    if (item1.priority == Priority.urgent ||
        item2.priority == Priority.urgent) {
      severity += 3;
    }
    if (item1.priority == Priority.high || item2.priority == Priority.high) {
      severity += 2;
    }

    // Longer overlaps are more severe
    final overlapStart = item1.startTime.isAfter(item2.startTime)
        ? item1.startTime
        : item2.startTime;
    final overlapEnd = item1.endTime.isBefore(item2.endTime)
        ? item1.endTime
        : item2.endTime;
    final overlapMinutes = overlapEnd.difference(overlapStart).inMinutes;

    severity += (overlapMinutes / 30).round();

    return severity;
  }

  // Generate smart suggestions
  List<String> generateSmartSuggestions(List<AgendaItem> items) {
    final suggestions = <String>[];
    final patterns = analyzeSchedulePatterns(items);

    // Productivity suggestions
    final bestHours = patterns['bestHours'] as List<int>;
    if (bestHours.isNotEmpty) {
      suggestions.add(
        '💡 You\'re most productive between ${bestHours.first}:00-${bestHours.first + 2}:00. '
        'Schedule important tasks during this time.',
      );
    }

    // Work-life balance
    final totalItems = items.length;
    final workItems = items.where((i) => i.category == 'Work').length;
    final workPercentage = totalItems > 0 ? (workItems / totalItems) * 100 : 0;

    if (workPercentage > 70) {
      suggestions.add(
        '⚖️ ${workPercentage.toStringAsFixed(0)}% of your events are work-related. '
        'Consider scheduling more personal time.',
      );
    }

    // Break reminders
    final dayItems = items.where((item) {
      final now = DateTime.now();
      return item.startTime.year == now.year &&
          item.startTime.month == now.month &&
          item.startTime.day == now.day;
    }).toList();

    bool hasBreak = dayItems.any(
      (i) =>
          i.category == 'Personal' && i.title.toLowerCase().contains('break'),
    );
    if (dayItems.length > 4 && !hasBreak) {
      suggestions.add(
        '☕ You have ${dayItems.length} events today but no breaks scheduled. '
        'Add a 15-minute break to stay refreshed.',
      );
    }

    // Completion rate
    final completed = items.where((i) => i.isCompleted).length;
    final completionRate = totalItems > 0 ? (completed / totalItems) * 100 : 0;

    if (completionRate < 50 && totalItems > 5) {
      suggestions.add(
        '📊 Your completion rate is ${completionRate.toStringAsFixed(0)}%. '
        'Try breaking large tasks into smaller ones.',
      );
    }

    // Category suggestions
    final topCategory = patterns['topCategory'];
    if (topCategory == 'Work') {
      final healthItems = items.where((i) => i.category == 'Health').length;
      if (healthItems < 2) {
        suggestions.add(
          '🏃 Add some health and fitness activities to balance your schedule.',
        );
      }
    }

    return suggestions;
  }

  // Auto-categorize event from title
  String suggestCategory(String title) {
    final lower = title.toLowerCase();

    if (lower.contains('meeting') ||
        lower.contains('call') ||
        lower.contains('interview')) {
      return 'Meeting';
    } else if (lower.contains('gym') ||
        lower.contains('workout') ||
        lower.contains('exercise') ||
        lower.contains('run')) {
      return 'Health';
    } else if (lower.contains('lunch') ||
        lower.contains('dinner') ||
        lower.contains('breakfast') ||
        lower.contains('meal')) {
      return 'Personal';
    } else if (lower.contains('study') ||
        lower.contains('learn') ||
        lower.contains('read') ||
        lower.contains('course')) {
      return 'Study';
    } else if (lower.contains('flight') ||
        lower.contains('travel') ||
        lower.contains('trip')) {
      return 'Travel';
    } else if (lower.contains('bill') ||
        lower.contains('payment') ||
        lower.contains('bank')) {
      return 'Finance';
    }

    return 'Work';
  }

  // Suggest event duration based on category and title
  Duration suggestDuration(String title, String category) {
    final lower = title.toLowerCase();

    // Quick meetings
    if (lower.contains('standup') ||
        lower.contains('quick') ||
        lower.contains('sync')) {
      return const Duration(minutes: 30);
    }

    // Long meetings
    if (lower.contains('review') ||
        lower.contains('planning') ||
        lower.contains('workshop')) {
      return const Duration(hours: 2);
    }

    // Category-based defaults
    switch (category) {
      case 'Meeting':
        return const Duration(hours: 1);
      case 'Health':
        return const Duration(hours: 1, minutes: 30);
      case 'Study':
        return const Duration(hours: 2);
      case 'Personal':
        return const Duration(minutes: 45);
      default:
        return const Duration(hours: 1);
    }
  }
}

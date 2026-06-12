// Analytics Provider
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../model/analytics_data.dart';
import '../model/daily_stats.dart';
import 'agenda_items_provider.dart';

final analyticsProvider = Provider<AnalyticsData>((ref) {
  final items = ref.read(agendaItemsProvider).value ?? [];
  final now = DateTime.now();

  // Calculate various metrics
  final completed = items.where((i) => i.isCompleted).length;
  final upcoming = items
      .where((i) => i.startTime.isAfter(now) && !i.isCompleted)
      .length;
  final overdue = items
      .where((i) => i.endTime.isBefore(now) && !i.isCompleted)
      .length;

  // Category distribution
  final Map<String, int> categoryDist = {};
  final Map<String, double> timeByCategory = {};
  for (final item in items) {
    categoryDist[item.category] = (categoryDist[item.category] ?? 0) + 1;
    final hours = item.endTime.difference(item.startTime).inHours.toDouble();
    timeByCategory[item.category] =
        (timeByCategory[item.category] ?? 0) + hours;
  }

  // Priority distribution
  final Map<String, int> priorityDist = {};
  for (final item in items) {
    final priority = item.priority.toString().split('.').last;
    priorityDist[priority] = (priorityDist[priority] ?? 0) + 1;
  }

  // Weekly stats (last 7 days)
  final weeklyStats = <DailyStats>[];
  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dayItems = items.where((item) {
      final itemDate = DateTime(
        item.startTime.year,
        item.startTime.month,
        item.startTime.day,
      );
      final checkDate = DateTime(date.year, date.month, date.day);
      return itemDate == checkDate;
    }).toList();

    final dayCompleted = dayItems.where((i) => i.isCompleted).length;
    final dayHours = dayItems.fold<double>(
      0,
      (sum, item) => sum + item.endTime.difference(item.startTime).inHours,
    );

    weeklyStats.add(
      DailyStats(
        date: date,
        totalEvents: dayItems.length,
        completedEvents: dayCompleted,
        hoursScheduled: dayHours,
      ),
    );
  }

  // Monthly stats (last 30 days)
  final monthlyStats = <DailyStats>[];
  for (int i = 29; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dayItems = items.where((item) {
      final itemDate = DateTime(
        item.startTime.year,
        item.startTime.month,
        item.startTime.day,
      );
      final checkDate = DateTime(date.year, date.month, date.day);
      return itemDate == checkDate;
    }).toList();

    final dayCompleted = dayItems.where((i) => i.isCompleted).length;
    final dayHours = dayItems.fold<double>(
      0,
      (sum, item) => sum + item.endTime.difference(item.startTime).inHours,
    );

    monthlyStats.add(
      DailyStats(
        date: date,
        totalEvents: dayItems.length,
        completedEvents: dayCompleted,
        hoursScheduled: dayHours,
      ),
    );
  }

  // Most productive day
  final dayOfWeekStats = <int, int>{};
  for (final item in items) {
    if (item.isCompleted) {
      final weekday = item.startTime.weekday;
      dayOfWeekStats[weekday] = (dayOfWeekStats[weekday] ?? 0) + 1;
    }
  }
  final mostProductiveDay = dayOfWeekStats.entries.isEmpty
      ? 'N/A'
      : DateFormat('EEEE').format(
          DateTime(
            2024,
            1,
            dayOfWeekStats.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key,
          ),
        );

  // Most active category
  final mostActiveCategory = categoryDist.entries.isEmpty
      ? 'N/A'
      : categoryDist.entries.reduce((a, b) => a.value > b.value ? a : b).key;

  // Total hours scheduled
  final totalHours = items.fold<int>(
    0,
    (sum, item) => sum + item.endTime.difference(item.startTime).inHours,
  );

  return AnalyticsData(
    totalEvents: items.length,
    completedEvents: completed,
    upcomingEvents: upcoming,
    overdueEvents: overdue,
    completionRate: items.isEmpty ? 0 : (completed / items.length) * 100,
    categoryDistribution: categoryDist,
    priorityDistribution: priorityDist,
    timeByCategory: timeByCategory,
    weeklyStats: weeklyStats,
    monthlyStats: monthlyStats,
    totalHoursScheduled: totalHours,
    mostProductiveDay: mostProductiveDay,
    mostActiveCategory: mostActiveCategory,
  );
});

enum RecurrenceType { none, daily, weekly, biweekly, monthly, yearly, custom }

class RecurrencePattern {
  final RecurrenceType type;
  final int interval;
  final List<int>? daysOfWeek; // 1-7 (Monday-Sunday)
  final DateTime? endDate;
  final int? occurrences;

  RecurrencePattern({
    required this.type,
    this.interval = 1,
    this.daysOfWeek,
    this.endDate,
    this.occurrences,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'endDate': endDate?.toIso8601String(),
      'occurrences': occurrences,
    };
  }

  factory RecurrencePattern.fromJson(Map<String, dynamic> json) {
    return RecurrencePattern(
      type: RecurrenceType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => RecurrenceType.none,
      ),
      interval: json['interval'] ?? 1,
      daysOfWeek: json['daysOfWeek'] != null
          ? List<int>.from(json['daysOfWeek'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      occurrences: json['occurrences'],
    );
  }
}

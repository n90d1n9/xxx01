import 'package:flutter/material.dart';
import '../models/task_model.dart';

class GanttDateUtils {
  GanttDateUtils._();

  static DateTime dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static int daysBetween(DateTime from, DateTime to) =>
      dateOnly(to).difference(dateOnly(from)).inDays;

  /// Generate a list of dates from [start] to [end] inclusive.
  static List<DateTime> daysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = dateOnly(start);
    final last = dateOnly(end);
    while (!current.isAfter(last)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  static String formatDay(DateTime date) {
    const weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday]} ${date.day}';
  }

  static String formatMonth(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month]} ${date.year}';
  }

  static String formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = dateOnly(now);
    final d = dateOnly(date);
    final diff = d.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 0 && diff <= 7) return 'In $diff days';
    if (diff < 0 && diff >= -7) return '${-diff} days ago';
    return formatShortDate(date);
  }

  /// Get all unique months in a date range
  static List<DateTime> monthsInRange(DateTime start, DateTime end) {
    final months = <DateTime>[];
    var current = DateTime(start.year, start.month, 1);
    final last = DateTime(end.year, end.month, 1);
    while (!current.isAfter(last)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }
    return months;
  }

  /// Calculate pixel offset from gantt start date
  static double dayOffset(DateTime ganttStart, DateTime date, double dayWidth) {
    return daysBetween(ganttStart, date) * dayWidth;
  }

  /// Calculate pixel width of a task bar
  static double taskBarWidth(Task task, double dayWidth) {
    if (task.isMilestone) return dayWidth;
    final days = daysBetween(task.startDate, task.endDate) + 1;
    return days * dayWidth;
  }

  static String durationLabel(Task task) {
    final days = daysBetween(task.startDate, task.endDate) + 1;
    if (days == 1) return '1 day';
    if (days < 7) return '$days days';
    final weeks = days ~/ 7;
    final rem = days % 7;
    if (rem == 0) return '$weeks ${weeks == 1 ? 'week' : 'weeks'}';
    return '$weeks w ${rem}d';
  }

  static String weekLabel(DateTime date) {
    final weekNum = _weekOfYear(date);
    return 'W$weekNum';
  }

  static int _weekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday = startOfYear.add(
      Duration(days: (8 - startOfYear.weekday) % 7),
    );
    if (date.isBefore(firstMonday)) {
      return _weekOfYear(DateTime(date.year - 1, 12, 28));
    }
    return ((date.difference(firstMonday).inDays + 1) / 7).ceil();
  }

  static String quarterLabel(DateTime date) {
    final q = ((date.month - 1) ~/ 3) + 1;
    return 'Q$q ${date.year}';
  }
}

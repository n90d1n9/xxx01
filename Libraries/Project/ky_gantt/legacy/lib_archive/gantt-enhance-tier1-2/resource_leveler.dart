import '../models/task_model.dart';
import 'date_utils.dart';

/// Resource Leveling Engine
///
/// Resolves resource overloads by delaying lower-priority tasks.
/// Algorithm: Iterative (greedy) — for each overloaded day, find the lowest-
/// priority non-critical unfixed task assigned to that day and push it 1 day.
/// Repeat until no overloads remain or max iterations reached.
class ResourceLevelingResult {
  final List<Task> tasks;
  final int shiftsApplied;
  final int daysExtended;

  const ResourceLevelingResult({
    required this.tasks,
    required this.shiftsApplied,
    required this.daysExtended,
  });
}

class ResourceLeveler {
  ResourceLeveler._();

  static ResourceLevelingResult level(
    List<Task> tasks,
    List<Assignee> assignees, {
    Set<String> criticalIds = const {},
    int maxIterations = 500,
  }) {
    if (tasks.isEmpty || assignees.isEmpty) {
      return ResourceLevelingResult(tasks: tasks, shiftsApplied: 0, daysExtended: 0);
    }

    final capacityMap = {for (final a in assignees) a.id: a.allocatedHoursPerDay};
    var current = List<Task>.from(tasks);
    int shifts = 0;

    for (int iter = 0; iter < maxIterations; iter++) {
      final overloadedDay = _findFirstOverloadedDay(current, capacityMap);
      if (overloadedDay == null) break;

      // Find the task to delay: assigned on this day, auto-schedule, not critical, lowest priority
      final candidates = current.where((t) =>
        t.autoSchedule &&
        !t.isLocked &&
        !criticalIds.contains(t.id) &&
        t.assignees.isNotEmpty &&
        !t.startDate.isAfter(overloadedDay) &&
        !t.endDate.isBefore(overloadedDay) &&
        t.constraint == TaskConstraint.asap
      ).toList();

      if (candidates.isEmpty) break; // Can't resolve, stop

      // Sort by priority ascending (low priority = delay first), then by latest end date
      candidates.sort((a, b) {
        final pa = a.priority.index;
        final pb = b.priority.index;
        if (pa != pb) return pa.compareTo(pb);
        return a.endDate.compareTo(b.endDate);
      });

      final toDelay = candidates.first;
      final newStart = toDelay.startDate.add(const Duration(days: 1));
      final duration = toDelay.durationDays - 1;

      current = current.map((t) => t.id == toDelay.id
          ? t.copyWith(
              startDate: newStart,
              endDate: newStart.add(Duration(days: duration)),
              updatedAt: DateTime.now(),
            )
          : t).toList();

      shifts++;
    }

    // Compute how many extra days were added to project end
    final originalEnd = tasks.isEmpty ? DateTime.now() : tasks.map((t) => t.endDate).reduce((a, b) => a.isAfter(b) ? a : b);
    final newEnd = current.isEmpty ? DateTime.now() : current.map((t) => t.endDate).reduce((a, b) => a.isAfter(b) ? a : b);
    final daysExtended = GanttDateUtils.daysBetween(originalEnd, newEnd).clamp(0, 9999);

    return ResourceLevelingResult(tasks: current, shiftsApplied: shifts, daysExtended: daysExtended);
  }

  static DateTime? _findFirstOverloadedDay(List<Task> tasks, Map<String, double> capacity) {
    // Build per-day total load
    final dailyLoad = <DateTime, double>{};
    for (final task in tasks) {
      if (task.assignees.isEmpty) continue;
      final days = GanttDateUtils.daysBetween(task.startDate, task.endDate) + 1;
      if (days <= 0) continue;
      final hPerDayPerAssignee = task.estimatedHours > 0
          ? (task.estimatedHours / days) / task.assignees.length
          : 8.0 / task.assignees.length;
      for (int d = 0; d < days; d++) {
        final day = GanttDateUtils.dateOnly(task.startDate.add(Duration(days: d)));
        for (final a in task.assignees) {
          final cap = capacity[a.id] ?? 8.0;
          dailyLoad.update(day, (v) => v + hPerDayPerAssignee, ifAbsent: () => hPerDayPerAssignee);
          // Check overload for this assignee alone on this day
          // Use total team capacity as comparison
        }
      }
    }

    // Find first day where total load exceeds total capacity
    final totalCap = capacity.values.fold(0.0, (s, v) => s + v);
    final days = dailyLoad.keys.toList()..sort();
    for (final day in days) {
      if ((dailyLoad[day] ?? 0) > totalCap) return day;
    }
    return null;
  }
}

import '../models/task_model.dart';
import 'date_utils.dart';

/// Recurrence Engine
///
/// Generates recurring task instances from a parent task's [RecurrenceRule].
/// Instances are stored as normal Tasks with [recurrenceParentId] set.
///
/// Triggered after any state mutation — idempotent (won't duplicate instances).
class RecurrenceEngine {
  RecurrenceEngine._();

  static List<Task> expandAll(List<Task> tasks) {
    final parents = tasks.where((t) => t.recurrence != null && t.recurrenceParentId == null).toList();
    if (parents.isEmpty) return tasks;

    // Remove stale instances (whose parent no longer exists or rule changed)
    final parentIds = {for (final p in parents) p.id};
    final cleaned = tasks.where((t) => t.recurrenceParentId == null || parentIds.contains(t.recurrenceParentId)).toList();

    final result = List<Task>.from(cleaned);

    for (final parent in parents) {
      final rule = parent.recurrence!;
      final instances = _generateInstances(parent, rule);

      // Remove old instances for this parent, then add fresh ones
      result.removeWhere((t) => t.recurrenceParentId == parent.id);
      result.addAll(instances);
    }

    return result;
  }

  static List<Task> _generateInstances(Task parent, RecurrenceRule rule) {
    final instances = <Task>[];
    final duration = parent.durationDays;
    var currentStart = _nextOccurrence(parent.startDate, rule);
    int count = 0;
    final maxCount = rule.count ?? 52; // hard cap at 52 if no explicit count

    while (true) {
      if (rule.count != null && count >= rule.count!) break;
      if (rule.endDate != null && currentStart.isAfter(rule.endDate!)) break;
      if (count >= maxCount) break;

      final currentEnd = currentStart.add(Duration(days: duration - 1));
      final now = DateTime.now();

      instances.add(parent.copyWith(
        id: '${parent.id}_r$count',
        title: parent.title,
        startDate: currentStart,
        endDate: currentEnd,
        recurrenceParentId: parent.id,
        recurrence: null, // instances don't spawn further
        baseline: null,
        comments: const [],
        timeEntries: const [],
        progress: 0.0,
        status: TaskStatus.todo,
        createdAt: now,
        updatedAt: now,
      ));

      currentStart = _nextOccurrence(currentStart, rule);
      count++;
    }
    return instances;
  }

  static DateTime _nextOccurrence(DateTime from, RecurrenceRule rule) {
    return switch (rule.frequency) {
      RecurrenceFrequency.daily    => from.add(Duration(days: rule.interval)),
      RecurrenceFrequency.weekly   => from.add(Duration(days: 7 * rule.interval)),
      RecurrenceFrequency.biweekly => from.add(Duration(days: 14 * rule.interval)),
      RecurrenceFrequency.monthly  => DateTime(from.year, from.month + rule.interval, from.day),
    };
  }
}

// Recurring Event Helper
import '../model/agenda_item.dart';
import '../state/analytics_provider.dart';

class RecurringEventHelper {
  static List<AgendaItem> generateRecurringInstances(
    AgendaItem template,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    if (template.recurrence == null ||
        template.recurrence!.type == RecurrenceType.none) {
      return [template];
    }

    final instances = <AgendaItem>[];
    final pattern = template.recurrence!;
    var currentDate = template.startTime;
    var instanceCount = 0;

    while (currentDate.isBefore(rangeEnd) &&
        (pattern.occurrences == null || instanceCount < pattern.occurrences!)) {
      if (pattern.endDate != null && currentDate.isAfter(pattern.endDate!)) {
        break;
      }

      if (currentDate.isAfter(rangeStart) ||
          currentDate.isAtSameMomentAs(rangeStart)) {
        final duration = template.endTime.difference(template.startTime);
        final instance = template.copyWith(
          id: '${template.id}_$instanceCount',
          startTime: currentDate,
          endTime: currentDate.add(duration),
          parentRecurringId: template.id,
        );
        instances.add(instance);
      }

      currentDate = _getNextOccurrence(currentDate, pattern);
      instanceCount++;
    }

    return instances;
  }

  static DateTime _getNextOccurrence(
    DateTime current,
    RecurrencePattern pattern,
  ) {
    switch (pattern.type) {
      case RecurrenceType.daily:
        return current.add(Duration(days: pattern.interval));
      case RecurrenceType.weekly:
        return current.add(Duration(days: 7 * pattern.interval));
      case RecurrenceType.biweekly:
        return current.add(Duration(days: 14 * pattern.interval));
      case RecurrenceType.monthly:
        return DateTime(
          current.year,
          current.month + pattern.interval,
          current.day,
          current.hour,
          current.minute,
        );
      case RecurrenceType.yearly:
        return DateTime(
          current.year + pattern.interval,
          current.month,
          current.day,
          current.hour,
          current.minute,
        );
      default:
        return current;
    }
  }
}

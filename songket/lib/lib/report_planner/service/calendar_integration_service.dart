import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/browser.dart';
import 'package:timezone/timezone.dart' as tz;

import '../model/agenda_item.dart';
import '../model/reminder_settings.dart';
import '../state/analytics_provider.dart';

class CalendarIntegrationService {
  final DeviceCalendarPlugin _deviceCalendar = DeviceCalendarPlugin();

  Future<bool> requestPermissions() async {
    final status = await Permission.calendar.request();
    return status.isGranted;
  }

  Future<List<Calendar>> getCalendars() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return [];

    try {
      final calendarsResult = await _deviceCalendar.retrieveCalendars();
      return calendarsResult.data ?? [];
    } catch (e) {
      debugPrint('Error retrieving calendars: $e');
      return [];
    }
  }

  Future<bool> syncEventToCalendar(AgendaItem item, String calendarId) async {
    try {
      final event = Event(calendarId);
      event.title = item.title;
      event.description = item.description;
      event.start = TZDateTime.from(item.startTime, tz.local);
      event.end = TZDateTime.from(item.endTime, tz.local);
      event.location = item.location;
      event.allDay = item.isAllDay;

      // Add reminders
      if (item.reminders.isNotEmpty) {
        event.reminders = item.reminders
            .map((r) => Reminder(minutes: r.minutesBefore))
            .toList();
      }

      // Handle recurrence
      if (item.recurrence != null &&
          item.recurrence!.type != RecurrenceType.none) {
        event.recurrenceRule = _buildRecurrenceRule(item.recurrence!);
      }

      final result = await _deviceCalendar.createOrUpdateEvent(event);
      return result?.isSuccess ?? false;
    } catch (e) {
      debugPrint('Error syncing to calendar: $e');
      return false;
    }
  }

  Future<List<Event>> importFromCalendar(
    String calendarId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final params = RetrieveEventsParams(startDate: start, endDate: end);

      final eventsResult = await _deviceCalendar.retrieveEvents(
        calendarId,
        params,
      );
      return eventsResult.data ?? [];
    } catch (e) {
      debugPrint('Error importing from calendar: $e');
      return [];
    }
  }

  RecurrenceRule _buildRecurrenceRule(RecurrencePattern pattern) {
    RecurrenceFrequency frequency;

    switch (pattern.type) {
      case RecurrenceType.daily:
        frequency = RecurrenceFrequency.Daily;
        break;
      case RecurrenceType.weekly:
        frequency = RecurrenceFrequency.Weekly;
        break;
      case RecurrenceType.monthly:
        frequency = RecurrenceFrequency.Monthly;
        break;
      case RecurrenceType.yearly:
        frequency = RecurrenceFrequency.Yearly;
        break;
      default:
        frequency = RecurrenceFrequency.Daily;
    }

    return RecurrenceRule(
      frequency,
      interval: pattern.interval,
      endDate: pattern.endDate != null
          ? TZDateTime.from(pattern.endDate!, tz.local)
          : null,
      totalOccurrences: pattern.occurrences,
    );
  }

  AgendaItem convertCalendarEvent(Event event, String category, Color color) {
    return AgendaItem(
      id: event.eventId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title ?? 'Untitled Event',
      description: event.description ?? '',
      startTime: event.start!.toLocal(),
      endTime: event.end!.toLocal(),
      color: color,
      category: category,
      location: event.location,
      isAllDay: event.allDay ?? false,
      reminders:
          event.reminders
              ?.map((r) => ReminderSetting(minutesBefore: r.minutes ?? 15))
              .toList() ??
          [],
    );
  }
}

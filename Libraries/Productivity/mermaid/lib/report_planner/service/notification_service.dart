// Notification Service
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz; // Add this import

import '../model/agenda_item.dart';
import 'local_notification.dart';

class NotificationService {
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // Request permissions for iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> scheduleEventReminders(AgendaItem item) async {
    // Cancel existing reminders for this event
    await cancelEventReminders(item.id);

    if (item.isCompleted) return;

    for (var i = 0; i < item.reminders.length; i++) {
      final reminder = item.reminders[i];
      if (!reminder.enabled) continue;

      final scheduledTime = item.startTime.subtract(
        Duration(minutes: reminder.minutesBefore),
      );

      if (scheduledTime.isBefore(DateTime.now())) continue;

      final notificationId = '${item.id}_$i'.hashCode;

      const androidDetails = AndroidNotificationDetails(
        'agenda_reminders',
        'Event Reminders',
        channelDescription: 'Reminders for scheduled events',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convert DateTime to TZDateTime
      final location = tz.getLocation('local'); // Use 'local' timezone
      final tzScheduledTime = tz.TZDateTime(
        location,
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        item.title,
        'Starting ${reminder.minutesBefore == 0 ? "now" : "in ${reminder.minutesBefore} minutes"}${item.location != null ? " at ${item.location}" : ""}',
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // Remove the uiLocalNotificationDateInterpretation parameter
      );
    }
  }

  static Future<void> cancelEventReminders(String eventId) async {
    // Cancel all notifications for this event
    for (var i = 0; i < 10; i++) {
      final notificationId = '${eventId}_$i'.hashCode;
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }
}

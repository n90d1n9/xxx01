import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import 'models/notification_message.dart';

enum NotificationPriority { high, defaultPriority, low }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permissions
    await _requestPermissions();

    // Android initialization
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // macOS initialization
    const macosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Linux initialization
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macosSettings,
      linux: linuxSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  static Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.isDenied.then((value) {
        if (value) {
          Permission.notification.request();
        }
      });
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'websocket_channel',
      'WebSocket Notifications',
      channelDescription: 'Notifications from WebSocket events',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const macosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
      category: LinuxNotificationCategory.im,
      defaultActionName: 'Open',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
      linux: linuxDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showScheduledNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications from WebSocket',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const macosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
      category: LinuxNotificationCategory.im,
      defaultActionName: 'Open',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
      linux: linuxDetails,
    );

    // Convert DateTime to TZDateTime
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    await _notifications.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      tzScheduledTime,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void handleNotification(NotificationMessage message) {
    // Determine notification priority based on message type
    NotificationPriority priority = NotificationPriority.defaultPriority;

    switch (message.type.toLowerCase()) {
      case 'urgent':
      case 'error':
      case 'alert':
        priority = NotificationPriority.high;
        break;
      case 'warning':
        priority = NotificationPriority.defaultPriority;
        break;
      case 'info':
      default:
        priority = NotificationPriority.low;
        break;
    }

    // Show notification
    showNotification(
      title: message.title,
      body: message.message,
      payload: jsonEncode({
        'type': message.type,
        'data': message.data,
        'timestamp': message.timestamp.toIso8601String(),
      }),
      priority: priority,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

/* 
// Notification Service
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    
    await _notifications.initialize(initializationSettings);
  }
  
  Future<void> scheduleTaskReminder(GanttTask task) async {
    if (task.reminderDate == null) return;
    
    await _notifications.schedule(
      task.id.hashCode,
      'Task Reminder',
      'Task "${task.name}" is due soon',
      task.reminderDate!,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'gantt_tasks',
          'Task Reminders',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
 */
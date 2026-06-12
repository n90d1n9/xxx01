import 'admin_notification.dart';

class NotificationService {
  //static const String _storageKey = 'admin_notifications';

  final notifications = <AdminNotification>[
    AdminNotification(
      id: '1',
      title: 'New order received',
      message: 'Order #2458 was placed by John Smith.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.order,
      isRead: false,
    ),
    AdminNotification(
      id: '2',
      title: 'Payment successful',
      message: 'Payment of \$534.25 received for order #2457.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.payment,
      isRead: false,
    ),
    AdminNotification(
      id: '3',
      title: 'Low inventory alert',
      message: 'Product "Wireless Earbuds" has low inventory (3 remaining).',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.inventory,
      isRead: true,
    ),
    AdminNotification(
      id: '4',
      title: 'New user registered',
      message: 'Emma Johnson created a new account.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.user,
      isRead: true,
    ),
  ];

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = notifications.indexWhere(
      (notification) => notification.id == id,
    );
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _saveNotifications();
    }
  }

  void markAllAsRead() {
    notifications.asMap().forEach((index, notification) {
      notifications[index] = notification.copyWith(isRead: true);
    });
    _saveNotifications();
  }

  void addNotification(AdminNotification notification) {
    notifications.insert(0, notification);
    _saveNotifications();
  }

  void removeNotification(String id) {
    notifications.removeWhere((notification) => notification.id == id);
    _saveNotifications();
  }

  void _saveNotifications() {
    // In a real app, this would save to local storage or a database
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setString(_storageKey, jsonEncode(notifications.map((n) => n.toJson()).toList()));
    // });
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../notification/services/admin_notification.dart';
import '../../notification/services/notif_service.dart';

final notificationServiceProvider =
    StateNotifierProvider<NotificationNotifier, List<AdminNotification>>(
      (ref) => NotificationNotifier(),
    );

final notificationsProvider = Provider<List<AdminNotification>>((ref) {
  return ref.watch(notificationServiceProvider);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((item) => !item.isRead).length;
});

class NotificationNotifier extends StateNotifier<List<AdminNotification>> {
  NotificationNotifier() : super(List.of(NotificationService().notifications));

  void markAsRead(String id) {
    state = [
      for (final notification in state)
        notification.id == id
            ? notification.copyWith(isRead: true)
            : notification,
    ];
  }

  void markAllAsRead() {
    state = [
      for (final notification in state) notification.copyWith(isRead: true),
    ];
  }

  void addNotification(AdminNotification notification) {
    state = [notification, ...state];
  }

  void removeNotification(String id) {
    state = [
      for (final notification in state)
        if (notification.id != id) notification,
    ];
  }
}

// Add NotificationProvider to app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notification/services/notif_service.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

final notificationsProvider = Provider((ref) {
  return ref.watch(notificationServiceProvider).notifications;
});

final unreadNotificationsCountProvider = Provider((ref) {
  return ref.watch(notificationServiceProvider).unreadCount;
});

// Create a notification center widget

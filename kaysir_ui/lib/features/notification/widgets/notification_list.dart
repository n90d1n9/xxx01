import 'package:flutter/material.dart';

import '../services/admin_notification.dart';
import 'notification_tile.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({
    super.key,
    required this.notifications,
    required this.onRead,
    required this.onDismiss,
  });

  final List<AdminNotification> notifications;
  final ValueChanged<String> onRead;
  final ValueChanged<String> onDismiss;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 6),
      shrinkWrap: true,
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final notification = notifications[index];

        return NotificationTile(
          notification: notification,
          onTap: () => onRead(notification.id),
          onDismiss: () => onDismiss(notification.id),
        );
      },
    );
  }
}

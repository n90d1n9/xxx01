import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ky_admin/states/notification_provider.dart';
import 'package:ky_admin/widgets/admin_dialog_surface.dart';

import 'notification_center_footer.dart';
import 'notification_center_header.dart';
import 'notification_empty_state.dart';
import 'notification_list.dart';

class NotificationCenter extends ConsumerWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final notificationService = ref.read(notificationServiceProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return AdminDialogSurface(
      minWidth: 360,
      maxWidth: 420,
      maxHeight: 580,
      child: ColoredBox(
        color: colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NotificationCenterHeader(
              unreadCount: unreadCount,
              totalCount: notifications.length,
              onMarkAllRead:
                  unreadCount == 0
                      ? null
                      : () => notificationService.markAllAsRead(),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            if (notifications.isEmpty)
              const NotificationEmptyState()
            else
              Flexible(
                child: NotificationList(
                  notifications: notifications,
                  onRead: notificationService.markAsRead,
                  onDismiss: notificationService.removeNotification,
                ),
              ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            NotificationCenterFooter(
              totalCount: notifications.length,
              onClose: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

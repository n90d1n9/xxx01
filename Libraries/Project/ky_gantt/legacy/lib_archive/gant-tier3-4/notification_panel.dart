import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

// ─── Bell icon with unread badge (for toolbar) ────────────────────────────────

class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    final open = ref.watch(notificationPanelOpenProvider);

    return Tooltip(
      message: 'Notifications',
      child: InkWell(
        onTap: () =>
            ref.read(notificationPanelOpenProvider.notifier).state = !open,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: GanttAnimations.fast,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: open ? GanttTheme.accentDim : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Stack(alignment: Alignment.center, children: [
            Icon(open ? Icons.notifications : Icons.notifications_outlined,
                size: 16,
                color: open ? GanttTheme.accentLight : GanttTheme.textMuted),
            if (unread > 0)
              Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                        color: GanttTheme.danger, shape: BoxShape.circle),
                    child: Center(
                      child: Text(unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  )),
          ]),
        ),
      ),
    );
  }
}

// ─── Notification panel ───────────────────────────────────────────────────────

class NotificationPanel extends ConsumerWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider);

    return Container(
      width: 340,
      decoration: const BoxDecoration(
        color: GanttTheme.surface1,
        border: Border(left: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Column(children: [
        // Header
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: GanttTheme.surface4))),
          child: Row(children: [
            const Icon(Icons.notifications_outlined,
                size: 16, color: GanttTheme.textSecondary),
            const SizedBox(width: 8),
            const Text('Notifications',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: GanttTheme.textPrimary)),
            if (unread > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                    color: GanttTheme.danger,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('$unread',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
            const Spacer(),
            if (notifications.isNotEmpty) ...[
              if (unread > 0)
                TextButton(
                  onPressed: () =>
                      ref.read(notificationsProvider.notifier).markAllRead(),
                  style: TextButton.styleFrom(
                      foregroundColor: GanttTheme.accentLight,
                      textStyle:
                          const TextStyle(fontFamily: 'Inter', fontSize: 11),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero),
                  child: const Text('Mark all read'),
                ),
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined, size: 14),
                color: GanttTheme.textMuted,
                tooltip: 'Clear all',
                onPressed: () =>
                    ref.read(notificationsProvider.notifier).clearAll(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
            IconButton(
              icon: const Icon(Icons.close, size: 14),
              color: GanttTheme.textMuted,
              onPressed: () => ref
                  .read(notificationPanelOpenProvider.notifier)
                  .state = false,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ]),
        ),

        // List
        Expanded(
          child: notifications.isEmpty
              ? _empty()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: GanttTheme.surface4),
                  itemBuilder: (_, i) => _NotificationRow(
                    notification: notifications[i],
                    onTap: () {
                      ref
                          .read(notificationsProvider.notifier)
                          .markRead(notifications[i].id);
                      if (notifications[i].taskId != null) {
                        ref.read(selectedTaskIdProvider.notifier).state =
                            notifications[i].taskId;
                      }
                    },
                    onDismiss: () => ref
                        .read(notificationsProvider.notifier)
                        .dismiss(notifications[i].id),
                  ),
                ),
        ),
      ]),
    );
  }

  Widget _empty() => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.notifications_off_outlined,
            size: 32, color: GanttTheme.textDisabled),
        const SizedBox(height: 8),
        const Text('All caught up!',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: GanttTheme.textMuted)),
        const SizedBox(height: 4),
        const Text(
            'Notifications for overdue tasks,\nmilestones and mentions appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: GanttTheme.textDisabled)),
      ]));
}

class _NotificationRow extends StatelessWidget {
  final GanttNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  const _NotificationRow(
      {required this.notification,
      required this.onTap,
      required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: GanttTheme.danger.withOpacity(0.2),
        child: const Icon(Icons.delete_outline,
            color: GanttTheme.danger, size: 18),
      ),
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: GanttAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: n.isRead ? Colors.transparent : n.color.withOpacity(0.06),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: n.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(n.icon, size: 15, color: n.color),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(
                        child: Text(n.title,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: n.isRead
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                                color: GanttTheme.textPrimary))),
                    Text(GanttDateUtils.formatRelativeDate(n.createdAt),
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: GanttTheme.textDisabled)),
                  ]),
                  const SizedBox(height: 2),
                  Text(n.body,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: GanttTheme.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ])),
            if (!n.isRead)
              Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  decoration:
                      BoxDecoration(color: n.color, shape: BoxShape.circle)),
          ]),
        ),
      ),
    );
  }
}

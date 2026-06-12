import 'package:flutter/material.dart';

class NotificationCenterHeader extends StatelessWidget {
  const NotificationCenterHeader({
    super.key,
    required this.unreadCount,
    required this.totalCount,
    required this.onMarkAllRead,
  });

  final int unreadCount;
  final int totalCount;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle =
        unreadCount == 0
            ? 'All caught up'
            : '$unreadCount unread of $totalCount';
    final isCompact = MediaQuery.of(context).size.width < 420;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Notifications',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isCompact)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all read',
              onPressed: onMarkAllRead,
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Mark all read'),
              onPressed: onMarkAllRead,
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class NotificationCenterFooter extends StatelessWidget {
  const NotificationCenterFooter({
    super.key,
    required this.totalCount,
    required this.onClose,
  });

  final int totalCount;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label =
        totalCount == 1 ? '1 notification' : '$totalCount notifications';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Close'),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

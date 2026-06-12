import 'package:flutter/material.dart';

import 'restaurant_inline_notice.dart';

class RestaurantEmptyState extends StatelessWidget {
  const RestaurantEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final actionLabel = this.actionLabel;
    final onAction = this.onAction;

    return RestaurantInlineNotice(
      icon: icon,
      message: message,
      backgroundColor: colors.surfaceContainerHighest.withValues(alpha: .4),
      borderColor: colors.outlineVariant.withValues(alpha: .5),
      foregroundColor: colors.onSurfaceVariant,
      padding: const EdgeInsets.all(16),
      leadingSpacing: 12,
      messageStyle: theme.textTheme.bodySmall?.copyWith(
        color: colors.onSurfaceVariant,
      ),
      trailing: actionLabel == null || onAction == null
          ? null
          : TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
              label: Text(actionLabel),
            ),
    );
  }
}

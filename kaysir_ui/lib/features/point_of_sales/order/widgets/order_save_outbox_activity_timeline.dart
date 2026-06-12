import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_ui.dart';
import '../utils/order_save_outbox_activity.dart';
import '../utils/order_save_outbox_activity_display.dart';

class OrderSaveOutboxActivityTimeline extends StatelessWidget {
  final List<POSOrderSaveOutboxActivity> activity;
  final int limit;

  const OrderSaveOutboxActivityTimeline({
    super.key,
    required this.activity,
    this.limit = 4,
  });

  @override
  Widget build(BuildContext context) {
    final latest = latestPOSOrderSaveOutboxActivity(activity, limit: limit);
    if (latest.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return POSSurface(
      border: Border.all(color: theme.dividerColor),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: POSUiTokens.gap),
              Expanded(
                child: Text(
                  'Recent activity',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: POSUiTokens.gap),
          for (var index = 0; index < latest.length; index++) ...[
            if (index > 0) const Divider(height: 14),
            _OrderSaveOutboxActivityRow(activity: latest[index]),
          ],
        ],
      ),
    );
  }
}

class _OrderSaveOutboxActivityRow extends StatelessWidget {
  final POSOrderSaveOutboxActivity activity;

  const _OrderSaveOutboxActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = POSOrderSaveOutboxActivityDisplay.fromActivity(activity);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _background(theme.colorScheme),
            borderRadius: BorderRadius.circular(POSUiTokens.radius),
          ),
          child: Icon(_icon(), size: 16, color: _foreground(theme.colorScheme)),
        ),
        const SizedBox(width: POSUiTokens.gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                display.title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                display.detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: POSUiTokens.gap),
        Text(
          display.timeLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  IconData _icon() {
    switch (activity.type) {
      case POSOrderSaveOutboxActivityType.queued:
        return Icons.cloud_upload_outlined;
      case POSOrderSaveOutboxActivityType.sending:
        return Icons.sync_outlined;
      case POSOrderSaveOutboxActivityType.sent:
        return Icons.cloud_done_outlined;
      case POSOrderSaveOutboxActivityType.failed:
        return Icons.sync_problem_outlined;
      case POSOrderSaveOutboxActivityType.retried:
        return Icons.refresh;
      case POSOrderSaveOutboxActivityType.removed:
        return Icons.delete_outline;
      case POSOrderSaveOutboxActivityType.clearedSent:
        return Icons.cleaning_services_outlined;
    }
  }

  Color _background(ColorScheme colorScheme) {
    switch (activity.type) {
      case POSOrderSaveOutboxActivityType.failed:
        return colorScheme.errorContainer;
      case POSOrderSaveOutboxActivityType.sent:
      case POSOrderSaveOutboxActivityType.clearedSent:
        return colorScheme.primaryContainer;
      case POSOrderSaveOutboxActivityType.sending:
      case POSOrderSaveOutboxActivityType.retried:
        return colorScheme.tertiaryContainer;
      case POSOrderSaveOutboxActivityType.queued:
      case POSOrderSaveOutboxActivityType.removed:
        return colorScheme.secondaryContainer;
    }
  }

  Color _foreground(ColorScheme colorScheme) {
    switch (activity.type) {
      case POSOrderSaveOutboxActivityType.failed:
        return colorScheme.onErrorContainer;
      case POSOrderSaveOutboxActivityType.sent:
      case POSOrderSaveOutboxActivityType.clearedSent:
        return colorScheme.onPrimaryContainer;
      case POSOrderSaveOutboxActivityType.sending:
      case POSOrderSaveOutboxActivityType.retried:
        return colorScheme.onTertiaryContainer;
      case POSOrderSaveOutboxActivityType.queued:
      case POSOrderSaveOutboxActivityType.removed:
        return colorScheme.onSecondaryContainer;
    }
  }
}

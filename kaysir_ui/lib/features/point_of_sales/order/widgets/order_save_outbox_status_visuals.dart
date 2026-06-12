import 'package:flutter/material.dart';

import '../utils/order_save_outbox_status_presentation.dart';

class POSOrderSaveOutboxStatusVisuals {
  const POSOrderSaveOutboxStatusVisuals._();

  static IconData iconFor(POSOrderSaveOutboxStatusIntent intent) {
    switch (intent) {
      case POSOrderSaveOutboxStatusIntent.staleFailed:
      case POSOrderSaveOutboxStatusIntent.failed:
        return Icons.sync_problem_outlined;
      case POSOrderSaveOutboxStatusIntent.staleQueued:
        return Icons.schedule_send_outlined;
      case POSOrderSaveOutboxStatusIntent.agingQueued:
        return Icons.hourglass_bottom_outlined;
      case POSOrderSaveOutboxStatusIntent.syncing:
        return Icons.sync_outlined;
      case POSOrderSaveOutboxStatusIntent.queued:
        return Icons.cloud_upload_outlined;
      case POSOrderSaveOutboxStatusIntent.ready:
        return Icons.cloud_done_outlined;
    }
  }

  static POSOrderSaveOutboxStatusPalette chipPalette(
    ThemeData theme,
    POSOrderSaveOutboxStatusIntent intent,
  ) {
    switch (intent) {
      case POSOrderSaveOutboxStatusIntent.staleFailed:
      case POSOrderSaveOutboxStatusIntent.failed:
        return POSOrderSaveOutboxStatusPalette(
          icon: iconFor(intent),
          background: theme.colorScheme.errorContainer.withValues(alpha: 0.72),
          foreground: theme.colorScheme.onErrorContainer,
        );
      case POSOrderSaveOutboxStatusIntent.staleQueued:
        return POSOrderSaveOutboxStatusPalette(
          icon: iconFor(intent),
          background: theme.colorScheme.tertiaryContainer.withValues(
            alpha: 0.72,
          ),
          foreground: theme.colorScheme.onTertiaryContainer,
        );
      case POSOrderSaveOutboxStatusIntent.agingQueued:
        return POSOrderSaveOutboxStatusPalette(
          icon: iconFor(intent),
          background: theme.colorScheme.tertiaryContainer.withValues(
            alpha: 0.58,
          ),
          foreground: theme.colorScheme.onTertiaryContainer,
        );
      case POSOrderSaveOutboxStatusIntent.syncing:
        return POSOrderSaveOutboxStatusPalette(
          icon: iconFor(intent),
          background: theme.colorScheme.tertiaryContainer.withValues(
            alpha: 0.72,
          ),
          foreground: theme.colorScheme.onTertiaryContainer,
        );
      case POSOrderSaveOutboxStatusIntent.queued:
        return POSOrderSaveOutboxStatusPalette(
          icon: iconFor(intent),
          background: theme.colorScheme.secondaryContainer,
          foreground: theme.colorScheme.onSecondaryContainer,
        );
      case POSOrderSaveOutboxStatusIntent.ready:
        return POSOrderSaveOutboxStatusPalette(
          icon: iconFor(intent),
          background: theme.colorScheme.surfaceContainerHighest,
          foreground: theme.colorScheme.onSurfaceVariant,
        );
    }
  }
}

class POSOrderSaveOutboxStatusPalette {
  final IconData icon;
  final Color background;
  final Color foreground;

  const POSOrderSaveOutboxStatusPalette({
    required this.icon,
    required this.background,
    required this.foreground,
  });
}

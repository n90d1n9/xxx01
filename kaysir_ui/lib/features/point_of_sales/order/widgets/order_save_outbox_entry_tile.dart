import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_ui.dart';
import '../utils/order_save_outbox.dart';
import '../utils/order_save_outbox_display.dart';

class OrderSaveOutboxEntryTile extends StatelessWidget {
  final POSOrderSaveOutboxEntry entry;
  final ValueChanged<POSOrderSaveOutboxEntry>? onRetry;

  const OrderSaveOutboxEntryTile({
    super.key,
    required this.entry,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = POSOrderSaveOutboxEntryDisplay.fromEntry(entry);
    final palette = _palette(theme, entry.status);

    return POSSurface(
      border: Border.all(color: theme.dividerColor),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          POSIconBadge(
            icon: palette.icon,
            backgroundColor: palette.background,
            foregroundColor: palette.foreground,
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        display.orderLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      display.statusLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: palette.foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${display.lineSummary} | ${display.terminalLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${display.queuedLabel} | ${display.attemptsLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (display.errorLabel != null) ...[
                  const SizedBox(height: POSUiTokens.gap),
                  Text(
                    display.errorLabel!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (entry.canRetry && onRetry != null) ...[
            const SizedBox(width: POSUiTokens.gap),
            IconButton.filledTonal(
              tooltip: 'Retry order',
              icon: const Icon(Icons.refresh),
              onPressed: () => onRetry!(entry),
            ),
          ],
        ],
      ),
    );
  }

  _OutboxEntryPalette _palette(
    ThemeData theme,
    POSOrderSaveOutboxStatus status,
  ) {
    switch (status) {
      case POSOrderSaveOutboxStatus.pending:
        return _OutboxEntryPalette(
          icon: Icons.cloud_upload_outlined,
          background: theme.colorScheme.secondaryContainer,
          foreground: theme.colorScheme.onSecondaryContainer,
        );
      case POSOrderSaveOutboxStatus.sending:
        return _OutboxEntryPalette(
          icon: Icons.sync_outlined,
          background: theme.colorScheme.tertiaryContainer,
          foreground: theme.colorScheme.onTertiaryContainer,
        );
      case POSOrderSaveOutboxStatus.sent:
        return _OutboxEntryPalette(
          icon: Icons.cloud_done_outlined,
          background: theme.colorScheme.surfaceContainerHighest,
          foreground: theme.colorScheme.onSurfaceVariant,
        );
      case POSOrderSaveOutboxStatus.failed:
        return _OutboxEntryPalette(
          icon: Icons.sync_problem_outlined,
          background: theme.colorScheme.errorContainer,
          foreground: theme.colorScheme.onErrorContainer,
        );
    }
  }
}

class _OutboxEntryPalette {
  final IconData icon;
  final Color background;
  final Color foreground;

  const _OutboxEntryPalette({
    required this.icon,
    required this.background,
    required this.foreground,
  });
}

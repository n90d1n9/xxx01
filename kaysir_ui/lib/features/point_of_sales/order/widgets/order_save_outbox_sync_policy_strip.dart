import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_ui.dart';
import '../utils/order_save_outbox_sync_behavior.dart';

class OrderSaveOutboxSyncPolicyStrip extends StatelessWidget {
  final POSOrderSaveOutboxSyncBehavior behavior;

  const OrderSaveOutboxSyncPolicyStrip({super.key, required this.behavior});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return POSSurface(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.72),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          POSIconBadge(
            icon: Icons.rule_folder_outlined,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sync policy',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  behavior.queueDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: POSUiTokens.gap),
                Wrap(
                  spacing: POSUiTokens.gap,
                  runSpacing: POSUiTokens.gap,
                  children:
                      behavior.policyLabels.map((label) {
                        return POSMetricPill(
                          label: label,
                          backgroundColor: theme.colorScheme.surface,
                          foregroundColor: theme.colorScheme.onSurfaceVariant,
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

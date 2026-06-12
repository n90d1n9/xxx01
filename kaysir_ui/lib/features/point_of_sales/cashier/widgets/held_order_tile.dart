import 'package:flutter/material.dart';

import '../states/held_order_provider.dart';
import '../utils/held_order_display.dart';
import 'pos_ui.dart';

class HeldOrderTile extends StatelessWidget {
  final HeldOrder heldOrder;
  final VoidCallback onResume;
  final VoidCallback onRemove;
  final DateTime now;

  const HeldOrderTile({
    super.key,
    required this.heldOrder,
    required this.onResume,
    required this.onRemove,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = heldOrder.note;

    return POSSurface(
      color: theme.colorScheme.surface,
      border: Border.all(color: theme.dividerColor),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const POSIconBadge(icon: Icons.receipt_long_outlined),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order #${heldOrder.shortOrderId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    POSMetricPill(
                      label: heldOrderAgeLabel(heldOrder.heldAt, now),
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: POSUiTokens.gap),
                Text(
                  '${heldOrderSummaryLabel(heldOrder)} | ${heldOrderTimeLabel(heldOrder.heldAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (note != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              POSActionButton(
                icon: const Icon(Icons.play_arrow),
                label: 'Resume',
                variant: POSActionButtonVariant.filled,
                onPressed: onResume,
              ),
              const SizedBox(height: POSUiTokens.gap),
              IconButton(
                tooltip: 'Remove hold',
                icon: const Icon(Icons.delete_outline),
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

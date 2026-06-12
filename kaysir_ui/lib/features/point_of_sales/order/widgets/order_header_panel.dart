import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_ui.dart';
import '../models/order.dart';
import '../utils/order_display.dart';

class OrderHeaderPanel extends StatelessWidget {
  final Order order;
  final bool compact;
  final VoidCallback onNewOrderPressed;
  final bool showNewOrderAction;
  final String? statusLabel;

  const OrderHeaderPanel({
    super.key,
    required this.order,
    required this.onNewOrderPressed,
    this.compact = false,
    this.showNewOrderAction = true,
    this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemCount = totalPOSOrderItems(order);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        compact ? 12 : 16,
        12,
        compact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.14),
          ),
        ),
      ),
      child: Row(
        children: [
          POSIconBadge(
            icon: Icons.shopping_cart_outlined,
            backgroundColor: theme.colorScheme.onPrimary.withValues(
              alpha: 0.12,
            ),
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Order #${shortPOSOrderId(order.id)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$itemCount item${itemCount == 1 ? '' : 's'} | ${statusLabel ?? posOrderReadinessLabel(order)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.76),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (showNewOrderAction)
            IconButton(
              tooltip: 'New order',
              icon: const Icon(Icons.add_shopping_cart_outlined),
              color: theme.colorScheme.onPrimary,
              onPressed: onNewOrderPressed,
            ),
        ],
      ),
    );
  }
}

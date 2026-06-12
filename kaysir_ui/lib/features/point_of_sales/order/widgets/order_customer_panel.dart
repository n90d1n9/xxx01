import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_ui.dart';
import '../models/order.dart';

class OrderCustomerPanel extends StatelessWidget {
  final Order order;
  final bool compact;
  final VoidCallback onSelectCustomer;
  final VoidCallback onRemoveCustomer;
  final bool canManageCustomer;

  const OrderCustomerPanel({
    super.key,
    required this.order,
    required this.onSelectCustomer,
    required this.onRemoveCustomer,
    this.compact = false,
    this.canManageCustomer = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customer = order.customer;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          const POSIconBadge(
            icon: Icons.person_outline,
            size: 32,
            iconSize: 18,
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child:
                customer == null
                    ? Text(
                      'Walk-in customer',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          customer.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${customer.loyaltyPoints} loyalty points',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
          ),
          if (canManageCustomer)
            POSActionButton(
              icon: Icon(customer == null ? Icons.person_add_alt : Icons.edit),
              label: customer == null ? 'Add' : 'Change',
              onPressed: onSelectCustomer,
            ),
          if (canManageCustomer && customer != null) ...[
            const SizedBox(width: POSUiTokens.gap),
            IconButton(
              tooltip: 'Remove customer',
              icon: const Icon(Icons.close),
              onPressed: onRemoveCustomer,
            ),
          ],
        ],
      ),
    );
  }
}

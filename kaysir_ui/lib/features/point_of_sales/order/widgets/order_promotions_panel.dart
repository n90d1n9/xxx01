import 'package:flutter/material.dart';

import '../../cashier/utils/pos_formatters.dart';
import '../../cashier/widgets/pos_ui.dart';
import '../models/order.dart';

class OrderPromotionsPanel extends StatelessWidget {
  final Order order;
  final VoidCallback onManagePromotions;
  final ValueChanged<String> onRemovePromotion;
  final bool canManagePromotions;

  const OrderPromotionsPanel({
    super.key,
    required this.order,
    required this.onManagePromotions,
    required this.onRemovePromotion,
    this.canManagePromotions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (order.appliedPromotions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.22),
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 18,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: POSUiTokens.gap),
              Expanded(
                child: Text(
                  'Promotions',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (canManagePromotions)
                TextButton(
                  onPressed: onManagePromotions,
                  child: const Text('Manage'),
                ),
            ],
          ),
          const SizedBox(height: 2),
          ...order.appliedPromotions.map(
            (promo) => _PromotionRow(
              name: promo.name,
              percentage: promo.discountPercentage,
              amount: promo.discountAmount,
              canRemove: canManagePromotions,
              onRemove: () => onRemovePromotion(promo.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromotionRow extends StatelessWidget {
  final String name;
  final double percentage;
  final double amount;
  final bool canRemove;
  final VoidCallback onRemove;

  const _PromotionRow({
    required this.name,
    required this.percentage,
    required this.amount,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(name, style: theme.textTheme.bodyMedium)),
          if (percentage > 0)
            Text(
              '-${percentage.toStringAsFixed(percentage % 1 == 0 ? 0 : 1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w800,
              ),
            ),
          if (amount > 0 && percentage > 0)
            Text(' + ', style: theme.textTheme.bodyMedium),
          if (amount > 0)
            Text(
              '-${formatPOSCurrency(amount)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w800,
              ),
            ),
          if (canRemove)
            IconButton(
              tooltip: 'Remove promotion',
              icon: const Icon(Icons.close, size: 16),
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              padding: EdgeInsets.zero,
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

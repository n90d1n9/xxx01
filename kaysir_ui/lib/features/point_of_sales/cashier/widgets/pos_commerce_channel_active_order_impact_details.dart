import 'package:flutter/material.dart';

import '../experiences/pos_commerce_channel_active_order_impact.dart';
import 'pos_commerce_channel_active_order_impact_summary.dart';
import 'pos_ui.dart';

class POSCommerceChannelActiveOrderImpactDetails extends StatelessWidget {
  final POSCommerceChannelActiveOrderImpact impact;

  const POSCommerceChannelActiveOrderImpactDetails({
    super.key,
    required this.impact,
  });

  @override
  Widget build(BuildContext context) {
    if (!impact.isVisible) return const SizedBox.shrink();

    final detailItems =
        impact.items.where((item) => item.message.trim().isNotEmpty).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        POSCommerceChannelActiveOrderImpactSummary(
          impact: impact,
          maxVisibleItems: 6,
        ),
        if (detailItems.isNotEmpty) ...[
          const SizedBox(height: POSUiTokens.gap),
          for (final item in detailItems) _ImpactDetailRow(item: item),
        ],
      ],
    );
  }
}

class _ImpactDetailRow extends StatelessWidget {
  final POSCommerceChannelActiveOrderImpactItem item;

  const _ImpactDetailRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground =
        item.requiresAttention ? colors.onTertiaryContainer : colors.onSurface;
    final background =
        item.requiresAttention
            ? colors.tertiaryContainer.withValues(alpha: 0.38)
            : colors.surfaceContainerHighest.withValues(alpha: 0.52);
    final border =
        item.requiresAttention
            ? colors.tertiary.withValues(alpha: 0.20)
            : colors.outlineVariant.withValues(alpha: 0.52);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon(item.role), size: 16, color: foreground),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foreground.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(POSCommerceChannelActiveOrderImpactRole role) {
    switch (role) {
      case POSCommerceChannelActiveOrderImpactRole.orderKept:
        return Icons.shopping_bag_outlined;
      case POSCommerceChannelActiveOrderImpactRole.layoutChange:
        return Icons.splitscreen_outlined;
      case POSCommerceChannelActiveOrderImpactRole.fulfillmentChange:
        return Icons.local_shipping_outlined;
      case POSCommerceChannelActiveOrderImpactRole.requirement:
        return Icons.rule_folder_outlined;
      case POSCommerceChannelActiveOrderImpactRole.retiredDetail:
        return Icons.warning_amber_outlined;
    }
  }
}

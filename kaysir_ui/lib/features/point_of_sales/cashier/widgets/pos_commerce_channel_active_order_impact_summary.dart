import 'package:flutter/material.dart';

import '../experiences/pos_commerce_channel_active_order_impact.dart';
import 'pos_switch_preview_pill.dart';

class POSCommerceChannelActiveOrderImpactSummary extends StatelessWidget {
  final POSCommerceChannelActiveOrderImpact impact;
  final int maxVisibleItems;

  const POSCommerceChannelActiveOrderImpactSummary({
    super.key,
    required this.impact,
    this.maxVisibleItems = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (!impact.isVisible) return const SizedBox.shrink();

    final visibleItems = impact.items.take(maxVisibleItems).toList();
    final hiddenCount = impact.items.length - visibleItems.length;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final item in visibleItems)
          POSSwitchPreviewPill(
            icon: _icon(item.role),
            label: item.label,
            tone: _tone(item),
          ),
        if (hiddenCount > 0)
          POSSwitchPreviewPill(
            icon: Icons.more_horiz,
            label:
                '+$hiddenCount more order '
                '${hiddenCount == 1 ? 'impact' : 'impacts'}',
            tone:
                impact.requiresAttention
                    ? POSSwitchPreviewTone.warning
                    : POSSwitchPreviewTone.neutral,
          ),
      ],
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

  POSSwitchPreviewTone _tone(POSCommerceChannelActiveOrderImpactItem item) {
    if (item.requiresAttention) return POSSwitchPreviewTone.warning;

    switch (item.role) {
      case POSCommerceChannelActiveOrderImpactRole.orderKept:
        return POSSwitchPreviewTone.positive;
      case POSCommerceChannelActiveOrderImpactRole.layoutChange:
      case POSCommerceChannelActiveOrderImpactRole.fulfillmentChange:
      case POSCommerceChannelActiveOrderImpactRole.requirement:
      case POSCommerceChannelActiveOrderImpactRole.retiredDetail:
        return POSSwitchPreviewTone.neutral;
    }
  }
}

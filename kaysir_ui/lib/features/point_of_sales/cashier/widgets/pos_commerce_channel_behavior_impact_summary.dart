import 'package:flutter/material.dart';

import '../experiences/pos_commerce_channel_behavior.dart';
import '../experiences/pos_commerce_channel_behavior_impact.dart';
import 'pos_switch_preview_pill.dart';

class POSCommerceChannelBehaviorImpactSummary extends StatelessWidget {
  final POSCommerceChannelBehaviorImpact impact;
  final int maxAdded;
  final bool includeRemoved;

  const POSCommerceChannelBehaviorImpactSummary({
    super.key,
    required this.impact,
    this.maxAdded = 2,
    this.includeRemoved = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!impact.hasChanges) return const SizedBox.shrink();

    final safeMax = maxAdded < 1 ? 1 : maxAdded;
    final visibleAdded = impact.addedItems.take(safeMax).toList();
    final hiddenAddedCount = impact.addedItems.length - visibleAdded.length;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final item in visibleAdded)
          Tooltip(
            message: item.module.description,
            child: POSSwitchPreviewPill(
              icon: _areaIcon(item.module.area),
              label: item.label,
              tone: POSSwitchPreviewTone.positive,
            ),
          ),
        if (hiddenAddedCount > 0)
          POSSwitchPreviewPill(
            icon: Icons.add,
            label:
                '+$hiddenAddedCount addition'
                '${hiddenAddedCount == 1 ? '' : 's'}',
            tone: POSSwitchPreviewTone.positive,
          ),
        if (includeRemoved && impact.removedItems.isNotEmpty)
          POSSwitchPreviewPill(
            icon: Icons.remove_circle_outline,
            label:
                'Removes ${impact.removedItems.length} behavior'
                '${impact.removedItems.length == 1 ? '' : 's'}',
            tone: POSSwitchPreviewTone.warning,
          ),
      ],
    );
  }

  IconData _areaIcon(POSCommerceChannelBehaviorArea area) {
    switch (area) {
      case POSCommerceChannelBehaviorArea.orderCapture:
        return Icons.add_shopping_cart_outlined;
      case POSCommerceChannelBehaviorArea.checkout:
        return Icons.point_of_sale_outlined;
      case POSCommerceChannelBehaviorArea.fulfillment:
        return Icons.local_shipping_outlined;
      case POSCommerceChannelBehaviorArea.inventory:
        return Icons.inventory_2_outlined;
      case POSCommerceChannelBehaviorArea.pricing:
        return Icons.sell_outlined;
      case POSCommerceChannelBehaviorArea.customer:
        return Icons.person_outline;
      case POSCommerceChannelBehaviorArea.operations:
        return Icons.hub_outlined;
      case POSCommerceChannelBehaviorArea.synchronization:
        return Icons.sync_outlined;
    }
  }
}

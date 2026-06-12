import 'package:flutter/material.dart';

import '../experiences/pos_commerce_channel_behavior.dart';
import 'pos_switch_preview_pill.dart';

class POSCommerceChannelBehaviorSummary extends StatelessWidget {
  final POSCommerceChannelBehaviorProfile? profile;
  final int maxModules;

  const POSCommerceChannelBehaviorSummary({
    super.key,
    required this.profile,
    this.maxModules = 3,
  });

  @override
  Widget build(BuildContext context) {
    final behaviorProfile = profile;
    if (behaviorProfile == null || behaviorProfile.modules.isEmpty) {
      return const SizedBox.shrink();
    }

    final safeMax = maxModules < 1 ? 1 : maxModules;
    final visibleModules = behaviorProfile.modules.take(safeMax).toList();
    final hiddenCount = behaviorProfile.modules.length - visibleModules.length;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final module in visibleModules)
          Tooltip(
            message: module.description,
            child: POSSwitchPreviewPill(
              icon: _areaIcon(module.area),
              label: module.label,
            ),
          ),
        if (hiddenCount > 0)
          POSSwitchPreviewPill(
            icon: Icons.more_horiz,
            label: '+$hiddenCount behavior${hiddenCount == 1 ? '' : 's'}',
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

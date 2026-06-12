import 'package:flutter/material.dart';

import '../experiences/pos_commerce_channel_switch_plan.dart';
import 'pos_switch_plan_action_summary.dart';
import 'pos_switch_preview_pill.dart';

class POSCommerceChannelSwitchPlanActionSummary extends StatelessWidget {
  final POSCommerceChannelSwitchPlan plan;
  final bool includeCurrent;
  final bool includePassiveActions;

  const POSCommerceChannelSwitchPlanActionSummary({
    super.key,
    required this.plan,
    this.includeCurrent = false,
    this.includePassiveActions = false,
  });

  @override
  Widget build(BuildContext context) {
    if (plan.isCurrent && !includeCurrent) return const SizedBox.shrink();

    return POSSwitchPlanActionSummary(
      items: [
        for (final action in plan.actions)
          if (_shouldShow(action))
            POSSwitchPlanActionSummaryItem(
              icon: _icon(action.role),
              label: action.label,
              tone: _tone(action),
            ),
      ],
    );
  }

  bool _shouldShow(POSCommerceChannelSwitchPlanAction action) {
    return includePassiveActions ||
        action.requiresAttention ||
        !_isPassive(action.role);
  }

  bool _isPassive(POSCommerceChannelSwitchPlanActionRole role) {
    switch (role) {
      case POSCommerceChannelSwitchPlanActionRole.keepChannel:
      case POSCommerceChannelSwitchPlanActionRole.keepLayout:
      case POSCommerceChannelSwitchPlanActionRole.keepFulfillment:
        return true;
      case POSCommerceChannelSwitchPlanActionRole.selectChannel:
      case POSCommerceChannelSwitchPlanActionRole.applyLayout:
      case POSCommerceChannelSwitchPlanActionRole.prepareFulfillment:
      case POSCommerceChannelSwitchPlanActionRole.reviewFulfillment:
        return false;
    }
  }

  IconData _icon(POSCommerceChannelSwitchPlanActionRole role) {
    switch (role) {
      case POSCommerceChannelSwitchPlanActionRole.keepChannel:
        return Icons.radio_button_checked;
      case POSCommerceChannelSwitchPlanActionRole.selectChannel:
        return Icons.swap_horiz_outlined;
      case POSCommerceChannelSwitchPlanActionRole.keepLayout:
        return Icons.dashboard_outlined;
      case POSCommerceChannelSwitchPlanActionRole.applyLayout:
        return Icons.splitscreen_outlined;
      case POSCommerceChannelSwitchPlanActionRole.keepFulfillment:
        return Icons.inventory_2_outlined;
      case POSCommerceChannelSwitchPlanActionRole.prepareFulfillment:
        return Icons.local_shipping_outlined;
      case POSCommerceChannelSwitchPlanActionRole.reviewFulfillment:
        return Icons.assignment_late_outlined;
    }
  }

  POSSwitchPreviewTone _tone(POSCommerceChannelSwitchPlanAction action) {
    if (action.requiresAttention) return POSSwitchPreviewTone.warning;

    switch (action.role) {
      case POSCommerceChannelSwitchPlanActionRole.keepChannel:
      case POSCommerceChannelSwitchPlanActionRole.keepLayout:
      case POSCommerceChannelSwitchPlanActionRole.keepFulfillment:
        return POSSwitchPreviewTone.neutral;
      case POSCommerceChannelSwitchPlanActionRole.selectChannel:
        return POSSwitchPreviewTone.positive;
      case POSCommerceChannelSwitchPlanActionRole.applyLayout:
      case POSCommerceChannelSwitchPlanActionRole.prepareFulfillment:
        return POSSwitchPreviewTone.neutral;
      case POSCommerceChannelSwitchPlanActionRole.reviewFulfillment:
        return POSSwitchPreviewTone.warning;
    }
  }
}

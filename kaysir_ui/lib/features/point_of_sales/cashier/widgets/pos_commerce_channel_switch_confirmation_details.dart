import 'package:flutter/material.dart';

import '../experiences/pos_commerce_channel_active_order_impact.dart';
import '../experiences/pos_commerce_channel_switch_plan.dart';
import '../experiences/pos_commerce_channel_switch_preflight.dart';
import 'pos_commerce_channel_active_order_impact_details.dart';
import 'pos_commerce_channel_switch_preflight_panel.dart';
import 'pos_ui.dart';

class POSCommerceChannelSwitchConfirmationDetails extends StatelessWidget {
  final POSCommerceChannelSwitchPlan plan;
  final ValueNotifier<bool>? canConfirmNotifier;

  const POSCommerceChannelSwitchConfirmationDetails({
    super.key,
    required this.plan,
    this.canConfirmNotifier,
  });

  static bool hasContent(POSCommerceChannelSwitchPlan plan) {
    final impact = POSCommerceChannelActiveOrderImpact.fromPlan(plan);
    final preflight = POSCommerceChannelSwitchPreflight.fromPlan(plan);

    return impact.isVisible || preflight.hasRequirements;
  }

  @override
  Widget build(BuildContext context) {
    final impact = POSCommerceChannelActiveOrderImpact.fromPlan(plan);
    final preflight = POSCommerceChannelSwitchPreflight.fromPlan(plan);
    final showImpact = impact.isVisible;
    final showPreflight = preflight.hasRequirements;

    if (!showImpact && !showPreflight) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showImpact)
          POSCommerceChannelActiveOrderImpactDetails(impact: impact),
        if (showImpact && showPreflight)
          const SizedBox(height: POSUiTokens.gapLarge),
        if (showPreflight)
          POSCommerceChannelSwitchPreflightPanel(
            plan: plan,
            canConfirmNotifier: canConfirmNotifier,
          ),
      ],
    );
  }
}

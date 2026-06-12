import 'package:flutter/material.dart';

import '../utils/billing_product_release_channel.dart';
import 'billing_navigation_destination.dart';
import 'billing_product_release_channel_launch_dispatch_plan.dart';
import 'billing_product_release_channel_launch_panel_registry.dart';
import 'billing_product_release_channel_launch_panel_sources.dart';

class BillingProductReleaseChannelLaunchPlanPanel extends StatelessWidget {
  final BillingProductReleaseChannelLaunchPlan launchPlan;
  final BillingProductReleaseChannelLaunchDispatchPlan? dispatchPlan;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingProductReleaseChannelLaunchPlanPanel({
    super.key,
    required this.launchPlan,
    this.dispatchPlan,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return billingProductReleaseChannelLaunchPlanPanelDescriptor.build(
      BillingProductReleaseChannelLaunchPlanPanelSource(
        launchPlan: launchPlan,
        dispatchPlan: dispatchPlan,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}

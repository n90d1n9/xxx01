import 'package:flutter/foundation.dart';

import '../utils/billing_product_release_channel.dart';
import 'billing_navigation_destination.dart';
import 'billing_product_release_channel_launch_dispatch_plan.dart';
import 'billing_product_release_channel_launch_queue.dart';

class BillingProductReleaseChannelLaunchPlanPanelSource {
  final BillingProductReleaseChannelLaunchPlan launchPlan;
  final BillingProductReleaseChannelLaunchDispatchPlan? dispatchPlan;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingProductReleaseChannelLaunchPlanPanelSource({
    required this.launchPlan,
    this.dispatchPlan,
    this.onDestinationSelected,
  });
}

class BillingProductReleaseChannelLaunchQueuePanelSource {
  final BillingProductReleaseChannelLaunchQueue queue;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingProductReleaseChannelLaunchQueuePanelSource({
    required this.queue,
    this.onDestinationSelected,
  });
}

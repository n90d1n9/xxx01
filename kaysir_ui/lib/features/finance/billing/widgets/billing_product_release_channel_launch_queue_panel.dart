import 'package:flutter/material.dart';

import 'billing_navigation_destination.dart';
import 'billing_product_release_channel_launch_panel_registry.dart';
import 'billing_product_release_channel_launch_panel_sources.dart';
import 'billing_product_release_channel_launch_queue.dart';

class BillingProductReleaseChannelLaunchQueuePanel extends StatelessWidget {
  final BillingProductReleaseChannelLaunchQueue queue;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingProductReleaseChannelLaunchQueuePanel({
    super.key,
    required this.queue,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return billingProductReleaseChannelLaunchQueuePanelDescriptor.build(
      BillingProductReleaseChannelLaunchQueuePanelSource(
        queue: queue,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}

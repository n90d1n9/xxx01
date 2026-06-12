import 'package:flutter/material.dart';

import 'billing_product_release_channel_launch_panel_registry.dart';
import 'billing_product_release_channel_launch_runbook.dart';

class BillingProductReleaseChannelLaunchRunbookPanel extends StatelessWidget {
  final BillingProductReleaseChannelLaunchRunbook runbook;

  const BillingProductReleaseChannelLaunchRunbookPanel({
    super.key,
    required this.runbook,
  });

  @override
  Widget build(BuildContext context) {
    return billingProductReleaseChannelLaunchRunbookPanelDescriptor.build(
      runbook,
    );
  }
}

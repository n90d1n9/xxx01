import 'package:flutter/material.dart';

import '../utils/billing_product_package_launch_playbook.dart';
import 'billing_product_package_panel_registry.dart';

class BillingProductPackageLaunchPlaybookPanel extends StatelessWidget {
  final BillingProductPackageLaunchPlaybook playbook;

  const BillingProductPackageLaunchPlaybookPanel({
    super.key,
    required this.playbook,
  });

  @override
  Widget build(BuildContext context) {
    return billingProductPackageLaunchPlaybookPanelDescriptor.build(playbook);
  }
}

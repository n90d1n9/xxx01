import 'package:flutter/material.dart';

import '../utils/billing_product_package_plan.dart';
import 'billing_product_package_panel_registry.dart';

class BillingProductPackagePanel extends StatelessWidget {
  final BillingProductPackagePortfolio portfolio;

  const BillingProductPackagePanel({super.key, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return billingProductPackagePortfolioPanelDescriptor.build(portfolio);
  }
}

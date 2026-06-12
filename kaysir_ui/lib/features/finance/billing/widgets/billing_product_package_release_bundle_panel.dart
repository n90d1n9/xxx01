import 'package:flutter/material.dart';

import '../utils/billing_product_package_release_bundle.dart';
import 'billing_product_package_panel_registry.dart';

class BillingProductPackageReleaseBundlePanel extends StatelessWidget {
  final BillingProductPackageReleaseBundleCatalog catalog;

  const BillingProductPackageReleaseBundlePanel({
    super.key,
    required this.catalog,
  });

  @override
  Widget build(BuildContext context) {
    return billingProductPackageReleaseBundlePanelDescriptor.build(catalog);
  }
}

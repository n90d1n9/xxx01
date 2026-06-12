import 'package:flutter/material.dart';

import '../utils/billing_product_package_release_manifest.dart';
import 'billing_product_package_panel_registry.dart';

class BillingProductPackageReleaseManifestPanel extends StatelessWidget {
  final BillingProductPackageReleaseManifestCatalog catalog;

  const BillingProductPackageReleaseManifestPanel({
    super.key,
    required this.catalog,
  });

  @override
  Widget build(BuildContext context) {
    return billingProductPackageReleaseManifestPanelDescriptor.build(catalog);
  }
}

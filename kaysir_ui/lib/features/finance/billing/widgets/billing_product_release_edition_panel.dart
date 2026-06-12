import 'package:flutter/material.dart';

import '../utils/billing_product_release_edition.dart';
import 'billing_product_release_panel_registry.dart';

class BillingProductReleaseEditionPanel extends StatelessWidget {
  final BillingProductReleaseEditionCatalog catalog;

  const BillingProductReleaseEditionPanel({super.key, required this.catalog});

  @override
  Widget build(BuildContext context) {
    return billingProductReleaseEditionPanelDescriptor.build(catalog);
  }
}

import 'package:flutter/material.dart';

import '../utils/billing_product_release_channel.dart';
import 'billing_product_release_panel_registry.dart';

class BillingProductReleaseChannelMatrixPanel extends StatelessWidget {
  final BillingProductReleaseChannelMatrix matrix;

  const BillingProductReleaseChannelMatrixPanel({
    super.key,
    required this.matrix,
  });

  @override
  Widget build(BuildContext context) {
    return billingProductReleaseChannelMatrixPanelDescriptor.build(matrix);
  }
}

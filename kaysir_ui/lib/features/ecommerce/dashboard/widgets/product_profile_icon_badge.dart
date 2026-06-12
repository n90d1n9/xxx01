import 'package:flutter/material.dart';

import '../models/product_profile.dart';
import 'tonal_icon_badge.dart';

class ProductProfileIconBadge extends StatelessWidget {
  final ProductProfile profile;
  final bool selected;

  const ProductProfileIconBadge({
    super.key,
    required this.profile,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TonalIconBadge(
      icon: productProfileIcon(profile),
      backgroundColor:
          selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
      foregroundColor:
          selected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
    );
  }
}

IconData productProfileIcon(ProductProfile profile) {
  final capabilities = profile.capabilities.toSet();

  if (capabilities.contains(ProductCapability.subscriptionBilling)) {
    return Icons.autorenew_outlined;
  }
  if (capabilities.contains(ProductCapability.marketplaceOrders) &&
      !capabilities.contains(ProductCapability.storefrontCheckout)) {
    return Icons.store_mall_directory_outlined;
  }
  if (capabilities.contains(ProductCapability.remotePayment)) {
    return Icons.payments_outlined;
  }
  if (capabilities.contains(ProductCapability.shipping) ||
      capabilities.contains(ProductCapability.pickupDelivery)) {
    return Icons.local_shipping_outlined;
  }

  return Icons.view_quilt_outlined;
}

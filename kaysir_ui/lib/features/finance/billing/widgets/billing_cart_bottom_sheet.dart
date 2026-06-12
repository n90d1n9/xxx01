import 'package:flutter/material.dart';

import '../models/billing_tenant_preferences.dart';
import 'billing_cart_panel.dart';

class CartBottomSheet extends StatelessWidget {
  final String tenantId;
  final ScrollController scrollController;
  final VoidCallback? onCheckout;
  final BillingTenantPreferences preferences;

  const CartBottomSheet({
    super.key,
    required this.tenantId,
    required this.scrollController,
    this.onCheckout,
    this.preferences = const BillingTenantPreferences(),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BillingCartPanel(
        tenantId: tenantId,
        scrollController: scrollController,
        preferences: preferences,
        showDragHandle: true,
        onCheckout: () {
          Navigator.pop(context);
          onCheckout?.call();
        },
      ),
    );
  }
}

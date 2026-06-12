import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_tenant_preferences.dart';
import '../states/billing_cart_provider.dart';
import '../utils/billing_formatters.dart';

class BillingCheckoutBar extends ConsumerWidget {
  final String tenantId;
  final VoidCallback onCheckout;
  final BillingTenantPreferences preferences;

  const BillingCheckoutBar({
    super.key,
    required this.tenantId,
    required this.onCheckout,
    this.preferences = const BillingTenantPreferences(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsForTenantProvider(tenantId));
    final summary = ref.watch(cartSummaryForTenantProvider(tenantId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 16,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  Text(
                    formatBillingCurrency(
                      summary.total,
                      preferences: preferences,
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1A202C),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: cartItems.isEmpty ? null : onCheckout,
              icon: const Icon(Icons.point_of_sale_outlined, size: 18),
              label: Text('Checkout (${summary.itemCount})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

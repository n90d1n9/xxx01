import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_tenant_preferences.dart';
import '../states/billing_cart_provider.dart';
import '../utils/billing_cart_summary.dart';
import 'billing_cart_item_tile.dart';
import 'billing_order_summary.dart';

class BillingCartPanel extends ConsumerWidget {
  final String tenantId;
  final ScrollController? scrollController;
  final VoidCallback? onCheckout;
  final BillingTenantPreferences preferences;
  final bool showDragHandle;

  const BillingCartPanel({
    super.key,
    required this.tenantId,
    this.scrollController,
    this.onCheckout,
    this.preferences = const BillingTenantPreferences(),
    this.showDragHandle = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsForTenantProvider(tenantId));
    final summary = ref.watch(cartSummaryForTenantProvider(tenantId));

    return Column(
      children: [
        if (showDragHandle) const _CartDragHandle(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Your Cart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (cartItems.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    ref.read(cartProvider.notifier).clearTenantCart(tenantId);
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE53E3E),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child:
              cartItems.isEmpty
                  ? const _EmptyCartState()
                  : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      return CartItemTile(
                        cartItem: cartItems[index],
                        preferences: preferences,
                      );
                    },
                  ),
        ),
        if (cartItems.isNotEmpty)
          _CartSummaryFooter(
            summary: summary,
            preferences: preferences,
            onCheckout: onCheckout,
          ),
      ],
    );
  }
}

class _CartDragHandle extends StatelessWidget {
  const _CartDragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _CartSummaryFooter extends StatelessWidget {
  final BillingCartSummary summary;
  final BillingTenantPreferences preferences;
  final VoidCallback? onCheckout;

  const _CartSummaryFooter({
    required this.summary,
    required this.preferences,
    this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
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
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BillingOrderSummary(
              summary: summary,
              preferences: preferences,
              title: 'Cart Summary',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCheckout,
                icon: const Icon(Icons.point_of_sale_outlined, size: 18),
                label: const Text('Proceed to Checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Color(0xFFCBD5E0),
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(color: Color(0xFF718096), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

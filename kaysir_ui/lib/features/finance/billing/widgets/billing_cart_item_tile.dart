import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_cart_item.dart';
import '../models/billing_tenant_preferences.dart';
import '../states/billing_cart_provider.dart';
import '../utils/billing_formatters.dart';
import 'billing_product_category_icon.dart';

class CartItemTile extends ConsumerWidget {
  final CartItem cartItem;
  final BillingTenantPreferences preferences;

  const CartItemTile({
    super.key,
    required this.cartItem,
    this.preferences = const BillingTenantPreferences(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductThumbnail(cartItem: cartItem),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatBillingCurrency(cartItem.product.price, preferences: preferences)} per unit',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _QuantityStepper(cartItem: cartItem),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatBillingCurrency(cartItem.total, preferences: preferences),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              IconButton(
                tooltip: 'Remove item',
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE53E3E),
                  size: 20,
                ),
                onPressed: () {
                  ref
                      .read(cartProvider.notifier)
                      .removeFromCart(cartItem.product.id, cartItem.tenantId);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  final CartItem cartItem;

  const _ProductThumbnail({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF6FF),
        borderRadius: BorderRadius.circular(12),
        image:
            cartItem.product.imageUrl != null
                ? DecorationImage(
                  image: AssetImage(cartItem.product.imageUrl!),
                  fit: BoxFit.contain,
                )
                : null,
      ),
      child:
          cartItem.product.imageUrl == null
              ? Icon(
                billingProductCategoryIcon(cartItem.product.category),
                size: 30,
                color: const Color(0xFF2563EB),
              )
              : null,
    );
  }
}

class _QuantityStepper extends ConsumerWidget {
  final CartItem cartItem;

  const _QuantityStepper({required this.cartItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _QuantityButton(
          icon: Icons.remove,
          onTap: () {
            ref
                .read(cartProvider.notifier)
                .updateQuantity(
                  cartItem.product.id,
                  cartItem.tenantId,
                  cartItem.quantity - 1,
                );
          },
        ),
        SizedBox(
          width: 38,
          child: Text(
            '${cartItem.quantity}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        _QuantityButton(
          icon: Icons.add,
          onTap: () {
            ref
                .read(cartProvider.notifier)
                .updateQuantity(
                  cartItem.product.id,
                  cartItem.tenantId,
                  cartItem.quantity + 1,
                );
          },
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF475569)),
      ),
    );
  }
}

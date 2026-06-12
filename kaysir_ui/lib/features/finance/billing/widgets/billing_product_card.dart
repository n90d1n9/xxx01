import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_product.dart';
import '../models/billing_tenant_preferences.dart';
import '../states/billing_cart_provider.dart';
import '../utils/billing_formatters.dart';
import 'billing_product_category_icon.dart';

class BillingProductCard extends ConsumerWidget {
  final Product product;
  final String tenantId;
  final BillingTenantPreferences preferences;

  const BillingProductCard({
    super.key,
    required this.product,
    required this.tenantId,
    this.preferences = const BillingTenantPreferences(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF6FF),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                image:
                    product.imageUrl != null
                        ? DecorationImage(
                          image: AssetImage(product.imageUrl!),
                          fit: BoxFit.contain,
                        )
                        : null,
              ),
              child:
                  product.imageUrl == null
                      ? Center(
                        child: Icon(
                          billingProductCategoryIcon(product.category),
                          size: 48,
                          color: const Color(0xFF2563EB),
                        ),
                      )
                      : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatBillingCurrency(
                          product.price,
                          preferences: preferences,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: 'Add item',
                      onPressed: () {
                        ref
                            .read(cartProvider.notifier)
                            .addToCart(product, tenantId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.square(38),
                        fixedSize: const Size.square(38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

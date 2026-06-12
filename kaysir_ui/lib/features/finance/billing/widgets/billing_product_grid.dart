import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_tenant.dart';
import '../states/billing_product_catalog_provider.dart';
import 'billing_product_card.dart';

class BillingProductGrid extends ConsumerWidget {
  final Tenant tenant;

  const BillingProductGrid({super.key, required this.tenant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider(tenant.id));

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Text(
              'No products match the current filters',
              style: TextStyle(color: Color(0xFF718096)),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns =
                width >= 1200
                    ? 5
                    : width >= 900
                    ? 4
                    : width >= 640
                    ? 3
                    : 2;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: 0.76,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return BillingProductCard(
                  product: product,
                  tenantId: tenant.id,
                  preferences: tenant.preferences,
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Failed to load products')),
    );
  }
}

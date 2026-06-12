import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/billing_product.dart';
import '../models/billing_product_filter.dart';
import '../models/billing_tenant.dart';
import '../repositories/billing_product_catalog_repository.dart';
import '../repositories/billing_product_tenant_repository.dart';
import '../utils/billing_product_collection.dart';

final currentTenantProvider = StateProvider<Tenant?>((ref) => null);

final billingProductTenantRepositoryProvider =
    Provider<BillingProductTenantRepository>(
      (ref) => const DemoBillingProductTenantRepository(),
    );

final billingProductCatalogRepositoryProvider =
    Provider<BillingProductCatalogRepository>(
      (ref) => const DemoBillingProductCatalogRepository(),
    );

final billingProductTenantsProvider = FutureProvider<List<Tenant>>((ref) async {
  return ref.watch(billingProductTenantRepositoryProvider).fetchTenants();
});

final productsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  tenantId,
) async {
  return ref
      .watch(billingProductCatalogRepositoryProvider)
      .fetchProducts(tenantId);
});

final productCatalogFilterProvider =
    StateProvider.family<BillingProductCatalogFilter, String>(
      (ref, tenantId) => const BillingProductCatalogFilter(),
    );

final productCategoriesProvider =
    Provider.family<AsyncValue<List<String>>, String>((ref, tenantId) {
      return ref
          .watch(productsProvider(tenantId))
          .whenData(billingProductCategories);
    });

final filteredProductsProvider =
    Provider.family<AsyncValue<List<Product>>, String>((ref, tenantId) {
      final productsAsync = ref.watch(productsProvider(tenantId));
      final filter = ref.watch(productCatalogFilterProvider(tenantId));

      return productsAsync.whenData((products) {
        return filterBillingProducts(
          products,
          query: filter.query,
          category: filter.category,
          sort: filter.sort,
        );
      });
    });

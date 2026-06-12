import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/models/billing_product_filter.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_product_catalog_repository.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_product_tenant_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_product_catalog_provider.dart';

void main() {
  test(
    'billingProductTenantsProvider loads tenants through the repository',
    () async {
      final repository = _FakeBillingProductTenantRepository();
      final container = _container(tenantRepository: repository);
      addTearDown(container.dispose);

      final tenants = await container.read(
        billingProductTenantsProvider.future,
      );

      expect(repository.fetchCount, 1);
      expect(tenants.map((tenant) => tenant.name), [
        'Acme Corp',
        'TechStart Inc',
      ]);
    },
  );

  test('productsProvider loads catalog through the repository', () async {
    final repository = _FakeBillingProductCatalogRepository();
    final container = _container(catalogRepository: repository);
    addTearDown(container.dispose);

    final products = await container.read(
      productsProvider('tenant-test').future,
    );

    expect(repository.tenantIds, ['tenant-test']);
    expect(products, hasLength(3));
    expect(
      products.map((product) => product.category),
      contains('Subscription'),
    );
    expect(
      products.map((product) => product.name),
      contains('Premium Support'),
    );
  });

  test('productCategoriesProvider exposes sorted categories', () async {
    final container = _container();
    addTearDown(container.dispose);

    await container.read(productsProvider('tenant-test').future);

    final categories = container.read(productCategoriesProvider('tenant-test'));

    expect(categories.requireValue, ['Hosting', 'Service', 'Subscription']);
  });

  test('filteredProductsProvider narrows by category query and sort', () async {
    final container = _container();
    addTearDown(container.dispose);

    await container.read(productsProvider('tenant-test').future);
    container
        .read(productCatalogFilterProvider('tenant-test').notifier)
        .state = const BillingProductCatalogFilter(
      sort: BillingProductSortOption.priceHighToLow,
    );

    final sorted = container.read(filteredProductsProvider('tenant-test'));
    expect(sorted.requireValue.map((product) => product.id), [
      'plan',
      'support',
      'hosting',
    ]);

    container
        .read(productCatalogFilterProvider('tenant-test').notifier)
        .state = container
        .read(productCatalogFilterProvider('tenant-test'))
        .withCategory('Service')
        .withQuery('support');

    final filtered = container.read(filteredProductsProvider('tenant-test'));

    expect(filtered.hasValue, isTrue);
    expect(filtered.requireValue.map((product) => product.name), [
      'Premium Support',
    ]);
  });

  test('product catalog filters stay isolated per tenant', () async {
    final container = _container();
    addTearDown(container.dispose);

    await container.read(productsProvider('tenant-test').future);

    container
        .read(productCatalogFilterProvider('tenant-test').notifier)
        .state = const BillingProductCatalogFilter(category: 'Service');

    expect(
      container
          .read(filteredProductsProvider('tenant-test'))
          .requireValue
          .map((product) => product.id),
      ['support'],
    );
    expect(
      container.read(productCatalogFilterProvider('tenant-other')).category,
      isNull,
    );
  });
}

ProviderContainer _container({
  BillingProductCatalogRepository? catalogRepository,
  BillingProductTenantRepository? tenantRepository,
}) {
  return ProviderContainer(
    overrides: [
      billingProductCatalogRepositoryProvider.overrideWithValue(
        catalogRepository ?? _FakeBillingProductCatalogRepository(),
      ),
      billingProductTenantRepositoryProvider.overrideWithValue(
        tenantRepository ?? _FakeBillingProductTenantRepository(),
      ),
    ],
  );
}

class _FakeBillingProductTenantRepository
    implements BillingProductTenantRepository {
  int fetchCount = 0;

  @override
  Future<List<Tenant>> fetchTenants() async {
    fetchCount++;
    return const [
      Tenant(id: 'tenant-a', name: 'Acme Corp', logoUrl: ''),
      Tenant(id: 'tenant-b', name: 'TechStart Inc', logoUrl: ''),
    ];
  }
}

class _FakeBillingProductCatalogRepository
    implements BillingProductCatalogRepository {
  final tenantIds = <String>[];

  @override
  Future<List<Product>> fetchProducts(String tenantId) async {
    tenantIds.add(tenantId);
    return const [
      Product(
        id: 'plan',
        name: 'Business Plan',
        price: 79.99,
        category: 'Subscription',
      ),
      Product(
        id: 'support',
        name: 'Premium Support',
        price: 29.99,
        category: 'Service',
      ),
      Product(
        id: 'hosting',
        name: 'Website Hosting',
        price: 15.99,
        category: 'Hosting',
      ),
    ];
  }
}

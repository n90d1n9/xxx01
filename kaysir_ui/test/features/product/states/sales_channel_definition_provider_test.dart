import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/states/sales_channel_definition_provider.dart';

void main() {
  test('product sales channel definitions provider exposes defaults', () {
    final container = ProviderContainer(
      overrides: [_memoryPreferencesRepositoryOverride()],
    );
    addTearDown(container.dispose);

    final registry = container.read(productSalesChannelProfileRegistryProvider);

    expect(
      registry.profileIds,
      defaultProductSalesChannelProfileRegistry.profileIds,
    );
    expect(
      registry.fallbackProfile,
      defaultProductSalesChannelProfileRegistry.fallbackProfile,
    );

    final definitions = container.read(productSalesChannelDefinitionsProvider);

    expect(definitions, defaultProductSalesChannelDefinitions);
  });

  test('product sales channel definitions provider follows active profile', () {
    final container = ProviderContainer(
      overrides: [_memoryPreferencesRepositoryOverride()],
    );
    addTearDown(container.dispose);

    container.read(productSalesChannelProfileIdProvider.notifier).state =
        ProductSalesChannelProfileId.digitalCommerce;

    expect(
      container.read(productSalesChannelProfileProvider),
      digitalCommerceProductSalesChannelProfile,
    );

    final definitions = container.read(productSalesChannelDefinitionsProvider);

    expect(definitions.map((definition) => definition.channel), [
      ProductSalesChannel.onlineStore,
      ProductSalesChannel.marketplace,
    ]);
  });

  test(
    'product sales channel profile falls back when selected id is absent',
    () {
      final container = ProviderContainer(
        overrides: [
          productSalesChannelProfilesProvider.overrideWithValue([
            counterServiceProductSalesChannelProfile,
          ]),
          _memoryPreferencesRepositoryOverride(),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(productSalesChannelProfileProvider),
        counterServiceProductSalesChannelProfile,
      );
    },
  );

  test('product sales channel profile registry can be overridden', () {
    final registry = ProductSalesChannelProfileRegistry(
      profiles: [
        omniRetailProductSalesChannelProfile,
        digitalCommerceProductSalesChannelProfile,
      ],
      fallbackProfileId: ProductSalesChannelProfileId.digitalCommerce,
    );
    final container = ProviderContainer(
      overrides: [
        productSalesChannelProfileRegistryProvider.overrideWithValue(registry),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(productSalesChannelProfilesProvider), [
      omniRetailProductSalesChannelProfile,
      digitalCommerceProductSalesChannelProfile,
    ]);

    container.read(productSalesChannelProfileIdProvider.notifier).state =
        ProductSalesChannelProfileId.counterService;

    expect(
      container.read(productSalesChannelProfileProvider),
      digitalCommerceProductSalesChannelProfile,
    );
    expect(
      container
          .read(productSalesChannelDefinitionsProvider)
          .map((definition) => definition.channel),
      [ProductSalesChannel.onlineStore, ProductSalesChannel.marketplace],
    );
  });

  test('product sales channel profile packs compose registry variants', () {
    const groceryProfileId = ProductSalesChannelProfileId('grocery_market');
    final groceryProfile = ProductSalesChannelProfile(
      id: groceryProfileId,
      title: 'Grocery Market',
      subtitle: 'Fresh goods and shelf scanning readiness',
      definitions: const [],
    );
    final container = ProviderContainer(
      overrides: [
        productSalesChannelProfilePacksProvider.overrideWithValue([
          defaultProductSalesChannelProfilePack,
          ProductSalesChannelProfilePack(
            id: 'grocery_pack',
            title: 'Grocery Pack',
            profiles: [groceryProfile],
            fallbackProfileId: groceryProfileId,
          ),
        ]),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    final registry = container.read(productSalesChannelProfileRegistryProvider);

    expect(registry.profileIds, [
      ProductSalesChannelProfileId.omniRetail,
      ProductSalesChannelProfileId.counterService,
      ProductSalesChannelProfileId.digitalCommerce,
      groceryProfileId,
    ]);
    expect(registry.fallbackProfile, groceryProfile);
    expect(container.read(productSalesChannelProfileProvider), groceryProfile);

    final overview = container.read(
      productSalesChannelProfilePackOverviewProvider,
    );

    expect(overview.statusLabel, 'Composable');
    expect(overview.selectedSourceLabel, 'Grocery Pack');
    expect(overview.fallbackProfile, groceryProfile);
  });

  test('product sales channel fallback provider overrides pack fallback', () {
    const groceryProfileId = ProductSalesChannelProfileId('grocery_market');
    final groceryProfile = ProductSalesChannelProfile(
      id: groceryProfileId,
      title: 'Grocery Market',
      subtitle: 'Fresh goods and shelf scanning readiness',
      definitions: const [],
    );
    final container = ProviderContainer(
      overrides: [
        productSalesChannelProfilePacksProvider.overrideWithValue([
          defaultProductSalesChannelProfilePack,
          ProductSalesChannelProfilePack(
            id: 'grocery_pack',
            title: 'Grocery Pack',
            profiles: [groceryProfile],
            fallbackProfileId: groceryProfileId,
          ),
        ]),
        productSalesChannelFallbackProfileIdProvider.overrideWithValue(
          ProductSalesChannelProfileId.digitalCommerce,
        ),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container
          .read(productSalesChannelProfileRegistryProvider)
          .fallbackProfile,
      digitalCommerceProductSalesChannelProfile,
    );
  });

  test('product sales channel profile provider accepts custom profile ids', () {
    const groceryProfileId = ProductSalesChannelProfileId('grocery_market');
    final groceryProfile = ProductSalesChannelProfile(
      id: groceryProfileId,
      title: 'Grocery Market',
      subtitle: 'Fresh goods and shelf scanning readiness',
      definitions: const [],
    );
    final registry = ProductSalesChannelProfileRegistry(
      profiles: [groceryProfile],
      fallbackProfileId: groceryProfileId,
    );
    final container = ProviderContainer(
      overrides: [
        productSalesChannelProfileRegistryProvider.overrideWithValue(registry),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    container.read(productSalesChannelProfileIdProvider.notifier).state =
        groceryProfileId;

    expect(container.read(productSalesChannelProfileProvider), groceryProfile);
    expect(container.read(productSalesChannelDefinitionsProvider), isEmpty);
  });

  test('product sales channel definitions provider can be overridden', () {
    final definition = ProductSalesChannelDefinition(
      channel: ProductSalesChannel.onlineStore,
      title: 'Custom Online',
      subtitle: 'Tenant-specific online readiness',
      readyWhen: (record) => record.unitPrice > 0,
      reviewFilter: InventoryProductCatalogFilter.all,
      issueDefinitions: [
        ProductSalesChannelIssueDefinition(
          blocker: ProductSalesChannelBlocker.missingPrice,
          label: 'missing price',
          reviewFilter: InventoryProductCatalogFilter.all,
          matches: (record) => record.unitPrice <= 0,
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        productSalesChannelDefinitionsProvider.overrideWithValue([definition]),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(productSalesChannelDefinitionsProvider), [
      definition,
    ]);
  });
}

dynamic _memoryPreferencesRepositoryOverride() {
  return productManagementPackPreferencesRepositoryProvider.overrideWithValue(
    ProductManagementPackPreferencesRepository(
      store: MemoryProductManagementPackPreferencesStore(),
    ),
  );
}

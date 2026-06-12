import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_saved_view.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_preferences.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_table_view_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_view_mode.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring_session.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/states/sales_channel_definition_provider.dart';

void main() {
  test('product management pack providers expose core defaults', () {
    final container = ProviderContainer(
      overrides: [_memoryPreferencesRepositoryOverride()],
    );
    addTearDown(container.dispose);

    expect(
      container.read(productManagementPackProvider),
      coreProductManagementPack,
    );
    expect(container.read(productManagementPackOptionsProvider), [
      coreProductManagementPack,
      groceryFreshGoodsProductManagementPack,
    ]);
    expect(container.read(productManagementProfilePacksProvider), [
      defaultProductSalesChannelProfilePack,
    ]);
    expect(
      container
          .read(productSalesChannelProfileRegistryProvider)
          .fallbackProfile,
      omniRetailProductSalesChannelProfile,
    );
  });

  test('product management packs activate variant profile packs', () async {
    final container = ProviderContainer(
      overrides: [
        productManagementPacksProvider.overrideWithValue([
          coreProductManagementPack,
          groceryFreshGoodsProductManagementPack,
        ]),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(productManagementPackIdProvider.notifier)
        .selectPack(ProductManagementPackId.groceryFreshGoods);
    container.read(productSalesChannelProfileIdProvider.notifier).state =
        groceryFreshGoodsProductManagementPack.defaultChannelProfileId;

    expect(
      container.read(productManagementPackProvider),
      groceryFreshGoodsProductManagementPack,
    );
    expect(container.read(productManagementProfilePacksProvider), [
      groceryFreshGoodsProductSalesChannelProfilePack,
    ]);
    expect(
      container
          .read(productSalesChannelProfileRegistryProvider)
          .fallbackProfile,
      groceryFreshGoodsProductSalesChannelProfile,
    );
    expect(
      container.read(productSalesChannelProfileProvider),
      groceryFreshGoodsProductSalesChannelProfile,
    );
  });

  test('product management fallback can pin an earlier active pack', () {
    final container = ProviderContainer(
      overrides: [
        productManagementPacksProvider.overrideWithValue([
          coreProductManagementPack,
          groceryFreshGoodsProductManagementPack,
        ]),
        productManagementFallbackPackIdProvider.overrideWithValue(
          ProductManagementPackId.coreCatalog,
        ),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(productManagementPackProvider),
      coreProductManagementPack,
    );
    expect(
      container.read(productManagementPackRegistryProvider).fallbackPack,
      coreProductManagementPack,
    );
  });

  test('product management pack id provider persists selected pack', () async {
    final store = MemoryProductManagementPackPreferencesStore();
    final container = ProviderContainer(
      overrides: [
        productManagementPackPreferencesRepositoryProvider.overrideWithValue(
          ProductManagementPackPreferencesRepository(store: store),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(productManagementPackIdProvider.notifier)
        .selectPack(ProductManagementPackId.groceryFreshGoods);
    await container.read(productManagementPackIdProvider.notifier).flush();

    expect(
      container.read(productManagementPackProvider).id.value,
      'grocery_fresh_goods',
    );
    expect(store.snapshot, {'selectedPackId': 'grocery_fresh_goods'});
  });

  test(
    'product management pack id provider persists selected channel profile',
    () async {
      final store = MemoryProductManagementPackPreferencesStore();
      final container = ProviderContainer(
        overrides: [
          productManagementPackPreferencesRepositoryProvider.overrideWithValue(
            ProductManagementPackPreferencesRepository(store: store),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(productManagementPackIdProvider.notifier)
          .selectPack(
            ProductManagementPackId.groceryFreshGoods,
            channelProfileId:
                groceryFreshGoodsProductManagementPack.defaultChannelProfileId,
          );
      await container.read(productManagementPackIdProvider.notifier).flush();

      expect(store.snapshot, {
        'selectedPackId': 'grocery_fresh_goods',
        'selectedChannelProfileId': 'grocery_fresh_goods',
      });
    },
  );

  test(
    'product management pack id provider preserves catalog table preferences',
    () async {
      final tableViewState =
          InventoryProductCatalogTablePreset.pricing.viewState;
      final store = MemoryProductManagementPackPreferencesStore(
        initialSnapshot: {
          'selectedPackId': 'core_catalog',
          'catalogViewMode': InventoryProductCatalogViewMode.table.key,
          'catalogTableViewState': tableViewState.toJson(),
        },
      );
      final container = ProviderContainer(
        overrides: [
          productManagementPackPreferencesRepositoryProvider.overrideWithValue(
            ProductManagementPackPreferencesRepository(store: store),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(productManagementPackIdProvider.notifier)
          .selectPack(ProductManagementPackId.groceryFreshGoods);
      await container.read(productManagementPackIdProvider.notifier).flush();

      final preferences = ProductManagementPackPreferences.fromJson(
        store.snapshot!,
      );
      expect(store.snapshot, {
        'selectedPackId': 'grocery_fresh_goods',
        'catalogPresentationState':
            InventoryProductCatalogPresentationState(
              viewMode: InventoryProductCatalogViewMode.table,
              tableViewState: tableViewState,
            ).toJson(),
      });
      expect(
        preferences.catalogViewMode,
        InventoryProductCatalogViewMode.table,
      );
      expect(preferences.catalogTableViewState.matches(tableViewState), isTrue);
      expect(
        preferences.catalogPresentationState.matches(
          InventoryProductCatalogPresentationState(
            viewMode: InventoryProductCatalogViewMode.table,
            tableViewState: tableViewState,
          ),
        ),
        isTrue,
      );
      expect(store.snapshot?['catalogViewMode'], isNull);
      expect(store.snapshot?['catalogTableViewState'], isNull);
    },
  );

  test(
    'product management preferences repository merges queued catalog saves',
    () async {
      final tableViewState =
          InventoryProductCatalogTablePreset.pricing.viewState;
      final store = MemoryProductManagementPackPreferencesStore(
        initialSnapshot: const {'selectedPackId': 'core_catalog'},
      );
      final repository = ProductManagementPackPreferencesRepository(
        store: store,
      );

      await Future.wait([
        repository.saveCatalogViewMode(InventoryProductCatalogViewMode.table),
        repository.saveCatalogTableViewState(tableViewState),
      ]);

      final preferences = ProductManagementPackPreferences.fromJson(
        store.snapshot!,
      );
      expect(store.snapshot, {
        'selectedPackId': 'core_catalog',
        'catalogPresentationState':
            InventoryProductCatalogPresentationState(
              viewMode: InventoryProductCatalogViewMode.table,
              tableViewState: tableViewState,
            ).toJson(),
      });
      expect(
        preferences.catalogViewMode,
        InventoryProductCatalogViewMode.table,
      );
      expect(preferences.catalogTableViewState.matches(tableViewState), isTrue);
      expect(
        preferences.catalogPresentationState.matches(
          InventoryProductCatalogPresentationState(
            viewMode: InventoryProductCatalogViewMode.table,
            tableViewState: tableViewState,
          ),
        ),
        isTrue,
      );
      expect(store.snapshot?['catalogViewMode'], isNull);
      expect(store.snapshot?['catalogTableViewState'], isNull);
    },
  );

  test(
    'product management preferences repository persists availability authoring session',
    () async {
      const session = ProductAvailabilityRuleAuthoringSession(
        selectedSourceId: 'freshness_availability_templates',
        selectedTemplateId: ProductAvailabilityRuleTemplateId.freshShelf,
        selectedTarget: ProductAvailabilityRuleAuthoringTarget.stockAttention,
      );
      final store = MemoryProductManagementPackPreferencesStore(
        initialSnapshot: const {'selectedPackId': 'core_catalog'},
      );
      final repository = ProductManagementPackPreferencesRepository(
        store: store,
      );

      await repository.saveAvailabilityAuthoringSession(session);

      var preferences = ProductManagementPackPreferences.fromJson(
        store.snapshot!,
      );
      expect(preferences.availabilityAuthoringSession, session);
      expect(store.snapshot, {
        'selectedPackId': 'core_catalog',
        'availabilityAuthoringSession': session.toJson(),
      });

      await repository.saveAvailabilityAuthoringSession(
        ProductAvailabilityRuleAuthoringSession.defaults,
      );

      preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);
      expect(
        preferences.availabilityAuthoringSession,
        ProductAvailabilityRuleAuthoringSession.defaults,
      );
      expect(store.snapshot, {'selectedPackId': 'core_catalog'});
    },
  );

  test(
    'product management preferences repository persists catalog saved views',
    () async {
      final savedView = InventoryProductCatalogSavedView(
        id: 'pricing-review',
        label: 'Pricing review',
        description: 'Margin review',
        presentationState:
            InventoryProductCatalogPresentationPreset.pricing.presentationState,
      );
      final store = MemoryProductManagementPackPreferencesStore(
        initialSnapshot: const {'selectedPackId': 'core_catalog'},
      );
      final repository = ProductManagementPackPreferencesRepository(
        store: store,
      );

      await repository.saveCatalogSavedView(savedView);

      var preferences = ProductManagementPackPreferences.fromJson(
        store.snapshot!,
      );
      expect(preferences.catalogSavedViews, hasLength(1));
      expect(preferences.catalogSavedViews.single.matches(savedView), isTrue);
      expect(preferences.activeCatalogSavedViewId, savedView.id);
      expect(
        preferences.catalogPresentationState.matches(
          savedView.presentationState,
        ),
        isTrue,
      );
      expect(store.snapshot?['catalogSavedViews'], isA<List>());
      expect(store.snapshot?['activeCatalogSavedViewId'], savedView.id);

      await repository.saveCatalogViewMode(
        InventoryProductCatalogViewMode.cards,
      );
      preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);

      expect(preferences.catalogSavedViews, hasLength(1));
      expect(preferences.activeCatalogSavedViewId, isNull);

      final updatedView = savedView.copyWith(
        description: 'Operations review',
        presentationState:
            InventoryProductCatalogPresentationPreset
                .operationsTable
                .presentationState,
      );
      await repository.saveCatalogSavedView(updatedView);
      preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);

      expect(preferences.catalogSavedViews, hasLength(1));
      expect(preferences.catalogSavedViews.single.matches(updatedView), isTrue);
      expect(preferences.activeCatalogSavedViewId, updatedView.id);
      expect(
        preferences.catalogPresentationState.matches(
          updatedView.presentationState,
        ),
        isTrue,
      );

      final renamedView = updatedView.copyWith(label: 'Ops startup');
      await repository.saveCatalogSavedViewMetadata(renamedView);
      preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);

      expect(preferences.catalogSavedViews.single.matches(renamedView), isTrue);
      expect(preferences.activeCatalogSavedViewId, renamedView.id);
      expect(
        preferences.catalogPresentationState.matches(
          updatedView.presentationState,
        ),
        isTrue,
      );

      await repository.setDefaultCatalogSavedView(renamedView.id);
      preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);

      expect(preferences.defaultCatalogSavedViewId, renamedView.id);
      expect(preferences.startupCatalogSavedViewId, renamedView.id);
      expect(
        preferences.startupCatalogPresentationState.matches(
          renamedView.presentationState,
        ),
        isTrue,
      );
      expect(store.snapshot?['defaultCatalogSavedViewId'], renamedView.id);

      await repository.deleteCatalogSavedView(updatedView.id);
      preferences = ProductManagementPackPreferences.fromJson(store.snapshot!);

      expect(preferences.catalogSavedViews, isEmpty);
      expect(preferences.activeCatalogSavedViewId, isNull);
      expect(preferences.defaultCatalogSavedViewId, isNull);
      expect(store.snapshot?['catalogSavedViews'], isNull);
      expect(store.snapshot?['activeCatalogSavedViewId'], isNull);
      expect(store.snapshot?['defaultCatalogSavedViewId'], isNull);
      expect(
        preferences.catalogPresentationState.matches(
          updatedView.presentationState,
        ),
        isTrue,
      );
    },
  );

  test('product management pack id provider hydrates persisted pack', () async {
    final store = MemoryProductManagementPackPreferencesStore(
      initialSnapshot: const {'selectedPackId': 'grocery_fresh_goods'},
    );
    final container = ProviderContainer(
      overrides: [
        productManagementPackPreferencesRepositoryProvider.overrideWithValue(
          ProductManagementPackPreferencesRepository(store: store),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(productManagementPackIdProvider.notifier).hydrate();

    expect(
      container.read(productManagementPackProvider),
      groceryFreshGoodsProductManagementPack,
    );
    expect(container.read(productManagementProfilePacksProvider), [
      groceryFreshGoodsProductSalesChannelProfilePack,
    ]);
  });

  test(
    'product management pack id provider falls back from stale persisted pack',
    () async {
      final store = MemoryProductManagementPackPreferencesStore(
        initialSnapshot: const {'selectedPackId': 'unknown_pack'},
      );
      final container = ProviderContainer(
        overrides: [
          productManagementPackPreferencesRepositoryProvider.overrideWithValue(
            ProductManagementPackPreferencesRepository(store: store),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(productManagementPackIdProvider.notifier).hydrate();

      expect(
        container.read(productManagementPackProvider),
        coreProductManagementPack,
      );
    },
  );
}

dynamic _memoryPreferencesRepositoryOverride() {
  return productManagementPackPreferencesRepositoryProvider.overrideWithValue(
    ProductManagementPackPreferencesRepository(
      store: MemoryProductManagementPackPreferencesStore(),
    ),
  );
}

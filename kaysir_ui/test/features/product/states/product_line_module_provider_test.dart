import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/states/product_line_module_provider.dart';
import 'package:kaysir/features/product/utils/default_product_line_module_manifests.dart';

void main() {
  test('product line module providers expose active core modules', () {
    final container = ProviderContainer(
      overrides: [_memoryPreferencesRepositoryOverride()],
    );
    addTearDown(container.dispose);

    expect(container.read(productLineModuleRegistryProvider).definitionIds, [
      'coffee_counter_operations',
      'restaurant_menu_operations',
      'retail_assortment_operations',
      'kiosk_self_service_operations',
    ]);
    expect(
      container
          .read(activeProductLineModuleDefinitionsProvider)
          .map((definition) => definition.normalizedId),
      [
        'coffee_counter_operations',
        'restaurant_menu_operations',
        'retail_assortment_operations',
        'kiosk_self_service_operations',
      ],
    );
    expect(
      container
          .read(activeProductLineModuleSetupTargetsProvider)
          .map((target) => target.normalizedId),
      ['coffee_menu', 'restaurant_menu', 'retail_assortment', 'kiosk_bundle'],
    );
    expect(
      container
          .read(productLineModuleContributionManifestsProvider)
          .map((manifest) => manifest.id),
      [
        'coffee_counter_operations',
        'restaurant_menu_operations',
        'retail_assortment_operations',
        'kiosk_self_service_operations',
      ],
    );
  });

  test('active product line providers follow selected management pack', () {
    final container = ProviderContainer(
      overrides: [
        _memoryPreferencesRepositoryOverride(),
        productManagementPackProvider.overrideWithValue(
          groceryFreshGoodsProductManagementPack,
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(activeProductLineModuleDefinitionsProvider), isEmpty);
    expect(
      container.read(activeProductLineModuleSetupTargetsProvider),
      isEmpty,
    );
  });

  test('product line definitions provider is overrideable', () {
    final container = ProviderContainer(
      overrides: [
        _memoryPreferencesRepositoryOverride(),
        productLineModuleDefinitionsProvider.overrideWithValue([
          coffeeCounterProductLineModuleDefinition,
        ]),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(productLineModuleRegistryProvider).definitionIds, [
      'coffee_counter_operations',
    ]);
    expect(
      container
          .read(productLineModuleContributionManifestsProvider)
          .map((manifest) => manifest.id),
      ['coffee_counter_operations'],
    );
  });
}

dynamic _memoryPreferencesRepositoryOverride() {
  return productManagementPackPreferencesRepositoryProvider.overrideWithValue(
    ProductManagementPackPreferencesRepository(
      store: MemoryProductManagementPackPreferencesStore(),
    ),
  );
}

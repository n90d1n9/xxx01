import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/edition.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/states/edition_provider.dart';

void main() {
  test('product edition providers expose default editions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registry = container.read(productEditionRegistryProvider);
    final editions = container.read(productEditionsProvider);

    expect(registry, defaultProductEditionRegistry);
    expect(editions, defaultProductEditions);
  });

  test('product edition providers support custom registries', () {
    const restaurantEdition = ProductEdition(
      id: ProductEditionId('restaurant_counter'),
      title: 'Restaurant Counter',
      subtitle: 'Counter-service menu catalog',
      description: 'Restaurant edition for cashier-led menu selling.',
      kind: ProductEditionKind.counterService,
      experienceProfileId: ProductExperienceProfileId.catalogOperations,
      managementPackId: ProductManagementPackId.coreCatalog,
      channelProfileId: ProductSalesChannelProfileId.counterService,
      capabilityLabels: ['Menu catalog', 'Counter checkout'],
    );
    const registry = ProductEditionRegistry([restaurantEdition]);
    final container = ProviderContainer(
      overrides: [productEditionRegistryProvider.overrideWithValue(registry)],
    );
    addTearDown(container.dispose);

    expect(container.read(productEditionsProvider), [restaurantEdition]);
    expect(
      container
          .read(productEditionRegistryProvider)
          .editionForId(const ProductEditionId('restaurant_counter')),
      restaurantEdition,
    );
  });
}

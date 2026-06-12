import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/edition.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test('default product edition registry resolves common editions', () {
    final registry = defaultProductEditionRegistry;

    expect(registry.hasEditions, isTrue);
    expect(registry.fallbackEdition, coreRetailProductEdition);
    expect(
      registry.editionForId(ProductEditionId.groceryFreshGoods),
      groceryFreshGoodsProductEdition,
    );
    expect(
      registry.editionForValue('digital_commerce'),
      digitalCommerceProductEdition,
    );
    expect(registry.editionForValue(' '), isNull);
  });

  test('product editions generate launch targets from edition defaults', () {
    final target = groceryFreshGoodsProductEdition.launchTarget();

    expect(target.title, 'Fresh Goods');
    expect(target.modeSourceLabel, 'Edition mode');
    expect(
      target.uri,
      '/product-workspace?experience=fresh_goods&pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
  });

  test('product edition registry filters by experience and kind', () {
    final registry = defaultProductEditionRegistry;

    expect(
      registry
          .editionsForExperienceProfile(
            ProductExperienceProfileId.omnichannelCommerce,
          )
          .map((edition) => edition.id),
      [ProductEditionId.digitalCommerce, ProductEditionId.kioskSelfService],
    );
    expect(
      registry
          .editionsForKind(ProductEditionKind.operations)
          .map((edition) => edition.id),
      [ProductEditionId.catalogOperations, ProductEditionId.stockControl],
    );
  });

  test('product editions fall back when an experience profile is missing', () {
    const registry = ProductExperienceProfileRegistry([
      productFullSuiteExperienceProfile,
    ]);
    final target = groceryFreshGoodsProductEdition.launchTarget(
      profileRegistry: registry,
    );

    expect(target.title, 'Products');
    expect(
      target.uri,
      '/product-workspace?experience=full_suite&pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
  });

  test('custom product editions can extend the registry', () {
    const coffeeEdition = ProductEdition(
      id: ProductEditionId('coffee_counter'),
      title: 'Coffee Counter',
      subtitle: 'Menu-style counter catalog',
      description: 'Coffee shop edition for cashier-led beverage products.',
      kind: ProductEditionKind.counterService,
      experienceProfileId: ProductExperienceProfileId.catalogOperations,
      managementPackId: ProductManagementPackId.coreCatalog,
      channelProfileId: ProductSalesChannelProfileId.counterService,
      capabilityLabels: ['Menu catalog', 'Fast checkout'],
    );
    const registry = ProductEditionRegistry([
      coffeeEdition,
      coreRetailProductEdition,
    ]);

    expect(registry.fallbackEdition, coffeeEdition);
    expect(registry.editionsForKind(ProductEditionKind.counterService), [
      coffeeEdition,
    ]);
    expect(coffeeEdition.capabilitySummaryLabel, 'Menu catalog, Fast checkout');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_module_destination.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test('default product experience registry resolves profiles', () {
    final registry = defaultProductExperienceProfileRegistry;

    expect(registry.hasProfiles, isTrue);
    expect(
      registry.profileForId(ProductExperienceProfileId.fullSuite),
      productFullSuiteExperienceProfile,
    );
    expect(
      registry.profileForValue('fresh_goods'),
      productFreshGoodsExperienceProfile,
    );
    expect(registry.profileForValue(' '), isNull);
    expect(
      registry.profileOrFallback(
        const ProductExperienceProfileId('unknown_profile'),
      ),
      productFullSuiteExperienceProfile,
    );
  });

  test('full suite profile exposes every default destination in order', () {
    final registry = productFullSuiteExperienceProfile.destinationRegistry();

    expect(
      registry.destinations.map((destination) => destination.id),
      defaultProductModuleDestinationIds,
    );
  });

  test('core operations profile excludes fresh-only modules', () {
    final registry =
        productCoreOperationsExperienceProfile.destinationRegistry();

    expect(
      productCoreOperationsExperienceProfile.defaultPackId,
      ProductManagementPackId.coreCatalog,
    );
    expect(
      registry.destinations.map((destination) => destination.id),
      isNot(contains(ProductModuleDestinationId.freshnessReview)),
    );
    expect(
      registry.destinations.map((destination) => destination.id),
      containsAll([
        ProductModuleDestinationId.catalog,
        ProductModuleDestinationId.stockMovements,
        ProductModuleDestinationId.discrepancyReport,
      ]),
    );
  });

  test('fresh goods profile exposes fresh operations and defaults', () {
    final registry = productFreshGoodsExperienceProfile.destinationRegistry();

    expect(productFreshGoodsExperienceProfile.workspaceTitle, 'Fresh Goods');
    expect(
      productFreshGoodsExperienceProfile.defaultPackId,
      ProductManagementPackId.groceryFreshGoods,
    );
    expect(
      productFreshGoodsExperienceProfile.defaultChannelProfileId,
      groceryFreshGoodsProfileId,
    );
    expect(registry.destinations.map((destination) => destination.id), [
      ProductModuleDestinationId.catalog,
      ProductModuleDestinationId.freshnessReview,
      ProductModuleDestinationId.stockOpname,
      ProductModuleDestinationId.scanProduct,
      ProductModuleDestinationId.discrepancyReport,
      ProductModuleDestinationId.availabilityManagement,
      ProductModuleDestinationId.channelReadiness,
      ProductModuleDestinationId.setupTargets,
      ProductModuleDestinationId.packContracts,
    ]);
    expect(
      productFreshGoodsExperienceProfile.containsDestinationId(
        ProductModuleDestinationId.pricingManagement,
      ),
      isFalse,
    );
  });

  test('omnichannel profile exposes channel commerce modules', () {
    final registry =
        productOmnichannelCommerceExperienceProfile.destinationRegistry();

    expect(
      productOmnichannelCommerceExperienceProfile.defaultChannelProfileId,
      ProductSalesChannelProfileId.digitalCommerce,
    );
    expect(registry.destinations.map((destination) => destination.id), [
      ProductModuleDestinationId.strategy,
      ProductModuleDestinationId.catalog,
      ProductModuleDestinationId.addProduct,
      ProductModuleDestinationId.channelReadiness,
      ProductModuleDestinationId.availabilityManagement,
      ProductModuleDestinationId.pricingManagement,
      ProductModuleDestinationId.relationshipManagement,
      ProductModuleDestinationId.stockMovements,
    ]);
  });

  test(
    'experience profile skips destinations unavailable in source registry',
    () {
      const source = ProductModuleDestinationRegistry([
        productCatalogDestination,
      ]);
      final registry = productStockControlExperienceProfile.destinationRegistry(
        source: source,
      );

      expect(registry.destinations, [productCatalogDestination]);
    },
  );

  test('product management pack ids resolve workspace experience profiles', () {
    expect(
      productExperienceProfileForManagementPackId(
        ProductManagementPackId.coreCatalog,
      ),
      productCoreOperationsExperienceProfile,
    );
    expect(
      productExperienceProfileForManagementPackId(
        ProductManagementPackId.groceryFreshGoods,
      ),
      productFreshGoodsExperienceProfile,
    );
    expect(
      productExperienceProfileForManagementPackId(
        const ProductManagementPackId('custom_pack'),
      ),
      productCoreOperationsExperienceProfile,
    );
  });
}

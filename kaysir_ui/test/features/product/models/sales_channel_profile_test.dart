import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';

void main() {
  test('default product sales channel profiles expose reusable packs', () {
    expect(
      defaultProductSalesChannelProfiles.map((profile) => profile.id),
      ProductSalesChannelProfileId.values,
    );
    expect(
      defaultProductSalesChannelProfile.id,
      ProductSalesChannelProfileId.omniRetail,
    );
    expect(
      omniRetailProductSalesChannelProfile.definitions,
      defaultProductSalesChannelDefinitions,
    );
    expect(
      omniRetailProductSalesChannelProfile.behavior.businessModelLabel,
      'Omni-channel retail',
    );
    expect(
      omniRetailProductSalesChannelProfile.behavior.capabilitySummaryLabel,
      'Store checkout, Online catalog + 2 more',
    );
  });

  test('counter and digital profiles select focused channel definitions', () {
    expect(
      counterServiceProductSalesChannelProfile.definitions.map(
        (definition) => definition.channel,
      ),
      [ProductSalesChannel.posCheckout, ProductSalesChannel.kiosk],
    );
    expect(
      digitalCommerceProductSalesChannelProfile.definitions.map(
        (definition) => definition.channel,
      ),
      [ProductSalesChannel.onlineStore, ProductSalesChannel.marketplace],
    );
    expect(
      counterServiceProductSalesChannelProfile.behavior.operatorFocusLabel,
      'Keep price, stock, and scan readiness fast for service',
    );
    expect(
      digitalCommerceProductSalesChannelProfile.behavior.capabilityLabels,
      ['SKU discipline', 'Product copy', 'Marketplace taxonomy'],
    );
    expect(
      productSalesChannelProfileFor(
        ProductSalesChannelProfileId.digitalCommerce,
      ),
      digitalCommerceProductSalesChannelProfile,
    );
  });

  test(
    'sales channel profile registry resolves fallbacks and query values',
    () {
      final registry = ProductSalesChannelProfileRegistry(
        profiles: [
          counterServiceProductSalesChannelProfile,
          digitalCommerceProductSalesChannelProfile,
        ],
        fallbackProfileId: ProductSalesChannelProfileId.counterService,
      );

      expect(registry.profileIds, [
        ProductSalesChannelProfileId.counterService,
        ProductSalesChannelProfileId.digitalCommerce,
      ]);
      expect(
        registry.contains(ProductSalesChannelProfileId.omniRetail),
        isFalse,
      );
      expect(
        registry.resolve(ProductSalesChannelProfileId.digitalCommerce),
        digitalCommerceProductSalesChannelProfile,
      );
      expect(
        registry.resolve(ProductSalesChannelProfileId.omniRetail),
        counterServiceProductSalesChannelProfile,
      );
      expect(
        registry.resolveQueryValue('online'),
        ProductSalesChannelProfileId.digitalCommerce,
      );
      expect(
        registry.resolveQueryValue('omni-retail'),
        ProductSalesChannelProfileId.counterService,
      );
      expect(
        registry.fallbackProfile,
        counterServiceProductSalesChannelProfile,
      );
    },
  );

  test('sales channel profile ids support custom product packs', () {
    const groceryProfileId = ProductSalesChannelProfileId('grocery_market');
    const sameGroceryProfileId = ProductSalesChannelProfileId('grocery_market');
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

    expect(groceryProfileId, sameGroceryProfileId);
    expect(
      productSalesChannelProfileQueryValue(groceryProfileId),
      'grocery_market',
    );
    expect(registry.contains(sameGroceryProfileId), isTrue);
    expect(registry.resolve(sameGroceryProfileId), groceryProfile);
    expect(registry.resolveQueryValue('grocery-market'), groceryProfileId);
    expect(
      registry.profileOrNull(ProductSalesChannelProfileId.omniRetail),
      isNull,
    );
  });

  test('sales channel profile registry composes profile packs', () {
    const groceryProfileId = ProductSalesChannelProfileId('grocery_market');
    final groceryProfile = ProductSalesChannelProfile(
      id: groceryProfileId,
      title: 'Grocery Market',
      subtitle: 'Fresh goods and shelf scanning readiness',
      definitions: const [],
    );
    final digitalOverride = ProductSalesChannelProfile(
      id: ProductSalesChannelProfileId.digitalCommerce,
      title: 'Digital Growth',
      subtitle: 'Custom digital commerce pack',
      definitions: const [],
    );
    final registry = ProductSalesChannelProfileRegistry.fromPacks([
      defaultProductSalesChannelProfilePack,
      ProductSalesChannelProfilePack(
        id: 'grocery_pack',
        title: 'Grocery Pack',
        profiles: [digitalOverride, groceryProfile],
        fallbackProfileId: groceryProfileId,
      ),
    ]);

    expect(registry.profileIds, [
      ProductSalesChannelProfileId.omniRetail,
      ProductSalesChannelProfileId.counterService,
      ProductSalesChannelProfileId.digitalCommerce,
      groceryProfileId,
    ]);
    expect(
      registry.resolve(ProductSalesChannelProfileId.digitalCommerce),
      digitalOverride,
    );
    expect(registry.fallbackProfile, groceryProfile);
    expect(
      defaultProductSalesChannelProfilePack.title,
      'Default Product Channels',
    );
  });

  test('sales channel profile query values round trip safely', () {
    expect(
      productSalesChannelProfileQueryValue(
        ProductSalesChannelProfileId.counterService,
      ),
      'counter_service',
    );
    expect(
      productSalesChannelProfileIdFromQuery('digital-commerce'),
      ProductSalesChannelProfileId.digitalCommerce,
    );
    expect(
      productSalesChannelProfileIdFromQuery('grocery-market'),
      const ProductSalesChannelProfileId('grocery_market'),
    );
    expect(
      productSalesChannelProfileIdFromQuery(' unknown pack '),
      const ProductSalesChannelProfileId('unknown_pack'),
    );
  });

  test('profile behavior defaults support custom profile packs', () {
    final profile = ProductSalesChannelProfile(
      id: ProductSalesChannelProfileId.counterService,
      title: 'Wholesale Pack',
      subtitle: 'Partner ordering readiness',
      definitions: const [],
    );

    expect(profile.behavior, defaultProductSalesChannelProfileBehavior);
    expect(profile.behavior.businessModelLabel, 'Product operations');
    expect(profile.behavior.capabilitySummaryLabel, 'Custom product behavior');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/experience_profile_launch_target.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test(
    'experience launch target uses current mode when profile has no default',
    () {
      final target = ProductExperienceProfileLaunchTarget.forProfile(
        productStockControlExperienceProfile,
        fallbackPackId: ProductManagementPackId.coreCatalog,
        fallbackChannelProfileId: ProductSalesChannelProfileId.omniRetail,
      );

      expect(target.title, 'Product Stock Control');
      expect(target.subtitle, 'Counts, ledger, and variance');
      expect(target.modeSourceLabel, 'Current mode');
      expect(
        target.uri,
        '/product-workspace?experience=stock_control&pack=core_catalog&profile=omni_retail',
      );
    },
  );

  test('experience launch target prefers profile pack and channel defaults', () {
    final target = ProductExperienceProfileLaunchTarget.forProfile(
      productFreshGoodsExperienceProfile,
      fallbackPackId: ProductManagementPackId.coreCatalog,
      fallbackChannelProfileId: ProductSalesChannelProfileId.omniRetail,
    );

    expect(target.modeSourceLabel, 'Profile mode');
    expect(
      target.uri,
      '/product-workspace?experience=fresh_goods&pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
  });

  test('experience launch target supports partial profile defaults', () {
    final target = ProductExperienceProfileLaunchTarget.forProfile(
      productOmnichannelCommerceExperienceProfile,
      fallbackPackId: ProductManagementPackId.coreCatalog,
      fallbackChannelProfileId: groceryFreshGoodsProfileId,
    );

    expect(target.modeSourceLabel, 'Mixed mode');
    expect(
      target.uri,
      '/product-workspace?experience=omnichannel_commerce&pack=core_catalog&profile=digital_commerce',
    );
  });

  test('experience launch targets can be generated from a registry', () {
    const registry = ProductExperienceProfileRegistry([
      productCatalogOperationsExperienceProfile,
      productFreshGoodsExperienceProfile,
    ]);

    final targets = productExperienceProfileLaunchTargetsForRegistry(
      registry,
      fallbackPackId: ProductManagementPackId.coreCatalog,
      fallbackChannelProfileId: ProductSalesChannelProfileId.omniRetail,
    );

    expect(targets.map((target) => target.title), [
      'Product Catalog',
      'Fresh Goods',
    ]);
    expect(targets.first.modeSourceLabel, 'Current mode');
    expect(targets.last.modeSourceLabel, 'Profile mode');
  });
}

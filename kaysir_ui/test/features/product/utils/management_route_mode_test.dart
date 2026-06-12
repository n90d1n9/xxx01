import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/utils/management_route_mode.dart';

void main() {
  test('product route mode leaves default catalog URLs clean', () {
    const mode = ProductManagementRouteMode(
      packId: ProductManagementPackId.coreCatalog,
      channelProfileId: ProductSalesChannelProfileId.omniRetail,
    );

    expect(
      productRouteWithManagementMode(ProductRoutes.catalogPath, mode: mode),
      ProductRoutes.catalogPath,
    );
  });

  test('product route mode appends active mode to supported product URLs', () {
    const mode = ProductManagementRouteMode(
      packId: ProductManagementPackId.groceryFreshGoods,
      channelProfileId: ProductSalesChannelProfileId('grocery_fresh_goods'),
    );

    expect(
      productRouteWithManagementMode(
        '/products?filter=attention&review=Attention+Review',
        mode: mode,
      ),
      '/products?filter=attention&review=Attention+Review&pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        '/product-workspace?setup=freshness',
        mode: mode,
      ),
      '/product-workspace?setup=freshness&pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(ProductRoutes.strategyPath, mode: mode),
      '/products/strategy?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        ProductRoutes.assortmentPlanningPath,
        mode: mode,
      ),
      '/products/assortment-planning?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        ProductRoutes.categoryManagementPath,
        mode: mode,
      ),
      '/products/categories?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        ProductRoutes.pricingManagementPath,
        mode: mode,
      ),
      '/products/pricing?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        ProductRoutes.sourcingManagementPath,
        mode: mode,
      ),
      '/products/sourcing?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        ProductRoutes.lifecycleManagementPath,
        mode: mode,
      ),
      '/products/lifecycle?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        ProductRoutes.variantManagementPath,
        mode: mode,
      ),
      '/products/variants?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        ProductRoutes.relationshipManagementPath,
        mode: mode,
      ),
      '/products/relationships?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        ProductRoutes.availabilityManagementPath,
        mode: mode,
      ),
      '/products/availability?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        ProductRoutes.channelReadinessPath,
        mode: mode,
      ),
      '/products/channel-readiness?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        ProductRoutes.setupTargetsPath,
        mode: mode,
      ),
      '/products/setup-targets?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        ProductRoutes.packContractsPath,
        mode: mode,
      ),
      '/products/pack-contracts?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(
        ProductRoutes.freshnessReviewPath,
        mode: mode,
      ),
      '/products/freshness?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode(ProductRoutes.addProductPath, mode: mode),
      '/products/new?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productRouteWithManagementMode('/products/p1/edit', mode: mode),
      '/products/p1/edit?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
  });

  test(
    'product route mode preserves explicit route mode and unsupported URLs',
    () {
      const mode = ProductManagementRouteMode(
        packId: ProductManagementPackId.groceryFreshGoods,
        channelProfileId: ProductSalesChannelProfileId('grocery_fresh_goods'),
      );

      expect(
        productRouteWithManagementMode(
          '/products?pack=core_catalog&profile=counter_service',
          mode: mode,
        ),
        '/products?pack=core_catalog&profile=counter_service',
      );
      expect(
        productRouteWithManagementMode(
          '/products/new?pack=core_catalog',
          mode: mode,
        ),
        '/products/new?pack=core_catalog&profile=grocery_fresh_goods',
      );
      expect(
        productRouteWithManagementMode('/products/p1', mode: mode),
        '/products/p1',
      );
    },
  );
}

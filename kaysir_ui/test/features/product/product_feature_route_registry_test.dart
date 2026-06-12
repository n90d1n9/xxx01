import 'package:flutter_test/flutter_test.dart';
import 'package:ky_core/core/features/feature_routes.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/product_module_destination.dart';
import 'package:kaysir/features/product/product_feature_route_registry.dart';
import 'package:kaysir/features/product/product_routes.dart';

void main() {
  test('product feature route registry builds workspace route tree', () {
    const registry = ProductFeatureRouteRegistry();
    final route = registry.workspaceRoute();

    expect(route.name, ProductRoutes.workspaceRouteName);
    expect(route.title, 'Products');
    expect(route.subtitle, 'Catalog and stock health');
    expect(route.path, ProductRoutes.workspacePath);
    expect(route.icon, 'inventory');
    expect(route.pageBuilder, isNotNull);
    expect(route.position, contains(MenuPosition.sidebar));
    expect(route.items.map((item) => item.name), [
      for (final destination
          in defaultProductModuleDestinationRegistry.destinations)
        destination.routeName,
    ]);
    expect(_catalogRouteIn(route).items.map((item) => item.name), [
      ProductRoutes.editProductRouteName,
    ]);
  });

  test(
    'product feature route registry accepts custom destination registries',
    () {
      const registry = ProductFeatureRouteRegistry(
        destinationRegistry: ProductModuleDestinationRegistry([
          productCatalogDestination,
          productFreshnessReviewDestination,
        ]),
      );
      final route = registry.workspaceRoute();

      expect(route.items.map((item) => item.name), [
        ProductRoutes.catalogRouteName,
        ProductRoutes.freshnessReviewRouteName,
      ]);
      expect(_catalogRouteIn(route).items.map((item) => item.name), [
        ProductRoutes.editProductRouteName,
      ]);
    },
  );

  test(
    'product feature route registry keeps edit reachable without catalog',
    () {
      const registry = ProductFeatureRouteRegistry(
        destinationRegistry: ProductModuleDestinationRegistry([
          productFreshnessReviewDestination,
        ]),
      );
      final route = registry.workspaceRoute();

      expect(route.items.map((item) => item.name), [
        ProductRoutes.freshnessReviewRouteName,
        ProductRoutes.editProductRouteName,
      ]);
    },
  );

  test(
    'product feature route registry scopes routes by experience profile',
    () {
      const registry = ProductFeatureRouteRegistry(
        experienceProfile: productFreshGoodsExperienceProfile,
      );
      final route = registry.workspaceRoute();

      expect(route.title, 'Fresh Goods');
      expect(route.subtitle, 'Fresh inventory operations');
      expect(route.items.map((item) => item.name), [
        ProductRoutes.catalogRouteName,
        ProductRoutes.freshnessReviewRouteName,
        ProductRoutes.stockOpnameRouteName,
        ProductRoutes.scanProductRouteName,
        ProductRoutes.discrepancyReportRouteName,
        ProductRoutes.availabilityManagementRouteName,
        ProductRoutes.channelReadinessRouteName,
        ProductRoutes.setupTargetsRouteName,
        ProductRoutes.packContractsRouteName,
      ]);
      expect(_catalogRouteIn(route).items.map((item) => item.name), [
        ProductRoutes.editProductRouteName,
      ]);
    },
  );

  test('product feature route registry accepts route-time profiles', () {
    const registry = ProductFeatureRouteRegistry();
    final route = registry.workspaceRoute(
      experienceProfile: productStockControlExperienceProfile,
    );

    expect(route.title, 'Product Stock Control');
    expect(route.items.map((item) => item.name), [
      ProductRoutes.catalogRouteName,
      ProductRoutes.stockMovementsRouteName,
      ProductRoutes.addStockMovementRouteName,
      ProductRoutes.stockOpnameRouteName,
      ProductRoutes.scanProductRouteName,
      ProductRoutes.discrepancyReportRouteName,
    ]);
    expect(_catalogRouteIn(route).items.map((item) => item.name), [
      ProductRoutes.editProductRouteName,
    ]);
  });
}

FeatureRoutes _catalogRouteIn(FeatureRoutes route) {
  return route.items.singleWhere(
    (item) => item.name == ProductRoutes.catalogRouteName,
  );
}

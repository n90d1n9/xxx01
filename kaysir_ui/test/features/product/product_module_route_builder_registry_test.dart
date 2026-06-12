import 'package:flutter_test/flutter_test.dart';
import 'package:ky_core/core/features/feature_routes.dart';
import 'package:kaysir/features/product/models/product_module_destination.dart';
import 'package:kaysir/features/product/product_module_route_builder_registry.dart';
import 'package:kaysir/features/product/product_routes.dart';

void main() {
  test(
    'product module route builder registry creates routes for destinations',
    () {
      const registry = ProductModuleRouteBuilderRegistry();

      for (final destination
          in defaultProductModuleDestinationRegistry.destinations) {
        final route = registry.routeForDestination(destination);

        expect(route.name, destination.routeName);
        expect(route.title, destination.title);
        expect(route.subtitle, destination.subtitle);
        expect(route.description, destination.description);
        expect(route.path, destination.path);
        expect(route.icon, 'inventory');
        expect(route.pageBuilder, isNotNull);
        expect(route.position, contains(MenuPosition.sidebar));
      }
    },
  );

  test('product module route builder registry exposes all page builders', () {
    const registry = ProductModuleRouteBuilderRegistry();

    for (final destinationId in ProductModuleDestinationId.values) {
      expect(
        registry.pageBuilderForDestinationId(destinationId),
        isNotNull,
        reason: '$destinationId should have a page builder',
      );
    }
  });

  test('product module route builder registry attaches child routes', () {
    const registry = ProductModuleRouteBuilderRegistry();
    final editRoute = registry.editProductRoute();
    final route = registry.routeForDestination(
      productCatalogDestination,
      childRoutes: [editRoute],
    );

    expect(route.items, [editRoute]);
  });

  test('product module route builder registry owns hidden workflow routes', () {
    const registry = ProductModuleRouteBuilderRegistry();

    expect(
      registry
          .childRoutesForDestination(productCatalogDestination)
          .map((route) => route.name),
      [ProductRoutes.editProductRouteName],
    );
    expect(
      registry.childRoutesForDestination(productFreshnessReviewDestination),
      isEmpty,
    );
    expect(
      registry
          .fallbackRoutesForDestinations([productFreshnessReviewDestination])
          .map((route) => route.name),
      [ProductRoutes.editProductRouteName],
    );
    expect(
      registry.fallbackRoutesForDestinations([
        productCatalogDestination,
        productFreshnessReviewDestination,
      ]),
      isEmpty,
    );
  });

  test('product module route builder registry keeps edit route hidden', () {
    const registry = ProductModuleRouteBuilderRegistry();
    final route = registry.editProductRoute();

    expect(route.name, ProductRoutes.editProductRouteName);
    expect(route.title, 'Edit Product');
    expect(route.path, ProductRoutes.editProductPath);
    expect(route.pageBuilder, isNotNull);
    expect(route.position, isNot(contains(MenuPosition.sidebar)));
  });
}

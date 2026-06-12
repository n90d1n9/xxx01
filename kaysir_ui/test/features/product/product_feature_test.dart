import 'package:flutter_test/flutter_test.dart';
import 'package:ky_core/core/features/feature_routes.dart';
import 'package:kaysir/core/routes/shell/route_search_index.dart';
import 'package:kaysir/core/routes/shell/route_shell_metadata.dart';
import 'package:kaysir/features/product/models/product_module_destination.dart';
import 'package:kaysir/features/product/product_feature.dart';
import 'package:kaysir/features/product/product_routes.dart';

void main() {
  test('product feature exposes module destinations for the sidebar', () {
    final root = ProductFeature().registerScreens().single;
    final catalog = root.items.singleWhere(
      (item) => item.name == ProductRoutes.catalogRouteName,
    );
    final editProduct = catalog.items.singleWhere(
      (item) => item.name == ProductRoutes.editProductRouteName,
    );

    expect(root.name, ProductRoutes.workspaceRouteName);
    expect(root.title, 'Products');
    expect(root.subtitle, 'Catalog and stock health');
    expect(root.path, ProductFeature.workspacePath);
    expect(root.pageBuilder, isNotNull);
    expect(root.position, contains(MenuPosition.sidebar));

    for (final destination in defaultProductModuleDestinations) {
      final route = root.items.singleWhere(
        (item) => item.name == destination.routeName,
      );

      expect(route.name, destination.routeName);
      expect(route.title, destination.title);
      expect(route.subtitle, destination.subtitle);
      expect(route.description, destination.description);
      expect(route.path, destination.path);
      expect(route.pageBuilder, isNotNull);
      expect(route.position, contains(MenuPosition.sidebar));
    }

    expect(editProduct.title, 'Edit Product');
    expect(editProduct.path, ProductFeature.editProductPath);
    expect(editProduct.pageBuilder, isNotNull);
    expect(editProduct.position, isNot(contains(MenuPosition.sidebar)));
    expect(
      root.items.map((item) => item.name),
      isNot(contains(ProductRoutes.editProductRouteName)),
    );
  });

  test('product feature exposes product sidebar destinations in order', () {
    final root = ProductFeature().registerScreens().single;
    final sidebarItems =
        root.items
            .where((item) => item.position.contains(MenuPosition.sidebar))
            .toList();

    expect(
      sidebarItems.map((item) => item.title),
      defaultProductModuleDestinationRegistry.titles,
    );
    expect(
      sidebarItems.map((item) => item.path),
      defaultProductModuleDestinationRegistry.paths,
    );
    expect(
      root.items
          .singleWhere((item) => item.name == ProductRoutes.catalogRouteName)
          .items
          .singleWhere(
            (item) => item.name == ProductRoutes.editProductRouteName,
          )
          .position,
      isNot(contains(MenuPosition.sidebar)),
    );
  });

  test('product feature sidebar routes are visible to the route shell', () {
    final routes = ProductFeature().registerScreens();
    final visibleRoutes = routeShellVisibleNavigableRoutes(routes);

    expect(visibleRoutes.map(routeShellLabel), [
      'Products',
      ...defaultProductModuleDestinationRegistry.titles,
    ]);
    expect(visibleRoutes.map((route) => route.path), [
      ProductFeature.workspacePath,
      ...defaultProductModuleDestinationRegistry.paths,
    ]);
    expect(
      visibleRoutes.map((route) => route.name),
      isNot(contains(ProductRoutes.editProductRouteName)),
    );
  });

  test('product feature sidebar routes are indexed for route search', () {
    final routes = ProductFeature().registerScreens();
    final entries = buildRouteSearchEntries(routes);
    final visiblePaths =
        routeShellVisibleNavigableRoutes(
          routes,
        ).map((route) => route.path).whereType<String>().toList();

    expect(entries.map((entry) => entry.path), containsAll(visiblePaths));
    expect(
      entries.map((entry) => entry.path),
      isNot(contains(ProductFeature.editProductPath)),
    );
    expect(
      entries.singleWhere((entry) => entry.path == ProductFeature.catalogPath),
      isA<RouteSearchEntry>()
          .having((entry) => entry.title, 'title', 'Product Catalog')
          .having((entry) => entry.section, 'section', 'Products'),
    );
    expect(
      filterRouteSearchEntries(entries, 'barcode').single.path,
      ProductFeature.scanProductPath,
    );
  });

  test('product edit route selects the visible catalog route', () {
    final visibleRoute = routeShellSelectedVisibleRouteForPath(
      ProductFeature().registerScreens(),
      '/products/sku-1/edit',
    );

    expect(visibleRoute, isNotNull);
    expect(routeShellLabel(visibleRoute!), 'Product Catalog');
    expect(visibleRoute.path, ProductFeature.catalogPath);
  });
}

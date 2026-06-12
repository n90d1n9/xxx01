import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/core/features/features_registry.dart';
import 'package:kaysir/core/routes/routes.dart';
import 'package:kaysir/features/inventory/inventory_routes.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/routes/redirect_config.dart' as app_redirect;
import 'package:kaysir/routes/register_features.dart';
import 'package:kaysir/routes/register_routes_screen.dart';

void main() {
  setUp(FeaturesRegistry.reset);
  tearDown(FeaturesRegistry.reset);

  test('registered feature route names are unique for go_router', () {
    final features = [
      for (final feature in registerFeatures()) ...feature.registerScreens(),
      ...registerScreens(),
    ];
    final routePathsByName = <String, String>{};
    final duplicateNames = <String>[];

    void visit(FeatureRoutes route) {
      final routeName = route.goRouteName;
      if (route.path != null &&
          route.pageBuilder != null &&
          routeName != null) {
        final existingPath = routePathsByName[routeName];
        if (existingPath != null) {
          duplicateNames.add('$routeName:$existingPath, ${route.path}');
        } else {
          routePathsByName[routeName] = route.path!;
        }
      }

      for (final child in route.items) {
        visit(child);
      }
    }

    for (final feature in features) {
      visit(feature);
    }

    expect(duplicateNames, isEmpty);
  });

  test('registered go_router route graph names are unique', () {
    FeaturesRegistry.init();

    expect(_duplicateGoRouteNames(_registeredRouteRoots()), isEmpty);
  });

  test('stateful shell branch defaults are not parameterized', () {
    FeaturesRegistry.init();

    final parameterizedBranchDefaults = [
      for (final branch in Routes.branches)
        if (branch.initialLocation == null)
          if (branch.defaultRoute case final defaultRoute?)
            if (_hasPathParameters(defaultRoute.path)) defaultRoute.path,
    ];

    expect(parameterizedBranchDefaults, isEmpty);
    expect(
      _registeredTopLevelRoutePaths(),
      contains(ProductRoutes.editProductPath),
    );
  });

  test('registered page routes are reachable from sidebar unless hidden', () {
    final hiddenUtilityPaths = {
      app_redirect.loginRoute,
      ProductRoutes.editProductPath,
      InventoryRoutes.legacyStockOpname,
      InventoryRoutes.warehouseBranchDetail,
      InventoryRoutes.warehouseDetail,
    };
    final missingSidebarRoutes = <String>[];

    void visit(FeatureRoutes route) {
      final path = route.path?.trim();
      final hasPage =
          path != null &&
          path.isNotEmpty &&
          (route.pageBuilder != null ||
              route.builder != null ||
              route.child != null);
      if (hasPage &&
          !route.position.contains(MenuPosition.sidebar) &&
          !hiddenUtilityPaths.contains(path)) {
        missingSidebarRoutes.add('${route.title ?? route.name}:$path');
      }

      for (final child in route.items) {
        visit(child);
      }
    }

    for (final feature in [
      for (final feature in registerFeatures()) ...feature.registerScreens(),
      ...registerScreens(),
    ]) {
      visit(feature);
    }

    expect(missingSidebarRoutes, isEmpty);
  });

  test('feature route registration is idempotent', () {
    FeaturesRegistry.init();
    final firstSnapshot = _registeredGoRouteNames(_registeredRouteRoots());

    FeaturesRegistry.init();
    final secondSnapshot = _registeredGoRouteNames(_registeredRouteRoots());

    expect(secondSnapshot, firstSnapshot);
    expect(_duplicateGoRouteNames(_registeredRouteRoots()), isEmpty);
  });
}

List<RouteBase> _registeredRouteRoots() {
  return [
    ...Routes.routes,
    ...Routes.shellBranch('main', '/', const SizedBox.shrink()).routes,
    for (final branch in Routes.branches) ...branch.routes,
  ];
}

List<String> _registeredTopLevelRoutePaths() {
  return RouteBase.routesRecursively(
    Routes.routes,
  ).whereType<GoRoute>().map((route) => route.path).toList(growable: false);
}

bool _hasPathParameters(String path) {
  return path
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .any((segment) => segment.startsWith(':'));
}

List<String> _registeredGoRouteNames(List<RouteBase> roots) {
  return RouteBase.routesRecursively(roots)
      .whereType<GoRoute>()
      .map((route) => route.name)
      .whereType<String>()
      .toList(growable: false);
}

List<String> _duplicateGoRouteNames(List<RouteBase> roots) {
  final pathsByName = <String, List<String>>{};

  for (final route in RouteBase.routesRecursively(roots).whereType<GoRoute>()) {
    final name = route.name;
    if (name == null) continue;

    pathsByName.putIfAbsent(name, () => <String>[]).add(route.path);
  }

  return [
    for (final entry in pathsByName.entries)
      if (entry.value.length > 1) '${entry.key}:${entry.value.join(', ')}',
  ];
}

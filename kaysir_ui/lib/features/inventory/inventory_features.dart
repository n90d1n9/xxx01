import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ky_core/core/features/feature_routes.dart';
import 'package:ky_core/core/features/features_base.dart';

import 'inventory_feature_route_catalog.dart';
import 'invent_apps.dart';
import 'inventory_routes.dart';

class InventoryFeatures extends FeaturesBase {
  @override
  List<FeatureRoutes> registerScreens() => [
    FeatureRoutes(
      name: 'Inventory',
      title: 'Inventory',
      subtitle: 'Stock operations',
      description:
          'Inventory workspace for stock, products, warehouses, purchasing, counts, reports, and replenishment.',
      icon: 'inventory',
      items: [
        for (final destination in inventoryFeatureRouteDestinations)
          _routeForDestination(destination),
        _warehouseBranchDetailRoute(),
        _warehouseDetailRoute(),
        _legacyStockOpnameRoute(),
      ],
    ),
  ];
}

FeatureRoutes _routeForDestination(
  InventoryFeatureRouteDestination destination,
) {
  return FeatureRoutes(
    name: destination.name,
    subtitle: destination.subtitle,
    description: destination.description,
    path: destination.path,
    icon: 'inventory',
    pageBuilder: _inventoryPageBuilder(destination.path),
  );
}

FeatureRoutes _legacyStockOpnameRoute() {
  return FeatureRoutes(
    name: 'Stock Opname Legacy',
    subtitle: 'Compatibility route',
    description:
        'Legacy stock opname URL retained for older links; use ${InventoryRoutes.stockOpname} in the sidebar.',
    path: InventoryRoutes.legacyStockOpname,
    icon: 'inventory',
    position: const [MenuPosition.node],
    pageBuilder: _inventoryPageBuilder(InventoryRoutes.stockOpname),
  );
}

FeatureRoutes _warehouseBranchDetailRoute() {
  return FeatureRoutes(
    name: 'Warehouse Branch Detail',
    subtitle: 'Branch drilldown',
    description:
        'Hidden warehouse branch drilldown for branch capacity, stock pressure, and operational shortcuts.',
    path: InventoryRoutes.warehouseBranchDetail,
    icon: 'inventory',
    position: const [MenuPosition.node],
    pageBuilder: _inventoryPageBuilder(InventoryRoutes.warehouseBranchDetail),
  );
}

FeatureRoutes _warehouseDetailRoute() {
  return FeatureRoutes(
    name: 'Warehouse Detail',
    subtitle: 'Location drilldown',
    description:
        'Hidden warehouse drilldown for location capacity, stock readiness, recent movement context, and scoped shortcuts.',
    path: InventoryRoutes.warehouseDetail,
    icon: 'inventory',
    position: const [MenuPosition.node],
    pageBuilder: _inventoryPageBuilder(InventoryRoutes.warehouseDetail),
  );
}

Page<dynamic> Function(BuildContext, GoRouterState) _inventoryPageBuilder(
  String initialRoute,
) {
  return (BuildContext context, GoRouterState state) {
    final route = state.uri.query.isEmpty ? initialRoute : state.uri.toString();
    return MaterialPage(child: InventoryManagementApp(initialRoute: route));
  };
}

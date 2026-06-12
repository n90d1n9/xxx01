import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/inventory_feature_route_catalog.dart';
import 'package:kaysir/features/inventory/inventory_features.dart';
import 'package:kaysir/features/inventory/inventory_routes.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/routes/register_features.dart';
import 'package:ky_core/core/features/feature_routes.dart';

void main() {
  test('inventory feature route catalog reuses navigation paths', () {
    final navigationRoutes =
        inventoryFeatureRouteDestinations
            .where((destination) => destination.navigationDestination != null)
            .toList();

    expect(
      navigationRoutes.map((destination) => destination.navigationDestination),
      containsAll(InventoryNavigationDrawer.destinations),
    );
    for (final destination in navigationRoutes) {
      expect(destination.path, destination.navigationDestination!.routePath);
    }
  });

  test('inventory feature exposes operational pages and forms in sidebar', () {
    final inventory = InventoryFeatures().registerScreens().single;
    final sidebarRoutes =
        inventory.items
            .where((route) => route.position.contains(MenuPosition.sidebar))
            .toList();
    final routes = {for (final route in sidebarRoutes) route.name: route};

    expect(inventory.name, 'Inventory');
    expect(inventory.position, contains(MenuPosition.sidebar));
    expect(sidebarRoutes.map((route) => route.path), [
      InventoryRoutes.dashboard,
      InventoryRoutes.stock,
      InventoryRoutes.products,
      InventoryRoutes.warehouses,
      InventoryRoutes.warehouseDashboard,
      InventoryRoutes.warehouseCapacity,
      InventoryRoutes.branches,
      InventoryRoutes.purchaseOrders,
      InventoryRoutes.createPurchaseOrder,
      InventoryRoutes.stockOpname,
      InventoryRoutes.movements,
      InventoryRoutes.lowStock,
      InventoryRoutes.reports,
      InventoryRoutes.analytics,
    ]);

    expect(routes['Create Purchase Order']?.subtitle, 'Supplier order form');
    expect(routes['Branches']?.subtitle, 'Multi-branch directory');
    expect(routes['Warehouse Dashboard']?.subtitle, 'Warehouse control hub');
    expect(routes['Warehouse Capacity']?.subtitle, 'Capacity control');
    expect(routes['Stock Opname']?.subtitle, 'Physical count form');

    for (final route in sidebarRoutes) {
      expect(route.pageBuilder, isNotNull, reason: '${route.name} route');
      expect(route.path, isNotNull, reason: '${route.name} path');
      expect(route.description, isNotEmpty, reason: '${route.name} metadata');
    }
  });

  test('inventory keeps legacy stock opname URL out of the sidebar', () {
    final inventory = InventoryFeatures().registerScreens().single;
    final legacy = inventory.items.singleWhere(
      (route) => route.path == InventoryRoutes.legacyStockOpname,
    );

    expect(legacy.name, 'Stock Opname Legacy');
    expect(legacy.position, isNot(contains(MenuPosition.sidebar)));
    expect(legacy.pageBuilder, isNotNull);
    expect(
      inventory.items
          .where((route) => route.position.contains(MenuPosition.sidebar))
          .map((route) => route.name),
      isNot(contains('Stokopname')),
    );
  });

  test('inventory exposes warehouse branch drilldown outside the sidebar', () {
    final inventory = InventoryFeatures().registerScreens().single;
    final branchDetail = inventory.items.singleWhere(
      (route) => route.path == InventoryRoutes.warehouseBranchDetail,
    );
    final warehouseDetail = inventory.items.singleWhere(
      (route) => route.path == InventoryRoutes.warehouseDetail,
    );

    expect(branchDetail.name, 'Warehouse Branch Detail');
    expect(branchDetail.subtitle, 'Branch drilldown');
    expect(branchDetail.position, isNot(contains(MenuPosition.sidebar)));
    expect(branchDetail.pageBuilder, isNotNull);
    expect(warehouseDetail.name, 'Warehouse Detail');
    expect(warehouseDetail.subtitle, 'Location drilldown');
    expect(warehouseDetail.position, isNot(contains(MenuPosition.sidebar)));
    expect(warehouseDetail.pageBuilder, isNotNull);
  });

  test('inventory feature is registered with application features', () {
    expect(registerFeatures().whereType<InventoryFeatures>(), hasLength(1));
  });
}

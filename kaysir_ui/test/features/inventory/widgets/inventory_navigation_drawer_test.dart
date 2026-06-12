import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/inventory_routes.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';

void main() {
  test('inventory navigation metadata covers every destination', () {
    expect(
      inventoryNavigationDestinations,
      InventoryNavigationDestination.values,
    );
    expect(
      inventoryNavigationDestinationDetailsByDestination.keys.toSet(),
      InventoryNavigationDestination.values.toSet(),
    );
    expect(
      inventoryNavigationDestinations.map(
        (destination) => destination.details.destination,
      ),
      inventoryNavigationDestinations,
    );
  });

  test('inventory navigation destinations use canonical inventory paths', () {
    final expectedRoutes = {
      InventoryNavigationDestination.dashboard: InventoryRoutes.dashboard,
      InventoryNavigationDestination.inventory: InventoryRoutes.stock,
      InventoryNavigationDestination.purchaseOrders:
          InventoryRoutes.purchaseOrders,
      InventoryNavigationDestination.warehouseCapacity:
          InventoryRoutes.warehouseCapacity,
      InventoryNavigationDestination.warehouseDashboard:
          InventoryRoutes.warehouseDashboard,
      InventoryNavigationDestination.branches: InventoryRoutes.branches,
      InventoryNavigationDestination.stockOpname: InventoryRoutes.stockOpname,
    };

    for (final entry in expectedRoutes.entries) {
      expect(entry.key.routePath, entry.value);
    }
  });

  testWidgets('inventory navigation drawer renders typed destinations', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: InventoryNavigationDrawer(
          currentDestination: InventoryNavigationDestination.lowStock,
        ),
      ),
    );

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );

    expect(
      drawer.selectedIndex,
      InventoryNavigationDrawer.destinations.indexOf(
        InventoryNavigationDestination.lowStock,
      ),
    );
    for (final destination in InventoryNavigationDrawer.destinations) {
      final matcher =
          destination == InventoryNavigationDestination.inventory
              ? findsWidgets
              : findsOneWidget;
      expect(find.text(destination.label), matcher);
    }
  });

  testWidgets('inventory navigation drawer emits selected destination', (
    tester,
  ) async {
    InventoryNavigationDestination? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: InventoryNavigationDrawer(
          onDestinationSelected: (destination) {
            selectedDestination = destination;
          },
        ),
      ),
    );

    await tester.tap(find.text('Warehouses'));

    expect(selectedDestination, InventoryNavigationDestination.warehouses);
  });
}

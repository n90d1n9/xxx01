import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/dashboard_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/inventory_movement_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_dashboard_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('inventory dashboard composes reusable dashboard widgets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1100, 820));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _dashboardPage(
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
          Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 350),
        ],
        warehouses: [
          Warehouse(
            id: 'w1',
            name: 'Main Warehouse',
            branchId: 'branch-jakarta',
            branchName: 'Jakarta Central',
            location: 'Jakarta',
          ),
          Warehouse(
            id: 'w2',
            name: 'North Warehouse',
            branchId: 'branch-surabaya',
            branchName: 'Surabaya North',
            location: 'Surabaya',
          ),
        ],
        inventoryItems: [
          InventoryItem(
            id: 'i1',
            productId: 'p1',
            warehouseId: 'w1',
            currentQuantity: 3,
            reorderPoint: 5,
            reorderQuantity: 8,
          ),
          InventoryItem(
            id: 'i2',
            productId: 'p2',
            warehouseId: 'w2',
            currentQuantity: 2,
            reorderPoint: 1,
            reorderQuantity: 4,
          ),
        ],
        movements: [
          InventoryMovement(
            id: 'm1',
            productId: 'p2',
            sourceWarehouseId: 'w2',
            quantity: 2,
            type: MovementType.sale,
            date: DateTime(2026, 5, 31, 12),
            reference: 'SO-001',
          ),
          InventoryMovement(
            id: 'm2',
            productId: 'p1',
            sourceWarehouseId: 'w1',
            quantity: 3,
            type: MovementType.purchase,
            date: DateTime(2026, 5, 30, 8),
            reference: 'PO-001',
          ),
        ],
      ),
    );

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryNavigationDrawer), findsNothing);
    expect(find.byType(InventoryDashboardSummary), findsOneWidget);
    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.byType(RecentInventoryMovementsPanel), findsOneWidget);
    expect(find.text('Inventory Dashboard'), findsWidgets);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);
    expect(find.text('2 branches covered'), findsOneWidget);
    expect(find.text(r'$1,000.00'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Inbound'), findsOneWidget);
    expect(find.text('Outbound'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryNavigationDrawer), findsOneWidget);
    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(
      drawer.selectedIndex,
      InventoryNavigationDrawer.destinations.indexOf(
        InventoryNavigationDestination.dashboard,
      ),
    );
  });
}

Widget _dashboardPage({
  required List<Product> products,
  required List<Warehouse> warehouses,
  required List<InventoryItem> inventoryItems,
  required List<InventoryMovement> movements,
}) {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(products)),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(warehouses)),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(inventoryItems),
      ),
      inventoryMovementsProvider.overrideWith(
        (ref) => _SeededInventoryMovements(movements),
      ),
    ],
    child: const MaterialApp(home: DashboardPage()),
  );
}

class _SeededProducts extends ProductsNotifier {
  _SeededProducts(List<Product> products) {
    state = products;
  }
}

class _SeededWarehouses extends WarehousesNotifier {
  _SeededWarehouses(List<Warehouse> warehouses) {
    state = warehouses;
  }
}

class _SeededInventoryItems extends InventoryItemsNotifier {
  _SeededInventoryItems(List<InventoryItem> items) {
    state = items;
  }
}

class _SeededInventoryMovements extends InventoryMovementsNotifier {
  _SeededInventoryMovements(List<InventoryMovement> movements) {
    state = movements;
  }
}

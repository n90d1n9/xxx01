import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/report_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/inventory_movement_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_report_hub_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('reports page composes modern report hub', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_reportsPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryReportHubSummary), findsOneWidget);
    expect(find.byType(InventoryReportCatalogPanel), findsOneWidget);
    expect(find.text('Report Hub'), findsOneWidget);
    expect(find.text('Inventory Valuation'), findsOneWidget);
    expect(find.text('Stock Movement History'), findsOneWidget);
    expect(find.text('Low Stock Report'), findsOneWidget);
    expect(find.text('Warehouse Capacity'), findsOneWidget);
  });

  testWidgets('reports page opens valuation report from catalog', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_reportsPage());

    await tester.tap(find.text('Inventory Valuation'));
    await tester.pumpAndSettle();

    expect(find.text('Inventory Valuation Report'), findsWidgets);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Main Warehouse'), findsOneWidget);
  });

  testWidgets('reports page opens movement report from catalog', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_reportsPage());

    await tester.tap(find.text('Stock Movement History'));
    await tester.pumpAndSettle();

    expect(find.text('Stock Movement Report'), findsWidgets);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.textContaining('Main Warehouse'), findsOneWidget);
    expect(find.text('Purchase'), findsOneWidget);
  });

  testWidgets('reports page uses shared inventory navigation drawer', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_reportsPage());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryNavigationDrawer), findsOneWidget);

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(
      drawer.selectedIndex,
      InventoryNavigationDrawer.destinations.indexOf(
        InventoryNavigationDestination.reports,
      ),
    );
  });
}

Widget _reportsPage() {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(_products())),
      warehousesProvider.overrideWith(
        (ref) => _SeededWarehouses(_warehouses()),
      ),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(_inventoryItems()),
      ),
      inventoryMovementsProvider.overrideWith(
        (ref) => _SeededMovements(_movements()),
      ),
    ],
    child: const MaterialApp(home: ReportsPage()),
  );
}

List<Product> _products() {
  return [
    Product(
      id: 'p1',
      name: 'Laptop',
      sku: 'LT-001',
      category: 'Electronics',
      price: 100,
    ),
    Product(
      id: 'p2',
      name: 'Cable',
      sku: 'CB-001',
      category: 'Accessories',
      price: 25,
    ),
  ];
}

List<Warehouse> _warehouses() {
  return [
    Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
    Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
  ];
}

List<InventoryItem> _inventoryItems() {
  return [
    InventoryItem(
      id: 'i1',
      productId: 'p1',
      warehouseId: 'w1',
      currentQuantity: 5,
      reorderPoint: 2,
      reorderQuantity: 8,
    ),
    InventoryItem(
      id: 'i2',
      productId: 'p2',
      warehouseId: 'w2',
      currentQuantity: 1,
      reorderPoint: 4,
      reorderQuantity: 10,
    ),
  ];
}

List<InventoryMovement> _movements() {
  return [
    InventoryMovement(
      id: 'm1',
      productId: 'p1',
      sourceWarehouseId: 'w1',
      quantity: 5,
      type: MovementType.purchase,
      date: DateTime(2026, 5, 31, 8),
      reference: 'PO-001',
    ),
  ];
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

class _SeededMovements extends InventoryMovementsNotifier {
  _SeededMovements(List<InventoryMovement> movements) {
    state = movements;
  }
}

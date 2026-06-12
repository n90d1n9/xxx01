import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/invent_apps.dart';
import 'package:kaysir/features/inventory/inventory_routes.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/warehouse_detail_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/inventory_movement_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_detail_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('warehouse detail composes location workspace', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehouseDetailPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryWarehouseDetailSummaryGrid), findsOneWidget);
    expect(find.byType(InventoryWarehouseDetailActionPanel), findsOneWidget);
    expect(find.byType(InventoryWarehouseDetailCapacityPanel), findsOneWidget);
    expect(find.text('Main Warehouse'), findsWidgets);

    await tester.scrollUntilVisible(find.text('Stock Health'), 500);
    await tester.pumpAndSettle();

    expect(
      find.byType(InventoryWarehouseDetailStockHealthPanel),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(find.text('Replenishment Plan'), 500);
    await tester.pumpAndSettle();

    expect(
      find.byType(InventoryWarehouseDetailReplenishmentPanel),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(find.text('Category Mix'), 500);
    await tester.pumpAndSettle();

    expect(
      find.byType(InventoryWarehouseDetailCategoryMixPanel),
      findsOneWidget,
    );
    expect(find.text('Furniture'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Stock Readiness'), 500);
    await tester.pumpAndSettle();

    expect(find.byType(InventoryWarehouseDetailStockPanel), findsOneWidget);
    expect(find.text('Tablet'), findsWidgets);

    await tester.scrollUntilVisible(find.text('Movement Flow'), 500);
    await tester.pumpAndSettle();

    expect(
      find.byType(InventoryWarehouseDetailMovementFlowPanel),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(find.text('Recent Movements'), 500);
    await tester.pumpAndSettle();

    expect(find.byType(InventoryWarehouseDetailMovementPanel), findsOneWidget);
    expect(find.textContaining('SO-001'), findsOneWidget);
  });

  testWidgets('warehouse detail keeps warehouse directory selected in drawer', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehouseDetailPage());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(
      drawer.selectedIndex,
      InventoryNavigationDrawer.destinations.indexOf(
        InventoryNavigationDestination.warehouses,
      ),
    );
  });

  testWidgets('warehouse detail routes stock action with warehouse query', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehouseDetailPageWithRouteCapture());

    await tester.tap(find.widgetWithText(FilledButton, 'Stock'));
    await tester.pumpAndSettle();

    expect(
      find.text('${InventoryRoutes.stock}?branch=branch-jakarta&warehouse=w1'),
      findsOneWidget,
    );
  });

  testWidgets('warehouse detail routes replenishment action to stock queue', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehouseDetailPageWithRouteCapture());

    await tester.scrollUntilVisible(find.text('Replenishment Plan'), 500);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Open stock queue'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        '${InventoryRoutes.stock}?branch=branch-jakarta&warehouse=w1&filter=attention',
      ),
      findsOneWidget,
    );
  });

  testWidgets('warehouse detail routes stock readiness attention action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehouseDetailPageWithRouteCapture());

    await tester.scrollUntilVisible(find.text('Stock Readiness'), 500);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Review attention'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        '${InventoryRoutes.stock}?branch=branch-jakarta&warehouse=w1&filter=attention',
      ),
      findsOneWidget,
    );
  });

  testWidgets('warehouse detail routes movement flow action to filtered ledger', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehouseDetailPageWithRouteCapture());

    await tester.scrollUntilVisible(find.text('Movement Flow'), 500);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open inbound movements'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        '${InventoryRoutes.movements}?branch=branch-jakarta&warehouse=w1&filter=inbound',
      ),
      findsOneWidget,
    );
  });

  testWidgets('warehouse detail renders missing warehouse state', (
    tester,
  ) async {
    await tester.pumpWidget(_warehouseDetailPage(warehouseId: 'missing'));

    expect(find.text('Warehouse not found'), findsOneWidget);
    expect(find.text('Open warehouse directory'), findsOneWidget);
  });

  testWidgets('inventory app resolves warehouse detail query route', (
    tester,
  ) async {
    await tester.pumpWidget(
      const InventoryManagementApp(
        initialRoute: '/inventory/warehouses/detail?warehouse=1',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Main Warehouse'), findsWidgets);
    expect(find.byType(InventoryWarehouseDetailSummaryGrid), findsOneWidget);
  });
}

Widget _warehouseDetailPage({String warehouseId = 'w1'}) {
  return _providerScope(
    child: MaterialApp(home: WarehouseDetailPage(warehouseId: warehouseId)),
  );
}

Widget _warehouseDetailPageWithRouteCapture() {
  return _providerScope(
    child: MaterialApp(
      home: const WarehouseDetailPage(warehouseId: 'w1'),
      onGenerateRoute:
          (settings) => MaterialPageRoute<void>(
            builder:
                (context) =>
                    Scaffold(body: Center(child: Text(settings.name ?? ''))),
          ),
    ),
  );
}

Widget _providerScope({required Widget child}) {
  return ProviderScope(
    overrides: [
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(_warehouses)),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(_items),
      ),
      productsProvider.overrideWith((ref) => _SeededProducts(_products)),
      inventoryMovementsProvider.overrideWith(
        (ref) => _SeededMovements(_movements),
      ),
    ],
    child: child,
  );
}

final _warehouses = [
  Warehouse(
    id: 'w1',
    name: 'Main Warehouse',
    branchId: 'branch-jakarta',
    branchName: 'Jakarta Central',
    location: 'Jakarta',
    capacity: 100,
  ),
];

final _items = [
  InventoryItem(
    id: 'i1',
    productId: 'p1',
    warehouseId: 'w1',
    currentQuantity: 20,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i2',
    productId: 'p2',
    warehouseId: 'w1',
    currentQuantity: 8,
    reorderPoint: 10,
    reorderQuantity: 20,
  ),
  InventoryItem(
    id: 'i3',
    productId: 'p3',
    warehouseId: 'w1',
    currentQuantity: 4,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
];

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LP-001',
    category: 'Electronics',
    price: 100,
  ),
  Product(
    id: 'p2',
    name: 'Tablet',
    sku: 'TB-001',
    category: 'Electronics',
    price: 200,
  ),
  Product(
    id: 'p3',
    name: 'Chair',
    sku: 'CH-001',
    category: 'Furniture',
    price: 50,
  ),
];

final _movements = [
  InventoryMovement(
    id: 'm1',
    productId: 'p1',
    sourceWarehouseId: 'w1',
    quantity: 10,
    type: MovementType.purchase,
    date: DateTime(2026, 1, 3),
    reference: 'PO-001',
  ),
  InventoryMovement(
    id: 'm2',
    productId: 'p2',
    sourceWarehouseId: 'w1',
    quantity: 3,
    type: MovementType.sale,
    date: DateTime(2026, 1, 4),
    reference: 'SO-001',
  ),
];

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

class _SeededProducts extends ProductsNotifier {
  _SeededProducts(List<Product> products) {
    state = products;
  }
}

class _SeededMovements extends InventoryMovementsNotifier {
  _SeededMovements(List<InventoryMovement> movements) {
    state = movements;
  }
}

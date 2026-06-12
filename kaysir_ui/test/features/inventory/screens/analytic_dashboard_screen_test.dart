import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/invent_apps.dart';
import 'package:kaysir/features/inventory/models/inventory_filter_deep_link.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/analytic_dashboard_screen.dart';
import 'package:kaysir/features/inventory/screens/inventory_movement_screen.dart';
import 'package:kaysir/features/inventory/screens/inventory_screen.dart';
import 'package:kaysir/features/inventory/screens/low_stock_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/inventory_movement_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_dashboard_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('analytics dashboard composes modern analytics workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_analyticsDashboardPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryAnalyticsSummaryGrid), findsOneWidget);
    expect(
      find.byType(InventoryAnalyticsDashboardInsightPanel),
      findsOneWidget,
    );
    expect(find.byType(InventoryAnalyticsPriorityQueuePanel), findsOneWidget);
    expect(find.byType(InventoryAnalyticsCategoryPanel), findsOneWidget);
    expect(find.text('Analytics Dashboard'), findsWidgets);
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Accessories'), findsOneWidget);
    expect(find.text(r'$815.00'), findsOneWidget);

    await tester.tap(find.text('Review replenishment watchlist'));
    await tester.pumpAndSettle();

    expect(find.byType(LowStockPage), findsOneWidget);
    expect(find.text('Low Stock Alerts'), findsWidgets);

    Navigator.of(tester.element(find.byType(LowStockPage))).pop();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Movement Trend'),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.byType(InventoryAnalyticsMovementTrendPanel), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Value by Branch'),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.byType(InventoryAnalyticsBranchValuePanel), findsOneWidget);
    expect(find.text('Jakarta Central'), findsWidgets);
    expect(find.text('Surabaya North'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Branch Drill-down'),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.byType(InventoryAnalyticsBranchDetailPanel), findsOneWidget);
    expect(find.text('Recent Movement'), findsOneWidget);
    expect(find.textContaining('Inbound to Main Warehouse'), findsOneWidget);

    await tester.tap(find.text('Main Warehouse').first);
    await tester.pumpAndSettle();

    expect(find.byType(InventoryPage), findsOneWidget);
    expect(find.text('Stock Workspace'), findsOneWidget);
    expect(find.text('2 of 4 stock lines shown'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.textContaining('Inbound to Main Warehouse'),
      500,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.textContaining('Inbound to Main Warehouse'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryMovementsPage), findsOneWidget);
    expect(find.text('Movement History'), findsOneWidget);
    expect(find.text('1 of 4 movements shown'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Value by Warehouse'),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.byType(InventoryAnalyticsWarehouseValuePanel), findsOneWidget);
    expect(find.text('Main Warehouse'), findsWidgets);
    expect(find.text('North Warehouse'), findsOneWidget);
  });

  testWidgets('analytics dashboard uses shared inventory navigation drawer', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_analyticsDashboardPage());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryNavigationDrawer), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(
      drawer.selectedIndex,
      InventoryNavigationDrawer.destinations.indexOf(
        InventoryNavigationDestination.analytics,
      ),
    );
  });

  testWidgets('inventory query routes open filtered workspaces', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _inventoryRouteApp(
        inventoryStockDeepLink(branch: 'branch-jakarta', warehouseId: 'w1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(InventoryPage), findsOneWidget);
    expect(find.text('2 of 4 stock lines shown'), findsOneWidget);

    await tester.pumpWidget(
      _inventoryRouteApp(
        inventoryMovementsDeepLink(
          branch: 'branch-jakarta',
          query: 'PO-001',
          filter: InventoryMovementFilter.inbound,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(InventoryMovementsPage), findsOneWidget);
    expect(find.text('1 of 4 movements shown'), findsOneWidget);
  });
}

Widget _analyticsDashboardPage() {
  return _inventoryProviderScope(
    const MaterialApp(
      home: AnalyticsDashboardPage(),
      onGenerateRoute: inventoryRouteFromSettings,
    ),
  );
}

Widget _inventoryRouteApp(String initialRoute) {
  return _inventoryProviderScope(
    MaterialApp(
      key: ValueKey(initialRoute),
      initialRoute: initialRoute,
      onGenerateRoute: inventoryRouteFromSettings,
    ),
  );
}

Widget _inventoryProviderScope(Widget child) {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(_products())),
      warehousesProvider.overrideWith(
        (ref) => _SeededWarehouses(_warehouses()),
      ),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(_items()),
      ),
      inventoryMovementsProvider.overrideWith(
        (ref) => _SeededInventoryMovements(_movements()),
      ),
    ],
    child: child,
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
    Product(id: 'p3', name: 'Notebook', sku: 'NB-001', price: 5),
  ];
}

List<Warehouse> _warehouses() {
  return [
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
  ];
}

List<InventoryItem> _items() {
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
      warehouseId: 'w1',
      currentQuantity: 2,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
    InventoryItem(
      id: 'i3',
      productId: 'p2',
      warehouseId: 'w2',
      currentQuantity: 10,
      reorderPoint: 4,
      reorderQuantity: 10,
    ),
    InventoryItem(
      id: 'i4',
      productId: 'p3',
      warehouseId: 'w2',
      currentQuantity: 3,
      reorderPoint: 3,
      reorderQuantity: 8,
    ),
  ];
}

List<InventoryMovement> _movements() {
  return [
    InventoryMovement(
      id: 'm1',
      productId: 'p1',
      sourceWarehouseId: 'w1',
      quantity: 4,
      type: MovementType.purchase,
      date: DateTime(2026, 5, 31, 8),
      reference: 'PO-001',
    ),
    InventoryMovement(
      id: 'm2',
      productId: 'p2',
      sourceWarehouseId: 'w1',
      quantity: 1,
      type: MovementType.sale,
      date: DateTime(2026, 5, 31, 9),
      reference: 'SO-001',
    ),
    InventoryMovement(
      id: 'm3',
      productId: 'p2',
      sourceWarehouseId: 'w1',
      quantity: -2,
      type: MovementType.adjustment,
      date: DateTime(2026, 5, 31, 10),
      reference: 'ADJ-001',
    ),
    InventoryMovement(
      id: 'm4',
      productId: 'p2',
      sourceWarehouseId: 'w1',
      quantity: 3,
      type: MovementType.adjustment,
      date: DateTime(2026, 5, 31, 11),
      reference: 'ADJ-002',
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

class _SeededInventoryMovements extends InventoryMovementsNotifier {
  _SeededInventoryMovements(List<InventoryMovement> movements) {
    state = movements;
  }
}

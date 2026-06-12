import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/inventory_routes.dart';
import 'package:kaysir/features/inventory/invent_apps.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_dashboard.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/warehouse_branch_detail_screen.dart';
import 'package:kaysir/features/inventory/screens/warehouse_branch_detail_routes.dart';
import 'package:kaysir/features/inventory/states/inventory_branch_provider.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_branch_detail_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('warehouse branch detail composes branch workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_branchDetailPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(
      find.byType(InventoryWarehouseBranchDetailWorkspace),
      findsOneWidget,
    );
    expect(
      find.byType(InventoryWarehouseBranchDetailSummaryGrid),
      findsOneWidget,
    );
    expect(
      find.byType(InventoryWarehouseBranchDetailActionPanel),
      findsOneWidget,
    );
    expect(
      find.byType(InventoryWarehouseBranchWarehouseOperationsPanel),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(find.text('Warehouse Capacity'), 500);
    await tester.pumpAndSettle();

    expect(find.byType(InventoryWarehouseBranchCapacityPanel), findsOneWidget);
    expect(find.text('Jakarta Central'), findsWidgets);
    expect(find.text('Main Warehouse'), findsWidgets);

    await tester.scrollUntilVisible(find.text('Stock Pressure'), 500);
    await tester.pumpAndSettle();

    expect(
      find.byType(InventoryWarehouseBranchStockPressurePanel),
      findsOneWidget,
    );
    expect(find.text('Laptop'), findsOneWidget);
  });

  testWidgets(
    'warehouse branch detail keeps warehouse hub selected in drawer',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1180, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_branchDetailPage());

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      final drawer = tester.widget<NavigationDrawer>(
        find.byType(NavigationDrawer),
      );
      expect(
        drawer.selectedIndex,
        InventoryNavigationDrawer.destinations.indexOf(
          InventoryNavigationDestination.warehouseDashboard,
        ),
      );
    },
  );

  testWidgets('warehouse branch detail routes stock action with branch query', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_branchDetailPageWithRouteCapture());

    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Stock').first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Stock').first);
    await tester.pumpAndSettle();

    expect(
      find.text('${InventoryRoutes.stock}?branch=branch-jakarta'),
      findsOneWidget,
    );
  });

  testWidgets(
    'warehouse branch detail routes warehouse operation actions with warehouse query',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1180, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_branchDetailPageWithRouteCapture());

      await tester.ensureVisible(find.text('Warehouse Operations'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Capacity'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          '${InventoryRoutes.warehouseCapacity}?branch=branch-jakarta&warehouse=w1',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('warehouse branch detail opens warehouse detail route', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_branchDetailPageWithRouteCapture());

    await tester.ensureVisible(find.text('Warehouse Operations'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Open'));
    await tester.pumpAndSettle();

    expect(
      find.text('${InventoryRoutes.warehouseDetail}?warehouse=w1'),
      findsOneWidget,
    );
  });

  testWidgets('warehouse branch detail renders missing branch state', (
    tester,
  ) async {
    await tester.pumpWidget(_branchDetailPage(branchKey: 'missing'));

    expect(
      find.byType(InventoryWarehouseBranchDetailNotFoundState),
      findsOneWidget,
    );
    expect(find.text('Branch not found'), findsOneWidget);
    expect(find.text('Open warehouse hub'), findsOneWidget);
  });

  testWidgets('inventory app resolves warehouse branch detail query route', (
    tester,
  ) async {
    await tester.pumpWidget(
      const InventoryManagementApp(
        initialRoute:
            '/inventory/warehouses/branch?branch=branch-jakarta-central',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jakarta Central'), findsWidgets);
    expect(
      find.byType(InventoryWarehouseBranchDetailSummaryGrid),
      findsOneWidget,
    );
  });

  test('warehouse branch detail routes build branch and warehouse targets', () {
    final detail =
        buildInventoryWarehouseBranchDetail(
          branchKey: 'branch-jakarta',
          branches: _branches,
          warehouses: _warehouses,
          inventoryItems: _items,
          products: _products,
        )!;
    final operation = detail.warehouseOperations.single;
    final routes = WarehouseBranchDetailRoutes(detail);

    expect(routes.hubRoute, InventoryRoutes.warehouseDashboard);
    expect(routes.stockRoute, '${InventoryRoutes.stock}?branch=branch-jakarta');
    expect(
      routes.operationCapacityRoute(operation),
      '${InventoryRoutes.warehouseCapacity}?branch=branch-jakarta&warehouse=w1',
    );
    expect(
      routes.warehouseDetailRoute(operation),
      '${InventoryRoutes.warehouseDetail}?warehouse=w1',
    );
  });
}

Widget _branchDetailPage({String branchKey = 'branch-jakarta'}) {
  return _providerScope(
    child: MaterialApp(home: WarehouseBranchDetailPage(branchKey: branchKey)),
  );
}

Widget _branchDetailPageWithRouteCapture() {
  return _providerScope(
    child: MaterialApp(
      home: const WarehouseBranchDetailPage(branchKey: 'branch-jakarta'),
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
      inventoryBranchesProvider.overrideWith(
        (ref) => _SeededBranches(_branches),
      ),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(_warehouses)),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(_items),
      ),
      productsProvider.overrideWith((ref) => _SeededProducts(_products)),
    ],
    child: child,
  );
}

const _branches = [
  InventoryBranch(
    id: 'branch-jakarta',
    name: 'Jakarta Central',
    city: 'Jakarta',
    managerName: 'Rina',
    contact: 'jakarta@example.test',
  ),
];

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
    currentQuantity: 8,
    reorderPoint: 10,
    reorderQuantity: 20,
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
];

class _SeededBranches extends InventoryBranchesNotifier {
  _SeededBranches(List<InventoryBranch> branches) {
    state = branches;
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

class _SeededProducts extends ProductsNotifier {
  _SeededProducts(List<Product> products) {
    state = products;
  }
}

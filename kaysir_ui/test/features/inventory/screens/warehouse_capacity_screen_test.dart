import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/warehouse_capacity_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_capacity_report_components.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  setUp(_mockClipboard);
  tearDown(_clearClipboardMock);

  testWidgets('warehouse capacity report composes modern capacity workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_capacityPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryWarehouseCapacitySummaryGrid), findsOneWidget);
    expect(find.byType(InventoryWarehouseCapacityPanel), findsOneWidget);
    expect(find.text('Warehouse Capacity Report'), findsWidgets);
    expect(find.text('Main Warehouse'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('Untracked'), findsOneWidget);
    expect(find.text('Not set'), findsOneWidget);
  });

  testWidgets('warehouse capacity export action copies CSV to clipboard', (
    tester,
  ) async {
    await tester.pumpWidget(_capacityPage());

    await tester.tap(find.byTooltip('Export capacity report'));
    await tester.pumpAndSettle();

    expect(find.textContaining('warehouse-capacity-'), findsOneWidget);
    expect(find.textContaining('copied to clipboard (2 rows)'), findsOneWidget);
  });

  testWidgets('warehouse capacity report applies initial branch filter', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_capacityPage(initialBranch: 'Jakarta Central'));

    expect(find.text('Main Warehouse'), findsOneWidget);
    expect(find.text('North Warehouse'), findsNothing);
  });

  testWidgets('warehouse capacity report applies initial warehouse filter', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_capacityPage(initialWarehouseId: 'w2'));

    expect(find.text('Main Warehouse'), findsNothing);
    expect(find.text('North Warehouse'), findsWidgets);
  });

  testWidgets('warehouse capacity route page uses provider data and sidebar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_capacityRoutePage());

    expect(find.text('Warehouse Capacity Report'), findsWidgets);
    expect(find.text('Main Warehouse'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(
      drawer.selectedIndex,
      InventoryNavigationDrawer.destinations.indexOf(
        InventoryNavigationDestination.warehouseCapacity,
      ),
    );
  });
}

void _mockClipboard() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
}

void _clearClipboardMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, null);
}

Widget _capacityPage({String? initialBranch, String? initialWarehouseId}) {
  return MaterialApp(
    home: WarehouseCapacityReportPage(
      warehouses: [
        Warehouse(
          id: 'w1',
          name: 'Main Warehouse',
          branchName: 'Jakarta Central',
          location: 'Jakarta',
          capacity: 100,
        ),
        Warehouse(
          id: 'w2',
          name: 'North Warehouse',
          branchName: 'Surabaya North',
          location: 'Surabaya',
        ),
      ],
      inventoryItems: [
        InventoryItem(
          id: 'i1',
          productId: 'p1',
          warehouseId: 'w1',
          currentQuantity: 95,
          reorderPoint: 2,
          reorderQuantity: 8,
        ),
        InventoryItem(
          id: 'i2',
          productId: 'p2',
          warehouseId: 'w2',
          currentQuantity: 10,
          reorderPoint: 2,
          reorderQuantity: 8,
        ),
      ],
      initialBranch: initialBranch,
      initialWarehouseId: initialWarehouseId,
    ),
  );
}

Widget _capacityRoutePage() {
  return ProviderScope(
    overrides: [
      warehousesProvider.overrideWith(
        (ref) => _SeededWarehouses([
          Warehouse(
            id: 'w1',
            name: 'Main Warehouse',
            location: 'Jakarta',
            capacity: 100,
          ),
        ]),
      ),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems([
          InventoryItem(
            id: 'i1',
            productId: 'p1',
            warehouseId: 'w1',
            currentQuantity: 95,
            reorderPoint: 2,
            reorderQuantity: 8,
          ),
        ]),
      ),
    ],
    child: const MaterialApp(home: WarehouseCapacityPage()),
  );
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

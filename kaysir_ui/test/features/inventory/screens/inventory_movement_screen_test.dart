import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/inventory_movement_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_movement_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_movement_history_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('inventory movement page composes movement workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _movementPage(
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001'),
          Product(id: 'p2', name: 'Speaker', sku: 'SP-001'),
        ],
        warehouses: [
          Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
          Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
        ],
        movements: [
          InventoryMovement(
            id: 'm1',
            productId: 'p2',
            sourceWarehouseId: 'w1',
            destinationWarehouseId: 'w2',
            quantity: 2,
            type: MovementType.transfer,
            date: DateTime(2026, 5, 31, 9),
            reference: 'TRF-001',
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
    expect(find.byType(InventoryMovementHistorySummary), findsOneWidget);
    expect(find.byType(InventoryMovementHistoryToolbar), findsOneWidget);
    expect(find.byType(InventoryMovementHistoryPanel), findsOneWidget);
    expect(find.text('Movement History'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Transfer'), findsWidgets);
    expect(find.text('Inbound'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'speaker');
    await tester.pump();

    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);
  });

  testWidgets('inventory movement page copies the current filtered link', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final clipboardCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboardCalls.add(call);
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await tester.pumpWidget(
      _movementPage(
        page: const InventoryMovementsPage(
          initialBranch: 'branch-jakarta',
          initialWarehouseId: 'w1',
          initialQuery: 'PO-001',
          initialFilter: InventoryMovementFilter.inbound,
        ),
        products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001')],
        warehouses: [
          Warehouse(
            id: 'w1',
            name: 'Main Warehouse',
            branchId: 'branch-jakarta',
            branchName: 'Jakarta Central',
            location: 'Jakarta',
          ),
        ],
        movements: [
          InventoryMovement(
            id: 'm1',
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

    await tester.tap(find.byTooltip('Copy filtered link'));
    await tester.pumpAndSettle();

    expect(clipboardCalls, hasLength(1));
    final arguments = clipboardCalls.single.arguments as Map<Object?, Object?>;
    final link = arguments['text']! as String;
    expect(link, contains('/#/inventory/movements?'));
    expect(link, contains('branch=branch-jakarta'));
    expect(link, contains('warehouse=w1'));
    expect(link, contains('q=PO-001'));
    expect(link, contains('filter=inbound'));
    expect(find.text('Filtered movement link copied'), findsOneWidget);
  });

  testWidgets('inventory movement page uses shared navigation shell', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _movementPage(
        products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001')],
        warehouses: [
          Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
        ],
        movements: const [],
      ),
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryNavigationDrawer), findsOneWidget);

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(
      drawer.selectedIndex,
      InventoryNavigationDrawer.destinations.indexOf(
        InventoryNavigationDestination.movements,
      ),
    );
  });
}

Widget _movementPage({
  InventoryMovementsPage page = const InventoryMovementsPage(),
  required List<Product> products,
  required List<Warehouse> warehouses,
  required List<InventoryMovement> movements,
}) {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(products)),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(warehouses)),
      inventoryMovementsProvider.overrideWith(
        (ref) => _SeededInventoryMovements(movements),
      ),
    ],
    child: MaterialApp(home: page),
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

class _SeededInventoryMovements extends InventoryMovementsNotifier {
  _SeededInventoryMovements(List<InventoryMovement> movements) {
    state = movements;
  }
}

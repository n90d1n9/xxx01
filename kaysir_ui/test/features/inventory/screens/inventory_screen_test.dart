import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/inventory_routes.dart';
import 'package:kaysir/features/inventory/screens/inventory_screen.dart';
import 'package:kaysir/features/inventory/screens/low_stock_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/inventory_movement_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_low_stock_alert_dialog.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_adjustment_dialog.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_create_dialog.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_detail_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_list_panel.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_summary.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_toolbar.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_transfer_dialog.dart';
import 'package:kaysir/features/inventory/widgets/low_stock_restock_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('inventory page composes modern stock workspace', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _inventoryPage(
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
          Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
        ],
        warehouses: [
          Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
          Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
        ],
        inventoryItems: [
          InventoryItem(
            id: 'i1',
            productId: 'p1',
            warehouseId: 'w1',
            currentQuantity: 3,
            reorderPoint: 5,
            reorderQuantity: 10,
          ),
          InventoryItem(
            id: 'i2',
            productId: 'p2',
            warehouseId: 'w2',
            currentQuantity: 20,
            reorderPoint: 5,
            reorderQuantity: 10,
          ),
        ],
      ),
    );

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryStockSummary), findsOneWidget);
    expect(find.byType(InventoryStockToolbar), findsOneWidget);
    expect(find.byType(InventoryStockListPanel), findsOneWidget);
    expect(find.byType(InventoryLowStockAlertIcon), findsOneWidget);
    expect(find.text('Stock Workspace'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
    expect(find.text('In stock'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'speaker');
    await tester.pump();

    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);
  });

  testWidgets('inventory page copies the current filtered stock link', (
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
      _inventoryPage(
        page: const InventoryPage(
          initialBranch: 'branch-jakarta',
          initialWarehouseId: 'w1',
          initialQuery: 'Laptop',
          initialFilter: InventoryStockFilter.needsAttention,
        ),
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
        ],
        warehouses: [
          Warehouse(
            id: 'w1',
            name: 'Main Warehouse',
            branchId: 'branch-jakarta',
            branchName: 'Jakarta Central',
            location: 'Jakarta',
          ),
        ],
        inventoryItems: [
          InventoryItem(
            id: 'i1',
            productId: 'p1',
            warehouseId: 'w1',
            currentQuantity: 3,
            reorderPoint: 5,
            reorderQuantity: 10,
          ),
        ],
      ),
    );

    await tester.tap(find.byTooltip('Copy filtered link'));
    await tester.pumpAndSettle();

    expect(clipboardCalls, hasLength(1));
    final arguments = clipboardCalls.single.arguments as Map<Object?, Object?>;
    final link = arguments['text']! as String;
    expect(link, contains('/#/inventory/stock?'));
    expect(link, contains('branch=branch-jakarta'));
    expect(link, contains('warehouse=w1'));
    expect(link, contains('q=Laptop'));
    expect(link, contains('filter=attention'));
    expect(find.text('Filtered inventory link copied'), findsOneWidget);
  });

  testWidgets(
    'inventory page opens navigation drawer and routes to low stock',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1180, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _inventoryPage(
          products: [
            Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
          ],
          warehouses: [
            Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
          ],
          inventoryItems: [
            InventoryItem(
              id: 'i1',
              productId: 'p1',
              warehouseId: 'w1',
              currentQuantity: 3,
              reorderPoint: 5,
              reorderQuantity: 10,
            ),
          ],
        ),
      );

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      expect(find.byType(InventoryNavigationDrawer), findsOneWidget);

      await tester.tap(find.text('Low Stock Alerts').last);
      await tester.pumpAndSettle();

      expect(find.text('Replenishment Queue'), findsOneWidget);
    },
  );

  testWidgets('inventory page opens low stock alert and restocks from it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _inventoryPage(
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
        ],
        warehouses: [
          Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
        ],
        inventoryItems: [
          InventoryItem(
            id: 'i1',
            productId: 'p1',
            warehouseId: 'w1',
            currentQuantity: 3,
            reorderPoint: 5,
            reorderQuantity: 10,
          ),
        ],
      ),
    );

    await tester.tap(find.byTooltip('1 low stock alert'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryLowStockAlertDialog), findsOneWidget);
    expect(find.text('Low Stock Alerts'), findsOneWidget);
    expect(find.text('Laptop'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Restock'));
    await tester.pumpAndSettle();

    expect(find.byType(LowStockRestockDialog), findsOneWidget);
    expect(find.text('Restock Laptop'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm restock'));
    await tester.pumpAndSettle();

    expect(find.byType(LowStockRestockDialog), findsNothing);
    expect(find.text('Laptop restocked successfully'), findsOneWidget);
    expect(find.byTooltip('Low stock alerts'), findsOneWidget);
  });

  testWidgets('inventory page opens stock detail sheet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _inventoryPage(
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
        ],
        warehouses: [
          Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
        ],
        inventoryItems: [
          InventoryItem(
            id: 'i1',
            productId: 'p1',
            warehouseId: 'w1',
            currentQuantity: 3,
            reorderPoint: 5,
            reorderQuantity: 10,
          ),
        ],
        movements: [
          InventoryMovement(
            id: 'm1',
            productId: 'p1',
            sourceWarehouseId: 'w1',
            quantity: 3,
            type: MovementType.purchase,
            date: DateTime(2026, 5, 31, 9),
            reference: 'PO-001',
          ),
        ],
      ),
    );

    await tester.tap(find.byTooltip('View stock details'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryStockDetailSheet), findsOneWidget);
    expect(find.text('Stock Detail'), findsOneWidget);
    expect(find.text('Recent Movements'), findsOneWidget);
    expect(find.textContaining('PO-001'), findsOneWidget);
  });

  testWidgets('inventory page creates a new stock line', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _inventoryPage(
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
          Product(id: 'p2', name: 'Cable', sku: 'CB-001', price: 25),
        ],
        warehouses: [
          Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
        ],
        inventoryItems: [
          InventoryItem(
            id: 'i1',
            productId: 'p1',
            warehouseId: 'w1',
            currentQuantity: 3,
            reorderPoint: 5,
            reorderQuantity: 10,
          ),
        ],
      ),
    );

    expect(find.text('Cable'), findsNothing);

    await tester.tap(find.byTooltip('Add stock line'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryStockCreateDialog), findsOneWidget);

    final numberFields = find.byType(TextFormField);
    await tester.enterText(numberFields.at(0), '7');
    await tester.enterText(numberFields.at(1), '2');
    await tester.enterText(numberFields.at(2), '5');
    await tester.tap(find.widgetWithText(FilledButton, 'Create stock line'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryStockCreateDialog), findsNothing);
    expect(find.text('Cable'), findsOneWidget);
    expect(
      find.text('Cable stock line created for Main Warehouse'),
      findsOneWidget,
    );
  });

  testWidgets('inventory page applies stock increase adjustment', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _inventoryPage(
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
        ],
        warehouses: [
          Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
        ],
        inventoryItems: [
          InventoryItem(
            id: 'i1',
            productId: 'p1',
            warehouseId: 'w1',
            currentQuantity: 3,
            reorderPoint: 5,
            reorderQuantity: 10,
          ),
        ],
      ),
    );

    await tester.tap(find.byTooltip('Increase stock'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryStockAdjustmentDialog), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '4');
    await tester.tap(find.widgetWithText(FilledButton, 'Increase stock'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryStockAdjustmentDialog), findsNothing);
    expect(find.text('Stock increased successfully'), findsOneWidget);
    expect(find.text('7'), findsWidgets);
  });

  testWidgets('inventory page transfers stock to another warehouse', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _inventoryPage(
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
        ],
        warehouses: [
          Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
          Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
        ],
        inventoryItems: [
          InventoryItem(
            id: 'i1',
            productId: 'p1',
            warehouseId: 'w1',
            currentQuantity: 8,
            reorderPoint: 5,
            reorderQuantity: 10,
          ),
        ],
      ),
    );

    await tester.tap(find.byTooltip('Transfer stock'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryStockTransferDialog), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '2');
    await tester.tap(find.widgetWithText(FilledButton, 'Transfer stock'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryStockTransferDialog), findsNothing);
    expect(find.text('Stock transferred successfully'), findsOneWidget);
    expect(find.text('Laptop'), findsNWidgets(2));
    expect(find.textContaining('North Warehouse'), findsOneWidget);
  });
}

Widget _inventoryPage({
  InventoryPage page = const InventoryPage(),
  required List<Product> products,
  required List<Warehouse> warehouses,
  required List<InventoryItem> inventoryItems,
  List<InventoryMovement> movements = const [],
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
    child: MaterialApp(
      home: page,
      routes: {InventoryRoutes.lowStock: (context) => const LowStockPage()},
    ),
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

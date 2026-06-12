import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/invent_apps.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/purchase_order.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/low_stock_screen.dart';
import 'package:kaysir/features/inventory/screens/purchase_order/purchase_order_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/inventory_movement_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/purchase_order_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/low_stock_replenishment_components.dart';
import 'package:kaysir/features/inventory/widgets/low_stock_restock_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('low stock page composes replenishment workflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _lowStockPage(
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
          Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
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
          InventoryItem(
            id: 'i2',
            productId: 'p2',
            warehouseId: 'w1',
            currentQuantity: 0,
            reorderPoint: 4,
            reorderQuantity: 6,
          ),
        ],
      ),
    );

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(LowStockReplenishmentSummary), findsOneWidget);
    expect(find.byType(LowStockReplenishmentPanel), findsOneWidget);
    expect(find.text('Low Stock Alerts'), findsWidgets);
    expect(find.text('Replenishment Queue'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Order now'), findsOneWidget);
    expect(find.text('Plan reorder'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Restock').first);
    await tester.pumpAndSettle();

    expect(find.byType(LowStockRestockDialog), findsOneWidget);
    expect(find.text('Restock Speaker'), findsOneWidget);
    expect(find.text('Quantity to order'), findsOneWidget);
    final quantityField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    expect(quantityField.controller?.text, '6');
  });

  testWidgets('low stock page uses shared inventory navigation shell', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _lowStockPage(
        products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001')],
        warehouses: [
          Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
        ],
        inventoryItems: const [],
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
        InventoryNavigationDestination.lowStock,
      ),
    );
  });

  testWidgets('low stock page restock action clears replenished item', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _lowStockPage(
        products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001')],
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

    final restockButton = find.widgetWithText(FilledButton, 'Restock');
    await tester.ensureVisible(restockButton);
    await tester.tap(restockButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm restock'));
    await tester.pumpAndSettle();

    expect(find.text('Stock is healthy'), findsOneWidget);
    expect(find.text('Laptop restocked successfully'), findsOneWidget);
  });

  testWidgets(
    'low stock page creates draft purchase order from visible queue',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1180, 860));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final purchaseOrders = _SeededPurchaseOrders();

      await tester.pumpWidget(
        _lowStockPage(
          products: [
            Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
            Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
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
            InventoryItem(
              id: 'i2',
              productId: 'p2',
              warehouseId: 'w1',
              currentQuantity: 0,
              reorderPoint: 4,
              reorderQuantity: 6,
            ),
          ],
          purchaseOrdersNotifier: purchaseOrders,
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Create PO draft'));
      await tester.pumpAndSettle();

      expect(purchaseOrders.orders, hasLength(1));
      expect(purchaseOrders.orders.single.status, OrderStatus.draft);
      expect(purchaseOrders.orders.single.items, hasLength(2));
      expect(purchaseOrders.orders.single.totalAmount, 2500);
      expect(find.text('2 PO lines saved as draft'), findsOneWidget);
    },
  );

  testWidgets('low stock page opens generated draft from snackbar action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final purchaseOrders = _SeededPurchaseOrders([
      PurchaseOrder(
        id: 'PO-EXISTING',
        vendorName: 'Existing Supplier',
        orderDate: DateTime(2026, 6, 1),
        totalAmount: 10,
        status: OrderStatus.pending,
        items: [
          PurchaseOrderItem(
            id: 'existing',
            name: 'Existing item',
            quantity: 1,
            unitPrice: 10,
          ),
        ],
      ),
    ]);

    await tester.pumpWidget(
      _lowStockPage(
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
        purchaseOrdersNotifier: purchaseOrders,
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Create PO draft'));
    await tester.pumpAndSettle();
    final generatedOrderId = purchaseOrders.orders.last.id;

    await tester.tap(find.text('View draft'));
    await tester.pumpAndSettle();

    expect(find.byType(PurchaseOrdersScreen), findsOneWidget);
    expect(find.text(generatedOrderId), findsNWidgets(2));
    expect(find.text('PO-EXISTING'), findsNothing);
  });
}

Widget _lowStockPage({
  required List<Product> products,
  required List<Warehouse> warehouses,
  required List<InventoryItem> inventoryItems,
  _SeededPurchaseOrders? purchaseOrdersNotifier,
}) {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(products)),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(warehouses)),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(inventoryItems),
      ),
      inventoryMovementsProvider.overrideWith(
        (ref) => _SeededInventoryMovements(),
      ),
      purchaseOrdersProvider.overrideWith(
        (ref) => purchaseOrdersNotifier ?? _SeededPurchaseOrders(),
      ),
    ],
    child: MaterialApp(
      home: const LowStockPage(),
      onGenerateRoute: inventoryRouteFromSettings,
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
  _SeededInventoryMovements() {
    state = <InventoryMovement>[];
  }
}

class _SeededPurchaseOrders extends PurchaseOrdersNotifier {
  _SeededPurchaseOrders([List<PurchaseOrder> orders = const <PurchaseOrder>[]])
    : super() {
    state = orders;
  }

  List<PurchaseOrder> get orders => state;
}

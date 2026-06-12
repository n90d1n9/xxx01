import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_detail.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_separated_list.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_capacity_report_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_detail_components.dart';
import 'package:kaysir/features/inventory/widgets/low_stock_replenishment_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_command_grid.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('warehouse detail summary renders location metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDetailSummaryGrid(detail: _detail),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Utilization'), findsOneWidget);
    expect(find.text('Stock Lines'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
    expect(find.text('Attention'), findsOneWidget);
  });

  testWidgets('warehouse detail actions emit callbacks', (tester) async {
    var openedStock = false;
    var openedMovements = false;
    var openedCapacity = false;
    var openedBranch = false;
    var openedDirectory = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDetailActionPanel(
            warehouseName: 'Main Warehouse',
            onOpenStock: () => openedStock = true,
            onOpenMovements: () => openedMovements = true,
            onOpenCapacity: () => openedCapacity = true,
            onOpenBranch: () => openedBranch = true,
            onOpenDirectory: () => openedDirectory = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(AppCommandGrid), findsOneWidget);
    expect(find.text('Warehouse Actions'), findsOneWidget);
    expect(
      find.text('Review on-hand lines and attention queues'),
      findsOneWidget,
    );
    expect(find.text('Return to the warehouse directory'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Stock'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Movements'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Capacity'));
    await tester.tap(find.widgetWithText(TextButton, 'Branch'));
    await tester.tap(find.widgetWithText(TextButton, 'Directory'));

    expect(openedStock, isTrue);
    expect(openedMovements, isTrue);
    expect(openedCapacity, isTrue);
    expect(openedBranch, isTrue);
    expect(openedDirectory, isTrue);
  });

  testWidgets('warehouse detail capacity panel renders capacity tile', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDetailCapacityPanel(detail: _detail),
        ),
      ),
    );

    expect(find.text('Capacity Readiness'), findsOneWidget);
    expect(find.byType(InventoryWarehouseCapacityTile), findsOneWidget);
    expect(find.text('Main Warehouse'), findsOneWidget);
  });

  testWidgets('warehouse detail stock health panel renders status breakdown', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDetailStockHealthPanel(detail: _detail),
        ),
      ),
    );

    expect(find.text('Stock Health'), findsOneWidget);
    expect(
      find.byType(InventorySeparatedList<InventoryWarehouseStockHealthLine>),
      findsOneWidget,
    );
    expect(find.byType(InventoryTileSurface), findsNWidgets(3));
    expect(find.text('Watch'), findsOneWidget);
    expect(find.text('Out of stock'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
    expect(find.text('In stock'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
  });

  testWidgets('warehouse detail replenishment panel renders scoped plan', (
    tester,
  ) async {
    var openedQueue = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDetailReplenishmentPanel(
            detail: _detail,
            onOpenStockQueue: () => openedQueue = true,
          ),
        ),
      ),
    );

    expect(find.text('Replenishment Plan'), findsOneWidget);
    expect(find.byType(LowStockReplenishmentTile), findsNWidgets(2));
    expect(find.text('Tablet'), findsOneWidget);
    expect(find.text('Chair'), findsOneWidget);
    expect(find.text('30 suggested units'), findsOneWidget);
    expect(find.text('Restock'), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Open stock queue'));

    expect(openedQueue, isTrue);
  });

  testWidgets('warehouse detail category mix panel renders category rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDetailCategoryMixPanel(detail: _detail),
        ),
      ),
    );

    expect(find.text('Category Mix'), findsOneWidget);
    expect(
      find.byType(InventorySeparatedList<InventoryWarehouseCategoryMixLine>),
      findsOneWidget,
    );
    expect(find.byType(InventoryTileSurface), findsNWidgets(2));
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Furniture'), findsOneWidget);
    expect(find.text('95% value'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
  });

  testWidgets('warehouse detail stock panel renders attention rows', (
    tester,
  ) async {
    var openedStock = false;
    var openedAttention = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDetailStockPanel(
            detail: _detail,
            onOpenStock: () => openedStock = true,
            onOpenAttentionStock: () => openedAttention = true,
          ),
        ),
      ),
    );

    expect(find.text('Stock Readiness'), findsOneWidget);
    expect(find.text('Tablet'), findsOneWidget);
    expect(find.text('Chair'), findsOneWidget);
    expect(find.text('Low stock'), findsWidgets);
    expect(find.text('2 shown'), findsOneWidget);
    expect(find.text('2 attention'), findsOneWidget);
    expect(find.text('1 hidden'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Review attention'));
    await tester.tap(find.widgetWithText(TextButton, 'Open all stock'));

    expect(openedAttention, isTrue);
    expect(openedStock, isTrue);
  });

  testWidgets('warehouse detail movement panel renders recent movements', (
    tester,
  ) async {
    var openedTimeline = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDetailMovementPanel(
            detail: _detail,
            onOpenMovements: () => openedTimeline = true,
          ),
        ),
      ),
    );

    expect(find.text('Recent Movements'), findsOneWidget);
    expect(find.textContaining('SO-001'), findsOneWidget);
    expect(find.textContaining('PO-001'), findsOneWidget);
    expect(find.text('3 shown'), findsOneWidget);
    expect(find.text('0 hidden'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Open full timeline'));

    expect(openedTimeline, isTrue);
  });

  testWidgets('warehouse detail movement flow panel renders flow summary', (
    tester,
  ) async {
    final openedFilters = <InventoryMovementFilter>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseDetailMovementFlowPanel(
            detail: _detail,
            onOpenMovementFilter: openedFilters.add,
          ),
        ),
      ),
    );

    expect(find.text('Movement Flow'), findsOneWidget);
    expect(
      find.byType(InventorySeparatedList<InventoryWarehouseMovementFlowLine>),
      findsOneWidget,
    );
    expect(find.byType(InventoryTileSurface), findsNWidgets(3));
    expect(find.text('Inbound'), findsOneWidget);
    expect(find.text('Outbound'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);
    expect(find.text('+5 net'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(3));

    await tester.tap(find.byTooltip('Open inbound movements'));
    await tester.tap(find.byTooltip('Open outbound movements'));
    await tester.tap(find.byTooltip('Open transfer movements'));

    expect(openedFilters, [
      InventoryMovementFilter.inbound,
      InventoryMovementFilter.outbound,
      InventoryMovementFilter.transfer,
    ]);
  });
}

final _detail =
    buildInventoryWarehouseDetail(
      warehouseId: 'w1',
      warehouses: _warehouses,
      inventoryItems: _items,
      stockRecords: buildInventoryStockRecords(
        inventoryItems: _items,
        products: _products,
        warehouses: _warehouses,
      ),
      movementRecords: buildInventoryMovementRecords(
        movements: _movements,
        products: _products,
        warehouses: _warehouses,
      ),
    )!;

final _warehouses = [
  Warehouse(
    id: 'w1',
    name: 'Main Warehouse',
    branchId: 'branch-jakarta',
    branchName: 'Jakarta Central',
    location: 'Jakarta',
    capacity: 100,
  ),
  Warehouse(
    id: 'w2',
    name: 'North Warehouse',
    branchId: 'branch-surabaya',
    branchName: 'Surabaya North',
    location: 'Surabaya',
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
  InventoryMovement(
    id: 'm3',
    productId: 'p3',
    sourceWarehouseId: 'w1',
    destinationWarehouseId: 'w2',
    quantity: 2,
    type: MovementType.transfer,
    date: DateTime(2026, 1, 5),
    reference: 'TRF-001',
  ),
];

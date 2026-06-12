import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_dashboard.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_metric_chip.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_branch_detail_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_capacity_report_components.dart';
import 'package:kaysir/widgets/ui/app_command_grid.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('warehouse branch detail summary renders branch metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseBranchDetailSummaryGrid(detail: _detail),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Warehouses'), findsOneWidget);
    expect(find.text('Capacity'), findsOneWidget);
    expect(find.text('Stock Lines'), findsOneWidget);
    expect(find.text('Attention'), findsOneWidget);
  });

  testWidgets('warehouse branch detail action panel emits actions', (
    tester,
  ) async {
    var openedStock = false;
    var openedMovements = false;
    var openedCapacity = false;
    var openedHub = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseBranchDetailActionPanel(
            branchName: 'Jakarta Central',
            onOpenStock: () => openedStock = true,
            onOpenMovements: () => openedMovements = true,
            onOpenCapacity: () => openedCapacity = true,
            onOpenHub: () => openedHub = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(AppCommandGrid), findsOneWidget);
    expect(find.text('Branch Actions'), findsOneWidget);
    expect(
      find.text('Review all branch warehouse stock lines'),
      findsOneWidget,
    );
    expect(find.text('Return to the warehouse command center'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Stock'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Movements'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Capacity'));
    await tester.tap(find.widgetWithText(TextButton, 'Warehouse Hub'));

    expect(openedStock, isTrue);
    expect(openedMovements, isTrue);
    expect(openedCapacity, isTrue);
    expect(openedHub, isTrue);
  });

  testWidgets('warehouse branch capacity panel renders capacity rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseBranchCapacityPanel(detail: _detail),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(InventoryWarehouseBranchCapacityStatusPill),
      findsOneWidget,
    );
    expect(find.byType(InventoryWarehouseBranchCapacityList), findsOneWidget);
    expect(find.byType(InventoryWarehouseCapacityTile), findsOneWidget);
    expect(find.text('Warehouse Capacity'), findsOneWidget);
    expect(find.text('Main Warehouse'), findsOneWidget);
  });

  testWidgets('warehouse branch capacity panel renders empty branch state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseBranchCapacityPanel(detail: _emptyDetail),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(InventoryWarehouseBranchCapacityEmptyState),
      findsOneWidget,
    );
    expect(
      find.byType(InventoryWarehouseBranchCapacityStatusPill),
      findsNothing,
    );
    expect(find.text('No warehouses in this branch'), findsOneWidget);
  });

  testWidgets('warehouse branch operations panel renders action rows', (
    tester,
  ) async {
    InventoryWarehouseOperationSummary? openedStock;
    InventoryWarehouseOperationSummary? openedMovements;
    InventoryWarehouseOperationSummary? openedCapacity;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseBranchWarehouseOperationsPanel(
            detail: _detail,
            onOpenStock: (operation) => openedStock = operation,
            onOpenMovements: (operation) => openedMovements = operation,
            onOpenCapacity: (operation) => openedCapacity = operation,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(InventoryWarehouseBranchOperationStatusPill),
      findsOneWidget,
    );
    expect(find.byType(InventoryWarehouseBranchOperationList), findsOneWidget);
    expect(find.byType(InventoryWarehouseOperationTile), findsOneWidget);
    expect(find.byType(InventoryWarehouseOperationHeader), findsOneWidget);
    expect(find.byType(InventoryTileSurface), findsAtLeastNWidgets(1));
    expect(find.byType(InventoryMetricChip), findsNWidgets(5));
    expect(find.text('Warehouse Operations'), findsOneWidget);
    expect(find.text('Main Warehouse'), findsOneWidget);
    expect(find.text('Stock lines'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Stock'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Movements'));
    await tester.tap(find.widgetWithText(TextButton, 'Capacity'));

    expect(openedStock?.warehouseId, 'w1');
    expect(openedMovements?.warehouseId, 'w1');
    expect(openedCapacity?.warehouseId, 'w1');
  });

  testWidgets('warehouse branch operations panel renders empty branch state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseBranchWarehouseOperationsPanel(
            detail: _emptyDetail,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(InventoryWarehouseBranchOperationEmptyState),
      findsOneWidget,
    );
    expect(
      find.byType(InventoryWarehouseBranchOperationStatusPill),
      findsNothing,
    );
    expect(find.text('No warehouse operations yet'), findsOneWidget);
  });

  testWidgets('warehouse branch stock pressure panel renders alerts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseBranchStockPressurePanel(detail: _detail),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(InventoryWarehouseBranchStockPressureStatusPill),
      findsOneWidget,
    );
    expect(
      find.byType(InventoryWarehouseBranchStockPressureList),
      findsOneWidget,
    );
    expect(find.text('Stock Pressure'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
  });

  testWidgets('warehouse branch stock pressure panel renders healthy state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryWarehouseBranchStockPressurePanel(
            detail: _healthyDetail,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(InventoryWarehouseBranchStockPressureStatusPill),
      findsOneWidget,
    );
    expect(
      find.byType(InventoryWarehouseBranchStockPressureEmptyState),
      findsOneWidget,
    );
    expect(find.text('Healthy'), findsOneWidget);
    expect(find.text('No low stock pressure'), findsOneWidget);
  });
}

final _detail =
    buildInventoryWarehouseBranchDetail(
      branchKey: 'branch-jakarta',
      branches: const [
        InventoryBranch(
          id: 'branch-jakarta',
          name: 'Jakarta Central',
          city: 'Jakarta',
          managerName: 'Rina',
          contact: 'jakarta@example.test',
        ),
      ],
      warehouses: [
        Warehouse(
          id: 'w1',
          name: 'Main Warehouse',
          branchId: 'branch-jakarta',
          branchName: 'Jakarta Central',
          location: 'Jakarta',
          capacity: 100,
        ),
      ],
      inventoryItems: [
        InventoryItem(
          id: 'i1',
          productId: 'p1',
          warehouseId: 'w1',
          currentQuantity: 8,
          reorderPoint: 10,
          reorderQuantity: 20,
        ),
      ],
      products: [
        Product(
          id: 'p1',
          name: 'Laptop',
          sku: 'LP-001',
          category: 'Electronics',
          price: 100,
        ),
      ],
    )!;

final _emptyDetail =
    buildInventoryWarehouseBranchDetail(
      branchKey: 'branch-empty',
      branches: const [
        InventoryBranch(
          id: 'branch-empty',
          name: 'Empty Branch',
          city: 'Bandung',
          managerName: 'Dian',
          contact: 'bandung@example.test',
        ),
      ],
      warehouses: const [],
      inventoryItems: const [],
      products: const [],
    )!;

final _healthyDetail =
    buildInventoryWarehouseBranchDetail(
      branchKey: 'branch-healthy',
      branches: const [
        InventoryBranch(
          id: 'branch-healthy',
          name: 'Healthy Branch',
          city: 'Surabaya',
          managerName: 'Sari',
          contact: 'surabaya@example.test',
        ),
      ],
      warehouses: [
        Warehouse(
          id: 'w-healthy',
          name: 'Healthy Warehouse',
          branchId: 'branch-healthy',
          branchName: 'Healthy Branch',
          location: 'Surabaya',
          capacity: 100,
        ),
      ],
      inventoryItems: [
        InventoryItem(
          id: 'i-healthy',
          productId: 'p-healthy',
          warehouseId: 'w-healthy',
          currentQuantity: 40,
          reorderPoint: 10,
          reorderQuantity: 20,
        ),
      ],
      products: [
        Product(
          id: 'p-healthy',
          name: 'Printer Paper',
          sku: 'PPR-001',
          category: 'Supplies',
          price: 5,
        ),
      ],
    )!;

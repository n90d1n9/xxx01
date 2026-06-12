import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_purchase_order_create.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_replenishment_plan.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/low_stock_replenishment_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('low stock replenishment summary renders metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LowStockReplenishmentSummary(plans: _plans())),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Active Alerts'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Suggested Units'), findsOneWidget);
    expect(find.text('Estimated Cost'), findsOneWidget);
    expect(find.text(r'$2,500.00'), findsOneWidget);
  });

  testWidgets('low stock replenishment panel renders action rows', (
    tester,
  ) async {
    var selectedProduct = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LowStockReplenishmentPanel(
              plans: _plans(),
              onRestock: (plan) {
                selectedProduct = plan.record.productName;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(LowStockReplenishmentTile), findsNWidgets(2));
    expect(find.text('Replenishment Queue'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Order now'), findsOneWidget);
    expect(find.text('Plan reorder'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Restock').first);
    expect(selectedProduct, 'Speaker');
  });

  testWidgets('low stock replenishment panel filters queue urgency', (
    tester,
  ) async {
    var filter = InventoryReplenishmentPlanFilter.all;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: SingleChildScrollView(
                child: LowStockReplenishmentPanel(
                  plans: _plans(),
                  filter: filter,
                  onFilterChanged: (value) => setState(() => filter = value),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.byType(LowStockReplenishmentTile), findsNWidgets(2));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Critical'));
    await tester.pumpAndSettle();

    expect(find.byType(LowStockReplenishmentTile), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Reorder soon'));
    await tester.pumpAndSettle();

    expect(find.byType(LowStockReplenishmentTile), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Speaker'), findsNothing);
  });

  testWidgets('low stock replenishment panel scopes queue by warehouse', (
    tester,
  ) async {
    var selectedWarehouseId = null as String?;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: SingleChildScrollView(
                child: LowStockReplenishmentPanel(
                  plans: _warehousePlans(),
                  selectedWarehouseId: selectedWarehouseId,
                  onFilterChanged: (_) {},
                  onWarehouseChanged:
                      (value) => setState(() => selectedWarehouseId = value),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.byType(LowStockReplenishmentTile), findsNWidgets(3));

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Satellite Warehouse').last);
    await tester.pumpAndSettle();

    expect(find.byType(LowStockReplenishmentTile), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Speaker'), findsNothing);
    expect(find.text('Laptop'), findsNothing);
  });

  testWidgets('low stock replenishment panel sorts visible queue', (
    tester,
  ) async {
    var sort = InventoryReplenishmentPlanSort.priority;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: SingleChildScrollView(
                child: LowStockReplenishmentPanel(
                  plans: _warehousePlans(),
                  sort: sort,
                  onFilterChanged: (_) {},
                  onSortChanged: (value) => setState(() => sort = value),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(_visibleTileNames(tester), ['Speaker', 'Cable', 'Laptop']);

    await tester.tap(
      find.byType(DropdownButton<InventoryReplenishmentPlanSort>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Product name').last);
    await tester.pumpAndSettle();

    expect(_visibleTileNames(tester), ['Cable', 'Laptop', 'Speaker']);
  });

  testWidgets('low stock replenishment panel creates visible queue PO draft', (
    tester,
  ) async {
    InventoryPurchaseOrderCreateDraft? draft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LowStockReplenishmentPanel(
              plans: _warehousePlans(),
              selectedWarehouseId: 'w2',
              onFilterChanged: (_) {},
              onCreatePurchaseOrderDraft: (value) => draft = value,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(LowStockReplenishmentBulkActionBar), findsOneWidget);
    expect(find.text('Visible queue draft'), findsOneWidget);
    expect(find.text('1 alert line across 1 warehouse'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Create PO draft'));
    await tester.pumpAndSettle();

    expect(draft, isNotNull);
    expect(draft!.itemCount, 1);
    expect(draft!.items.single.name, 'Cable');
    expect(draft!.totalQuantity, 12);
  });

  testWidgets('low stock replenishment panel clears active triage filters', (
    tester,
  ) async {
    var filter = InventoryReplenishmentPlanFilter.critical;
    String? selectedWarehouseId = 'w2';

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: SingleChildScrollView(
                child: LowStockReplenishmentPanel(
                  plans: _warehousePlans(),
                  filter: filter,
                  selectedWarehouseId: selectedWarehouseId,
                  onFilterChanged: (value) => setState(() => filter = value),
                  onWarehouseChanged:
                      (value) => setState(() => selectedWarehouseId = value),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Active filters'), findsOneWidget);
    expect(find.text('Urgency: Critical'), findsOneWidget);
    expect(find.text('Warehouse: Satellite Warehouse'), findsOneWidget);
    expect(find.byType(LowStockReplenishmentTile), findsOneWidget);

    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsNothing);
    expect(find.byType(LowStockReplenishmentTile), findsNWidgets(3));
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);
  });

  testWidgets('low stock replenishment panel renders healthy empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LowStockReplenishmentPanel(plans: [])),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('Stock is healthy'), findsOneWidget);
  });
}

List<String> _visibleTileNames(WidgetTester tester) {
  return tester
      .widgetList<LowStockReplenishmentTile>(
        find.byType(LowStockReplenishmentTile),
      )
      .map((tile) => tile.plan.record.productName)
      .toList();
}

List<InventoryReplenishmentPlan> _plans() {
  return buildInventoryReplenishmentPlans(
    buildInventoryStockRecords(
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
}

List<InventoryReplenishmentPlan> _warehousePlans() {
  return buildInventoryReplenishmentPlans(
    buildInventoryStockRecords(
      products: [
        Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
        Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
        Product(id: 'p3', name: 'Cable', sku: 'CBL-001', price: 12),
      ],
      warehouses: [
        Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
        Warehouse(id: 'w2', name: 'Satellite Warehouse', location: 'Bandung'),
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
        InventoryItem(
          id: 'i3',
          productId: 'p3',
          warehouseId: 'w2',
          currentQuantity: 2,
          reorderPoint: 6,
          reorderQuantity: 12,
        ),
      ],
    ),
  );
}

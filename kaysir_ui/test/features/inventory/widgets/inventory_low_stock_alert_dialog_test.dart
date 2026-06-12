import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_replenishment_plan.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_dialog_content_layout.dart';
import 'package:kaysir/features/inventory/widgets/inventory_low_stock_alert_dialog.dart';
import 'package:kaysir/features/inventory/widgets/low_stock_replenishment_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('low stock alert icon renders a badge count', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: InventoryLowStockAlertIcon(count: 3)),
      ),
    );

    expect(find.byType(Badge), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('low stock alert icon hides badge when healthy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: InventoryLowStockAlertIcon(count: 0)),
      ),
    );

    expect(find.byType(Badge), findsNothing);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
  });

  testWidgets('low stock alert dialog renders replenishment actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var selectedProduct = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryLowStockAlertDialog(
            plans: _plans(),
            onRestock: (plan) {
              selectedProduct = plan.record.productName;
            },
          ),
        ),
      ),
    );

    expect(find.text('Low Stock Alerts'), findsOneWidget);
    expect(find.byType(InventoryDialogContentLayout), findsOneWidget);
    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.byType(LowStockReplenishmentTile), findsNWidgets(2));
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);

    final restockButton = find.widgetWithText(FilledButton, 'Restock').first;
    await tester.ensureVisible(restockButton);
    await tester.tap(restockButton);
    expect(selectedProduct, 'Speaker');
  });

  testWidgets('low stock alert dialog renders healthy state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: InventoryLowStockAlertDialog(plans: [])),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('Stock is healthy'), findsOneWidget);
  });
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

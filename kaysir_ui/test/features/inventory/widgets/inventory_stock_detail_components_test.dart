import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_movement_history_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_separated_list.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_detail_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_status_pill.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets(
    'inventory stock detail sheet renders stock and movement context',
    (tester) async {
      var increased = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InventoryStockDetailSheet(
              record: _stockRecord(),
              movements: _movementRecords(),
              onIncreaseStock: () => increased = true,
            ),
          ),
        ),
      );

      expect(find.text('Stock Detail'), findsOneWidget);
      expect(find.text('Laptop'), findsWidgets);
      expect(find.byType(InventoryStockStatusPill), findsOneWidget);
      expect(find.byType(AppMetricGrid), findsOneWidget);
      expect(find.text('Current Qty'), findsOneWidget);
      expect(find.text('Reorder Point'), findsOneWidget);
      expect(find.text('Stock Value'), findsOneWidget);
      expect(find.text(r'$300.00'), findsOneWidget);
      expect(find.text('Recent Movements'), findsOneWidget);
      expect(find.byType(InventoryTileSurface), findsAtLeastNWidgets(2));
      expect(
        find.byType(InventorySeparatedList<InventoryMovementRecord>),
        findsOneWidget,
      );
      expect(find.byType(InventoryMovementTimelineTile), findsOneWidget);
      expect(find.textContaining('PO-001'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Increase'));
      expect(increased, isTrue);
    },
  );
}

InventoryStockRecord _stockRecord() {
  return buildInventoryStockRecords(
    products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100)],
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
  ).single;
}

List<InventoryMovementRecord> _movementRecords() {
  return buildInventoryMovementRecords(
    products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001')],
    warehouses: [
      Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
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
  );
}

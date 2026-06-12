import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_detail_state.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('stock detail state limits recent movements', () {
    final movements = _movementRecords(8);

    final recentMovements = inventoryStockDetailRecentMovements(movements);

    expect(recentMovements, hasLength(6));
    expect(recentMovements.first.movement.reference, 'PO-0');
    expect(recentMovements.last.movement.reference, 'PO-5');
  });

  test('stock detail state formats movement subtitle', () {
    expect(inventoryStockDetailMovementSubtitle(0), '0 related stock events');
    expect(inventoryStockDetailMovementSubtitle(1), '1 related stock event');
    expect(inventoryStockDetailMovementSubtitle(3), '3 related stock events');
  });
}

List<InventoryMovementRecord> _movementRecords(int count) {
  return [
    for (var index = 0; index < count; index += 1)
      InventoryMovementRecord(
        movement: InventoryMovement(
          id: 'm$index',
          productId: 'p1',
          sourceWarehouseId: 'w1',
          quantity: index + 1,
          type: MovementType.purchase,
          date: DateTime(2026, 6, index + 1),
          reference: 'PO-$index',
        ),
        product: Product(id: 'p1', name: 'Laptop', sku: 'LT-001'),
        sourceWarehouse: Warehouse(
          id: 'w1',
          name: 'Main Warehouse',
          location: 'Jakarta',
        ),
      ),
  ];
}

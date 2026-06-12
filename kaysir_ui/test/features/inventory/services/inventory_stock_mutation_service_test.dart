import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_adjustment_draft.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_create_draft.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_transfer_draft.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/services/inventory_stock_mutation_service.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('create mutation adds stock line and opening movement', () {
    final occurredAt = DateTime(2026, 5, 31, 8, 30);

    final mutation = buildInventoryStockCreateMutation(
      draft: const InventoryStockCreateDraft(
        productId: 'p2',
        warehouseId: 'w1',
        currentQuantity: 7,
        reorderPoint: 2,
        reorderQuantity: 5,
      ),
      occurredAt: occurredAt,
    );

    expect(mutation.itemsToAdd, hasLength(1));
    expect(
      mutation.itemsToAdd.single.id,
      'INV-${occurredAt.millisecondsSinceEpoch}',
    );
    expect(mutation.itemsToAdd.single.currentQuantity, 7);
    expect(mutation.quantityUpdates, isEmpty);
    expect(mutation.movements, hasLength(1));
    expect(mutation.movements.single.type, MovementType.receipt);
    expect(mutation.movements.single.reference, startsWith('OPEN-'));
  });

  test('create mutation skips opening movement for zero quantity', () {
    final mutation = buildInventoryStockCreateMutation(
      draft: const InventoryStockCreateDraft(
        productId: 'p2',
        warehouseId: 'w1',
        currentQuantity: 0,
        reorderPoint: 2,
        reorderQuantity: 5,
      ),
      occurredAt: DateTime(2026, 5, 31),
    );

    expect(mutation.itemsToAdd, hasLength(1));
    expect(mutation.movements, isEmpty);
  });

  test('adjustment mutation updates quantity and movement note', () {
    final record = _record();
    final occurredAt = DateTime(2026, 5, 31, 9);

    final mutation = buildInventoryStockAdjustmentMutation(
      record: record,
      draft: const InventoryStockAdjustmentDraft(
        direction: InventoryStockAdjustmentDirection.decrease,
        quantity: 2,
        reason: '  Damaged stock  ',
      ),
      occurredAt: occurredAt,
    );

    expect(mutation.itemsToAdd, isEmpty);
    expect(mutation.quantityUpdates.single.itemId, 'i1');
    expect(mutation.quantityUpdates.single.quantity, 6);
    expect(mutation.movements.single.type, MovementType.adjustment);
    expect(mutation.movements.single.quantity, -2);
    expect(mutation.movements.single.notes, 'Damaged stock');
    expect(
      mutation.movements.single.reference,
      'ADJ-${occurredAt.millisecondsSinceEpoch}',
    );
  });

  test('transfer mutation creates destination stock line when missing', () {
    final record = _record();
    final occurredAt = DateTime(2026, 5, 31, 10);

    final mutation = buildInventoryStockTransferMutation(
      record: record,
      draft: const InventoryStockTransferDraft(
        destinationWarehouseId: 'w2',
        quantity: 3,
      ),
      inventoryItems: [record.item],
      occurredAt: occurredAt,
    );

    expect(mutation.quantityUpdates.single.itemId, 'i1');
    expect(mutation.quantityUpdates.single.quantity, 5);
    expect(
      mutation.itemsToAdd.single.id,
      'TRF-DST-${occurredAt.millisecondsSinceEpoch}',
    );
    expect(mutation.itemsToAdd.single.currentQuantity, 3);
    expect(mutation.itemsToAdd.single.reorderPoint, record.reorderPoint);
    expect(mutation.movements.single.type, MovementType.transfer);
    expect(mutation.movements.single.destinationWarehouseId, 'w2');
    expect(mutation.movements.single.notes, 'Warehouse stock transfer');
  });

  test('transfer mutation updates existing destination stock line', () {
    final record = _record();

    final mutation = buildInventoryStockTransferMutation(
      record: record,
      draft: const InventoryStockTransferDraft(
        destinationWarehouseId: 'w2',
        quantity: 3,
        notes: '  Store transfer  ',
      ),
      inventoryItems: [
        record.item,
        InventoryItem(
          id: 'i2',
          productId: 'p1',
          warehouseId: 'w2',
          currentQuantity: 4,
          reorderPoint: 2,
          reorderQuantity: 6,
        ),
      ],
      occurredAt: DateTime(2026, 5, 31, 11),
    );

    expect(mutation.itemsToAdd, isEmpty);
    expect(mutation.quantityUpdates, hasLength(2));
    expect(mutation.quantityUpdates[0].itemId, 'i1');
    expect(mutation.quantityUpdates[0].quantity, 5);
    expect(mutation.quantityUpdates[1].itemId, 'i2');
    expect(mutation.quantityUpdates[1].quantity, 7);
    expect(mutation.movements.single.notes, 'Store transfer');
  });
}

InventoryStockRecord _record() {
  return buildInventoryStockRecords(
    products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100)],
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
        reorderPoint: 4,
        reorderQuantity: 9,
      ),
    ],
  ).single;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_transfer_dialog_state.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('stock transfer state resolves destination warehouses', () {
    final record = _records().first;

    final destinations = inventoryStockTransferDestinationWarehouses(
      record: record,
      warehouses: _warehouses,
    );

    expect(destinations.map((warehouse) => warehouse.id), ['w2', 'w3']);
    expect(initialInventoryStockTransferDestinationId(destinations), 'w2');
    expect(initialInventoryStockTransferDestinationId(const []), isNull);
  });

  test('stock transfer state finds existing destination record', () {
    final records = _records(includeDestination: true);

    final destinationRecord = inventoryStockTransferDestinationRecord(
      record: records.first,
      destinationWarehouseId: 'w2',
      existingRecords: records,
    );

    expect(destinationRecord?.warehouse.id, 'w2');
    expect(destinationRecord?.quantity, 4);
    expect(
      inventoryStockTransferDestinationRecord(
        record: records.first,
        destinationWarehouseId: 'w3',
        existingRecords: records,
      ),
      isNull,
    );
  });

  test('stock transfer state parses draft input', () {
    final draft = inventoryStockTransferDraftFromInput(
      destinationWarehouseId: 'w2',
      quantityText: ' 3 ',
      notes: '  Rebalance floor stock  ',
    );

    expect(draft?.destinationWarehouseId, 'w2');
    expect(draft?.quantity, 3);
    expect(draft?.notes, 'Rebalance floor stock');
    expect(
      inventoryStockTransferDraftFromInput(
        destinationWarehouseId: null,
        quantityText: '3',
        notes: '',
      ),
      isNull,
    );
    expect(
      inventoryStockTransferDraftFromInput(
        destinationWarehouseId: 'w2',
        quantityText: 'abc',
        notes: '',
      ),
      isNull,
    );
  });
}

List<InventoryStockRecord> _records({bool includeDestination = false}) {
  return buildInventoryStockRecords(
    products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100)],
    warehouses: _warehouses,
    inventoryItems: [
      InventoryItem(
        id: 'i1',
        productId: 'p1',
        warehouseId: 'w1',
        currentQuantity: 8,
        reorderPoint: 5,
        reorderQuantity: 10,
      ),
      if (includeDestination)
        InventoryItem(
          id: 'i2',
          productId: 'p1',
          warehouseId: 'w2',
          currentQuantity: 4,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
    ],
  );
}

final _warehouses = [
  Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
  Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
  Warehouse(id: 'w3', name: 'East Warehouse', location: 'Bandung'),
];

import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_transfer_draft.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';

void main() {
  test('transfer draft projects source and destination quantities', () {
    const draft = InventoryStockTransferDraft(
      destinationWarehouseId: 'w2',
      quantity: 3,
      notes: 'Move to north warehouse',
    );

    expect(
      validateInventoryStockTransferDraft(
        draft,
        currentQuantity: 8,
        sourceWarehouseId: 'w1',
        warehouses: _warehouses(),
      ),
      isNull,
    );
    expect(draft.sourceQuantityAfter(8), 5);
    expect(draft.destinationQuantityAfter(4), 7);
    expect(draft.successLabel, 'Stock transferred successfully');
  });

  test('transfer draft validates quantity and destination', () {
    expect(
      validateInventoryStockTransferDraft(
        const InventoryStockTransferDraft(
          destinationWarehouseId: 'w2',
          quantity: 0,
        ),
        currentQuantity: 8,
        sourceWarehouseId: 'w1',
        warehouses: _warehouses(),
      ),
      InventoryStockTransferIssue.invalidQuantity,
    );
    expect(
      validateInventoryStockTransferDraft(
        const InventoryStockTransferDraft(
          destinationWarehouseId: 'w2',
          quantity: 9,
        ),
        currentQuantity: 8,
        sourceWarehouseId: 'w1',
        warehouses: _warehouses(),
      ),
      InventoryStockTransferIssue.insufficientStock,
    );
    expect(
      validateInventoryStockTransferDraft(
        const InventoryStockTransferDraft(
          destinationWarehouseId: 'w1',
          quantity: 1,
        ),
        currentQuantity: 8,
        sourceWarehouseId: 'w1',
        warehouses: _warehouses(),
      ),
      InventoryStockTransferIssue.sameWarehouse,
    );
    expect(
      validateInventoryStockTransferDraft(
        const InventoryStockTransferDraft(
          destinationWarehouseId: 'missing',
          quantity: 1,
        ),
        currentQuantity: 8,
        sourceWarehouseId: 'w1',
        warehouses: _warehouses(),
      ),
      InventoryStockTransferIssue.invalidDestination,
    );
  });
}

List<Warehouse> _warehouses() {
  return [
    Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
    Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
  ];
}

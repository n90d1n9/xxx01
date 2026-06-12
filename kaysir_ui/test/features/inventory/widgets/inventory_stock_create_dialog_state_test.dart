import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_create_dialog_state.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('stock create state detects available stock lines', () {
    final existingRecords = _records();

    expect(
      canCreateInventoryStockLine(
        products: _products,
        warehouses: _warehouses,
        existingRecords: existingRecords,
      ),
      isTrue,
    );
    expect(
      canCreateInventoryStockLine(
        products: [_products.first],
        warehouses: [_warehouses.first],
        existingRecords: existingRecords,
      ),
      isFalse,
    );
  });

  test('stock create state picks first available product warehouse pair', () {
    final selection = firstAvailableInventoryStockLocation(
      products: _products,
      warehouses: _warehouses,
      existingRecords: _records(),
    );

    expect(selection?.productId, 'p1');
    expect(selection?.warehouseId, 'w2');
    expect(
      firstAvailableInventoryStockLocation(
        products: [_products.first],
        warehouses: [_warehouses.first],
        existingRecords: _records(),
      ),
      isNull,
    );
  });

  test('stock create state parses draft input', () {
    final draft = inventoryStockCreateDraftFromInput(
      productId: 'p2',
      warehouseId: 'w1',
      quantityText: ' 12 ',
      reorderPointText: '4',
      reorderQuantityText: '8',
    );

    expect(draft?.productId, 'p2');
    expect(draft?.warehouseId, 'w1');
    expect(draft?.currentQuantity, 12);
    expect(draft?.reorderPoint, 4);
    expect(draft?.reorderQuantity, 8);
    expect(
      inventoryStockCreateDraftFromInput(
        productId: null,
        warehouseId: 'w1',
        quantityText: '12',
        reorderPointText: '4',
        reorderQuantityText: '8',
      ),
      isNull,
    );
    expect(
      inventoryStockCreateDraftFromInput(
        productId: 'p2',
        warehouseId: 'w1',
        quantityText: 'abc',
        reorderPointText: '4',
        reorderQuantityText: '8',
      ),
      isNull,
    );
  });
}

List<InventoryStockRecord> _records() {
  return buildInventoryStockRecords(
    products: _products,
    warehouses: _warehouses,
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
  );
}

final _products = [
  Product(id: 'p1', name: 'Laptop', sku: 'LT-001'),
  Product(id: 'p2', name: 'Cable', sku: 'CB-001'),
];

final _warehouses = [
  Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
  Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
];

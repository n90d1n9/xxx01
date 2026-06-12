import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_create_draft.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('valid stock create draft converts into an inventory item', () {
    const draft = InventoryStockCreateDraft(
      productId: 'p2',
      warehouseId: 'w1',
      currentQuantity: 12,
      reorderPoint: 4,
      reorderQuantity: 8,
    );

    final item = draft.toInventoryItem(id: 'i2');

    expect(
      validateInventoryStockCreateDraft(
        draft,
        existingRecords: _existingRecords(),
      ),
      isNull,
    );
    expect(item.id, 'i2');
    expect(item.productId, 'p2');
    expect(item.currentQuantity, 12);
    expect(item.reorderQuantity, 8);
  });

  test('stock create draft rejects duplicate product warehouse pairs', () {
    const draft = InventoryStockCreateDraft(
      productId: 'p1',
      warehouseId: 'w1',
      currentQuantity: 1,
      reorderPoint: 1,
      reorderQuantity: 1,
    );

    final issue = validateInventoryStockCreateDraft(
      draft,
      existingRecords: _existingRecords(),
    );

    expect(issue, InventoryStockCreateIssue.duplicateLocation);
    expect(
      inventoryStockCreateIssueLabel(issue!),
      'This product is already tracked in the selected warehouse.',
    );
  });

  test('stock create draft validates numeric thresholds', () {
    expect(
      validateInventoryStockCreateDraft(
        const InventoryStockCreateDraft(
          productId: 'p2',
          warehouseId: 'w1',
          currentQuantity: -1,
          reorderPoint: 1,
          reorderQuantity: 1,
        ),
        existingRecords: _existingRecords(),
      ),
      InventoryStockCreateIssue.negativeQuantity,
    );
    expect(
      validateInventoryStockCreateDraft(
        const InventoryStockCreateDraft(
          productId: 'p2',
          warehouseId: 'w1',
          currentQuantity: 0,
          reorderPoint: -1,
          reorderQuantity: 1,
        ),
        existingRecords: _existingRecords(),
      ),
      InventoryStockCreateIssue.negativeReorderPoint,
    );
    expect(
      validateInventoryStockCreateDraft(
        const InventoryStockCreateDraft(
          productId: 'p2',
          warehouseId: 'w1',
          currentQuantity: 0,
          reorderPoint: 0,
          reorderQuantity: 0,
        ),
        existingRecords: _existingRecords(),
      ),
      InventoryStockCreateIssue.invalidReorderQuantity,
    );
  });
}

List<InventoryStockRecord> _existingRecords() {
  return buildInventoryStockRecords(
    products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001')],
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
  );
}

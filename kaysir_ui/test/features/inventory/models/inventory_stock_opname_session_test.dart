import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_opname_session.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('builds count lines from stock records for selected warehouse', () {
    final lines = buildInventoryStockOpnameLines(
      records: _records(),
      warehouseId: 'w1',
    );

    expect(lines, hasLength(2));
    expect(
      lines.map((line) => line.productName),
      containsAll(['Laptop', 'Cable']),
    );
    final laptopLine = lines.singleWhere(
      (line) => line.productName == 'Laptop',
    );
    expect(laptopLine.systemQuantity, 5);
    expect(laptopLine.actualQuantity, 5);
  });

  test('summarizes matched, shortage, and overage lines', () {
    final stats = summarizeInventoryStockOpnameLines([
      _line(id: 'a', systemQuantity: 5, actualQuantity: 7),
      _line(id: 'b', systemQuantity: 8, actualQuantity: 6),
      _line(id: 'c', systemQuantity: 3, actualQuantity: 3),
    ]);

    expect(stats.lineCount, 3);
    expect(stats.matchedLineCount, 1);
    expect(stats.varianceLineCount, 2);
    expect(stats.overageUnits, 2);
    expect(stats.shortageUnits, 2);
    expect(stats.netVariance, 0);
  });

  test('validates required warehouse, counter, and count lines', () {
    expect(
      validateInventoryStockOpnameSession(
        warehouseId: null,
        conductedBy: 'Aisyah',
        lines: [_line()],
      ),
      InventoryStockOpnameIssue.missingWarehouse,
    );
    expect(
      validateInventoryStockOpnameSession(
        warehouseId: 'w1',
        conductedBy: '   ',
        lines: [_line()],
      ),
      InventoryStockOpnameIssue.missingCounter,
    );
    expect(
      validateInventoryStockOpnameSession(
        warehouseId: 'w1',
        conductedBy: 'Aisyah',
        lines: const [],
      ),
      InventoryStockOpnameIssue.emptyCountSheet,
    );
  });

  test('provides reusable field validation messages', () {
    expect(
      inventoryStockOpnameWarehouseFieldError(null),
      'Select a warehouse before saving the count.',
    );
    expect(
      inventoryStockOpnameCounterFieldError('   '),
      'Enter who conducted the stock opname.',
    );
    expect(inventoryStockOpnameWarehouseFieldError('w1'), isNull);
    expect(inventoryStockOpnameCounterFieldError('Nina'), isNull);
  });
}

List<InventoryStockRecord> _records() {
  return buildInventoryStockRecords(
    products: [
      Product(id: 'p1', name: 'Laptop', sku: 'LT-001'),
      Product(id: 'p2', name: 'Cable', sku: 'CB-001'),
      Product(id: 'p3', name: 'Speaker', sku: 'SP-001'),
    ],
    warehouses: [
      Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
      Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
    ],
    inventoryItems: [
      InventoryItem(
        id: 'i1',
        productId: 'p1',
        warehouseId: 'w1',
        currentQuantity: 5,
        reorderPoint: 2,
        reorderQuantity: 8,
      ),
      InventoryItem(
        id: 'i2',
        productId: 'p2',
        warehouseId: 'w1',
        currentQuantity: 12,
        reorderPoint: 4,
        reorderQuantity: 10,
      ),
      InventoryItem(
        id: 'i3',
        productId: 'p3',
        warehouseId: 'w2',
        currentQuantity: 9,
        reorderPoint: 3,
        reorderQuantity: 5,
      ),
    ],
  );
}

InventoryStockOpnameLine _line({
  String id = 'i1',
  int systemQuantity = 5,
  int actualQuantity = 5,
}) {
  return InventoryStockOpnameLine(
    id: id,
    inventoryItemId: id,
    productId: 'p1',
    productName: 'Laptop',
    skuLabel: 'LT-001',
    systemQuantity: systemQuantity,
    actualQuantity: actualQuantity,
  );
}

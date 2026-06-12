import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_movement_report.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/stock_movement_report_labels.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('stock movement report quantity labels keep direction semantics', () {
    final lines = _linesByType();

    expect(
      stockMovementReportQuantityLabel(lines[MovementType.purchase]!),
      '+5 units',
    );
    expect(
      stockMovementReportQuantityLabel(lines[MovementType.sale]!),
      '-2 units',
    );
    expect(
      stockMovementReportQuantityLabel(lines[MovementType.transfer]!),
      '4 moved',
    );
    expect(
      stockMovementReportQuantityLabel(lines[MovementType.adjustment]!),
      '+3 adjusted',
    );
    expect(
      stockMovementReportQuantityLabel(lines[MovementType.stockOpname]!),
      '7 counted',
    );
  });
}

Map<MovementType, InventoryStockMovementReportLine> _linesByType() {
  final lines = buildInventoryStockMovementReportLines(
    products: [Product(id: 'p1', name: 'Laptop', sku: 'LT-001')],
    warehouses: [
      Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
      Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
    ],
    movements: [
      InventoryMovement(
        id: 'purchase',
        productId: 'p1',
        sourceWarehouseId: 'w1',
        quantity: 5,
        type: MovementType.purchase,
        date: DateTime(2026, 5, 31, 10),
        reference: 'PO-001',
      ),
      InventoryMovement(
        id: 'sale',
        productId: 'p1',
        sourceWarehouseId: 'w1',
        quantity: 2,
        type: MovementType.sale,
        date: DateTime(2026, 5, 31, 9),
        reference: 'SO-001',
      ),
      InventoryMovement(
        id: 'transfer',
        productId: 'p1',
        sourceWarehouseId: 'w1',
        destinationWarehouseId: 'w2',
        quantity: 4,
        type: MovementType.transfer,
        date: DateTime(2026, 5, 31, 8),
        reference: 'TRF-001',
      ),
      InventoryMovement(
        id: 'adjustment',
        productId: 'p1',
        sourceWarehouseId: 'w1',
        quantity: 3,
        type: MovementType.adjustment,
        date: DateTime(2026, 5, 31, 7),
        reference: 'ADJ-001',
      ),
      InventoryMovement(
        id: 'opname',
        productId: 'p1',
        sourceWarehouseId: 'w1',
        quantity: 7,
        type: MovementType.stockOpname,
        date: DateTime(2026, 5, 31, 6),
        reference: 'OPN-001',
      ),
    ],
  );

  return {for (final line in lines) line.movementType: line};
}

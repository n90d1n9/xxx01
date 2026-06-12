import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_low_stock_report.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_movement_report.dart';
import 'package:kaysir/features/inventory/models/inventory_valuation_report.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_capacity_report.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/services/inventory_report_export_service.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('buildInventoryValuationCsvDocument exports escaped valuation rows', () {
    final document = buildInventoryValuationCsvDocument(
      lines: [
        const InventoryValuationLine(
          inventoryItemId: 'i1',
          productId: 'p1',
          productName: 'Laptop, Pro',
          skuLabel: 'LT-"001"',
          categoryLabel: 'Electronics',
          warehouseId: 'w1',
          warehouseName: 'Main Warehouse',
          warehouseBranch: 'Jakarta Central',
          warehouseLocation: 'Jakarta',
          quantity: 5,
          unitPrice: 100,
        ),
      ],
      asOfDate: DateTime(2026, 5, 31),
    );

    expect(document.fileName, 'inventory-valuation-2026-05-31.csv');
    expect(document.dataRowCount, 1);
    expect(
      document.contents,
      contains('"Laptop, Pro","LT-""001""",Electronics'),
    );
    expect(document.contents, contains('5,100.00,500.00'));
  });

  test('buildWarehouseCapacityCsvDocument exports capacity status', () {
    final document = buildWarehouseCapacityCsvDocument(
      lines: const [
        InventoryWarehouseCapacityLine(
          warehouseId: 'w1',
          warehouseName: 'Main Warehouse',
          branchLabel: 'Jakarta Central',
          locationLabel: 'Jakarta',
          usedUnits: 95,
          productCount: 2,
          capacity: 100,
        ),
        InventoryWarehouseCapacityLine(
          warehouseId: 'w2',
          warehouseName: 'North Warehouse',
          branchLabel: 'Surabaya North',
          locationLabel: 'Surabaya',
          usedUnits: 10,
          productCount: 1,
        ),
      ],
      asOfDate: DateTime(2026, 5, 31),
    );

    expect(document.fileName, 'warehouse-capacity-2026-05-31.csv');
    expect(document.dataRowCount, 2);
    expect(document.contents, contains('95,100,5,95.0,2,Critical'));
    expect(
      document.contents,
      contains(
        'w2,North Warehouse,Surabaya North,Surabaya,10,,,0.0,1,Untracked',
      ),
    );
  });

  test('buildLowStockCsvDocument exports replenishment context', () {
    final document = buildLowStockCsvDocument(
      lines: const [
        InventoryLowStockReportLine(
          inventoryItemId: 'i1',
          productId: 'p1',
          productName: 'Cable',
          skuLabel: 'CB-001',
          categoryLabel: 'Accessories',
          currentQuantity: 2,
          reorderPoint: 5,
          reorderQuantity: 10,
          unitPrice: 25,
          warehouseId: 'w1',
          warehouseName: 'Main Warehouse',
          warehouseBranch: 'Jakarta Central',
          warehouseLocation: 'Jakarta',
        ),
      ],
      asOfDate: DateTime(2026, 5, 31),
    );

    expect(document.fileName, 'low-stock-2026-05-31.csv');
    expect(document.dataRowCount, 1);
    expect(
      document.contents,
      contains(
        'w1,Main Warehouse,Jakarta Central,Jakarta,2,5,3,10,10,12,25.00,250.00,Critical',
      ),
    );
  });

  test('buildStockMovementCsvDocument exports movement context', () {
    final lines = buildInventoryStockMovementReportLines(
      products: [
        Product(id: 'p1', name: 'Laptop, Pro', sku: 'LT-"001"', price: 100),
      ],
      warehouses: [
        Warehouse(
          id: 'w1',
          name: 'Main Warehouse',
          branchName: 'Jakarta Central',
          location: 'Jakarta',
        ),
        Warehouse(
          id: 'w2',
          name: 'North Warehouse',
          branchName: 'Surabaya North',
          location: 'Surabaya',
        ),
      ],
      movements: [
        InventoryMovement(
          id: 'm1',
          productId: 'p1',
          sourceWarehouseId: 'w1',
          destinationWarehouseId: 'w2',
          quantity: 3,
          type: MovementType.transfer,
          date: DateTime(2026, 5, 31, 9, 30),
          reference: 'TRF-001',
          notes: 'Move to launch stock',
        ),
      ],
    );

    final document = buildStockMovementCsvDocument(
      lines: lines,
      asOfDate: DateTime(2026, 5, 31),
    );

    expect(document.fileName, 'stock-movement-2026-05-31.csv');
    expect(document.dataRowCount, 1);
    expect(document.contents, contains('m1,2026-05-31 09:30'));
    expect(document.contents, contains('"Laptop, Pro","LT-""001"""'));
    expect(
      document.contents,
      contains(
        'Transfer,transfer,3,3,w1,Main Warehouse,Jakarta Central,w2,North Warehouse,Surabaya North',
      ),
    );
    expect(document.contents, contains('100.00,300.00,Move to launch stock'));
  });
}

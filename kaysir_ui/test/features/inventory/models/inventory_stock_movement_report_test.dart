import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_movement_report.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('buildInventoryStockMovementReportLines enriches and sorts rows', () {
    final lines = buildInventoryStockMovementReportLines(
      products: _products(),
      movements: _movements(),
      warehouses: _warehouses(),
    );

    expect(lines.map((line) => line.id), ['m3', 'm2', 'm1', 'm4', 'm5']);

    final transfer = lines.first;
    expect(transfer.productName, 'Cable');
    expect(transfer.skuLabel, 'CB-001');
    expect(transfer.typeLabel, 'Transfer');
    expect(transfer.direction, InventoryMovementDirection.transfer);
    expect(transfer.sourceBranchId, 'branch-jakarta');
    expect(transfer.destinationBranchId, 'branch-surabaya');
    expect(transfer.destinationBranchLabel, 'Surabaya North');
    expect(transfer.routeLabel, 'Main Warehouse -> North Warehouse');
    expect(transfer.movementValue, 100);

    final outbound = lines[1];
    expect(outbound.typeLabel, 'Sale');
    expect(outbound.signedQuantity, -2);
    expect(outbound.notesLabel, 'Counter sale');
  });

  test(
    'summarizeInventoryStockMovementReportLines calculates activity totals',
    () {
      final lines = buildInventoryStockMovementReportLines(
        products: _products(),
        movements: _movements(),
        warehouses: _warehouses(),
      );

      final summary = summarizeInventoryStockMovementReportLines(lines);

      expect(summary.movementCount, 5);
      expect(summary.inboundQuantity, 5);
      expect(summary.outboundQuantity, 2);
      expect(summary.netQuantityChange, 2);
      expect(summary.transferCount, 1);
      expect(summary.adjustmentCount, 1);
      expect(summary.auditCount, 1);
      expect(summary.totalMovementValue, 1075);
      expect(summary.productCount, 2);
      expect(summary.warehouseCount, 2);
    },
  );

  test(
    'summarizeInventoryStockMovementReportLines nets transfer by warehouse',
    () {
      final lines = filterInventoryStockMovementReportLines(
        lines: buildInventoryStockMovementReportLines(
          products: _products(),
          movements: _movements(),
          warehouses: _warehouses(),
        ),
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        warehouseId: 'w1',
      );

      final summary = summarizeInventoryStockMovementReportLines(
        lines,
        warehouseId: 'w1',
      );

      expect(lines.map((line) => line.id), ['m3', 'm2', 'm1']);
      expect(summary.netQuantityChange, -1);
    },
  );

  test('filterInventoryStockMovementReportLines applies report filters', () {
    final lines = buildInventoryStockMovementReportLines(
      products: _products(),
      movements: _movements(),
      warehouses: _warehouses(),
    );

    expect(
      filterInventoryStockMovementReportLines(
        lines: lines,
        startDate: DateTime(2026, 5, 30),
        endDate: DateTime(2026, 5, 31),
      ).map((line) => line.id),
      ['m3', 'm2'],
    );
    expect(
      filterInventoryStockMovementReportLines(
        lines: lines,
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        productId: 'p2',
      ).map((line) => line.id),
      ['m3', 'm4', 'm5'],
    );
    expect(
      filterInventoryStockMovementReportLines(
        lines: lines,
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        movementType: MovementType.transfer,
      ).map((line) => line.id),
      ['m3'],
    );
    expect(
      filterInventoryStockMovementReportLines(
        lines: lines,
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        branchName: 'branch-surabaya',
      ).map((line) => line.id),
      ['m3', 'm4', 'm5'],
    );
    expect(
      filterInventoryStockMovementReportLines(
        lines: lines,
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        warehouseId: 'w2',
      ).map((line) => line.id),
      ['m3', 'm4', 'm5'],
    );
  });

  test('inventoryStockMovementReportTypeLabel names every movement type', () {
    expect(
      inventoryStockMovementReportTypeLabel(MovementType.receipt),
      'Receipt',
    );
    expect(inventoryStockMovementReportTypeLabel(MovementType.issue), 'Issue');
    expect(
      inventoryStockMovementReportTypeLabel(MovementType.inbound),
      'Inbound',
    );
    expect(
      inventoryStockMovementReportTypeLabel(MovementType.outbound),
      'Outbound',
    );
  });
}

List<Product> _products() {
  return [
    Product(
      id: 'p1',
      name: 'Laptop',
      sku: 'LT-001',
      category: 'Electronics',
      price: 100,
    ),
    Product(
      id: 'p2',
      name: 'Cable',
      sku: 'CB-001',
      category: 'Accessories',
      price: 25,
    ),
  ];
}

List<Warehouse> _warehouses() {
  return [
    Warehouse(
      id: 'w1',
      name: 'Main Warehouse',
      branchId: 'branch-jakarta',
      branchName: 'Jakarta Central',
      location: 'Jakarta',
    ),
    Warehouse(
      id: 'w2',
      name: 'North Warehouse',
      branchId: 'branch-surabaya',
      branchName: 'Surabaya North',
      location: 'Surabaya',
    ),
  ];
}

List<InventoryMovement> _movements() {
  return [
    InventoryMovement(
      id: 'm1',
      productId: 'p1',
      sourceWarehouseId: 'w1',
      quantity: 5,
      type: MovementType.purchase,
      date: DateTime(2026, 5, 29, 8),
      reference: 'PO-001',
    ),
    InventoryMovement(
      id: 'm2',
      productId: 'p1',
      sourceWarehouseId: 'w1',
      quantity: 2,
      type: MovementType.sale,
      date: DateTime(2026, 5, 30, 8),
      reference: 'SO-001',
      notes: 'Counter sale',
    ),
    InventoryMovement(
      id: 'm3',
      productId: 'p2',
      sourceWarehouseId: 'w1',
      destinationWarehouseId: 'w2',
      quantity: 4,
      type: MovementType.transfer,
      date: DateTime(2026, 5, 31, 9),
      reference: 'TRF-001',
    ),
    InventoryMovement(
      id: 'm4',
      productId: 'p2',
      sourceWarehouseId: 'w2',
      quantity: -1,
      type: MovementType.adjustment,
      date: DateTime(2026, 5, 28, 8),
      reference: 'ADJ-001',
    ),
    InventoryMovement(
      id: 'm5',
      productId: 'p2',
      sourceWarehouseId: 'w2',
      quantity: 10,
      type: MovementType.stockOpname,
      date: DateTime(2026, 5, 27, 8),
      reference: 'COUNT-001',
    ),
  ];
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('buildInventoryMovementRecords enriches and sorts newest first', () {
    final records = buildInventoryMovementRecords(
      products: [
        Product(id: 'p1', name: 'Laptop', sku: 'LT-001'),
        Product(id: 'p2', name: 'Speaker', sku: 'SP-001'),
      ],
      warehouses: [
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
      ],
      movements: [
        InventoryMovement(
          id: 'm1',
          productId: 'p1',
          sourceWarehouseId: 'w1',
          quantity: 3,
          type: MovementType.purchase,
          date: DateTime(2026, 5, 30, 8),
          reference: 'PO-001',
        ),
        InventoryMovement(
          id: 'm2',
          productId: 'p2',
          sourceWarehouseId: 'w1',
          destinationWarehouseId: 'w2',
          quantity: 2,
          type: MovementType.transfer,
          date: DateTime(2026, 5, 31, 9),
          reference: 'TRF-001',
        ),
      ],
    );

    expect(records.first.productName, 'Speaker');
    expect(records.first.typeLabel, 'Transfer');
    expect(records.first.destinationBranchLabel, 'Surabaya North');
    expect(records.first.routeLabel, 'Main Warehouse -> North Warehouse');
    expect(records.last.productName, 'Laptop');
    expect(records.last.direction, InventoryMovementDirection.inbound);
    expect(records.last.signedQuantity, 3);
  });

  test(
    'filterInventoryMovementRecords applies type, warehouse, and search',
    () {
      final records = buildInventoryMovementRecords(
        products: [
          Product(id: 'p1', name: 'Laptop', sku: 'LT-001'),
          Product(id: 'p2', name: 'Speaker', sku: 'SP-001'),
        ],
        warehouses: [
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
        ],
        movements: [
          InventoryMovement(
            id: 'm1',
            productId: 'p1',
            sourceWarehouseId: 'w1',
            quantity: 4,
            type: MovementType.sale,
            date: DateTime(2026, 5, 31),
            reference: 'SO-001',
            notes: 'Counter sale',
          ),
          InventoryMovement(
            id: 'm2',
            productId: 'p2',
            sourceWarehouseId: 'w1',
            destinationWarehouseId: 'w2',
            quantity: 2,
            type: MovementType.transfer,
            date: DateTime(2026, 5, 30),
            reference: 'TRF-001',
          ),
        ],
      );

      expect(
        filterInventoryMovementRecords(
          records,
          filter: InventoryMovementFilter.outbound,
        ).map((record) => record.productName),
        ['Laptop'],
      );
      expect(
        filterInventoryMovementRecords(
          records,
          warehouseId: 'w2',
        ).map((record) => record.productName),
        ['Speaker'],
      );
      expect(
        filterInventoryMovementRecords(
          records,
          branchName: 'branch-surabaya',
        ).map((record) => record.productName),
        ['Speaker'],
      );
      expect(
        filterInventoryMovementRecords(
          records,
          query: 'counter',
        ).map((record) => record.productName),
        ['Laptop'],
      );
    },
  );
}

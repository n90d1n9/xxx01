import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_branch_movements.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('buildInventoryAnalyticsBranchMovement labels movement copy safely', () {
    final movement = buildInventoryAnalyticsBranchMovement(
      movement: _movement(
        quantity: 4,
        type: MovementType.purchase,
        reference: '',
      ),
      product: Product(id: 'product-1', name: 'Laptop'),
      sourceWarehouseName: 'Main Warehouse',
      destinationWarehouseName: null,
    );

    expect(movement.productName, 'Laptop');
    expect(movement.quantity, 4);
    expect(movement.referenceLabel, 'No reference');
    expect(movement.routeLabel, 'Inbound to Main Warehouse');
  });

  test('inventoryAnalyticsBranchMovementQuantity signs outbound movements', () {
    expect(
      inventoryAnalyticsBranchMovementQuantity(
        _movement(quantity: 3, type: MovementType.sale),
      ),
      -3,
    );
    expect(
      inventoryAnalyticsBranchMovementQuantity(
        _movement(quantity: -3, type: MovementType.outbound),
      ),
      -3,
    );
    expect(
      inventoryAnalyticsBranchMovementQuantity(
        _movement(quantity: -2, type: MovementType.adjustment),
      ),
      -2,
    );
  });

  test(
    'inventoryAnalyticsBranchMovementRouteLabel describes route by type',
    () {
      expect(
        inventoryAnalyticsBranchMovementRouteLabel(
          _movement(type: MovementType.sale),
          sourceWarehouseName: 'Main Warehouse',
          destinationWarehouseName: null,
        ),
        'Outbound from Main Warehouse',
      );
      expect(
        inventoryAnalyticsBranchMovementRouteLabel(
          _movement(type: MovementType.transfer),
          sourceWarehouseName: 'Main Warehouse',
          destinationWarehouseName: 'North Warehouse',
        ),
        'Main Warehouse -> North Warehouse',
      );
      expect(
        inventoryAnalyticsBranchMovementRouteLabel(
          _movement(type: MovementType.transfer),
          sourceWarehouseName: 'Main Warehouse',
          destinationWarehouseName: null,
        ),
        'Main Warehouse -> No destination',
      );
    },
  );
}

InventoryMovement _movement({
  int quantity = 1,
  MovementType type = MovementType.purchase,
  String reference = 'REF-001',
}) {
  return InventoryMovement(
    id: 'movement-1',
    productId: 'product-1',
    sourceWarehouseId: 'warehouse-1',
    quantity: quantity,
    type: type,
    date: DateTime(2026, 6, 1, 9),
    reference: reference,
  );
}

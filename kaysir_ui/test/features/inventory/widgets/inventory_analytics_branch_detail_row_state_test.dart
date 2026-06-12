import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_dashboard.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_branch_detail_row_state.dart';

void main() {
  test('branch warehouse row state formats stock and health labels', () {
    final state = InventoryAnalyticsBranchWarehouseRowState.fromWarehouse(
      const InventoryAnalyticsBranchWarehouse(
        warehouseId: 'main',
        warehouseName: 'Main Warehouse',
        locationLabel: 'Jakarta',
        value: 11100,
        quantity: 120,
        lowStockCount: 2,
        productCount: 20,
      ),
    );

    expect(state.title, 'Main Warehouse');
    expect(state.subtitle, 'Jakarta | 120 units | 20 products');
    expect(state.valueLabel, r'$11,100.00');
    expect(state.healthLabel, '2 low');
    expect(state.healthIcon, Icons.warning_amber_rounded);
    expect(state.isHealthy, isFalse);
  });

  test('branch warehouse row state marks healthy warehouses', () {
    final state = InventoryAnalyticsBranchWarehouseRowState.fromWarehouse(
      const InventoryAnalyticsBranchWarehouse(
        warehouseId: 'north',
        warehouseName: 'North Warehouse',
        locationLabel: 'Surabaya',
        value: 7500,
        quantity: 157,
        lowStockCount: 0,
        productCount: 18,
      ),
    );

    expect(state.healthLabel, 'Healthy');
    expect(state.healthIcon, Icons.check_circle_rounded);
    expect(state.isHealthy, isTrue);
  });

  test('branch movement row state formats route and quantity labels', () {
    final state = InventoryAnalyticsBranchMovementRowState.fromMovement(
      InventoryAnalyticsBranchMovement(
        productName: 'Cable',
        type: MovementType.transfer,
        quantity: 6,
        referenceLabel: 'TRF-001',
        routeLabel: 'Main Warehouse -> Overflow Hub',
        date: DateTime(2026, 6, 7, 12),
      ),
    );

    expect(state.title, 'Cable');
    expect(
      state.subtitle,
      'Jun 7, 2026, 12:00 | Main Warehouse -> Overflow Hub | TRF-001',
    );
    expect(state.typeLabel, 'Transfer');
    expect(state.typeIcon, Icons.swap_horiz_rounded);
    expect(state.quantityLabel, '+6 units');
  });
}

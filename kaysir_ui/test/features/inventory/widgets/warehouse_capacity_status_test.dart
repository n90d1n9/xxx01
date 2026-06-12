import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_warehouse_capacity_report.dart';
import 'package:kaysir/features/inventory/widgets/warehouse_capacity_metrics.dart';
import 'package:kaysir/features/inventory/widgets/warehouse_capacity_progress.dart';
import 'package:kaysir/features/inventory/widgets/warehouse_capacity_status.dart';

void main() {
  test('warehouse capacity status icons remain stable', () {
    expect(
      inventoryWarehouseCapacityStatusIcon(
        InventoryWarehouseCapacityStatus.untracked,
      ),
      Icons.help_outline_rounded,
    );
    expect(
      inventoryWarehouseCapacityStatusIcon(
        InventoryWarehouseCapacityStatus.low,
      ),
      Icons.check_circle_outline_rounded,
    );
    expect(
      inventoryWarehouseCapacityStatusIcon(
        InventoryWarehouseCapacityStatus.moderate,
      ),
      Icons.speed_rounded,
    );
    expect(
      inventoryWarehouseCapacityStatusIcon(
        InventoryWarehouseCapacityStatus.high,
      ),
      Icons.trending_up_rounded,
    );
    expect(
      inventoryWarehouseCapacityStatusIcon(
        InventoryWarehouseCapacityStatus.critical,
      ),
      Icons.warning_amber_rounded,
    );
  });

  test('warehouse capacity labels format tracked and untracked values', () {
    expect(inventoryWarehouseCapacityPercentLabel(95), '95.0%');
    expect(inventoryWarehouseCapacityValueLabel(null), 'Not set');
    expect(inventoryWarehouseCapacityValueLabel(1200), '1,200');
    expect(inventoryWarehouseCapacityAvailableLabel(null), 'Unknown');
    expect(inventoryWarehouseCapacityAvailableLabel(-4), '-4');
  });
}

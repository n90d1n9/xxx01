import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/widgets/movement_direction_visuals.dart';

void main() {
  test('movement direction icons remain stable for timeline UI', () {
    expect(
      movementDirectionIcon(InventoryMovementDirection.inbound),
      Icons.south_west_rounded,
    );
    expect(
      movementDirectionIcon(InventoryMovementDirection.outbound),
      Icons.north_east_rounded,
    );
    expect(
      movementDirectionIcon(InventoryMovementDirection.transfer),
      Icons.compare_arrows_rounded,
    );
    expect(
      movementDirectionIcon(InventoryMovementDirection.adjustment),
      Icons.tune_rounded,
    );
    expect(
      movementDirectionIcon(InventoryMovementDirection.audit),
      Icons.fact_check_rounded,
    );
  });

  test('movement direction quantity labels describe operational impact', () {
    expect(
      movementDirectionQuantityLabel(InventoryMovementDirection.inbound, 1200),
      '+1,200 units',
    );
    expect(
      movementDirectionQuantityLabel(InventoryMovementDirection.outbound, 12),
      '-12 units',
    );
    expect(
      movementDirectionQuantityLabel(InventoryMovementDirection.transfer, 8),
      '8 moved',
    );
    expect(
      movementDirectionQuantityLabel(InventoryMovementDirection.adjustment, 3),
      '3 adjusted',
    );
    expect(
      movementDirectionQuantityLabel(InventoryMovementDirection.audit, 5),
      '5 counted',
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/widgets/movement_type_visuals.dart';

void main() {
  test('movement type labels group operational aliases consistently', () {
    expect(inventoryMovementTypeLabel(MovementType.purchase), 'Inbound');
    expect(inventoryMovementTypeLabel(MovementType.receipt), 'Inbound');
    expect(inventoryMovementTypeLabel(MovementType.inbound), 'Inbound');
    expect(inventoryMovementTypeLabel(MovementType.sale), 'Outbound');
    expect(inventoryMovementTypeLabel(MovementType.issue), 'Outbound');
    expect(inventoryMovementTypeLabel(MovementType.outbound), 'Outbound');
    expect(inventoryMovementTypeLabel(MovementType.transfer), 'Transfer');
    expect(inventoryMovementTypeLabel(MovementType.adjustment), 'Adjustment');
    expect(
      inventoryMovementTypeLabel(MovementType.stockOpname),
      'Stock Opname',
    );
  });

  test('movement type icons remain stable for reusable activity UI', () {
    expect(
      inventoryMovementTypeIcon(MovementType.purchase),
      Icons.call_received_rounded,
    );
    expect(
      inventoryMovementTypeIcon(MovementType.sale),
      Icons.call_made_rounded,
    );
    expect(
      inventoryMovementTypeIcon(MovementType.transfer),
      Icons.swap_horiz_rounded,
    );
    expect(
      inventoryMovementTypeIcon(MovementType.adjustment),
      Icons.tune_rounded,
    );
    expect(
      inventoryMovementTypeIcon(MovementType.stockOpname),
      Icons.fact_check_outlined,
    );
  });
}

import 'package:flutter/material.dart';

import '../models/inventory_movement_record.dart';

/// Visual contract shared by warehouse movement flow panels and tiles.
class InventoryWarehouseMovementFlowVisuals {
  const InventoryWarehouseMovementFlowVisuals({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

InventoryWarehouseMovementFlowVisuals
inventoryWarehouseMovementDirectionVisuals(
  BuildContext context,
  InventoryMovementDirection direction,
) {
  final colorScheme = Theme.of(context).colorScheme;

  switch (direction) {
    case InventoryMovementDirection.inbound:
      return InventoryWarehouseMovementFlowVisuals(
        label: 'Inbound',
        icon: Icons.south_west_rounded,
        color: Colors.green.shade700,
      );
    case InventoryMovementDirection.outbound:
      return InventoryWarehouseMovementFlowVisuals(
        label: 'Outbound',
        icon: Icons.north_east_rounded,
        color: colorScheme.error,
      );
    case InventoryMovementDirection.transfer:
      return InventoryWarehouseMovementFlowVisuals(
        label: 'Transfer',
        icon: Icons.compare_arrows_rounded,
        color: Colors.indigo.shade700,
      );
    case InventoryMovementDirection.adjustment:
      return InventoryWarehouseMovementFlowVisuals(
        label: 'Adjustment',
        icon: Icons.tune_rounded,
        color: Colors.orange.shade700,
      );
    case InventoryMovementDirection.audit:
      return InventoryWarehouseMovementFlowVisuals(
        label: 'Audit',
        icon: Icons.fact_check_rounded,
        color: Colors.blueGrey.shade700,
      );
  }
}

InventoryWarehouseMovementFlowVisuals inventoryWarehouseMovementNetVisuals(
  BuildContext context,
  int netUnits,
) {
  if (netUnits > 0) {
    return InventoryWarehouseMovementFlowVisuals(
      label: 'Net gain',
      icon: Icons.trending_up_rounded,
      color: Colors.green.shade700,
    );
  }
  if (netUnits < 0) {
    return InventoryWarehouseMovementFlowVisuals(
      label: 'Net loss',
      icon: Icons.trending_down_rounded,
      color: Theme.of(context).colorScheme.error,
    );
  }
  return InventoryWarehouseMovementFlowVisuals(
    label: 'Balanced',
    icon: Icons.remove_circle_outline_rounded,
    color: Colors.blueGrey.shade700,
  );
}

Color inventoryWarehouseSignedMovementColor(
  BuildContext context,
  int netUnits,
) {
  if (netUnits > 0) return Colors.green.shade700;
  if (netUnits < 0) return Theme.of(context).colorScheme.error;
  return Colors.blueGrey.shade700;
}

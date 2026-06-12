import 'package:flutter/material.dart';

import '../models/movement_type.dart';

/// Visual contract shared by movement activity rows and analytics drill-downs.
class InventoryMovementTypeVisuals {
  const InventoryMovementTypeVisuals({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// Returns the compact activity label for an inventory movement type.
String inventoryMovementTypeLabel(MovementType type) {
  switch (type) {
    case MovementType.purchase:
    case MovementType.receipt:
    case MovementType.inbound:
      return 'Inbound';
    case MovementType.sale:
    case MovementType.issue:
    case MovementType.outbound:
      return 'Outbound';
    case MovementType.transfer:
      return 'Transfer';
    case MovementType.adjustment:
      return 'Adjustment';
    case MovementType.stockOpname:
      return 'Stock Opname';
  }
}

/// Returns the Material icon used for an inventory movement type.
IconData inventoryMovementTypeIcon(MovementType type) {
  switch (type) {
    case MovementType.purchase:
    case MovementType.receipt:
    case MovementType.inbound:
      return Icons.call_received_rounded;
    case MovementType.sale:
    case MovementType.issue:
    case MovementType.outbound:
      return Icons.call_made_rounded;
    case MovementType.transfer:
      return Icons.swap_horiz_rounded;
    case MovementType.adjustment:
      return Icons.tune_rounded;
    case MovementType.stockOpname:
      return Icons.fact_check_outlined;
  }
}

/// Returns the tone color used for an inventory movement type.
Color inventoryMovementTypeColor(BuildContext context, MovementType type) {
  final colorScheme = Theme.of(context).colorScheme;

  switch (type) {
    case MovementType.purchase:
    case MovementType.receipt:
    case MovementType.inbound:
      return Colors.green.shade700;
    case MovementType.sale:
    case MovementType.issue:
    case MovementType.outbound:
      return colorScheme.error;
    case MovementType.transfer:
      return colorScheme.primary;
    case MovementType.adjustment:
      return Colors.orange.shade700;
    case MovementType.stockOpname:
      return Colors.indigo.shade600;
  }
}

/// Resolves the complete visual recipe for an inventory movement type.
InventoryMovementTypeVisuals inventoryMovementTypeVisuals(
  BuildContext context,
  MovementType type,
) {
  return InventoryMovementTypeVisuals(
    label: inventoryMovementTypeLabel(type),
    icon: inventoryMovementTypeIcon(type),
    color: inventoryMovementTypeColor(context, type),
  );
}

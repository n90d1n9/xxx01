import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/inventory_movement_record.dart';
import '../utils/inventory_formatters.dart';

/// Visual contract shared by movement history rows, summaries, and filters.
class MovementDirectionVisuals {
  const MovementDirectionVisuals({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

/// Returns the icon used for an inventory movement direction.
IconData movementDirectionIcon(InventoryMovementDirection direction) {
  switch (direction) {
    case InventoryMovementDirection.inbound:
      return Icons.south_west_rounded;
    case InventoryMovementDirection.outbound:
      return Icons.north_east_rounded;
    case InventoryMovementDirection.transfer:
      return Icons.compare_arrows_rounded;
    case InventoryMovementDirection.adjustment:
      return Icons.tune_rounded;
    case InventoryMovementDirection.audit:
      return Icons.fact_check_rounded;
  }
}

/// Returns a static tone for places that cannot depend on theme error color.
Color movementDirectionStaticColor(InventoryMovementDirection direction) {
  switch (direction) {
    case InventoryMovementDirection.inbound:
      return Colors.green.shade700;
    case InventoryMovementDirection.outbound:
      return Colors.red.shade700;
    case InventoryMovementDirection.transfer:
      return Colors.indigo.shade700;
    case InventoryMovementDirection.adjustment:
      return Colors.orange.shade700;
    case InventoryMovementDirection.audit:
      return Colors.blueGrey.shade700;
  }
}

/// Returns the tone color used for an inventory movement direction.
Color movementDirectionColor(
  BuildContext context,
  InventoryMovementDirection direction,
) {
  if (direction == InventoryMovementDirection.outbound) {
    return Theme.of(context).colorScheme.error;
  }
  return movementDirectionStaticColor(direction);
}

/// Resolves the complete visual recipe for an inventory movement direction.
MovementDirectionVisuals movementDirectionVisuals(
  BuildContext context,
  InventoryMovementDirection direction,
) {
  return MovementDirectionVisuals(
    icon: movementDirectionIcon(direction),
    color: movementDirectionColor(context, direction),
  );
}

/// Formats a compact quantity label for an inventory movement direction.
String movementDirectionQuantityLabel(
  InventoryMovementDirection direction,
  int quantity, {
  NumberFormat? formatter,
}) {
  final formatted = formatInventoryNumber(quantity, formatter: formatter);

  switch (direction) {
    case InventoryMovementDirection.inbound:
      return '+$formatted units';
    case InventoryMovementDirection.outbound:
      return '-$formatted units';
    case InventoryMovementDirection.transfer:
      return '$formatted moved';
    case InventoryMovementDirection.adjustment:
      return '$formatted adjusted';
    case InventoryMovementDirection.audit:
      return '$formatted counted';
  }
}

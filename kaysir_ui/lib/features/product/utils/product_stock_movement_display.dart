import 'package:flutter/material.dart';

import '../../inventory/models/movement_type.dart';
import '../../inventory/models/stock_movement.dart';

class ProductStockMovementDisplay {
  const ProductStockMovementDisplay({
    required this.icon,
    required this.color,
    required this.typeLabel,
    required this.quantityLabel,
  });

  final IconData icon;
  final Color color;
  final String typeLabel;
  final String quantityLabel;

  factory ProductStockMovementDisplay.fromMovement(StockMovement movement) {
    final presentation = _presentationFor(movement.type);
    final sign = _isNegative(movement.type) ? '-' : '+';

    return ProductStockMovementDisplay(
      icon: presentation.icon,
      color: presentation.color,
      typeLabel: presentation.label,
      quantityLabel: '$sign${movement.quantity} units',
    );
  }
}

bool _isNegative(MovementType type) {
  switch (type) {
    case MovementType.issue:
    case MovementType.sale:
    case MovementType.outbound:
      return true;
    case MovementType.receipt:
    case MovementType.transfer:
    case MovementType.adjustment:
    case MovementType.stockOpname:
    case MovementType.purchase:
    case MovementType.inbound:
      return false;
  }
}

_MovementPresentation _presentationFor(MovementType type) {
  switch (type) {
    case MovementType.inbound:
    case MovementType.receipt:
    case MovementType.purchase:
      return _MovementPresentation(
        icon: Icons.arrow_downward_rounded,
        color: Colors.green,
        label: _movementTypeLabel(type),
      );
    case MovementType.outbound:
    case MovementType.issue:
    case MovementType.sale:
      return _MovementPresentation(
        icon: Icons.arrow_upward_rounded,
        color: Colors.red,
        label: _movementTypeLabel(type),
      );
    case MovementType.transfer:
      return _MovementPresentation(
        icon: Icons.compare_arrows_rounded,
        color: Colors.blue,
        label: _movementTypeLabel(type),
      );
    case MovementType.adjustment:
    case MovementType.stockOpname:
      return _MovementPresentation(
        icon: Icons.sync_rounded,
        color: Colors.orange,
        label: _movementTypeLabel(type),
      );
  }
}

String _movementTypeLabel(MovementType type) {
  return productStockMovementTypeLabel(type);
}

String productStockMovementTypeLabel(MovementType type) {
  switch (type) {
    case MovementType.receipt:
      return 'Receipt';
    case MovementType.issue:
      return 'Issue';
    case MovementType.transfer:
      return 'Transfer';
    case MovementType.adjustment:
      return 'Adjustment';
    case MovementType.stockOpname:
      return 'Stock opname';
    case MovementType.purchase:
      return 'Purchase';
    case MovementType.sale:
      return 'Sale';
    case MovementType.inbound:
      return 'Inbound';
    case MovementType.outbound:
      return 'Outbound';
  }
}

class _MovementPresentation {
  const _MovementPresentation({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;
}

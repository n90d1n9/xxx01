import 'package:flutter/material.dart';

import '../models/inventory_stock_record.dart';

/// Visual contract shared by stock status pills, badges, and health panels.
class InventoryStockStatusVisuals {
  const InventoryStockStatusVisuals({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// Returns the human-readable stock status label used across inventory UI.
String inventoryStockStatusLabel(InventoryStockStatus status) {
  switch (status) {
    case InventoryStockStatus.outOfStock:
      return 'Out of stock';
    case InventoryStockStatus.lowStock:
      return 'Low stock';
    case InventoryStockStatus.inStock:
      return 'In stock';
  }
}

/// Returns the Material icon used to represent an inventory stock status.
IconData inventoryStockStatusIcon(InventoryStockStatus status) {
  switch (status) {
    case InventoryStockStatus.outOfStock:
      return Icons.error_outline_rounded;
    case InventoryStockStatus.lowStock:
      return Icons.warning_amber_rounded;
    case InventoryStockStatus.inStock:
      return Icons.check_circle_outline_rounded;
  }
}

/// Returns the tone color used to represent an inventory stock status.
Color inventoryStockStatusColor(
  BuildContext context,
  InventoryStockStatus status,
) {
  final colorScheme = Theme.of(context).colorScheme;

  switch (status) {
    case InventoryStockStatus.outOfStock:
      return colorScheme.error;
    case InventoryStockStatus.lowStock:
      return Colors.orange.shade700;
    case InventoryStockStatus.inStock:
      return Colors.green.shade700;
  }
}

/// Resolves the complete visual recipe for an inventory stock status.
InventoryStockStatusVisuals inventoryStockStatusVisuals(
  BuildContext context,
  InventoryStockStatus status,
) {
  return InventoryStockStatusVisuals(
    label: inventoryStockStatusLabel(status),
    icon: inventoryStockStatusIcon(status),
    color: inventoryStockStatusColor(context, status),
  );
}

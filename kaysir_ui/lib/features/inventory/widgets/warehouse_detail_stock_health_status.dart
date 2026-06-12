import 'package:flutter/material.dart';

import '../models/inventory_warehouse_detail.dart';

/// Visual tone shown in the stock-health panel summary pill.
class InventoryWarehouseStockHealthTone {
  const InventoryWarehouseStockHealthTone({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// Resolves the headline stock-health tone for a warehouse detail summary.
InventoryWarehouseStockHealthTone inventoryWarehouseStockHealthTone(
  BuildContext context,
  InventoryWarehouseDetail detail,
) {
  if (detail.outOfStockLineCount > 0) {
    return InventoryWarehouseStockHealthTone(
      label: 'Critical',
      icon: Icons.error_outline_rounded,
      color: Theme.of(context).colorScheme.error,
    );
  }

  if (detail.lowStockLineCount > 0) {
    return InventoryWarehouseStockHealthTone(
      label: 'Watch',
      icon: Icons.warning_amber_rounded,
      color: Colors.orange.shade700,
    );
  }

  return InventoryWarehouseStockHealthTone(
    label: 'Healthy',
    icon: Icons.check_circle_outline_rounded,
    color: Colors.green.shade700,
  );
}

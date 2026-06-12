import 'package:flutter/material.dart';

import '../models/inventory_report_catalog.dart';

/// Visual contract for an inventory report definition card.
class InventoryReportVisuals {
  const InventoryReportVisuals({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

/// Returns the icon used for a report type in the catalog.
IconData inventoryReportIconFor(InventoryReportType type) {
  switch (type) {
    case InventoryReportType.valuation:
      return Icons.payments_rounded;
    case InventoryReportType.movementHistory:
      return Icons.timeline_rounded;
    case InventoryReportType.lowStock:
      return Icons.warning_amber_rounded;
    case InventoryReportType.warehouseCapacity:
      return Icons.warehouse_rounded;
  }
}

/// Returns the tone color used for a report type in the catalog.
Color inventoryReportColorFor(InventoryReportType type) {
  switch (type) {
    case InventoryReportType.valuation:
      return Colors.green.shade700;
    case InventoryReportType.movementHistory:
      return Colors.blue.shade700;
    case InventoryReportType.lowStock:
      return Colors.orange.shade700;
    case InventoryReportType.warehouseCapacity:
      return Colors.purple.shade700;
  }
}

/// Resolves the complete visual recipe for a report type in the catalog.
InventoryReportVisuals inventoryReportVisualsFor(InventoryReportType type) {
  return InventoryReportVisuals(
    icon: inventoryReportIconFor(type),
    color: inventoryReportColorFor(type),
  );
}

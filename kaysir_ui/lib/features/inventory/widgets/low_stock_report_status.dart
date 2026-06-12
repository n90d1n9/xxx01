import 'package:flutter/material.dart';

import '../models/inventory_low_stock_report.dart';

/// Returns the icon used for a low-stock report status.
IconData inventoryLowStockReportStatusIcon(
  InventoryLowStockReportStatus status,
) {
  switch (status) {
    case InventoryLowStockReportStatus.outOfStock:
      return Icons.remove_circle_outline_rounded;
    case InventoryLowStockReportStatus.critical:
      return Icons.priority_high_rounded;
    case InventoryLowStockReportStatus.lowStock:
      return Icons.warning_amber_rounded;
  }
}

/// Returns the tone color used for a low-stock report status.
Color inventoryLowStockReportStatusColor(InventoryLowStockReportStatus status) {
  switch (status) {
    case InventoryLowStockReportStatus.outOfStock:
      return Colors.red.shade700;
    case InventoryLowStockReportStatus.critical:
      return Colors.deepOrange.shade700;
    case InventoryLowStockReportStatus.lowStock:
      return Colors.orange.shade700;
  }
}

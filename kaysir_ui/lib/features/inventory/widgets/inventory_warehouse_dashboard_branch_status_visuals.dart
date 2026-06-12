import 'package:flutter/material.dart';

import '../models/inventory_warehouse_dashboard.dart';

IconData inventoryWarehouseDashboardStatusIcon(
  InventoryWarehouseDashboardStatus status,
) {
  switch (status) {
    case InventoryWarehouseDashboardStatus.healthy:
      return Icons.check_circle_outline_rounded;
    case InventoryWarehouseDashboardStatus.watch:
      return Icons.visibility_rounded;
    case InventoryWarehouseDashboardStatus.attention:
      return Icons.warning_amber_rounded;
    case InventoryWarehouseDashboardStatus.setup:
      return Icons.add_business_rounded;
  }
}

Color inventoryWarehouseDashboardStatusColor(
  InventoryWarehouseDashboardStatus status,
) {
  switch (status) {
    case InventoryWarehouseDashboardStatus.healthy:
      return Colors.green.shade700;
    case InventoryWarehouseDashboardStatus.watch:
      return Colors.amber.shade800;
    case InventoryWarehouseDashboardStatus.attention:
      return Colors.deepOrange.shade700;
    case InventoryWarehouseDashboardStatus.setup:
      return Colors.blueGrey.shade700;
  }
}

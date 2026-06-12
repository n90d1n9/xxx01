import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_warehouse_capacity_report.dart';

/// Status pill for warehouse capacity health.
class InventoryWarehouseCapacityStatusPill extends StatelessWidget {
  const InventoryWarehouseCapacityStatusPill({
    super.key,
    required this.status,
    this.maxWidth = 140,
  });

  final InventoryWarehouseCapacityStatus status;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: inventoryWarehouseCapacityStatusLabel(status),
      icon: inventoryWarehouseCapacityStatusIcon(status),
      color: inventoryWarehouseCapacityStatusColor(status),
      maxWidth: maxWidth,
    );
  }
}

/// Returns the icon used for a warehouse capacity status.
IconData inventoryWarehouseCapacityStatusIcon(
  InventoryWarehouseCapacityStatus status,
) {
  switch (status) {
    case InventoryWarehouseCapacityStatus.untracked:
      return Icons.help_outline_rounded;
    case InventoryWarehouseCapacityStatus.low:
      return Icons.check_circle_outline_rounded;
    case InventoryWarehouseCapacityStatus.moderate:
      return Icons.speed_rounded;
    case InventoryWarehouseCapacityStatus.high:
      return Icons.trending_up_rounded;
    case InventoryWarehouseCapacityStatus.critical:
      return Icons.warning_amber_rounded;
  }
}

/// Returns the tone color used for a warehouse capacity status.
Color inventoryWarehouseCapacityStatusColor(
  InventoryWarehouseCapacityStatus status,
) {
  switch (status) {
    case InventoryWarehouseCapacityStatus.untracked:
      return Colors.blueGrey.shade700;
    case InventoryWarehouseCapacityStatus.low:
      return Colors.green.shade700;
    case InventoryWarehouseCapacityStatus.moderate:
      return Colors.amber.shade800;
    case InventoryWarehouseCapacityStatus.high:
      return Colors.orange.shade700;
    case InventoryWarehouseCapacityStatus.critical:
      return Colors.red.shade700;
  }
}

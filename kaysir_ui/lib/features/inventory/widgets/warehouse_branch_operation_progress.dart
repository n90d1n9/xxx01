import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_warehouse_capacity_report.dart';
import 'inventory_warehouse_capacity_status_visuals.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Capacity utilization progress bar for a warehouse operation row.
class InventoryWarehouseOperationCapacityProgress extends StatelessWidget {
  const InventoryWarehouseOperationCapacityProgress({
    super.key,
    required this.line,
  });

  final InventoryWarehouseCapacityLine line;

  @override
  Widget build(BuildContext context) {
    final statusColor = inventoryWarehouseCapacityStatusColor(line.status);

    return LinearProgressIndicator(
      value:
          line.hasTrackedCapacity
              ? (line.utilizationPercent / 100).clamp(0, 1)
              : 0,
      minHeight: 8,
      borderRadius: BorderRadius.circular(999),
      color: statusColor,
      backgroundColor: statusColor.withValues(alpha: 0.14),
    );
  }
}

@Preview(name: 'Warehouse branch operation capacity progress')
Widget inventoryWarehouseOperationCapacityProgressPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseOperationCapacityProgress(
      line: inventoryWarehouseBranchOperationPreview().capacityLine,
    ),
  );
}

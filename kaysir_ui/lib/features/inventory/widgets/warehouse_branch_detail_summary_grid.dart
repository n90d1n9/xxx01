import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_warehouse_dashboard.dart';
import '../utils/inventory_formatters.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Branch-level metric grid for warehouse count, capacity, stock, and alerts.
class InventoryWarehouseBranchDetailSummaryGrid extends StatelessWidget {
  const InventoryWarehouseBranchDetailSummaryGrid({
    super.key,
    required this.detail,
  });

  final InventoryWarehouseBranchDetail detail;

  @override
  Widget build(BuildContext context) {
    final summary = detail.summary;
    final utilization =
        summary.totalCapacity <= 0
            ? 'Untracked'
            : '${summary.utilizationPercent.toStringAsFixed(1)}%';

    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Warehouses',
          value: formatInventoryNumber(summary.warehouseCount),
          helper:
              '${formatInventoryNumber(summary.trackedWarehouseCount)} capacity tracked',
          icon: Icons.warehouse_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Capacity',
          value: utilization,
          helper:
              '${formatInventoryNumber(summary.usedUnits)} of ${formatInventoryNumber(summary.totalCapacity)} used',
          icon: Icons.speed_rounded,
          accentColor:
              summary.criticalWarehouseCount > 0
                  ? Colors.red.shade700
                  : Colors.green.shade700,
        ),
        AppMetricGridItem(
          title: 'Stock Lines',
          value: formatInventoryNumber(detail.stockLineCount),
          helper: '${formatInventoryNumber(detail.totalUnits)} units on hand',
          icon: Icons.inventory_2_rounded,
          accentColor: Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Attention',
          value: formatInventoryNumber(detail.attentionStockRecords.length),
          helper:
              '${formatInventoryNumber(summary.untrackedWarehouseCount)} untracked warehouses',
          icon: Icons.notification_important_rounded,
          accentColor:
              detail.attentionStockRecords.isEmpty
                  ? Colors.green.shade700
                  : Colors.deepOrange.shade700,
        ),
      ],
    );
  }
}

@Preview(name: 'Warehouse branch detail summary grid')
Widget inventoryWarehouseBranchDetailSummaryGridPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseBranchDetailSummaryGrid(
      detail: inventoryWarehouseBranchDetailPreviewDetail(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_warehouse_detail.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_warehouse_capacity_report_components.dart';
import 'warehouse_detail_overview_preview_data.dart';

/// Summary metric grid for utilization, stock, value, and attention.
class InventoryWarehouseDetailSummaryGrid extends StatelessWidget {
  const InventoryWarehouseDetailSummaryGrid({super.key, required this.detail});

  final InventoryWarehouseDetail detail;

  @override
  Widget build(BuildContext context) {
    final line = detail.capacityLine;
    final utilization =
        line.hasTrackedCapacity
            ? '${line.utilizationPercent.toStringAsFixed(1)}%'
            : 'Untracked';

    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Utilization',
          value: utilization,
          helper:
              '${formatInventoryNumber(line.usedUnits)} units used in this warehouse',
          icon: Icons.speed_rounded,
          accentColor: inventoryWarehouseCapacityStatusColor(line.status),
        ),
        AppMetricGridItem(
          title: 'Stock Lines',
          value: formatInventoryNumber(detail.stockLineCount),
          helper: '${formatInventoryNumber(detail.totalUnits)} total units',
          icon: Icons.inventory_2_rounded,
          accentColor: Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Value',
          value: formatInventoryCurrency(detail.stockValue),
          helper: 'Inventory value in location',
          icon: Icons.payments_rounded,
          accentColor: Colors.green.shade700,
        ),
        AppMetricGridItem(
          title: 'Attention',
          value: formatInventoryNumber(detail.attentionStockRecords.length),
          helper:
              '${formatInventoryNumber(detail.movementRecords.length)} movements tracked',
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

@Preview(name: 'Warehouse detail summary grid')
Widget inventoryWarehouseDetailSummaryGridPreview() {
  return inventoryWarehouseOverviewPreviewScaffold(
    InventoryWarehouseDetailSummaryGrid(
      detail: inventoryWarehouseOverviewPreviewDetail(),
    ),
  );
}

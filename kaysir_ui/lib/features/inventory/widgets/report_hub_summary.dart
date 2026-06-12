import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_report_catalog.dart';
import '../utils/inventory_formatters.dart';

/// Summary metric grid for the inventory report hub.
class InventoryReportHubSummary extends StatelessWidget {
  const InventoryReportHubSummary({super.key, required this.stats});

  final InventoryReportHubStats stats;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Reports',
          value:
              '${stats.readyReportCount}/${inventoryReportDefinitions.length}',
          helper: 'Ready from current data',
          icon: Icons.assessment_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Stock Lines',
          value: formatInventoryNumber(stats.stockLineCount),
          helper:
              '${formatInventoryNumber(stats.productCount)} products tracked',
          icon: Icons.inventory_2_rounded,
          accentColor: Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Movements',
          value: formatInventoryNumber(stats.movementCount),
          helper: 'Operational history records',
          icon: Icons.sync_alt_rounded,
          accentColor: Colors.indigo.shade700,
        ),
        AppMetricGridItem(
          title: 'Low Stock',
          value: formatInventoryNumber(stats.lowStockCount),
          helper: '${formatInventoryNumber(stats.warehouseCount)} warehouses',
          icon: Icons.notification_important_rounded,
          accentColor:
              stats.lowStockCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
        ),
      ],
    );
  }
}

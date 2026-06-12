import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_warehouse_capacity_report.dart';
import '../utils/inventory_formatters.dart';
import 'warehouse_capacity_progress.dart';

/// Summary metric grid for the warehouse capacity report.
class InventoryWarehouseCapacitySummaryGrid extends StatelessWidget {
  const InventoryWarehouseCapacitySummaryGrid({
    super.key,
    required this.summary,
  });

  final InventoryWarehouseCapacitySummary summary;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Utilization',
          value: inventoryWarehouseCapacityPercentLabel(
            summary.utilizationPercent,
          ),
          helper:
              '${formatInventoryNumber(summary.usedUnits)} of ${formatInventoryNumber(summary.totalCapacity)} capacity',
          icon: Icons.speed_rounded,
          accentColor:
              summary.criticalWarehouseCount > 0
                  ? Colors.red.shade700
                  : Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Warehouses',
          value: '${summary.trackedWarehouseCount}/${summary.warehouseCount}',
          helper: 'Locations with tracked capacity',
          icon: Icons.warehouse_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Available',
          value: formatInventoryNumber(summary.availableUnits),
          helper: 'Remaining tracked capacity',
          icon: Icons.inventory_rounded,
          accentColor:
              summary.availableUnits < 0
                  ? Colors.red.shade700
                  : Colors.green.shade700,
        ),
        AppMetricGridItem(
          title: 'Critical',
          value: formatInventoryNumber(summary.criticalWarehouseCount),
          helper:
              '${formatInventoryNumber(summary.productCount)} product slots',
          icon: Icons.warning_amber_rounded,
          accentColor:
              summary.criticalWarehouseCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_low_stock_report.dart';
import '../utils/inventory_formatters.dart';

/// Summary metric grid for low-stock report alerts.
class InventoryLowStockReportSummaryGrid extends StatelessWidget {
  const InventoryLowStockReportSummaryGrid({super.key, required this.summary});

  final InventoryLowStockReportSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Active Alerts',
          value: formatInventoryNumber(summary.alertCount),
          helper: '${formatInventoryNumber(summary.productCount)} products',
          icon: Icons.notification_important_rounded,
          accentColor:
              summary.alertCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Critical',
          value: formatInventoryNumber(summary.criticalCount),
          helper:
              '${formatInventoryNumber(summary.outOfStockCount)} out of stock',
          icon: Icons.priority_high_rounded,
          accentColor:
              summary.criticalCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
        ),
        AppMetricGridItem(
          title: 'Shortage',
          value: formatInventoryNumber(summary.totalShortage),
          helper: 'Units below reorder point',
          icon: Icons.remove_shopping_cart_rounded,
          accentColor: Colors.deepOrange.shade700,
        ),
        AppMetricGridItem(
          title: 'Suggested Units',
          value: formatInventoryNumber(summary.suggestedUnits),
          helper:
              '${formatInventoryCurrency(summary.estimatedCost)} estimated cost',
          icon: Icons.add_shopping_cart_rounded,
          accentColor: Colors.blue.shade700,
        ),
      ],
    );
  }
}

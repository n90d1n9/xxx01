import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_movement_record.dart';
import '../models/inventory_stock_movement_report.dart';
import '../utils/inventory_formatters.dart';
import 'movement_direction_visuals.dart';

/// Summary metric grid for the stock movement report.
class InventoryStockMovementReportSummaryGrid extends StatelessWidget {
  const InventoryStockMovementReportSummaryGrid({
    super.key,
    required this.summary,
  });

  final InventoryStockMovementReportSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Movements',
          value: formatInventoryNumber(summary.movementCount),
          helper:
              '${formatInventoryNumber(summary.productCount)} products, ${formatInventoryNumber(summary.warehouseCount)} warehouses',
          icon: Icons.timeline_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Inbound',
          value: formatInventoryNumber(summary.inboundQuantity),
          helper: 'Receipts, purchases, and inbound stock',
          icon: movementDirectionIcon(InventoryMovementDirection.inbound),
          accentColor: movementDirectionStaticColor(
            InventoryMovementDirection.inbound,
          ),
        ),
        AppMetricGridItem(
          title: 'Outbound',
          value: formatInventoryNumber(summary.outboundQuantity),
          helper: 'Sales, issues, and outbound stock',
          icon: movementDirectionIcon(InventoryMovementDirection.outbound),
          accentColor: movementDirectionStaticColor(
            InventoryMovementDirection.outbound,
          ),
        ),
        AppMetricGridItem(
          title: 'Net Change',
          value: formatInventorySignedNumber(summary.netQuantityChange),
          helper: '${formatInventoryNumber(summary.transferCount)} transfers',
          icon:
              summary.netQuantityChange >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
          accentColor:
              summary.netQuantityChange >= 0
                  ? Colors.teal.shade700
                  : Colors.red.shade700,
        ),
      ],
    );
  }
}

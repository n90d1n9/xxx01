import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_valuation_report.dart';
import '../utils/inventory_formatters.dart';

/// Summary metric grid for inventory valuation reports.
class InventoryValuationSummaryGrid extends StatelessWidget {
  const InventoryValuationSummaryGrid({super.key, required this.summary});

  final InventoryValuationSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Inventory Value',
          value: formatInventoryCurrency(summary.totalValue),
          helper:
              summary.highestValueLine == null
                  ? 'No valued stock yet'
                  : 'Top: ${summary.highestValueLine!.productName}',
          icon: Icons.payments_rounded,
          accentColor: Colors.green.shade700,
        ),
        AppMetricGridItem(
          title: 'Units On Hand',
          value: formatInventoryNumber(summary.totalUnits),
          helper: '${formatInventoryNumber(summary.lineCount)} stock lines',
          icon: Icons.inventory_2_rounded,
          accentColor: Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Products',
          value: formatInventoryNumber(summary.productCount),
          helper: 'Unique products in valuation',
          icon: Icons.category_rounded,
          accentColor: Colors.indigo.shade700,
        ),
        AppMetricGridItem(
          title: 'Avg Line Value',
          value: formatInventoryCurrency(summary.averageLineValue),
          helper: '${formatInventoryNumber(summary.warehouseCount)} warehouses',
          icon: Icons.analytics_rounded,
          accentColor: Colors.blue.shade700,
        ),
      ],
    );
  }
}

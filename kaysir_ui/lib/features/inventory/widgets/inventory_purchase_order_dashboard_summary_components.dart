import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_purchase_order_dashboard.dart';
import '../utils/inventory_formatters.dart';

class InventoryPurchaseOrderDashboardSummaryGrid extends StatelessWidget {
  const InventoryPurchaseOrderDashboardSummaryGrid({
    super.key,
    required this.summary,
  });

  final InventoryPurchaseOrderDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Products',
          value: formatInventoryNumber(summary.productCount),
          helper: '${formatInventoryNumber(summary.onHandUnits)} units on hand',
          icon: Icons.inventory_2_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Inventory Value',
          value: formatInventoryCurrency(summary.totalInventoryValue),
          helper: 'Current on-hand valuation',
          icon: Icons.payments_rounded,
          accentColor: Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Low Stock',
          value: formatInventoryNumber(summary.lowStockProductCount),
          helper:
              summary.lowStockProductCount == 0
                  ? 'No replenishment pressure'
                  : 'Products at or below threshold',
          icon: Icons.warning_amber_rounded,
          accentColor:
              summary.lowStockProductCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Receiving',
          value: formatInventoryNumber(summary.receivingOrderCount),
          helper: formatInventoryCurrency(summary.receivingOrderValue),
          icon: Icons.local_shipping_rounded,
          accentColor:
              summary.receivingOrderCount == 0
                  ? Colors.green.shade700
                  : Colors.indigo.shade700,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_purchase_order_workspace.dart';
import '../utils/inventory_formatters.dart';

class InventoryPurchaseOrderSummaryGrid extends StatelessWidget {
  const InventoryPurchaseOrderSummaryGrid({super.key, required this.summary});

  final InventoryPurchaseOrderSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Purchase Orders',
          value: formatInventoryNumber(summary.orderCount),
          helper: '${formatInventoryNumber(summary.totalUnits)} units ordered',
          icon: Icons.receipt_long_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Open Value',
          value: formatInventoryCurrency(summary.openValue),
          helper: '${formatInventoryNumber(summary.activeCount)} active orders',
          icon: Icons.account_balance_wallet_rounded,
          accentColor:
              summary.openValue == 0
                  ? Colors.green.shade700
                  : Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Needs Receiving',
          value: formatInventoryNumber(summary.needsReceivingCount),
          helper: '${formatInventoryNumber(summary.overdueCount)} overdue',
          icon: Icons.move_to_inbox_rounded,
          accentColor:
              summary.overdueCount == 0
                  ? Colors.indigo.shade700
                  : Colors.red.shade700,
        ),
        AppMetricGridItem(
          title: 'Received Value',
          value: formatInventoryCurrency(summary.receivedValue),
          helper:
              '${formatInventoryNumber(summary.receivedCount)} closed orders',
          icon: Icons.verified_rounded,
          accentColor: Colors.green.shade700,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_purchase_order_detail.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_purchase_order_detail_status_styles.dart';

class InventoryPurchaseOrderDetailSummaryGrid extends StatelessWidget {
  const InventoryPurchaseOrderDetailSummaryGrid({
    super.key,
    required this.detail,
  });

  final InventoryPurchaseOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Order Value',
          value: formatInventoryCurrency(detail.totalAmount),
          helper: detail.supplierLabel,
          icon: Icons.payments_rounded,
          accentColor: Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Units',
          value: formatInventoryNumber(detail.totalUnits),
          helper: '${formatInventoryNumber(detail.itemCount)} line items',
          icon: Icons.inventory_2_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Status',
          value: detail.statusLabel,
          helper: detail.receivingGuidance,
          icon: purchaseOrderDetailStatusIcon(detail.status),
          accentColor: purchaseOrderDetailStatusColor(
            detail.status,
            detail.isOverdue,
          ),
        ),
        AppMetricGridItem(
          title: 'Expected',
          value: purchaseOrderDetailExpectedDateMetric(detail),
          helper:
              detail.isOverdue ? 'Receiving attention needed' : 'Delivery plan',
          icon: Icons.event_available_rounded,
          accentColor:
              detail.isOverdue ? Colors.red.shade700 : Colors.indigo.shade700,
        ),
      ],
    );
  }
}

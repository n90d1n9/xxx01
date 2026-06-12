import 'package:flutter/material.dart';

import '../models/inventory_purchase_order_workspace.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_metric_chip.dart';
import 'inventory_purchase_order_queue_status.dart';

class InventoryPurchaseOrderQueueMetricStrip extends StatelessWidget {
  const InventoryPurchaseOrderQueueMetricStrip({
    super.key,
    required this.record,
  });

  final InventoryPurchaseOrderRecord record;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        InventoryPurchaseOrderQueueMetric(
          label: 'Value',
          value: formatInventoryCurrency(record.totalAmount),
          icon: Icons.payments_rounded,
        ),
        InventoryPurchaseOrderQueueMetric(
          label: 'Units',
          value: formatInventoryNumber(record.totalUnits),
          icon: Icons.inventory_2_rounded,
        ),
        InventoryPurchaseOrderQueueMetric(
          label: 'Ordered',
          value: formatInventoryShortDate(record.orderDate),
          icon: Icons.event_note_rounded,
        ),
        InventoryPurchaseOrderQueueMetric(
          label: 'Expected',
          value: inventoryPurchaseOrderCompactExpectedLabel(record),
          icon: Icons.local_shipping_rounded,
          emphasize: record.isOverdue,
        ),
      ],
    );
  }
}

class InventoryPurchaseOrderQueueMetric extends StatelessWidget {
  const InventoryPurchaseOrderQueueMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return InventoryMetricChip(
      label: label,
      value: value,
      icon: icon,
      emphasize: emphasize,
      emphasizeColor: Colors.red.shade700,
      maxValueWidth: 130,
    );
  }
}

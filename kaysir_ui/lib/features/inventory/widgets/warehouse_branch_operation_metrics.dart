import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_warehouse_dashboard.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_metric_chip.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Compact metric strip for a single warehouse operation summary.
class InventoryWarehouseOperationMetricStrip extends StatelessWidget {
  const InventoryWarehouseOperationMetricStrip({
    super.key,
    required this.operation,
  });

  final InventoryWarehouseOperationSummary operation;

  @override
  Widget build(BuildContext context) {
    final line = operation.capacityLine;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        InventoryWarehouseOperationMetric(
          label: 'Stock lines',
          value: formatInventoryNumber(operation.stockLineCount),
          icon: Icons.view_list_rounded,
        ),
        InventoryWarehouseOperationMetric(
          label: 'Units',
          value: formatInventoryNumber(operation.totalUnits),
          icon: Icons.inventory_2_rounded,
        ),
        InventoryWarehouseOperationMetric(
          label: 'Value',
          value: formatInventoryCurrency(operation.stockValue),
          icon: Icons.payments_rounded,
        ),
        InventoryWarehouseOperationMetric(
          label: 'Attention',
          value: formatInventoryNumber(operation.attentionStockCount),
          icon: Icons.notification_important_rounded,
          emphasize: operation.attentionStockCount > 0,
        ),
        InventoryWarehouseOperationMetric(
          label: 'Available',
          value: inventoryWarehouseOperationAvailableLabel(line.availableUnits),
          icon: Icons.space_dashboard_rounded,
          emphasize: line.isOverCapacity,
        ),
      ],
    );
  }
}

/// Small labeled metric chip used inside a warehouse operation tile.
class InventoryWarehouseOperationMetric extends StatelessWidget {
  const InventoryWarehouseOperationMetric({
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
      maxValueWidth: 120,
    );
  }
}

/// Formats nullable capacity availability into an operator-friendly label.
String inventoryWarehouseOperationAvailableLabel(num? availableUnits) {
  if (availableUnits == null) return 'Unknown';
  return formatInventoryNumber(availableUnits);
}

@Preview(name: 'Warehouse branch operation metrics')
Widget inventoryWarehouseOperationMetricStripPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseOperationMetricStrip(
      operation: inventoryWarehouseBranchOperationPreview(),
    ),
  );
}

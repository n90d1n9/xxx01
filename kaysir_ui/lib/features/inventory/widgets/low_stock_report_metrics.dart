import 'package:flutter/material.dart';

import '../models/inventory_low_stock_report.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_metric_chip.dart';

/// Metric strip for a single low-stock report line.
class InventoryLowStockReportMetricStrip extends StatelessWidget {
  const InventoryLowStockReportMetricStrip({super.key, required this.line});

  final InventoryLowStockReportLine line;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InventoryLowStockReportMetric(
          label: 'Branch',
          value: line.warehouseBranch,
          icon: Icons.account_tree_rounded,
        ),
        InventoryLowStockReportMetric(
          label: 'Current',
          value: formatInventoryNumber(line.currentQuantity),
          icon: Icons.inventory_rounded,
          emphasize: line.currentQuantity <= 0,
        ),
        InventoryLowStockReportMetric(
          label: 'Reorder',
          value: formatInventoryNumber(line.reorderPoint),
          icon: Icons.flag_rounded,
        ),
        InventoryLowStockReportMetric(
          label: 'Shortage',
          value: formatInventoryNumber(line.shortage),
          icon: Icons.warning_amber_rounded,
          emphasize: line.shortage > 0,
        ),
        InventoryLowStockReportMetric(
          label: 'Suggested',
          value: formatInventoryNumber(line.suggestedQuantity),
          icon: Icons.add_shopping_cart_rounded,
        ),
        InventoryLowStockReportMetric(
          label: 'Est. cost',
          value: formatInventoryCurrency(line.estimatedCost),
          icon: Icons.payments_rounded,
        ),
      ],
    );
  }
}

/// Metric chip used inside low-stock report line tiles.
class InventoryLowStockReportMetric extends StatelessWidget {
  const InventoryLowStockReportMetric({
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
      maxValueWidth: 140,
    );
  }
}

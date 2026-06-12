import 'package:flutter/material.dart';

import '../models/inventory_valuation_report.dart';
import '../utils/inventory_formatters.dart';
import 'valuation_metric_chip.dart';

/// Metric cluster for warehouse, quantity, unit cost, and value on a line.
class InventoryValuationLineMetrics extends StatelessWidget {
  const InventoryValuationLineMetrics({super.key, required this.line});

  final InventoryValuationLine line;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InventoryValuationMetricChip(
          label: 'Warehouse',
          value: line.warehouseName,
          icon: Icons.warehouse_rounded,
        ),
        InventoryValuationMetricChip(
          label: 'Branch',
          value: line.warehouseBranch,
          icon: Icons.account_tree_rounded,
        ),
        InventoryValuationMetricChip(
          label: 'Quantity',
          value: formatInventoryNumber(line.quantity),
          icon: Icons.numbers_rounded,
        ),
        InventoryValuationMetricChip(
          label: 'Unit',
          value: formatInventoryCurrency(line.unitPrice),
          icon: Icons.sell_rounded,
        ),
        InventoryValuationMetricChip(
          label: 'Value',
          value: formatInventoryCurrency(line.totalValue),
          icon: Icons.payments_rounded,
          emphasize: true,
        ),
      ],
    );
  }
}

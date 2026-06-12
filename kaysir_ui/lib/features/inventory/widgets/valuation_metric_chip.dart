import 'package:flutter/material.dart';

import 'inventory_metric_chip.dart';

/// Metric chip used by inventory valuation ledger rows.
class InventoryValuationMetricChip extends StatelessWidget {
  const InventoryValuationMetricChip({
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
      emphasizeColor: Colors.green.shade700,
      maxValueWidth: 160,
    );
  }
}

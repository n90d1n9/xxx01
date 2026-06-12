import 'package:flutter/material.dart';

import 'inventory_metric_chip.dart';

class InventoryWarehouseDashboardBranchMetric extends StatelessWidget {
  const InventoryWarehouseDashboardBranchMetric({
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
      emphasizeColor: Colors.deepOrange.shade700,
    );
  }
}

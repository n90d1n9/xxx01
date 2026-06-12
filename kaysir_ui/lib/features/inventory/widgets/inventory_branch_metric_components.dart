import 'package:flutter/material.dart';

import 'inventory_metric_chip.dart';

class InventoryBranchMetric extends StatelessWidget {
  const InventoryBranchMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InventoryMetricChip(
      label: label,
      value: value,
      icon: icon,
      maxValueWidth: 160,
    );
  }
}

import 'package:flutter/material.dart';

import '../models/inventory_warehouse_capacity_report.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_metric_chip.dart';

/// Metric strip for a warehouse capacity line.
class InventoryWarehouseCapacityMetricStrip extends StatelessWidget {
  const InventoryWarehouseCapacityMetricStrip({super.key, required this.line});

  final InventoryWarehouseCapacityLine line;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InventoryWarehouseCapacityMetric(
          label: 'Branch',
          value: line.branchLabel,
          icon: Icons.account_tree_rounded,
        ),
        InventoryWarehouseCapacityMetric(
          label: 'Used',
          value: formatInventoryNumber(line.usedUnits),
          icon: Icons.inventory_2_rounded,
        ),
        InventoryWarehouseCapacityMetric(
          label: 'Capacity',
          value: inventoryWarehouseCapacityValueLabel(line.capacity),
          icon: Icons.all_inbox_rounded,
        ),
        InventoryWarehouseCapacityMetric(
          label: 'Available',
          value: inventoryWarehouseCapacityAvailableLabel(line.availableUnits),
          icon: Icons.space_dashboard_rounded,
          emphasize: line.isOverCapacity,
        ),
        InventoryWarehouseCapacityMetric(
          label: 'Products',
          value: formatInventoryNumber(line.productCount),
          icon: Icons.category_rounded,
        ),
      ],
    );
  }
}

/// Metric chip used by warehouse capacity report tiles.
class InventoryWarehouseCapacityMetric extends StatelessWidget {
  const InventoryWarehouseCapacityMetric({
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
    );
  }
}

/// Formats tracked warehouse capacity for display.
String inventoryWarehouseCapacityValueLabel(num? capacity) {
  if (capacity == null) return 'Not set';
  return formatInventoryNumber(capacity);
}

/// Formats available warehouse capacity for display.
String inventoryWarehouseCapacityAvailableLabel(num? availableUnits) {
  if (availableUnits == null) return 'Unknown';
  return formatInventoryNumber(availableUnits);
}

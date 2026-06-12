import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/warehouse.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_metric_chip.dart';
import 'warehouse_directory_preview_data.dart';

/// Metric strip for branch, location, and capacity inside a warehouse row.
class InventoryWarehouseDirectoryMetricStrip extends StatelessWidget {
  const InventoryWarehouseDirectoryMetricStrip({
    super.key,
    required this.warehouse,
  });

  final Warehouse warehouse;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InventoryWarehouseDirectoryMetric(
          label: 'Branch',
          value: warehouse.branchLabel,
          icon: Icons.account_tree_rounded,
        ),
        InventoryWarehouseDirectoryMetric(
          label: 'Location',
          value: warehouse.location,
          icon: Icons.location_on_rounded,
        ),
        InventoryWarehouseDirectoryMetric(
          label: 'Capacity',
          value: inventoryWarehouseDirectoryCapacityLabel(warehouse.capacity),
          icon: Icons.inventory_rounded,
        ),
      ],
    );
  }
}

/// Single compact metric used by warehouse directory rows.
class InventoryWarehouseDirectoryMetric extends StatelessWidget {
  const InventoryWarehouseDirectoryMetric({
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
    return InventoryMetricChip(label: label, value: value, icon: icon);
  }
}

String inventoryWarehouseDirectoryCapacityLabel(num? capacity) {
  if (capacity == null) return 'Not set';
  return formatInventoryNumber(capacity);
}

@Preview(name: 'Warehouse directory metrics')
Widget inventoryWarehouseDirectoryMetricStripPreview() {
  return inventoryWarehouseDirectoryPreviewScaffold(
    InventoryWarehouseDirectoryMetricStrip(
      warehouse: inventoryWarehouseDirectoryPreviewWarehouse(),
    ),
  );
}

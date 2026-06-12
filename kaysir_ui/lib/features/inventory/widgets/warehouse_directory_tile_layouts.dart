import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'inventory_warehouse_directory_actions.dart';
import 'inventory_warehouse_directory_metrics.dart';
import 'inventory_warehouse_directory_status.dart';
import 'warehouse_directory_preview_data.dart';
import 'warehouse_directory_summary.dart';

/// Compact vertical layout used by warehouse directory tiles on narrow widths.
class InventoryWarehouseDirectoryCompactLayout extends StatelessWidget {
  const InventoryWarehouseDirectoryCompactLayout({
    super.key,
    required this.summary,
    required this.capacityStatus,
    required this.details,
    required this.actions,
  });

  final Widget summary;
  final Widget capacityStatus;
  final Widget details;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        summary,
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerLeft, child: capacityStatus),
        const SizedBox(height: 12),
        details,
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerRight, child: actions),
      ],
    );
  }
}

/// Expanded horizontal layout used by warehouse directory tiles on wide widths.
class InventoryWarehouseDirectoryExpandedLayout extends StatelessWidget {
  const InventoryWarehouseDirectoryExpandedLayout({
    super.key,
    required this.summary,
    required this.capacityStatus,
    required this.details,
    required this.actions,
  });

  final Widget summary;
  final Widget capacityStatus;
  final Widget details;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: summary),
        const SizedBox(width: 14),
        capacityStatus,
        const SizedBox(width: 12),
        Flexible(child: details),
        const SizedBox(width: 12),
        actions,
      ],
    );
  }
}

@Preview(name: 'Warehouse directory compact layout')
Widget inventoryWarehouseDirectoryCompactLayoutPreview() {
  final warehouse = inventoryWarehouseDirectoryPreviewWarehouse();

  return inventoryWarehouseDirectoryPreviewScaffold(
    InventoryWarehouseDirectoryCompactLayout(
      summary: InventoryWarehouseDirectorySummary(warehouse: warehouse),
      capacityStatus: InventoryWarehouseCapacityStatusPill(
        warehouse: warehouse,
      ),
      details: InventoryWarehouseDirectoryMetricStrip(warehouse: warehouse),
      actions: InventoryWarehouseDirectoryActions(
        warehouse: warehouse,
        onOpen: () {},
        onEdit: () {},
        onDelete: () {},
      ),
    ),
  );
}

@Preview(name: 'Warehouse directory expanded layout')
Widget inventoryWarehouseDirectoryExpandedLayoutPreview() {
  final warehouse = inventoryWarehouseDirectoryPreviewWarehouse();

  return inventoryWarehouseDirectoryPreviewScaffold(
    InventoryWarehouseDirectoryExpandedLayout(
      summary: InventoryWarehouseDirectorySummary(warehouse: warehouse),
      capacityStatus: InventoryWarehouseCapacityStatusPill(
        warehouse: warehouse,
      ),
      details: InventoryWarehouseDirectoryMetricStrip(warehouse: warehouse),
      actions: InventoryWarehouseDirectoryActions(
        warehouse: warehouse,
        onOpen: () {},
        onEdit: () {},
        onDelete: () {},
      ),
    ),
  );
}

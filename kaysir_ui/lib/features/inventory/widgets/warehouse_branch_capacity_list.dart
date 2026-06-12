import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_warehouse_capacity_report.dart';
import 'inventory_warehouse_capacity_report_components.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Vertical list of capacity rows for warehouses in a single branch.
class InventoryWarehouseBranchCapacityList extends StatelessWidget {
  const InventoryWarehouseBranchCapacityList({super.key, required this.lines});

  final List<InventoryWarehouseCapacityLine> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < lines.length; index += 1) ...[
          InventoryWarehouseCapacityTile(line: lines[index]),
          if (index != lines.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

@Preview(name: 'Warehouse branch capacity list')
Widget inventoryWarehouseBranchCapacityListPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseBranchCapacityList(
      lines: inventoryWarehouseBranchDetailPreviewDetail().capacityLines,
    ),
  );
}

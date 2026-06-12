import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_stock_record.dart';
import 'inventory_stock_list_panel.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Vertical list of branch stock records that need operator attention.
class InventoryWarehouseBranchStockPressureList extends StatelessWidget {
  const InventoryWarehouseBranchStockPressureList({
    super.key,
    required this.records,
  });

  final List<InventoryStockRecord> records;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < records.length; index += 1) ...[
          InventoryStockListItem(record: records[index]),
          if (index != records.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

@Preview(name: 'Warehouse branch stock pressure list')
Widget inventoryWarehouseBranchStockPressureListPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseBranchStockPressureList(
      records:
          inventoryWarehouseBranchDetailPreviewDetail().attentionStockRecords,
    ),
  );
}

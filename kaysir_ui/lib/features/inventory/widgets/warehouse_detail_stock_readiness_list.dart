import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_stock_record.dart';
import 'inventory_stock_list_panel.dart';
import 'warehouse_detail_stock_readiness_preview_data.dart';

/// Preview list of the stock rows most relevant to a warehouse detail view.
class InventoryWarehouseStockReadinessList extends StatelessWidget {
  const InventoryWarehouseStockReadinessList({
    super.key,
    required this.records,
  });

  final List<InventoryStockRecord> records;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < records.length; index += 1) ...[
          InventoryStockListItem(record: records[index]),
          if (index != records.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

@Preview(name: 'Warehouse stock readiness list')
Widget inventoryWarehouseStockReadinessListPreview() {
  final detail = inventoryWarehouseStockReadinessPreviewDetail();

  return inventoryWarehouseStockReadinessPreviewScaffold(
    InventoryWarehouseStockReadinessList(records: detail.focusStockRecords),
  );
}

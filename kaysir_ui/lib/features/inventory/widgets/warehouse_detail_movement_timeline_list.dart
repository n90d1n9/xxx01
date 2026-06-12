import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_movement_record.dart';
import 'inventory_movement_history_components.dart';
import 'warehouse_detail_movement_timeline_preview_data.dart';

/// Preview list of recent movement records in a warehouse detail view.
class InventoryWarehouseMovementTimelineList extends StatelessWidget {
  const InventoryWarehouseMovementTimelineList({
    super.key,
    required this.records,
  });

  final List<InventoryMovementRecord> records;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < records.length; index += 1) ...[
          InventoryMovementTimelineTile(record: records[index]),
          if (index != records.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

@Preview(name: 'Warehouse movement timeline list')
Widget inventoryWarehouseMovementTimelineListPreview() {
  final detail = inventoryWarehouseMovementTimelinePreviewDetail();

  return inventoryWarehouseMovementTimelinePreviewScaffold(
    InventoryWarehouseMovementTimelineList(
      records: detail.recentMovementRecords,
    ),
  );
}

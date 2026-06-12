import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import 'warehouse_detail_movement_timeline_preview_data.dart';

/// Status pill that summarizes transfer count in the recent movement panel.
class InventoryWarehouseMovementTimelineStatusPill extends StatelessWidget {
  const InventoryWarehouseMovementTimelineStatusPill({
    super.key,
    required this.transferCount,
  });

  final int transferCount;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: '$transferCount transfers',
      icon: Icons.compare_arrows_rounded,
      color: Colors.indigo.shade700,
      maxWidth: 130,
    );
  }
}

@Preview(name: 'Warehouse movement timeline status')
Widget inventoryWarehouseMovementTimelineStatusPillPreview() {
  return inventoryWarehouseMovementTimelinePreviewScaffold(
    const InventoryWarehouseMovementTimelineStatusPill(transferCount: 3),
  );
}

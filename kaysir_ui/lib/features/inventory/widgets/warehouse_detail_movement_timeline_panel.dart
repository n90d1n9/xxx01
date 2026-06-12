import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/inventory_warehouse_detail.dart';
import 'warehouse_detail_movement_timeline_action_footer.dart';
import 'warehouse_detail_movement_timeline_empty_state.dart';
import 'warehouse_detail_movement_timeline_facts.dart';
import 'warehouse_detail_movement_timeline_list.dart';
import 'warehouse_detail_movement_timeline_preview_data.dart';
import 'warehouse_detail_movement_timeline_status_pill.dart';

/// Warehouse detail panel that previews recent stock movement history.
class InventoryWarehouseDetailMovementPanel extends StatelessWidget {
  const InventoryWarehouseDetailMovementPanel({
    super.key,
    required this.detail,
    this.onOpenMovements,
  });

  final InventoryWarehouseDetail detail;
  final VoidCallback? onOpenMovements;

  @override
  Widget build(BuildContext context) {
    final records = detail.recentMovementRecords;

    return AppContentPanel(
      title: 'Recent Movements',
      subtitle:
          '${records.length} of ${detail.movementRecords.length} warehouse movements shown',
      leadingIcon: Icons.timeline_rounded,
      trailing:
          records.isEmpty
              ? null
              : InventoryWarehouseMovementTimelineStatusPill(
                transferCount: detail.transferCount,
              ),
      child:
          records.isEmpty
              ? InventoryWarehouseMovementTimelineEmptyState(
                onOpenMovements: onOpenMovements,
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InventoryWarehouseMovementTimelineFacts(
                    shownCount: records.length,
                    hiddenCount: detail.hiddenRecentMovementRecordCount,
                  ),
                  const SizedBox(height: 14),
                  InventoryWarehouseMovementTimelineList(records: records),
                  if (onOpenMovements != null) ...[
                    const SizedBox(height: 14),
                    InventoryWarehouseMovementTimelineActionFooter(
                      onOpenMovements: onOpenMovements,
                    ),
                  ],
                ],
              ),
    );
  }
}

@Preview(name: 'Warehouse movement timeline panel')
Widget inventoryWarehouseDetailMovementPanelPreview() {
  return inventoryWarehouseMovementTimelinePreviewScaffold(
    InventoryWarehouseDetailMovementPanel(
      detail: inventoryWarehouseMovementTimelinePreviewDetail(),
      onOpenMovements: () {},
    ),
  );
}

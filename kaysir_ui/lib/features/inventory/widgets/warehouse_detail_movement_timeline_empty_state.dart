import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_empty_state.dart';
import 'warehouse_detail_movement_timeline_preview_data.dart';

/// Empty state shown before a warehouse has movement history.
class InventoryWarehouseMovementTimelineEmptyState extends StatelessWidget {
  const InventoryWarehouseMovementTimelineEmptyState({
    super.key,
    this.onOpenMovements,
  });

  final VoidCallback? onOpenMovements;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'No movements yet',
      message:
          'Stock receipts, transfers, adjustments, and audits will appear here.',
      icon: Icons.timeline_rounded,
      action:
          onOpenMovements == null
              ? null
              : AppActionButton(
                label: 'Open timeline',
                icon: Icons.timeline_rounded,
                variant: AppActionButtonVariant.secondary,
                onPressed: onOpenMovements,
              ),
    );
  }
}

@Preview(name: 'Warehouse movement timeline empty')
Widget inventoryWarehouseMovementTimelineEmptyStatePreview() {
  return inventoryWarehouseMovementTimelinePreviewScaffold(
    InventoryWarehouseMovementTimelineEmptyState(onOpenMovements: () {}),
  );
}

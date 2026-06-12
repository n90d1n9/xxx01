import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_warehouse_detail.dart';
import 'inventory_warehouse_movement_flow_visuals.dart';
import 'warehouse_detail_movement_flow_preview_data.dart';

/// Progress indicator that compares one movement flow to total movements.
class InventoryWarehouseMovementFlowProgress extends StatelessWidget {
  const InventoryWarehouseMovementFlowProgress({
    super.key,
    required this.line,
    required this.totalMovements,
    required this.label,
    required this.accent,
  });

  final InventoryWarehouseMovementFlowLine line;
  final int totalMovements;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final movementShare =
        line.movementShare(totalMovements).clamp(0, 1).toDouble();
    final movementShareLabel = '${(movementShare * 100).round()}% of movements';

    return Semantics(
      label: '$label movement share',
      value: movementShareLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: movementShare,
          minHeight: 7,
          color: accent,
          backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

@Preview(name: 'Warehouse movement flow progress')
Widget inventoryWarehouseMovementFlowProgressPreview() {
  final detail = inventoryWarehouseMovementFlowPreviewDetail();
  final line = inventoryWarehouseMovementFlowPreviewLine(detail);

  return inventoryWarehouseMovementFlowPreviewScaffold(
    Builder(
      builder: (context) {
        final visuals = inventoryWarehouseMovementDirectionVisuals(
          context,
          line.direction,
        );

        return InventoryWarehouseMovementFlowProgress(
          line: line,
          totalMovements: detail.movementRecords.length,
          label: visuals.label,
          accent: visuals.color,
        );
      },
    ),
  );
}

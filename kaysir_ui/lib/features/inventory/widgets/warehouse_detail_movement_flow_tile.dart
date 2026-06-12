import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_movement_record.dart';
import '../models/inventory_warehouse_detail.dart';
import 'inventory_tile_surface.dart';
import 'inventory_warehouse_movement_flow_visuals.dart';
import 'warehouse_detail_movement_flow_facts.dart';
import 'warehouse_detail_movement_flow_header.dart';
import 'warehouse_detail_movement_flow_preview_data.dart';
import 'warehouse_detail_movement_flow_progress.dart';

/// Tile that presents one warehouse movement flow with metrics and drill-in.
class InventoryWarehouseMovementFlowTile extends StatelessWidget {
  const InventoryWarehouseMovementFlowTile({
    super.key,
    required this.line,
    required this.totalMovements,
    required this.totalActivityUnits,
    this.onOpenMovementFilter,
  });

  final InventoryWarehouseMovementFlowLine line;
  final int totalMovements;
  final int totalActivityUnits;
  final ValueChanged<InventoryMovementFilter>? onOpenMovementFilter;

  @override
  Widget build(BuildContext context) {
    final visuals = inventoryWarehouseMovementDirectionVisuals(
      context,
      line.direction,
    );

    return InventoryTileSurface(
      backgroundColor: visuals.color.withValues(alpha: 0.07),
      borderColor: visuals.color.withValues(alpha: 0.22),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          InventoryWarehouseMovementFlowHeader(
            line: line,
            visuals: visuals,
            onOpenMovementFilter: onOpenMovementFilter,
          ),
          const SizedBox(height: 12),
          InventoryWarehouseMovementFlowFacts(
            line: line,
            totalActivityUnits: totalActivityUnits,
            accent: visuals.color,
          ),
          const SizedBox(height: 12),
          InventoryWarehouseMovementFlowProgress(
            line: line,
            totalMovements: totalMovements,
            label: visuals.label,
            accent: visuals.color,
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Warehouse movement flow tile')
Widget inventoryWarehouseMovementFlowTilePreview() {
  final detail = inventoryWarehouseMovementFlowPreviewDetail();
  final line = inventoryWarehouseMovementFlowPreviewLine(detail);

  return inventoryWarehouseMovementFlowPreviewScaffold(
    InventoryWarehouseMovementFlowTile(
      line: line,
      totalMovements: detail.movementRecords.length,
      totalActivityUnits: detail.movementActivityUnits,
      onOpenMovementFilter: (_) {},
    ),
  );
}

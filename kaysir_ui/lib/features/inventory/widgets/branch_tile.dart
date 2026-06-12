import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_branch.dart';
import 'branch_preview_data.dart';
import 'branch_tile_actions.dart';
import 'branch_tile_layouts.dart';
import 'branch_tile_metrics.dart';
import 'branch_tile_status_pill.dart';
import 'branch_tile_summary.dart';
import 'inventory_tile_surface.dart';

/// Responsive branch directory tile with governance, assignment, and actions.
class InventoryBranchTile extends StatelessWidget {
  const InventoryBranchTile({
    super.key,
    required this.branch,
    required this.warehouseCount,
    this.onEdit,
    this.onDelete,
  });

  final InventoryBranch branch;
  final int warehouseCount;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final summary = InventoryBranchTileSummary(branch: branch);
    final metrics = InventoryBranchTileMetricStrip(
      branch: branch,
      warehouseCount: warehouseCount,
    );
    final status = InventoryBranchTileStatusPill(branch: branch);
    final actions = InventoryBranchTileActions(
      branch: branch,
      onEdit: onEdit,
      onDelete: onDelete,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 840;

        return InventoryTileSurface(
          child:
              isCompact
                  ? InventoryBranchTileCompactLayout(
                    summary: summary,
                    metrics: metrics,
                    status: status,
                    actions: actions,
                  )
                  : InventoryBranchTileExpandedLayout(
                    summary: summary,
                    metrics: metrics,
                    status: status,
                    actions: actions,
                  ),
        );
      },
    );
  }
}

@Preview(name: 'Inventory branch tile')
Widget inventoryBranchTilePreview() {
  return inventoryBranchPreviewScaffold(
    InventoryBranchTile(
      branch: inventoryBranchPreviewBranch(),
      warehouseCount: 3,
      onEdit: () {},
      onDelete: () {},
    ),
  );
}

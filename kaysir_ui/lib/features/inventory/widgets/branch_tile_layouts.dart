import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'branch_preview_data.dart';
import 'branch_tile_actions.dart';
import 'branch_tile_metrics.dart';
import 'branch_tile_status_pill.dart';
import 'branch_tile_summary.dart';

/// Compact vertical layout for narrow branch directory tiles.
class InventoryBranchTileCompactLayout extends StatelessWidget {
  const InventoryBranchTileCompactLayout({
    super.key,
    required this.summary,
    required this.metrics,
    required this.status,
    required this.actions,
  });

  final Widget summary;
  final Widget metrics;
  final Widget status;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        summary,
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerLeft, child: status),
        const SizedBox(height: 12),
        metrics,
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerRight, child: actions),
      ],
    );
  }
}

/// Wide horizontal layout for branch directory tiles.
class InventoryBranchTileExpandedLayout extends StatelessWidget {
  const InventoryBranchTileExpandedLayout({
    super.key,
    required this.summary,
    required this.metrics,
    required this.status,
    required this.actions,
  });

  final Widget summary;
  final Widget metrics;
  final Widget status;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: summary),
        const SizedBox(width: 14),
        Flexible(child: metrics),
        const SizedBox(width: 12),
        status,
        const SizedBox(width: 8),
        actions,
      ],
    );
  }
}

@Preview(name: 'Inventory branch tile compact layout')
Widget inventoryBranchTileCompactLayoutPreview() {
  final branch = inventoryBranchPreviewBranch();

  return inventoryBranchPreviewScaffold(
    InventoryBranchTileCompactLayout(
      summary: InventoryBranchTileSummary(branch: branch),
      metrics: InventoryBranchTileMetricStrip(
        branch: branch,
        warehouseCount: 3,
      ),
      status: InventoryBranchTileStatusPill(branch: branch),
      actions: InventoryBranchTileActions(
        branch: branch,
        onEdit: () {},
        onDelete: () {},
      ),
    ),
  );
}

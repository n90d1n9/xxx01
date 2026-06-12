import 'package:flutter/material.dart';

import '../models/inventory_warehouse_capacity_report.dart';
import 'inventory_tile_surface.dart';
import 'warehouse_capacity_line_summary.dart';
import 'warehouse_capacity_metrics.dart';
import 'warehouse_capacity_progress.dart';
import 'warehouse_capacity_tile_header.dart';

/// Ledger tile for a single warehouse capacity line.
class InventoryWarehouseCapacityTile extends StatelessWidget {
  const InventoryWarehouseCapacityTile({super.key, required this.line});

  final InventoryWarehouseCapacityLine line;

  @override
  Widget build(BuildContext context) {
    final summary = InventoryWarehouseCapacityLineSummary(line: line);
    final details = InventoryWarehouseCapacityMetricStrip(line: line);

    return InventoryTileSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InventoryWarehouseCapacityTileHeader(
            summary: summary,
            status: line.status,
          ),
          const SizedBox(height: 12),
          InventoryWarehouseCapacityProgress(line: line),
          const SizedBox(height: 12),
          details,
        ],
      ),
    );
  }
}

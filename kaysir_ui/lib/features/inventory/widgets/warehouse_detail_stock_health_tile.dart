import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_stock_record.dart';
import '../models/inventory_warehouse_detail.dart';
import 'inventory_stock_status_pill.dart';
import 'inventory_tile_surface.dart';
import 'warehouse_detail_stock_health_facts.dart';
import 'warehouse_detail_stock_health_preview_data.dart';
import 'warehouse_detail_stock_health_progress.dart';
import 'warehouse_detail_stock_health_status_row.dart';

/// Tile that presents one warehouse stock-health bucket and its share metrics.
class InventoryWarehouseStockHealthTile extends StatelessWidget {
  const InventoryWarehouseStockHealthTile({
    super.key,
    required this.line,
    required this.totalStockLines,
    required this.totalUnits,
    required this.totalValue,
  });

  final InventoryWarehouseStockHealthLine line;
  final int totalStockLines;
  final int totalUnits;
  final double totalValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusVisuals = inventoryStockStatusVisuals(context, line.status);
    final accent = statusVisuals.color;

    return InventoryTileSurface(
      backgroundColor:
          line.hasStock
              ? accent.withValues(alpha: 0.07)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.26),
      borderColor:
          line.hasStock
              ? accent.withValues(alpha: 0.22)
              : colorScheme.outlineVariant,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          InventoryWarehouseStockHealthStatusRow(line: line, accent: accent),
          const SizedBox(height: 12),
          InventoryWarehouseStockHealthFacts(
            line: line,
            totalValue: totalValue,
            accent: accent,
          ),
          const SizedBox(height: 12),
          InventoryWarehouseStockHealthShareProgress(
            line: line,
            totalStockLines: totalStockLines,
            totalUnits: totalUnits,
            statusLabel: statusVisuals.label,
            accent: accent,
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Warehouse stock health tile')
Widget inventoryWarehouseStockHealthTilePreview() {
  final detail = inventoryWarehouseStockHealthPreviewDetail();
  final line = detail.stockHealthLineFor(InventoryStockStatus.lowStock);

  return inventoryWarehouseStockHealthPreviewScaffold(
    InventoryWarehouseStockHealthTile(
      line: line,
      totalStockLines: detail.stockLineCount,
      totalUnits: detail.totalUnits,
      totalValue: detail.stockValue,
    ),
  );
}

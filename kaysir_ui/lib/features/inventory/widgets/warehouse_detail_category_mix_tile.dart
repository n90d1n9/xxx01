import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_warehouse_detail.dart';
import 'inventory_tile_surface.dart';
import 'warehouse_detail_category_mix_facts.dart';
import 'warehouse_detail_category_mix_header.dart';
import 'warehouse_detail_category_mix_preview_data.dart';
import 'warehouse_detail_category_mix_progress.dart';

/// Tile that presents one category's stock value, units, and attention share.
class InventoryWarehouseCategoryMixTile extends StatelessWidget {
  const InventoryWarehouseCategoryMixTile({
    super.key,
    required this.line,
    required this.totalUnits,
    required this.totalValue,
  });

  final InventoryWarehouseCategoryMixLine line;
  final int totalUnits;
  final double totalValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent =
        line.hasAttention ? Colors.deepOrange.shade700 : Colors.indigo.shade700;
    final valueShare = line.valueShare(totalValue).clamp(0, 1).toDouble();
    final valueShareLabel = '${(valueShare * 100).round()}% value';

    return InventoryTileSurface(
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.34,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          InventoryWarehouseCategoryMixHeader(
            line: line,
            valueShareLabel: valueShareLabel,
            accent: accent,
          ),
          const SizedBox(height: 14),
          InventoryWarehouseCategoryMixFacts(line: line, accent: accent),
          const SizedBox(height: 12),
          InventoryWarehouseCategoryMixProgress(
            line: line,
            totalUnits: totalUnits,
            valueShare: valueShare,
            valueShareLabel: valueShareLabel,
            accent: accent,
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Warehouse category mix tile')
Widget inventoryWarehouseCategoryMixTilePreview() {
  final detail = inventoryWarehouseCategoryMixPreviewDetail();
  final line = inventoryWarehouseCategoryMixPreviewLine(detail);

  return inventoryWarehouseCategoryMixPreviewScaffold(
    InventoryWarehouseCategoryMixTile(
      line: line,
      totalUnits: detail.totalUnits,
      totalValue: detail.stockValue,
    ),
  );
}

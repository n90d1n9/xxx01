import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_stock_record.dart';
import '../models/inventory_warehouse_detail.dart';
import 'inventory_stock_status_pill.dart';
import 'warehouse_detail_stock_health_preview_data.dart';

/// Progress indicator that compares one stock-health bucket to warehouse totals.
class InventoryWarehouseStockHealthShareProgress extends StatelessWidget {
  const InventoryWarehouseStockHealthShareProgress({
    super.key,
    required this.line,
    required this.totalStockLines,
    required this.totalUnits,
    required this.statusLabel,
    required this.accent,
  });

  final InventoryWarehouseStockHealthLine line;
  final int totalStockLines;
  final int totalUnits;
  final String statusLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lineShare = line.lineShare(totalStockLines).clamp(0, 1).toDouble();
    final lineShareLabel = '${(lineShare * 100).round()}% of lines';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '$statusLabel stock line share',
          value: lineShareLabel,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: lineShare,
              minHeight: 7,
              color: accent,
              backgroundColor: colorScheme.outlineVariant.withValues(
                alpha: 0.55,
              ),
            ),
          ),
        ),
        if (totalUnits > 0) ...[
          const SizedBox(height: 8),
          Text(
            '${(line.unitShare(totalUnits) * 100).round()}% of warehouse units',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

@Preview(name: 'Warehouse stock health progress')
Widget inventoryWarehouseStockHealthShareProgressPreview() {
  final detail = inventoryWarehouseStockHealthPreviewDetail();
  final line = detail.stockHealthLineFor(InventoryStockStatus.inStock);

  return inventoryWarehouseStockHealthPreviewScaffold(
    InventoryWarehouseStockHealthShareProgress(
      line: line,
      totalStockLines: detail.stockLineCount,
      totalUnits: detail.totalUnits,
      statusLabel: inventoryStockStatusLabel(line.status),
      accent: Colors.green.shade700,
    ),
  );
}

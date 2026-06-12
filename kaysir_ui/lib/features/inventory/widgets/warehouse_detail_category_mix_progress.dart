import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_warehouse_detail.dart';
import 'warehouse_detail_category_mix_preview_data.dart';

/// Progress indicator for category value share and warehouse unit share.
class InventoryWarehouseCategoryMixProgress extends StatelessWidget {
  const InventoryWarehouseCategoryMixProgress({
    super.key,
    required this.line,
    required this.totalUnits,
    required this.valueShare,
    required this.valueShareLabel,
    required this.accent,
  });

  final InventoryWarehouseCategoryMixLine line;
  final int totalUnits;
  final double valueShare;
  final String valueShareLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '${line.category} value share',
          value: valueShareLabel,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: valueShare,
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

@Preview(name: 'Warehouse category mix progress')
Widget inventoryWarehouseCategoryMixProgressPreview() {
  final detail = inventoryWarehouseCategoryMixPreviewDetail();
  final line = inventoryWarehouseCategoryMixPreviewLine(detail);
  final valueShare = line.valueShare(detail.stockValue).clamp(0, 1).toDouble();

  return inventoryWarehouseCategoryMixPreviewScaffold(
    InventoryWarehouseCategoryMixProgress(
      line: line,
      totalUnits: detail.totalUnits,
      valueShare: valueShare,
      valueShareLabel: '${(valueShare * 100).round()}% value',
      accent: Colors.deepOrange.shade700,
    ),
  );
}

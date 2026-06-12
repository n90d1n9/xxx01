import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_warehouse_detail.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_category_mix_preview_data.dart';

/// Header row for a category mix tile with category identity and value share.
class InventoryWarehouseCategoryMixHeader extends StatelessWidget {
  const InventoryWarehouseCategoryMixHeader({
    super.key,
    required this.line,
    required this.valueShareLabel,
    required this.accent,
  });

  final InventoryWarehouseCategoryMixLine line;
  final String valueShareLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.category_rounded, color: accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                line.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                '${compactInventoryWarehouseCount(line.productCount, 'product', 'products')} | ${compactInventoryWarehouseCount(line.stockLineCount, 'stock line', 'stock lines')}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AppStatusPill(
          label: valueShareLabel,
          color: accent,
          showDot: true,
          maxWidth: 92,
        ),
      ],
    );
  }
}

@Preview(name: 'Warehouse category mix header')
Widget inventoryWarehouseCategoryMixHeaderPreview() {
  final detail = inventoryWarehouseCategoryMixPreviewDetail();
  final line = inventoryWarehouseCategoryMixPreviewLine(detail);
  final share = line.valueShare(detail.stockValue).clamp(0, 1).toDouble();

  return inventoryWarehouseCategoryMixPreviewScaffold(
    InventoryWarehouseCategoryMixHeader(
      line: line,
      valueShareLabel: '${(share * 100).round()}% value',
      accent: Colors.deepOrange.shade700,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_warehouse_detail.dart';
import 'inventory_separated_list.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_category_mix_preview_data.dart';
import 'warehouse_detail_category_mix_tile.dart';

/// Warehouse detail panel that groups on-hand stock by product category.
class InventoryWarehouseDetailCategoryMixPanel extends StatelessWidget {
  const InventoryWarehouseDetailCategoryMixPanel({
    super.key,
    required this.detail,
  });

  final InventoryWarehouseDetail detail;

  @override
  Widget build(BuildContext context) {
    final lines = detail.categoryMixLines;
    final attentionCategoryCount = detail.attentionCategoryCount;
    final hasAttention = attentionCategoryCount > 0;

    return AppContentPanel(
      title: 'Category Mix',
      subtitle:
          lines.isEmpty
              ? 'Product categories will appear once stock is assigned here'
              : '${compactInventoryWarehouseCount(detail.stockLineCount, 'stock line', 'stock lines')} grouped by product category',
      leadingIcon: Icons.category_rounded,
      trailing:
          lines.isEmpty
              ? null
              : AppStatusPill(
                label:
                    hasAttention
                        ? compactInventoryWarehouseCount(
                          attentionCategoryCount,
                          'alert',
                          'alerts',
                        )
                        : compactInventoryWarehouseCount(
                          lines.length,
                          'category',
                          'categories',
                        ),
                icon:
                    hasAttention
                        ? Icons.warning_amber_rounded
                        : Icons.category_rounded,
                color:
                    hasAttention
                        ? Colors.deepOrange.shade700
                        : Colors.indigo.shade700,
                maxWidth: 140,
              ),
      child:
          lines.isEmpty
              ? const AppEmptyState(
                title: 'No category mix yet',
                message:
                    'Assign stock to this warehouse to understand its product concentration.',
                icon: Icons.category_outlined,
              )
              : InventorySeparatedList<InventoryWarehouseCategoryMixLine>(
                items: lines,
                itemBuilder: (context, line, index) {
                  return InventoryWarehouseCategoryMixTile(
                    line: line,
                    totalUnits: detail.totalUnits,
                    totalValue: detail.stockValue,
                  );
                },
              ),
    );
  }
}

@Preview(name: 'Warehouse category mix panel')
Widget inventoryWarehouseDetailCategoryMixPanelPreview() {
  return inventoryWarehouseCategoryMixPreviewScaffold(
    InventoryWarehouseDetailCategoryMixPanel(
      detail: inventoryWarehouseCategoryMixPreviewDetail(),
    ),
  );
}

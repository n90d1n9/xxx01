import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/inventory_warehouse_detail.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_stock_readiness_action_row.dart';
import 'warehouse_detail_stock_readiness_empty_state.dart';
import 'warehouse_detail_stock_readiness_facts.dart';
import 'warehouse_detail_stock_readiness_list.dart';
import 'warehouse_detail_stock_readiness_preview_data.dart';
import 'warehouse_detail_stock_readiness_status_pill.dart';

/// Warehouse detail panel that previews stock lines and attention status.
class InventoryWarehouseDetailStockPanel extends StatelessWidget {
  const InventoryWarehouseDetailStockPanel({
    super.key,
    required this.detail,
    this.onOpenStock,
    this.onOpenAttentionStock,
  });

  final InventoryWarehouseDetail detail;
  final VoidCallback? onOpenStock;
  final VoidCallback? onOpenAttentionStock;

  @override
  Widget build(BuildContext context) {
    final attentionRecords = detail.attentionStockRecords;
    final records = detail.focusStockRecords;
    final hiddenCount = detail.hiddenFocusStockRecordCount;
    final hasStock = detail.stockRecords.isNotEmpty;
    final hasAttention = attentionRecords.isNotEmpty;
    final actionRow = InventoryWarehouseStockReadinessActionRow(
      hasAttention: hasAttention,
      onOpenStock: onOpenStock,
      onOpenAttentionStock: onOpenAttentionStock,
    );

    return AppContentPanel(
      title: 'Stock Readiness',
      subtitle:
          !hasStock
              ? 'Stock lines will appear once products are assigned here'
              : hasAttention
              ? '${compactInventoryWarehouseCount(attentionRecords.length, 'stock line', 'stock lines')} need attention'
              : '${compactInventoryWarehouseCount(records.length, 'stock line', 'stock lines')} ready for review',
      leadingIcon: Icons.inventory_2_rounded,
      padding: const EdgeInsets.all(14),
      gap: 12,
      trailing:
          hasStock
              ? InventoryWarehouseStockReadinessStatusPill(
                hasAttention: hasAttention,
                attentionCount: attentionRecords.length,
              )
              : null,
      child:
          records.isEmpty
              ? InventoryWarehouseStockReadinessEmptyState(
                onOpenStock: onOpenStock,
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InventoryWarehouseStockReadinessFacts(
                    shownCount: records.length,
                    attentionCount: attentionRecords.length,
                    hiddenCount: hiddenCount,
                  ),
                  const SizedBox(height: 10),
                  InventoryWarehouseStockReadinessList(records: records),
                  if (actionRow.hasActions) ...[
                    const SizedBox(height: 10),
                    actionRow,
                  ],
                ],
              ),
    );
  }
}

@Preview(name: 'Warehouse stock readiness panel')
Widget inventoryWarehouseDetailStockPanelPreview() {
  return inventoryWarehouseStockReadinessPreviewScaffold(
    InventoryWarehouseDetailStockPanel(
      detail: inventoryWarehouseStockReadinessPreviewDetail(),
      onOpenStock: () {},
      onOpenAttentionStock: () {},
    ),
  );
}

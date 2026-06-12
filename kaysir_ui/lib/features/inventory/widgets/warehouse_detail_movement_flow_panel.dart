import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_movement_record.dart';
import '../models/inventory_warehouse_detail.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_separated_list.dart';
import 'inventory_warehouse_detail_support.dart';
import 'inventory_warehouse_movement_flow_visuals.dart';
import 'warehouse_detail_movement_flow_preview_data.dart';
import 'warehouse_detail_movement_flow_tile.dart';

/// Warehouse detail panel that summarizes movement volume by flow direction.
class InventoryWarehouseDetailMovementFlowPanel extends StatelessWidget {
  const InventoryWarehouseDetailMovementFlowPanel({
    super.key,
    required this.detail,
    this.onOpenMovementFilter,
  });

  final InventoryWarehouseDetail detail;
  final ValueChanged<InventoryMovementFilter>? onOpenMovementFilter;

  @override
  Widget build(BuildContext context) {
    final lines = detail.activeMovementFlowLines;
    final netUnits = detail.movementNetUnits;
    final netVisuals = inventoryWarehouseMovementNetVisuals(context, netUnits);

    return AppContentPanel(
      title: 'Movement Flow',
      subtitle:
          lines.isEmpty
              ? 'Movement flow will appear once stock events are recorded'
              : '${compactInventoryWarehouseCount(detail.movementRecords.length, 'movement', 'movements')} across ${compactInventoryWarehouseCount(lines.length, 'flow type', 'flow types')}',
      leadingIcon: Icons.sync_alt_rounded,
      trailing:
          lines.isEmpty
              ? null
              : AppStatusPill(
                label: '${formatInventorySignedNumber(netUnits)} net',
                icon: netVisuals.icon,
                color: netVisuals.color,
                maxWidth: 120,
              ),
      child:
          lines.isEmpty
              ? const AppEmptyState(
                title: 'No movement flow yet',
                message:
                    'Receipts, sales, transfers, adjustments, and audits will appear here.',
                icon: Icons.sync_alt_rounded,
              )
              : InventorySeparatedList<InventoryWarehouseMovementFlowLine>(
                items: lines,
                itemBuilder: (context, line, index) {
                  return InventoryWarehouseMovementFlowTile(
                    line: line,
                    totalMovements: detail.movementRecords.length,
                    totalActivityUnits: detail.movementActivityUnits,
                    onOpenMovementFilter: onOpenMovementFilter,
                  );
                },
              ),
    );
  }
}

@Preview(name: 'Warehouse movement flow panel')
Widget inventoryWarehouseDetailMovementFlowPanelPreview() {
  return inventoryWarehouseMovementFlowPreviewScaffold(
    InventoryWarehouseDetailMovementFlowPanel(
      detail: inventoryWarehouseMovementFlowPreviewDetail(),
      onOpenMovementFilter: (_) {},
    ),
  );
}

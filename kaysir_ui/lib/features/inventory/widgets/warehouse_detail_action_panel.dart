import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_command_grid.dart';
import '../../../widgets/ui/app_content_panel.dart';
import 'warehouse_detail_overview_preview_data.dart';

/// Shortcut panel for the primary operational routes of a warehouse detail.
class InventoryWarehouseDetailActionPanel extends StatelessWidget {
  const InventoryWarehouseDetailActionPanel({
    super.key,
    required this.warehouseName,
    this.onOpenStock,
    this.onOpenMovements,
    this.onOpenCapacity,
    this.onOpenBranch,
    this.onOpenDirectory,
  });

  final String warehouseName;
  final VoidCallback? onOpenStock;
  final VoidCallback? onOpenMovements;
  final VoidCallback? onOpenCapacity;
  final VoidCallback? onOpenBranch;
  final VoidCallback? onOpenDirectory;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Warehouse Actions',
      subtitle: '$warehouseName operational shortcuts',
      leadingIcon: Icons.bolt_rounded,
      child: AppCommandGrid(
        items: [
          AppCommandGridItem(
            title: 'Stock',
            helper: 'Review on-hand lines and attention queues',
            icon: Icons.inventory_2_rounded,
            variant: AppCommandGridItemVariant.primary,
            accentColor: Colors.teal.shade700,
            onPressed: onOpenStock,
          ),
          AppCommandGridItem(
            title: 'Movements',
            helper: 'Open warehouse receipts, transfers, and audits',
            icon: Icons.sync_alt_rounded,
            accentColor: Colors.indigo.shade700,
            onPressed: onOpenMovements,
          ),
          AppCommandGridItem(
            title: 'Capacity',
            helper: 'Inspect utilization and available space',
            icon: Icons.space_dashboard_rounded,
            accentColor: Colors.orange.shade700,
            onPressed: onOpenCapacity,
          ),
          AppCommandGridItem(
            title: 'Branch',
            helper: 'View branch-level warehouse operations',
            icon: Icons.account_tree_rounded,
            variant: AppCommandGridItemVariant.subtle,
            accentColor: Colors.blue.shade700,
            onPressed: onOpenBranch,
          ),
          AppCommandGridItem(
            title: 'Directory',
            helper: 'Return to the warehouse directory',
            icon: Icons.list_alt_rounded,
            variant: AppCommandGridItemVariant.subtle,
            accentColor: Colors.blueGrey.shade700,
            onPressed: onOpenDirectory,
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Warehouse detail actions')
Widget inventoryWarehouseDetailActionPanelPreview() {
  final detail = inventoryWarehouseOverviewPreviewDetail();

  return inventoryWarehouseOverviewPreviewScaffold(
    InventoryWarehouseDetailActionPanel(
      warehouseName: detail.warehouse.name,
      onOpenStock: () {},
      onOpenMovements: () {},
      onOpenCapacity: () {},
      onOpenBranch: () {},
      onOpenDirectory: () {},
    ),
  );
}

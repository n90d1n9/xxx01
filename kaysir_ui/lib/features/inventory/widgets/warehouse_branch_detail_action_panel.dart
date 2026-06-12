import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_command_grid.dart';
import '../../../widgets/ui/app_content_panel.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Operational shortcut panel for branch-scoped warehouse workflows.
class InventoryWarehouseBranchDetailActionPanel extends StatelessWidget {
  const InventoryWarehouseBranchDetailActionPanel({
    super.key,
    required this.branchName,
    this.onOpenStock,
    this.onOpenMovements,
    this.onOpenCapacity,
    this.onOpenHub,
  });

  final String branchName;
  final VoidCallback? onOpenStock;
  final VoidCallback? onOpenMovements;
  final VoidCallback? onOpenCapacity;
  final VoidCallback? onOpenHub;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Branch Actions',
      subtitle: '$branchName operational shortcuts',
      leadingIcon: Icons.bolt_rounded,
      child: AppCommandGrid(
        items: [
          AppCommandGridItem(
            title: 'Stock',
            helper: 'Review all branch warehouse stock lines',
            icon: Icons.inventory_2_rounded,
            variant: AppCommandGridItemVariant.primary,
            accentColor: Colors.teal.shade700,
            onPressed: onOpenStock,
          ),
          AppCommandGridItem(
            title: 'Movements',
            helper: 'Open branch receipts, transfers, and audits',
            icon: Icons.sync_alt_rounded,
            accentColor: Colors.indigo.shade700,
            onPressed: onOpenMovements,
          ),
          AppCommandGridItem(
            title: 'Capacity',
            helper: 'Inspect capacity across branch warehouses',
            icon: Icons.space_dashboard_rounded,
            accentColor: Colors.orange.shade700,
            onPressed: onOpenCapacity,
          ),
          AppCommandGridItem(
            title: 'Warehouse Hub',
            helper: 'Return to the warehouse command center',
            icon: Icons.view_quilt_rounded,
            variant: AppCommandGridItemVariant.subtle,
            accentColor: Colors.blue.shade700,
            onPressed: onOpenHub,
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Warehouse branch detail action panel')
Widget inventoryWarehouseBranchDetailActionPanelPreview() {
  final detail = inventoryWarehouseBranchDetailPreviewDetail();

  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseBranchDetailActionPanel(
      branchName: detail.summary.branchName,
      onOpenStock: () {},
      onOpenMovements: () {},
      onOpenCapacity: () {},
      onOpenHub: () {},
    ),
  );
}

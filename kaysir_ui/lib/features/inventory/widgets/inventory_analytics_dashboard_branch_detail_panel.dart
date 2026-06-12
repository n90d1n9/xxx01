import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_select_field.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_analytics_dashboard.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_analytics_branch_detail_panel_state.dart';
import 'inventory_analytics_dashboard_branch_detail_rows.dart';
import 'inventory_analytics_dashboard_branch_detail_sections.dart';
import 'inventory_analytics_dashboard_branch_detail_summary_components.dart';
import 'inventory_analytics_preview_data.dart';

/// Drill-down panel for branch inventory value, warehouse, and movement context.
class InventoryAnalyticsBranchDetailPanel extends StatelessWidget {
  const InventoryAnalyticsBranchDetailPanel({
    super.key,
    required this.details,
    required this.selectedBranchId,
    required this.onBranchChanged,
    this.onWarehouseSelected,
    this.onMovementSelected,
  });

  final List<InventoryAnalyticsBranchDetail> details;
  final String? selectedBranchId;
  final ValueChanged<String> onBranchChanged;
  final void Function(
    InventoryAnalyticsBranchDetail detail,
    InventoryAnalyticsBranchWarehouse warehouse,
  )?
  onWarehouseSelected;
  final void Function(
    InventoryAnalyticsBranchDetail detail,
    InventoryAnalyticsBranchMovement movement,
  )?
  onMovementSelected;

  @override
  Widget build(BuildContext context) {
    final state = InventoryAnalyticsBranchDetailPanelState.fromDetails(
      details: details,
      selectedBranchId: selectedBranchId,
    );
    final detail = state.selectedDetail;

    return AppContentPanel(
      title: 'Branch Drill-down',
      subtitle: 'Selected branch warehouses, alerts, and movement context',
      leadingIcon: Icons.account_tree_rounded,
      trailing:
          detail == null
              ? null
              : AppStatusPill(
                label: '${formatInventoryNumber(detail.movementCount)} moves',
                icon: Icons.swap_horiz_rounded,
                color: Theme.of(context).colorScheme.primary,
                maxWidth: 130,
              ),
      child:
          detail == null
              ? const AppEmptyState(
                title: 'No branch detail yet',
                message: 'Assign warehouses to branches to inspect them here.',
                icon: Icons.account_tree_outlined,
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSelectField<String>(
                    label: 'Branch',
                    icon: Icons.account_tree_rounded,
                    value: detail.branchId,
                    options: [
                      for (final option in state.options)
                        AppSelectOption<String>(
                          value: option.value,
                          label: option.label,
                        ),
                    ],
                    onChanged: onBranchChanged,
                    menuMaxHeight: 280,
                  ),
                  const SizedBox(height: 16),
                  InventoryAnalyticsBranchDetailSummaryGrid(detail: detail),
                  const SizedBox(height: 18),
                  InventoryAnalyticsBranchDetailSection(
                    title: 'Warehouses',
                    icon: Icons.warehouse_rounded,
                    emptyState: const AppEmptyState(
                      title: 'No warehouses assigned',
                      message: 'Branch warehouse coverage will appear here.',
                      icon: Icons.warehouse_outlined,
                    ),
                    children: [
                      for (final warehouse in detail.warehouses)
                        InventoryAnalyticsBranchWarehouseRow(
                          warehouse: warehouse,
                          onTap:
                              onWarehouseSelected == null
                                  ? null
                                  : () =>
                                      onWarehouseSelected!(detail, warehouse),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  InventoryAnalyticsBranchDetailSection(
                    title: 'Recent Movement',
                    icon: Icons.sync_alt_rounded,
                    emptyState: const AppEmptyState(
                      title: 'No branch movement',
                      message:
                          'Recent activity for this branch will appear here.',
                      icon: Icons.sync_alt_outlined,
                    ),
                    children: [
                      for (final movement in detail.recentMovements)
                        InventoryAnalyticsBranchMovementRow(
                          movement: movement,
                          onTap:
                              onMovementSelected == null
                                  ? null
                                  : () => onMovementSelected!(detail, movement),
                        ),
                    ],
                  ),
                ],
              ),
    );
  }
}

@Preview(name: 'Inventory analytics branch detail panel')
Widget inventoryAnalyticsBranchDetailPanelPreview() {
  return inventoryAnalyticsPreviewScaffold(
    InventoryAnalyticsBranchDetailPanel(
      details: inventoryAnalyticsPreviewBranchDetails(),
      selectedBranchId: 'branch-jakarta',
      onBranchChanged: (_) {},
    ),
  );
}

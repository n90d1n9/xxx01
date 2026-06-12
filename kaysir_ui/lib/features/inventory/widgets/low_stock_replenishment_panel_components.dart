import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_purchase_order_create.dart';
import '../models/inventory_replenishment_plan.dart';
import '../models/inventory_replenishment_purchase_order.dart';
import '../models/warehouse.dart';
import 'low_stock_replenishment_bulk_action_bar.dart';
import 'low_stock_replenishment_filter_bar.dart';
import 'low_stock_replenishment_preview_data.dart';
import 'low_stock_replenishment_queue_state.dart';
import 'low_stock_replenishment_tile_components.dart';
import 'low_stock_replenishment_triage_summary.dart';

/// Panel that renders and filters low-stock replenishment recommendations.
class LowStockReplenishmentPanel extends StatelessWidget {
  const LowStockReplenishmentPanel({
    super.key,
    required this.plans,
    this.filter = InventoryReplenishmentPlanFilter.all,
    this.sort = InventoryReplenishmentPlanSort.priority,
    this.selectedWarehouseId,
    this.onFilterChanged,
    this.onSortChanged,
    this.onWarehouseChanged,
    this.onCreatePurchaseOrderDraft,
    this.onRestock,
    this.currencyFormat,
  });

  final List<InventoryReplenishmentPlan> plans;
  final InventoryReplenishmentPlanFilter filter;
  final InventoryReplenishmentPlanSort sort;
  final String? selectedWarehouseId;
  final ValueChanged<InventoryReplenishmentPlanFilter>? onFilterChanged;
  final ValueChanged<InventoryReplenishmentPlanSort>? onSortChanged;
  final ValueChanged<String?>? onWarehouseChanged;
  final ValueChanged<InventoryPurchaseOrderCreateDraft>?
  onCreatePurchaseOrderDraft;
  final ValueChanged<InventoryReplenishmentPlan>? onRestock;
  final NumberFormat? currencyFormat;

  @override
  Widget build(BuildContext context) {
    final state = LowStockReplenishmentQueueState.resolve(
      plans: plans,
      filter: filter,
      sort: sort,
      warehouseId: selectedWarehouseId,
    );
    final warehouseOptions = _warehouseOptions(plans);
    final purchaseOrderProposal = InventoryReplenishmentPurchaseOrderProposal(
      plans: state.visiblePlans,
    );

    return AppContentPanel(
      title: 'Replenishment Queue',
      subtitle: 'Prioritized low-stock items with suggested restock quantities',
      leadingIcon: Icons.playlist_add_check_rounded,
      trailing:
          plans.isEmpty
              ? null
              : AppStatusPill(
                label: '${state.criticalCount} critical',
                icon: Icons.priority_high_rounded,
                color: Colors.red.shade700,
                maxWidth: 140,
              ),
      child:
          plans.isEmpty
              ? const AppEmptyState(
                title: 'Stock is healthy',
                message: 'No products are below reorder point right now.',
                icon: Icons.check_circle_outline_rounded,
              )
              : Column(
                children: [
                  if (onFilterChanged != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: LowStockReplenishmentFilterBar(
                        state: state,
                        onChanged: onFilterChanged!,
                        warehouses: warehouseOptions,
                        onWarehouseChanged: onWarehouseChanged,
                        onSortChanged: onSortChanged,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  LowStockReplenishmentTriageSummary(
                    state: state,
                    warehouses: warehouseOptions,
                    currencyFormat: currencyFormat,
                    onFilterCleared:
                        onFilterChanged == null
                            ? null
                            : () => onFilterChanged!(
                              InventoryReplenishmentPlanFilter.all,
                            ),
                    onWarehouseCleared:
                        onWarehouseChanged == null
                            ? null
                            : () => onWarehouseChanged!(null),
                    onClearAll:
                        onFilterChanged == null
                            ? null
                            : () {
                              onFilterChanged!(
                                InventoryReplenishmentPlanFilter.all,
                              );
                              onWarehouseChanged?.call(null);
                            },
                  ),
                  const SizedBox(height: 14),
                  if (onCreatePurchaseOrderDraft != null &&
                      state.visiblePlans.isNotEmpty) ...[
                    LowStockReplenishmentBulkActionBar(
                      proposal: purchaseOrderProposal,
                      currencyFormat: currencyFormat,
                      onCreateDraft:
                          () => onCreatePurchaseOrderDraft!(
                            purchaseOrderProposal.toCreateDraft(),
                          ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (state.visiblePlans.isEmpty)
                    const AppEmptyState(
                      title: 'No matching alerts',
                      message: 'Try another replenishment filter.',
                      icon: Icons.filter_alt_off_rounded,
                    )
                  else
                    for (
                      var index = 0;
                      index < state.visiblePlans.length;
                      index += 1
                    ) ...[
                      LowStockReplenishmentTile(
                        plan: state.visiblePlans[index],
                        onRestock:
                            onRestock == null
                                ? null
                                : () => onRestock!(state.visiblePlans[index]),
                        currencyFormat: currencyFormat,
                      ),
                      if (index != state.visiblePlans.length - 1)
                        const SizedBox(height: 10),
                    ],
                ],
              ),
    );
  }
}

List<Warehouse> _warehouseOptions(List<InventoryReplenishmentPlan> plans) {
  final warehousesById = <String, Warehouse>{};
  for (final plan in plans) {
    warehousesById[plan.record.warehouse.id] = plan.record.warehouse;
  }

  return warehousesById.values.toList()
    ..sort((first, second) => first.name.compareTo(second.name));
}

@Preview(name: 'Low stock replenishment panel')
Widget lowStockReplenishmentPanelPreview() {
  return lowStockReplenishmentPreviewScaffold(
    LowStockReplenishmentPanel(
      plans: lowStockReplenishmentPreviewPlans(),
      onFilterChanged: (_) {},
      onCreatePurchaseOrderDraft: (_) {},
      onRestock: (_) {},
    ),
  );
}

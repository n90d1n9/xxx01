import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_filter_chip_group.dart';
import '../models/inventory_replenishment_plan.dart';
import '../models/warehouse.dart';
import 'inventory_branch_filter.dart';
import 'low_stock_replenishment_preview_data.dart';
import 'low_stock_replenishment_queue_state.dart';
import 'low_stock_replenishment_sort_field.dart';

/// Filter controls for triaging the low-stock replenishment queue.
class LowStockReplenishmentFilterBar extends StatelessWidget {
  const LowStockReplenishmentFilterBar({
    super.key,
    required this.state,
    required this.onChanged,
    this.warehouses = const <Warehouse>[],
    this.onWarehouseChanged,
    this.onSortChanged,
  });

  final LowStockReplenishmentQueueState state;
  final ValueChanged<InventoryReplenishmentPlanFilter> onChanged;
  final List<Warehouse> warehouses;
  final ValueChanged<String?>? onWarehouseChanged;
  final ValueChanged<InventoryReplenishmentPlanSort>? onSortChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showWarehouseFilter =
            onWarehouseChanged != null && warehouses.length > 1;
        final warehouseWidth =
            constraints.maxWidth < 560 ? constraints.maxWidth : 260.0;
        final sortWidth =
            constraints.maxWidth < 560 ? constraints.maxWidth : 220.0;

        return Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppFilterChipGroup<InventoryReplenishmentPlanFilter>(
              value: state.filter,
              options: [
                AppFilterChipOption(
                  value: InventoryReplenishmentPlanFilter.all,
                  label: 'All',
                  icon: Icons.format_list_bulleted_rounded,
                  count: state.countFor(InventoryReplenishmentPlanFilter.all),
                  tooltip: 'Show every replenishment recommendation',
                ),
                AppFilterChipOption(
                  value: InventoryReplenishmentPlanFilter.critical,
                  label: 'Critical',
                  icon: Icons.priority_high_rounded,
                  count: state.countFor(
                    InventoryReplenishmentPlanFilter.critical,
                  ),
                  tooltip: 'Show empty or deeply under-threshold stock lines',
                ),
                AppFilterChipOption(
                  value: InventoryReplenishmentPlanFilter.reorderSoon,
                  label: 'Reorder soon',
                  icon: Icons.schedule_rounded,
                  count: state.countFor(
                    InventoryReplenishmentPlanFilter.reorderSoon,
                  ),
                  tooltip: 'Show low-stock lines that can be planned soon',
                ),
              ],
              onChanged: onChanged,
            ),
            if (showWarehouseFilter)
              SizedBox(
                width: warehouseWidth,
                child: InventoryWarehouseSelectField(
                  warehouses: warehouses,
                  selectedWarehouseId: state.selectedWarehouseId,
                  onChanged: onWarehouseChanged!,
                  label: 'Scope',
                ),
              ),
            if (onSortChanged != null)
              LowStockReplenishmentSortField(
                value: state.sort,
                width: sortWidth,
                onChanged: onSortChanged!,
              ),
          ],
        );
      },
    );
  }
}

@Preview(name: 'Low stock replenishment filter bar')
Widget lowStockReplenishmentFilterBarPreview() {
  final plans = lowStockReplenishmentPreviewPlans();
  final state = LowStockReplenishmentQueueState.resolve(
    plans: plans,
    filter: InventoryReplenishmentPlanFilter.all,
  );

  return lowStockReplenishmentPreviewScaffold(
    LowStockReplenishmentFilterBar(
      state: state,
      warehouses: lowStockReplenishmentPreviewWarehouses(),
      onChanged: (_) {},
      onWarehouseChanged: (_) {},
      onSortChanged: (_) {},
    ),
  );
}

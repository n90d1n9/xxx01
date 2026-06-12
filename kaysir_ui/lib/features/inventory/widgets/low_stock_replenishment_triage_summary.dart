import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../widgets/ui/app_active_filter_bar.dart';
import '../models/inventory_replenishment_plan.dart';
import '../models/warehouse.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_metric_chip.dart';
import 'low_stock_replenishment_preview_data.dart';
import 'low_stock_replenishment_queue_state.dart';

/// Compact summary of the currently visible low-stock replenishment queue.
class LowStockReplenishmentTriageSummary extends StatelessWidget {
  const LowStockReplenishmentTriageSummary({
    super.key,
    required this.state,
    this.warehouses = const <Warehouse>[],
    this.currencyFormat,
    this.onFilterCleared,
    this.onWarehouseCleared,
    this.onClearAll,
  });

  final LowStockReplenishmentQueueState state;
  final List<Warehouse> warehouses;
  final NumberFormat? currencyFormat;
  final VoidCallback? onFilterCleared;
  final VoidCallback? onWarehouseCleared;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    final tokens = _activeTokens();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InventoryMetricChip(
              label: 'Visible lines',
              value: formatInventoryNumber(state.visibleCount),
              icon: Icons.visibility_rounded,
            ),
            InventoryMetricChip(
              label: 'Suggested units',
              value: formatInventoryNumber(state.visibleSuggestedUnits),
              icon: Icons.add_shopping_cart_rounded,
            ),
            InventoryMetricChip(
              label: 'Visible cost',
              value: formatInventoryCurrency(
                state.visibleEstimatedCost,
                formatter: currencyFormat,
              ),
              icon: Icons.payments_rounded,
            ),
          ],
        ),
        if (tokens.isNotEmpty && onClearAll != null) ...[
          const SizedBox(height: 10),
          ActiveFilterBar(tokens: tokens, onClearAll: onClearAll!),
        ],
      ],
    );
  }

  List<ActiveFilterToken> _activeTokens() {
    return [
      if (state.filter != InventoryReplenishmentPlanFilter.all &&
          onFilterCleared != null)
        ActiveFilterToken(
          icon: Icons.priority_high_rounded,
          label: 'Urgency: ${_filterLabel(state.filter)}',
          clearTooltip: 'Clear urgency filter',
          onClear: onFilterCleared!,
        ),
      if (state.selectedWarehouseId != null && onWarehouseCleared != null)
        ActiveFilterToken(
          icon: Icons.warehouse_rounded,
          label: 'Warehouse: ${_warehouseLabel(state.selectedWarehouseId!)}',
          clearTooltip: 'Clear warehouse scope',
          onClear: onWarehouseCleared!,
        ),
    ];
  }

  String _warehouseLabel(String warehouseId) {
    for (final warehouse in warehouses) {
      if (warehouse.id == warehouseId) return warehouse.name;
    }
    return warehouseId;
  }
}

String _filterLabel(InventoryReplenishmentPlanFilter filter) {
  switch (filter) {
    case InventoryReplenishmentPlanFilter.all:
      return 'All';
    case InventoryReplenishmentPlanFilter.critical:
      return 'Critical';
    case InventoryReplenishmentPlanFilter.reorderSoon:
      return 'Reorder soon';
  }
}

@Preview(name: 'Low stock replenishment triage summary')
Widget lowStockReplenishmentTriageSummaryPreview() {
  final plans = lowStockReplenishmentPreviewPlans();
  final state = LowStockReplenishmentQueueState.resolve(
    plans: plans,
    filter: InventoryReplenishmentPlanFilter.critical,
    warehouseId: 'jakarta',
  );

  return lowStockReplenishmentPreviewScaffold(
    LowStockReplenishmentTriageSummary(
      state: state,
      warehouses: lowStockReplenishmentPreviewWarehouses(),
      onFilterCleared: () {},
      onWarehouseCleared: () {},
      onClearAll: () {},
    ),
  );
}

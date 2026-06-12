import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_analytics_dashboard.dart';
import 'inventory_analytics_preview_data.dart';
import 'inventory_analytics_value_breakdown_panel.dart';
import 'inventory_analytics_value_breakdown_state.dart';

/// Panel showing stock value concentration by product category.
class InventoryAnalyticsCategoryPanel extends StatelessWidget {
  const InventoryAnalyticsCategoryPanel({super.key, required this.values});

  final List<InventoryAnalyticsCategoryValue> values;

  @override
  Widget build(BuildContext context) {
    return InventoryAnalyticsValueBreakdownPanel(
      title: 'Inventory by Category',
      subtitle: 'Stock value concentration across product groups',
      leadingIcon: Icons.category_rounded,
      statusIcon: Icons.pie_chart_rounded,
      emptyTitle: 'No category value yet',
      emptyMessage: 'Add stocked products to populate category analytics.',
      emptyIcon: Icons.category_outlined,
      state: inventoryAnalyticsCategoryValueBreakdownState(values),
    );
  }
}

/// Panel showing stock value concentration by branch.
class InventoryAnalyticsBranchValuePanel extends StatelessWidget {
  const InventoryAnalyticsBranchValuePanel({super.key, required this.values});

  final List<InventoryAnalyticsBranchValue> values;

  @override
  Widget build(BuildContext context) {
    return InventoryAnalyticsValueBreakdownPanel(
      title: 'Value by Branch',
      subtitle: 'Stock value, units, and warehouse coverage by branch',
      leadingIcon: Icons.account_tree_rounded,
      statusIcon: Icons.account_tree_rounded,
      statusColor: Colors.teal.shade700,
      statusMaxWidth: 140,
      emptyTitle: 'No branch value yet',
      emptyMessage: 'Assign warehouses to branches to populate analytics.',
      emptyIcon: Icons.account_tree_outlined,
      state: inventoryAnalyticsBranchValueBreakdownState(values),
    );
  }
}

/// Panel showing stock value concentration by warehouse.
class InventoryAnalyticsWarehouseValuePanel extends StatelessWidget {
  const InventoryAnalyticsWarehouseValuePanel({
    super.key,
    required this.values,
  });

  final List<InventoryAnalyticsWarehouseValue> values;

  @override
  Widget build(BuildContext context) {
    return InventoryAnalyticsValueBreakdownPanel(
      title: 'Value by Warehouse',
      subtitle: 'Stock value, units, and product spread by location',
      leadingIcon: Icons.warehouse_rounded,
      statusIcon: Icons.location_city_rounded,
      statusColor: Colors.purple.shade700,
      statusMaxWidth: 140,
      emptyTitle: 'No warehouse value yet',
      emptyMessage: 'Add stock lines to populate warehouse analytics.',
      emptyIcon: Icons.warehouse_outlined,
      state: inventoryAnalyticsWarehouseValueBreakdownState(values),
    );
  }
}

@Preview(name: 'Inventory analytics value panels')
Widget inventoryAnalyticsValuePanelsPreview() {
  return inventoryAnalyticsPreviewScaffold(
    Column(
      children: [
        InventoryAnalyticsCategoryPanel(
          values: inventoryAnalyticsPreviewCategoryValues(),
        ),
        const SizedBox(height: 16),
        InventoryAnalyticsBranchValuePanel(
          values: inventoryAnalyticsPreviewBranchValues(),
        ),
        const SizedBox(height: 16),
        InventoryAnalyticsWarehouseValuePanel(
          values: inventoryAnalyticsPreviewWarehouseValues(),
        ),
      ],
    ),
  );
}

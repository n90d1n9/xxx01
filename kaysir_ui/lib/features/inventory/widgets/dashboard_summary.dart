import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

import '../utils/inventory_formatters.dart';

/// Summary metric grid for the inventory dashboard overview.
class InventoryDashboardSummary extends StatelessWidget {
  const InventoryDashboardSummary({
    super.key,
    required this.totalProducts,
    required this.totalWarehouses,
    required this.totalBranches,
    required this.lowStockItems,
    required this.inventoryValue,
    this.currency,
  });

  final int totalProducts;
  final int totalWarehouses;
  final int totalBranches;
  final int lowStockItems;
  final double inventoryValue;
  final NumberFormat? currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppMetricGrid(
      minTileWidth: 180,
      maxColumns: 4,
      metrics: [
        AppMetricGridItem(
          title: 'Products',
          value: totalProducts.toString(),
          icon: Icons.category_outlined,
          accentColor: colorScheme.primary,
          helper: 'Active SKUs',
        ),
        AppMetricGridItem(
          title: 'Warehouses',
          value: totalWarehouses.toString(),
          icon: Icons.warehouse_outlined,
          accentColor: Colors.teal.shade700,
          helper:
              totalBranches == 1
                  ? '1 branch covered'
                  : '$totalBranches branches covered',
        ),
        AppMetricGridItem(
          title: 'Low Stock',
          value: lowStockItems.toString(),
          icon: Icons.warning_amber_rounded,
          accentColor:
              lowStockItems > 0 ? colorScheme.error : Colors.green.shade700,
          helper: lowStockItems > 0 ? 'Needs attention' : 'Healthy',
        ),
        AppMetricGridItem(
          title: 'Inventory Value',
          value: formatInventoryCurrency(inventoryValue, formatter: currency),
          icon: Icons.account_balance_wallet_outlined,
          accentColor: Colors.indigo.shade600,
          helper: 'Current stock value',
        ),
      ],
    );
  }
}

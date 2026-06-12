import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../models/inventory_branch_filter.dart';
import '../states/inventory_projection_provider.dart';
import '../states/low_stock_items_provider.dart';
import '../states/product_provider.dart';
import '../states/warehouse_provider.dart';
import '../widgets/inventory_dashboard_components.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final warehouses = ref.watch(warehousesProvider);
    final lowStockItems = ref.watch(lowStockItemsProvider);
    final stockRecords = ref.watch(inventoryStockRecordsProvider);
    final movementRecords = ref.watch(inventoryMovementRecordsProvider);
    final branchCount = inventoryBranchOptionsForWarehouses(warehouses).length;

    final totalInventoryValue = stockRecords.fold<double>(
      0,
      (total, record) => total + record.inventoryValue,
    );
    final recentMovements = [
      for (final record in movementRecords.take(5))
        InventoryMovementListEntry(
          productName: record.productName,
          type: record.movement.type,
          quantity: record.movement.quantity,
          reference: record.movement.reference,
          date: record.movement.date,
        ),
    ];

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.dashboard,
      appBar: AppBar(title: const Text('Inventory Dashboard')),
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        physics: const AlwaysScrollableScrollPhysics(),
        header: AppTextCluster(
          eyebrow: 'Inventory',
          title: 'Inventory Dashboard',
          subtitle:
              '${products.length} products across ${warehouses.length} stock locations',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryDashboardSummary(
          totalProducts: products.length,
          totalWarehouses: warehouses.length,
          totalBranches: branchCount,
          lowStockItems: lowStockItems.length,
          inventoryValue: totalInventoryValue,
        ),
        children: [RecentInventoryMovementsPanel(movements: recentMovements)],
      ),
    );
  }
}

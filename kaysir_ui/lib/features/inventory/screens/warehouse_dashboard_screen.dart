import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../inventory_routes.dart';
import '../models/inventory_filter_deep_link.dart';
import '../models/inventory_warehouse_dashboard.dart';
import '../states/inventory_branch_provider.dart';
import '../states/inventory_item_provider.dart';
import '../states/warehouse_provider.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';
import '../widgets/inventory_warehouse_dashboard_components.dart';

class WarehouseDashboardPage extends ConsumerWidget {
  const WarehouseDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = buildInventoryWarehouseDashboardSnapshot(
      branches: ref.watch(inventoryBranchesProvider),
      warehouses: ref.watch(warehousesProvider),
      inventoryItems: ref.watch(inventoryItemsProvider),
    );

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.warehouseDashboard,
      appBar: AppBar(
        title: const Text('Warehouse Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Open warehouses',
            icon: const Icon(Icons.warehouse_rounded),
            onPressed: () => _openRoute(context, InventoryRoutes.warehouses),
          ),
          IconButton(
            tooltip: 'Open branches',
            icon: const Icon(Icons.account_tree_rounded),
            onPressed: () => _openRoute(context, InventoryRoutes.branches),
          ),
          IconButton(
            tooltip: 'Open capacity',
            icon: const Icon(Icons.space_dashboard_rounded),
            onPressed:
                () => _openRoute(context, InventoryRoutes.warehouseCapacity),
          ),
        ],
      ),
      body: AppListSurface(
        padding: const EdgeInsets.all(20),
        sectionSpacing: 20,
        header: AppTextCluster(
          eyebrow: 'Warehouse Management',
          title: 'Warehouse Dashboard',
          subtitle:
              '${snapshot.warehouseCount} warehouses across ${snapshot.branchCount} branch scopes',
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        metrics: InventoryWarehouseDashboardSummaryGrid(snapshot: snapshot),
        children: [
          InventoryWarehouseDashboardActionPanel(
            onOpenWarehouses:
                () => _openRoute(context, InventoryRoutes.warehouses),
            onOpenBranches: () => _openRoute(context, InventoryRoutes.branches),
            onOpenCapacity:
                () => _openRoute(context, InventoryRoutes.warehouseCapacity),
          ),
          InventoryWarehouseBranchHealthPanel(
            branchSummaries: snapshot.branchSummaries,
            totalWarehouseCount: snapshot.warehouseCount,
            onOpenBranch:
                (summary) => _openRoute(
                  context,
                  inventoryWarehouseBranchDetailDeepLink(
                    branchKey: summary.branchKey,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  void _openRoute(BuildContext context, String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }
}

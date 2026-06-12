import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../inventory_routes.dart';
import '../models/inventory_warehouse_dashboard.dart';
import '../states/inventory_branch_provider.dart';
import '../states/inventory_item_provider.dart';
import '../states/product_provider.dart';
import '../states/warehouse_provider.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';
import '../widgets/inventory_warehouse_branch_detail_components.dart';
import 'warehouse_branch_detail_routes.dart';

/// Branch-scoped warehouse detail page for capacity, stock, and operations.
class WarehouseBranchDetailPage extends ConsumerWidget {
  const WarehouseBranchDetailPage({super.key, this.branchKey});

  final String? branchKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = buildInventoryWarehouseBranchDetail(
      branchKey: branchKey,
      branches: ref.watch(inventoryBranchesProvider),
      warehouses: ref.watch(warehousesProvider),
      inventoryItems: ref.watch(inventoryItemsProvider),
      products: ref.watch(productsProvider),
    );

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.warehouseDashboard,
      isCanonicalDestination: false,
      appBar: AppBar(
        title: const Text('Branch Warehouse Detail'),
        actions: [
          IconButton(
            tooltip: 'Open warehouse hub',
            icon: const Icon(Icons.view_quilt_rounded),
            onPressed:
                () => _openRoute(context, InventoryRoutes.warehouseDashboard),
          ),
        ],
      ),
      body:
          detail == null
              ? InventoryWarehouseBranchDetailNotFoundState(
                onOpenHub: () => _openHub(context),
              )
              : InventoryWarehouseBranchDetailWorkspace(
                detail: detail,
                actions: _actionsFor(context, detail),
              ),
    );
  }

  InventoryWarehouseBranchDetailWorkspaceActions _actionsFor(
    BuildContext context,
    InventoryWarehouseBranchDetail detail,
  ) {
    final routes = WarehouseBranchDetailRoutes(detail);

    return InventoryWarehouseBranchDetailWorkspaceActions(
      onOpenHub: () => _openRoute(context, routes.hubRoute),
      onOpenStock: () => _openRoute(context, routes.stockRoute),
      onOpenMovements: () => _openRoute(context, routes.movementsRoute),
      onOpenCapacity: () => _openRoute(context, routes.capacityRoute),
      onOpenWarehouse:
          (operation) =>
              _openRoute(context, routes.warehouseDetailRoute(operation)),
      onOpenOperationStock:
          (operation) =>
              _openRoute(context, routes.operationStockRoute(operation)),
      onOpenOperationMovements:
          (operation) =>
              _openRoute(context, routes.operationMovementsRoute(operation)),
      onOpenOperationCapacity:
          (operation) =>
              _openRoute(context, routes.operationCapacityRoute(operation)),
    );
  }

  void _openHub(BuildContext context) {
    _openRoute(context, InventoryRoutes.warehouseDashboard);
  }

  void _openRoute(BuildContext context, String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }
}

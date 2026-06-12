import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_analytics_dashboard.dart';
import '../states/inventory_item_provider.dart';
import '../states/inventory_movement_provider.dart';
import '../states/product_provider.dart';
import '../states/warehouse_provider.dart';
import '../widgets/inventory_analytics_dashboard_components.dart';
import '../widgets/inventory_navigation_drawer.dart';
import '../widgets/inventory_navigation_scaffold.dart';

/// Inventory analytics workspace with summary, movement, value, and branch drill-downs.
class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  ConsumerState<AnalyticsDashboardPage> createState() =>
      _AnalyticsDashboardPageState();
}

/// Holds transient analytics branch selection while providers drive the data.
class _AnalyticsDashboardPageState
    extends ConsumerState<AnalyticsDashboardPage> {
  String? _selectedBranchId;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final inventoryItems = ref.watch(inventoryItemsProvider);
    final movements = ref.watch(inventoryMovementsProvider);
    final warehouses = ref.watch(warehousesProvider);
    final asOfDate = DateTime.now();
    final dashboard = buildInventoryAnalyticsDashboard(
      products: products,
      inventoryItems: inventoryItems,
      movements: movements,
      warehouses: warehouses,
      asOfDate: asOfDate,
    );

    return InventoryNavigationScaffold(
      currentDestination: InventoryNavigationDestination.analytics,
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: InventoryAnalyticsDashboardWorkspace(
        dashboard: dashboard,
        asOfDate: asOfDate,
        selectedBranchId: _selectedBranchId,
        actions: InventoryAnalyticsDashboardWorkspaceActions(
          onBranchChanged:
              (branchId) => setState(() => _selectedBranchId = branchId),
          onWarehouseSelected: _openWarehouseStock,
          onMovementSelected: _openBranchMovement,
          onPrioritySelected: _openPriority,
        ),
      ),
    );
  }

  void _openWarehouseStock(
    InventoryAnalyticsBranchDetail detail,
    InventoryAnalyticsBranchWarehouse warehouse,
  ) {
    Navigator.of(context).pushNamed(
      inventoryAnalyticsWarehouseStockRoute(
        detail: detail,
        warehouse: warehouse,
      ),
    );
  }

  void _openBranchMovement(
    InventoryAnalyticsBranchDetail detail,
    InventoryAnalyticsBranchMovement movement,
  ) {
    Navigator.of(context).pushNamed(
      inventoryAnalyticsBranchMovementRoute(detail: detail, movement: movement),
    );
  }

  void _openPriority(InventoryAnalyticsPriorityItemState priority) {
    Navigator.of(context).pushNamed(inventoryAnalyticsPriorityRoute(priority));
  }
}

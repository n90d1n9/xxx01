import 'package:flutter/material.dart';

import '../inventory_routes.dart';

/// Stable destinations available from the inventory navigation drawer.
enum InventoryNavigationDestination {
  dashboard,
  inventory,
  products,
  warehouses,
  warehouseDashboard,
  warehouseCapacity,
  branches,
  purchaseOrders,
  reports,
  analytics,
  stockOpname,
  movements,
  lowStock,
}

/// Route and icon metadata used to render one inventory navigation destination.
class InventoryNavigationDestinationDetails {
  const InventoryNavigationDestinationDetails({
    required this.destination,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.routePath,
  });

  final InventoryNavigationDestination destination;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String routePath;
}

/// Ordered inventory destinations shown in the shared drawer.
const inventoryNavigationDestinations = <InventoryNavigationDestination>[
  InventoryNavigationDestination.dashboard,
  InventoryNavigationDestination.inventory,
  InventoryNavigationDestination.products,
  InventoryNavigationDestination.warehouses,
  InventoryNavigationDestination.warehouseDashboard,
  InventoryNavigationDestination.warehouseCapacity,
  InventoryNavigationDestination.branches,
  InventoryNavigationDestination.purchaseOrders,
  InventoryNavigationDestination.reports,
  InventoryNavigationDestination.analytics,
  InventoryNavigationDestination.stockOpname,
  InventoryNavigationDestination.movements,
  InventoryNavigationDestination.lowStock,
];

/// Metadata keyed by inventory navigation destination.
const inventoryNavigationDestinationDetailsByDestination =
    <InventoryNavigationDestination, InventoryNavigationDestinationDetails>{
      InventoryNavigationDestination
          .dashboard: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.dashboard,
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        routePath: InventoryRoutes.dashboard,
      ),
      InventoryNavigationDestination
          .inventory: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.inventory,
        label: 'Inventory',
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2_rounded,
        routePath: InventoryRoutes.stock,
      ),
      InventoryNavigationDestination
          .products: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.products,
        label: 'Products',
        icon: Icons.category_outlined,
        selectedIcon: Icons.category_rounded,
        routePath: InventoryRoutes.products,
      ),
      InventoryNavigationDestination
          .warehouses: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.warehouses,
        label: 'Warehouses',
        icon: Icons.warehouse_outlined,
        selectedIcon: Icons.warehouse_rounded,
        routePath: InventoryRoutes.warehouses,
      ),
      InventoryNavigationDestination
          .warehouseDashboard: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.warehouseDashboard,
        label: 'Warehouse Hub',
        icon: Icons.view_quilt_outlined,
        selectedIcon: Icons.view_quilt_rounded,
        routePath: InventoryRoutes.warehouseDashboard,
      ),
      InventoryNavigationDestination
          .warehouseCapacity: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.warehouseCapacity,
        label: 'Capacity',
        icon: Icons.space_dashboard_outlined,
        selectedIcon: Icons.space_dashboard_rounded,
        routePath: InventoryRoutes.warehouseCapacity,
      ),
      InventoryNavigationDestination
          .branches: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.branches,
        label: 'Branches',
        icon: Icons.account_tree_outlined,
        selectedIcon: Icons.account_tree_rounded,
        routePath: InventoryRoutes.branches,
      ),
      InventoryNavigationDestination
          .purchaseOrders: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.purchaseOrders,
        label: 'Purchase Orders',
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long_rounded,
        routePath: InventoryRoutes.purchaseOrders,
      ),
      InventoryNavigationDestination
          .reports: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.reports,
        label: 'Reports',
        icon: Icons.assessment_outlined,
        selectedIcon: Icons.assessment_rounded,
        routePath: InventoryRoutes.reports,
      ),
      InventoryNavigationDestination
          .analytics: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.analytics,
        label: 'Analytics',
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics_rounded,
        routePath: InventoryRoutes.analytics,
      ),
      InventoryNavigationDestination
          .stockOpname: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.stockOpname,
        label: 'Stock Opname',
        icon: Icons.fact_check_outlined,
        selectedIcon: Icons.fact_check_rounded,
        routePath: InventoryRoutes.stockOpname,
      ),
      InventoryNavigationDestination
          .movements: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.movements,
        label: 'Movements',
        icon: Icons.sync_alt_outlined,
        selectedIcon: Icons.sync_alt_rounded,
        routePath: InventoryRoutes.movements,
      ),
      InventoryNavigationDestination
          .lowStock: InventoryNavigationDestinationDetails(
        destination: InventoryNavigationDestination.lowStock,
        label: 'Low Stock Alerts',
        icon: Icons.notification_important_outlined,
        selectedIcon: Icons.notification_important_rounded,
        routePath: InventoryRoutes.lowStock,
      ),
    };

extension InventoryNavigationDestinationLookup
    on InventoryNavigationDestination {
  InventoryNavigationDestinationDetails get details {
    return inventoryNavigationDestinationDetailsByDestination[this]!;
  }

  String get label => details.label;

  IconData get icon => details.icon;

  IconData get selectedIcon => details.selectedIcon;

  String get routePath => details.routePath;
}

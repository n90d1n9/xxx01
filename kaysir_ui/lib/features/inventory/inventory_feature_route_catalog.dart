import 'inventory_routes.dart';
import 'widgets/inventory_navigation_destination_details.dart';

/// Metadata used to register one inventory feature route in the app shell.
class InventoryFeatureRouteDestination {
  const InventoryFeatureRouteDestination({
    required this.name,
    required this.subtitle,
    required this.description,
    required String path,
  }) : navigationDestination = null,
       _path = path;

  const InventoryFeatureRouteDestination.navigation({
    required this.navigationDestination,
    required this.name,
    required this.subtitle,
    required this.description,
  }) : _path = null;

  final InventoryNavigationDestination? navigationDestination;
  final String name;
  final String subtitle;
  final String description;
  final String? _path;

  String get path => navigationDestination?.routePath ?? _path!;
}

/// Inventory feature routes shown in the application sidebar.
const inventoryFeatureRouteDestinations = [
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.dashboard,
    name: 'Inventory Dashboard',
    subtitle: 'Stock command center',
    description:
        'Inventory overview with stock value, low stock pressure, products, and recent movement signals.',
  ),
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.inventory,
    name: 'Stock Workspace',
    subtitle: 'Adjust, transfer, and add stock',
    description:
        'Operational stock workspace with create stock, adjustment, transfer, restock, and stock detail forms.',
  ),
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.products,
    name: 'Products',
    subtitle: 'Catalog forms',
    description:
        'Product catalog with add, edit, delete, search, stock coverage, and attention-state controls.',
  ),
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.warehouses,
    name: 'Warehouses',
    subtitle: 'Storage locations',
    description:
        'Warehouse directory with add, edit, delete, capacity, location, and storage metadata forms.',
  ),
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.warehouseDashboard,
    name: 'Warehouse Dashboard',
    subtitle: 'Warehouse control hub',
    description:
        'Warehouse management dashboard with branch health, capacity readiness, low-stock pressure, and module shortcuts.',
  ),
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.warehouseCapacity,
    name: 'Warehouse Capacity',
    subtitle: 'Capacity control',
    description:
        'Warehouse capacity workspace with branch scoping, utilization status, remaining capacity, and CSV export.',
  ),
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.branches,
    name: 'Branches',
    subtitle: 'Multi-branch directory',
    description:
        'Branch directory with add, edit, delete, manager, contact, status, and warehouse assignment context.',
  ),
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.purchaseOrders,
    name: 'Purchase Orders',
    subtitle: 'Procurement queue',
    description:
        'Purchase order workspace for supplier orders, receiving state, overdue orders, and detail review.',
  ),
  InventoryFeatureRouteDestination(
    name: 'Create Purchase Order',
    path: InventoryRoutes.createPurchaseOrder,
    subtitle: 'Supplier order form',
    description:
        'Purchase order form for supplier details, expected delivery, notes, and product line items.',
  ),
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.stockOpname,
    name: 'Stock Opname',
    subtitle: 'Physical count form',
    description:
        'Stock opname count form with warehouse selection, counter details, count lines, variances, and completion.',
  ),
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.movements,
    name: 'Movement History',
    subtitle: 'Stock event log',
    description:
        'Filterable movement history for purchases, sales, returns, adjustments, transfers, and count updates.',
  ),
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.lowStock,
    name: 'Low Stock Alerts',
    subtitle: 'Replenishment forms',
    description:
        'Low stock queue with restock forms, suggested quantities, urgency, and replenishment actions.',
  ),
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.reports,
    name: 'Reports',
    subtitle: 'Report hub',
    description:
        'Inventory report hub for valuation, movement, low stock, and warehouse capacity views.',
  ),
  InventoryFeatureRouteDestination.navigation(
    navigationDestination: InventoryNavigationDestination.analytics,
    name: 'Analytics',
    subtitle: 'Inventory intelligence',
    description:
        'Analytics dashboard for inventory value, categories, warehouses, movement trends, and alerts.',
  ),
];

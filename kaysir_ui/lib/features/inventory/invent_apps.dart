import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/inventory_filter_deep_link.dart';
import 'screens/analytic_dashboard_screen.dart';
import 'screens/branch_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_movement_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/low_stock_screen.dart';
import 'screens/product_screen.dart';
import 'screens/purchase_order/create_purchase_order_screen.dart';
import 'screens/purchase_order/purchase_order_screen.dart';
import 'screens/report_screen.dart';
import 'screens/stockopname_screen.dart';
import 'screens/warehouse_branch_detail_screen.dart';
import 'screens/warehouse_capacity_screen.dart';
import 'screens/warehouse_dashboard_screen.dart';
import 'screens/warehouse_detail_screen.dart';
import 'screens/warehouse_screen.dart';
import 'inventory_routes.dart';

class InventoryManagementApp extends StatelessWidget {
  const InventoryManagementApp({super.key, this.initialRoute});

  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Inventory Management',
        initialRoute: initialRoute ?? InventoryRoutes.dashboard,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        onGenerateRoute: inventoryRouteFromSettings,
        routes: {
          '/': (context) => const DashboardPage(),
          InventoryRoutes.dashboard: (context) => const DashboardPage(),
          InventoryRoutes.stock: (context) => const InventoryPage(),
          InventoryRoutes.products: (context) => const ProductPage(),
          InventoryRoutes.warehouses: (context) => const WarehousePage(),
          InventoryRoutes.warehouseDetail:
              (context) => const WarehouseDetailPage(),
          InventoryRoutes.warehouseDashboard:
              (context) => const WarehouseDashboardPage(),
          InventoryRoutes.warehouseBranchDetail:
              (context) => const WarehouseBranchDetailPage(),
          InventoryRoutes.warehouseCapacity:
              (context) => const WarehouseCapacityPage(),
          InventoryRoutes.branches: (context) => const BranchPage(),
          InventoryRoutes.purchaseOrders:
              (context) => const PurchaseOrdersScreen(),
          InventoryRoutes.createPurchaseOrder:
              (context) => const CreatePurchaseOrderScreen(),
          InventoryRoutes.reports: (context) => const ReportsPage(),
          InventoryRoutes.analytics:
              (context) => const AnalyticsDashboardPage(),
          InventoryRoutes.movements:
              (context) => const InventoryMovementsPage(),
          InventoryRoutes.lowStock: (context) => const LowStockPage(),
          InventoryRoutes.stockOpname: (context) => const StockOpnamePage(),
          InventoryRoutes.legacyDashboard: (context) => const DashboardPage(),
          InventoryRoutes.legacyStock: (context) => const InventoryPage(),
          InventoryRoutes.legacyProducts: (context) => const ProductPage(),
          InventoryRoutes.legacyWarehouses: (context) => const WarehousePage(),
          InventoryRoutes.legacyPurchaseOrders:
              (context) => const PurchaseOrdersScreen(),
          InventoryRoutes.legacyReports: (context) => const ReportsPage(),
          InventoryRoutes.legacyAnalytics:
              (context) => const AnalyticsDashboardPage(),
          InventoryRoutes.legacyMovements:
              (context) => const InventoryMovementsPage(),
          InventoryRoutes.legacyLowStock: (context) => const LowStockPage(),
          InventoryRoutes.legacyStockOpname:
              (context) => const StockOpnamePage(),
          InventoryRoutes.legacyStockOpnameDashed:
              (context) => const StockOpnamePage(),
        },
      ),
    );
  }
}

Route<dynamic>? inventoryRouteFromSettings(RouteSettings settings) {
  final routeName = settings.name;
  if (routeName == null) return null;

  final uri = Uri.parse(routeName);
  final query = uri.queryParameters;
  final page = _inventoryPageForUri(uri, query);
  if (page == null) return null;

  return MaterialPageRoute<dynamic>(
    settings: settings,
    builder: (context) => page,
  );
}

Widget? _inventoryPageForUri(Uri uri, Map<String, String> query) {
  switch (uri.path) {
    case '/':
    case InventoryRoutes.dashboard:
    case InventoryRoutes.legacyDashboard:
      return const DashboardPage();
    case InventoryRoutes.stock:
    case InventoryRoutes.legacyStock:
      return InventoryPage(
        initialBranch: query[InventoryFilterQueryKeys.branch],
        initialWarehouseId: query[InventoryFilterQueryKeys.warehouse],
        initialQuery: query[InventoryFilterQueryKeys.query] ?? '',
        initialFilter: inventoryStockFilterFromQuery(
          query[InventoryFilterQueryKeys.filter],
        ),
      );
    case InventoryRoutes.products:
    case InventoryRoutes.legacyProducts:
      return const ProductPage();
    case InventoryRoutes.warehouses:
    case InventoryRoutes.legacyWarehouses:
      return const WarehousePage();
    case InventoryRoutes.warehouseDetail:
      return WarehouseDetailPage(
        warehouseId: query[InventoryFilterQueryKeys.warehouse],
      );
    case InventoryRoutes.warehouseDashboard:
      return const WarehouseDashboardPage();
    case InventoryRoutes.warehouseBranchDetail:
      return WarehouseBranchDetailPage(
        branchKey: query[InventoryFilterQueryKeys.branch],
      );
    case InventoryRoutes.warehouseCapacity:
      return WarehouseCapacityPage(
        initialBranch: query[InventoryFilterQueryKeys.branch],
        initialWarehouseId: query[InventoryFilterQueryKeys.warehouse],
      );
    case InventoryRoutes.branches:
      return const BranchPage();
    case InventoryRoutes.purchaseOrders:
    case InventoryRoutes.legacyPurchaseOrders:
      return PurchaseOrdersScreen(
        initialQuery: query[InventoryFilterQueryKeys.query] ?? '',
      );
    case InventoryRoutes.createPurchaseOrder:
      return const CreatePurchaseOrderScreen();
    case InventoryRoutes.reports:
    case InventoryRoutes.legacyReports:
      return const ReportsPage();
    case InventoryRoutes.analytics:
    case InventoryRoutes.legacyAnalytics:
      return const AnalyticsDashboardPage();
    case InventoryRoutes.movements:
    case InventoryRoutes.legacyMovements:
      return InventoryMovementsPage(
        initialBranch: query[InventoryFilterQueryKeys.branch],
        initialWarehouseId: query[InventoryFilterQueryKeys.warehouse],
        initialQuery: query[InventoryFilterQueryKeys.query] ?? '',
        initialFilter: inventoryMovementFilterFromQuery(
          query[InventoryFilterQueryKeys.filter],
        ),
      );
    case InventoryRoutes.lowStock:
    case InventoryRoutes.legacyLowStock:
      return const LowStockPage();
    case InventoryRoutes.stockOpname:
    case InventoryRoutes.legacyStockOpname:
    case InventoryRoutes.legacyStockOpnameDashed:
      return const StockOpnamePage();
  }

  return null;
}

void main(List<String> args) {
  runApp(const InventoryManagementApp());
}

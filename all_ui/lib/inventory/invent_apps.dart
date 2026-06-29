import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/analytic_dashboard_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_movement_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/low_stock_screen.dart';
import 'screens/product_screen.dart';
import 'screens/report_screen.dart';
import 'screens/stockopname_screen.dart';
import 'screens/warehouse_screen.dart';

class InventoryManagementApp extends StatelessWidget {
  const InventoryManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Inventory Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const DashboardPage(),
        routes: {
          '/dashboard': (context) => const DashboardPage(),
          '/inventory': (context) => const InventoryPage(),
          '/products': (context) => const ProductPage(),
          '/warehouses': (context) => const WarehousePage(),
          '/reports': (context) => const ReportsPage(),
          '/analytics': (context) => const AnalyticsDashboardPage(),
          '/movements': (context) => const InventoryMovementsPage(),
          '/low-stock': (context) => const LowStockPage(),
          '/stock-opname': (context) => const StockOpnamePage(),
        },
      ),
    );
  }
}

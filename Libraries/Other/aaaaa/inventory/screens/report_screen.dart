import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../states/inventory_item_provider.dart';
import '../states/inventory_movement_provider.dart';
import '../states/low_stock_items_provider.dart';
import '../states/product_provider.dart';
import '../states/warehouse_provider.dart';
import 'dashboard_screen.dart';
import 'inventory_movement_screen.dart';
import 'inventory_screen.dart';
import 'inventory_valuation_screen.dart';
import 'low_stock_report_screen.dart';
import 'low_stock_screen.dart';
import 'product_screen.dart';
import 'stock_movement_screen.dart';
import 'warehouse_capacity_screen.dart';
import 'warehouse_screen.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildReportCard(
                    context,
                    'Inventory Valuation',
                    'Get the current value of inventory by product and warehouse',
                    Icons.attach_money,
                    Colors.green,
                    () => _generateInventoryValuationReport(context, ref),
                  ),
                  _buildReportCard(
                    context,
                    'Stock Movement History',
                    'Track inventory movements over time with detailed reports',
                    Icons.timeline,
                    Colors.blue,
                    () => _generateStockMovementReport(context, ref),
                  ),
                  _buildReportCard(
                    context,
                    'Low Stock Report',
                    'View all products that are below reorder points',
                    Icons.warning,
                    Colors.orange,
                    () => _generateLowStockReport(context, ref),
                  ),
                  _buildReportCard(
                    context,
                    'Warehouse Capacity',
                    'Analyze warehouse usage and available space',
                    Icons.warehouse,
                    Colors.purple,
                    () => _generateWarehouseCapacityReport(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(description, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                  child: const Text('Generate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateInventoryValuationReport(BuildContext context, WidgetRef ref) {
    final products = ref.read(productsProvider);
    final inventoryItems = ref.read(inventoryItemsProvider);
    final warehouses = ref.read(warehousesProvider);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryValuationReportPage(
          products: products,
          inventoryItems: inventoryItems,
          warehouses: warehouses,
        ),
      ),
    );
  }

  void _generateStockMovementReport(BuildContext context, WidgetRef ref) {
    final products = ref.read(productsProvider);
    final movements = ref.read(inventoryMovementsProvider);
    final warehouses = ref.read(warehousesProvider);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockMovementReportPage(
          products: products,
          movements: movements,
          warehouses: warehouses,
        ),
      ),
    );
  }

  void _generateLowStockReport(BuildContext context, WidgetRef ref) {
    final products = ref.read(productsProvider);
    final lowStockItems = ref.read(lowStockItemsProvider);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LowStockReportPage(
          products: products,
          lowStockItems: lowStockItems,
        ),
      ),
    );
  }

  void _generateWarehouseCapacityReport(BuildContext context, WidgetRef ref) {
    final warehouses = ref.read(warehousesProvider);
    final inventoryItems = ref.read(inventoryItemsProvider);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WarehouseCapacityReportPage(
          warehouses: warehouses,
          inventoryItems: inventoryItems,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Inventory Management',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Inventory'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const InventoryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProductPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.warehouse),
            title: const Text('Warehouses'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WarehousePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Inventory Movements'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventoryMovementsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Low Stock Alerts'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LowStockPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

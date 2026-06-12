import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../models/inventory_item.dart';
import '../models/inventory_movement.dart';
import '../models/product.dart';
import '../states/inventory_item_provider.dart';
import '../states/inventory_movement_provider.dart';
import '../states/product_provider.dart';
import 'dashboard_screen.dart';
import 'inventory_movement_screen.dart';
import 'inventory_screen.dart';
import 'low_stock_screen.dart';
import 'product_screen.dart';
import 'report_screen.dart';
import 'warehouse_screen.dart';

class AnalyticsDashboardPage extends ConsumerWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final inventoryItems = ref.watch(inventoryItemsProvider);
    final movements = ref.watch(inventoryMovementsProvider);

    // Prepare data for charts
    final categoryData = _prepareCategoryData(products, inventoryItems);
    final movementData = _prepareMovementData(movements);
    final valueByWarehouseData = _prepareWarehouseValueData(
      products,
      inventoryItems,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Inventory by Category Chart
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inventory by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: _buildInventoryByCategoryChart(categoryData),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Inventory Movement Trends
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inventory Movement Trends',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: _buildMovementTrendsChart(movementData),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Inventory Value by Warehouse
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inventory Value by Warehouse',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: _buildValueByWarehouseChart(valueByWarehouseData),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryByCategoryChart(Map<String, double> categoryData) {
    // Placeholder for chart implementation
    // In a real implementation, you would use a charting library like fl_chart
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final entry in categoryData.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    color: _getCategoryColor(entry.key),
                  ),
                  const SizedBox(width: 12),
                  Text(entry.key),
                  const Spacer(),
                  Text('\$${entry.value.toStringAsFixed(2)}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMovementTrendsChart(List<Map<String, dynamic>> movementData) {
    // Placeholder for chart implementation
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final entry in movementData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Text(entry['date'] as String),
                  const Spacer(),
                  Text('In: ${entry['in']}'),
                  const SizedBox(width: 12),
                  Text('Out: ${entry['out']}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildValueByWarehouseChart(List<Map<String, dynamic>> warehouseData) {
    // Placeholder for chart implementation
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final entry in warehouseData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Text(entry['warehouse'] as String),
                  const Spacer(),
                  Text('\$${(entry['value'] as double).toStringAsFixed(2)}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Map<String, double> _prepareCategoryData(
    List<Product> products,
    List<InventoryItem> inventoryItems,
  ) {
    final Map<String, double> result = {};

    // Calculate value by category
    for (final item in inventoryItems) {
      final product = products.firstWhere(
        (p) => p.id == item.productId,
        orElse: () => Product(
          id: '',
          name: '',
          sku: '',
          category: 'Uncategorized',
          price: 0,
        ),
      );

      final category = product.category.isEmpty
          ? 'Uncategorized'
          : product.category;
      final value = product.price * item.currentQuantity;

      if (result.containsKey(category)) {
        result[category] = result[category]! + value;
      } else {
        result[category] = value;
      }
    }

    return result;
  }

  List<Map<String, dynamic>> _prepareMovementData(
    List<InventoryMovement> movements,
  ) {
    // Group movements by date and calculate in/out quantities
    final Map<String, Map<String, dynamic>> result = {};

    // Get the last 7 days
    final DateTime endDate = DateTime.now();
    final DateTime startDate = endDate.subtract(const Duration(days: 6));

    // Initialize result with dates
    for (int i = 0; i <= 6; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      result[dateStr] = {'date': dateStr, 'in': 0, 'out': 0};
    }

    // Calculate in/out for each date
    for (final movement in movements) {
      final dateStr = DateFormat('yyyy-MM-dd').format(movement.date);
      if (result.containsKey(dateStr)) {
        if (movement.type == MovementType.purchase ||
            (movement.type == MovementType.adjustment &&
                movement.quantity > 0)) {
          result[dateStr]!['in'] =
              (result[dateStr]!['in'] as int) + movement.quantity;
        } else if (movement.type == MovementType.sale ||
            (movement.type == MovementType.adjustment &&
                movement.quantity < 0)) {
          result[dateStr]!['out'] =
              (result[dateStr]!['out'] as int) + movement.quantity.abs();
        }
      }
    }

    return result.values.toList()
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
  }

  List<Map<String, dynamic>> _prepareWarehouseValueData(
    List<Product> products,
    List<InventoryItem> inventoryItems,
  ) {
    // Calculate inventory value by warehouse
    final Map<String, Map<String, dynamic>> result = {};

    // Initialize with warehouse data
    final warehouseNames = <String, String>{};
    for (final item in inventoryItems) {
      if (!warehouseNames.containsKey(item.warehouseId)) {
        final warehouseIdParts = item.warehouseId.split('-');
        warehouseNames[item.warehouseId] = warehouseIdParts.isNotEmpty
            ? warehouseIdParts.first
            : item.warehouseId;
      }

      if (!result.containsKey(item.warehouseId)) {
        result[item.warehouseId] = {
          'warehouse': warehouseNames[item.warehouseId],
          'value': 0.0,
        };
      }
    }

    // Calculate value for each warehouse
    for (final item in inventoryItems) {
      final product = products.firstWhere(
        (p) => p.id == item.productId,
        orElse: () =>
            Product(id: '', name: '', sku: '', category: '', price: 0),
      );

      final value = product.price * item.currentQuantity;
      result[item.warehouseId]!['value'] =
          (result[item.warehouseId]!['value'] as double) + value;
    }

    return result.values.toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
  }

  Color _getCategoryColor(String category) {
    // Simple hash function to generate a color based on the category name
    final int hash = category.hashCode;
    final int r = ((hash & 0xFF0000) >> 16) % 200 + 55;
    final int g = ((hash & 0x00FF00) >> 8) % 200 + 55;
    final int b = (hash & 0x0000FF) % 200 + 55;
    return Color.fromRGBO(r, g, b, 1.0);
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ReportsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
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

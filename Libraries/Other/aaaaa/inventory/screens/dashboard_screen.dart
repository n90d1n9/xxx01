import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../models/inventory_movement.dart';
import '../models/product.dart';
import '../states/inventory_item_provider.dart';
import '../states/inventory_movement_provider.dart';
import '../states/low_stock_items_provider.dart';
import '../states/product_provider.dart';
import '../states/warehouse_provider.dart';
import 'inventory_movement_screen.dart';
import 'inventory_screen.dart';
import 'low_stock_screen.dart';
import 'product_screen.dart';
import 'stockopname_screen.dart';
import 'warehouse_screen.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final inventoryItems = ref.watch(inventoryItemsProvider);
    final warehouses = ref.watch(warehousesProvider);
    final lowStockItems = ref.watch(lowStockItemsProvider);
    final movements = ref.watch(inventoryMovementsProvider);

    // Calculate total inventory value
    double totalInventoryValue = 0;
    for (final item in inventoryItems) {
      final product = products.firstWhere(
        (p) => p.id == item.productId,
        orElse: () =>
            Product(id: '', name: '', sku: '', category: '', price: 0),
      );
      totalInventoryValue += product.price * item.currentQuantity;
    }

    // Get recent movements (last 5)
    final recentMovements = [...movements];
    recentMovements.sort((a, b) => b.date.compareTo(a.date));
    final last5Movements = recentMovements.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildInfoCard(
                  'Total Products',
                  products.length.toString(),
                  Icons.category,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildInfoCard(
                  'Total Warehouses',
                  warehouses.length.toString(),
                  Icons.warehouse,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildInfoCard(
                  'Low Stock Items',
                  lowStockItems.length.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildInfoCard(
                  'Inventory Value',
                  '\$${totalInventoryValue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Inventory Movements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Reference')),
                    ],
                    rows: last5Movements.map((movement) {
                      final product = products.firstWhere(
                        (p) => p.id == movement.productId,
                        orElse: () => Product(
                          id: '',
                          name: 'Unknown',
                          sku: '',
                          category: '',
                          price: 0,
                        ),
                      );

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              DateFormat('yyyy-MM-dd').format(movement.date),
                            ),
                          ),
                          DataCell(Text(product.name)),
                          DataCell(Text(_getMovementTypeText(movement.type))),
                          DataCell(Text(movement.quantity.toString())),
                          DataCell(Text(movement.reference)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(icon, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMovementTypeText(MovementType type) {
    switch (type) {
      case MovementType.purchase:
        return 'Purchase';
      case MovementType.sale:
        return 'Sale';
      case MovementType.transfer:
        return 'Transfer';
      case MovementType.adjustment:
        return 'Adjustment';
      case MovementType.stockOpname:
        return 'Stock Opname';
      default:
        return 'Unknown';
    }
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Inventory'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
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
              Navigator.push(
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WarehousePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Stock Opname'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StockOpnamePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Inventory Movements'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
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
              Navigator.push(
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

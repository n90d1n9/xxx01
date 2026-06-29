import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../states/inventory_provider.dart';
import '../states/order_provicer.dart';
import 'inventory_screen.dart';
import 'order_screen.dart';
import 'recipe_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final pendingOrders =
        ref
            .watch(orderProvider)
            .where(
              (order) =>
                  order.status == OrderStatus.pending ||
                  order.status == OrderStatus.processing,
            )
            .toList();
    final lowStockItems =
        ref.read(inventoryProvider.notifier).getLowStockItems();
    final expiringItems =
        ref.read(inventoryProvider.notifier).getExpiringItems();

    // Calculate today's sales
    final todaySales = ref
        .read(orderProvider.notifier)
        .getTotalSalesForDay(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Kitchen Dashboard')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Text(
                'Kitchen Management',
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
                  MaterialPageRoute(
                    builder: (context) => const InventoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Recipes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecipeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderScreen()),
                );
              },
            ),
            /* ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Staff'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StaffScreen()),
                );
              },
            ), */
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Today\'s Sales',
                      '\$${todaySales.toStringAsFixed(2)}',
                      Colors.green,
                      Icons.monetization_on,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Pending Orders',
                      pendingOrders.length.toString(),
                      Colors.orange,
                      Icons.receipt_long,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Low Stock Items',
                      lowStockItems.length.toString(),
                      Colors.red,
                      Icons.warning,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Pending Orders Section
              const Text(
                'Pending Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (pendingOrders.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No pending orders'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      pendingOrders.length > 3 ? 3 : pendingOrders.length,
                  itemBuilder: (context, index) {
                    final order = pendingOrders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          'Order #${order.id} - ${order.customerName}',
                        ),
                        subtitle: Text(
                          '${order.items.length} items - \$${order.totalAmount.toStringAsFixed(2)}',
                        ),
                        trailing: Chip(
                          label: Text(
                            order.status.toString().split('.').last,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor:
                              order.status == OrderStatus.pending
                                  ? Colors.orange
                                  : Colors.blue,
                        ),
                        onTap: () {
                          // Navigate to order details
                        },
                      ),
                    );
                  },
                ),

              if (pendingOrders.length > 3)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderScreen(),
                      ),
                    );
                  },
                  child: const Text('View all orders'),
                ),

              const SizedBox(height: 24),

              // Inventory Alerts Section
              const Text(
                'Inventory Alerts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Low Stock Items:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (lowStockItems.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No low stock items'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lowStockItems.length,
                      itemBuilder: (context, index) {
                        final item = lowStockItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                              'Only ${item.quantity} ${item.unit} left',
                            ),
                            trailing: const Icon(
                              Icons.warning,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 16),

                  const Text(
                    'Expiring Soon:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (expiringItems.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No items expiring soon'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: expiringItems.length,
                      itemBuilder: (context, index) {
                        final item = expiringItems[index];
                        final daysUntilExpiry =
                            item.expiryDate.difference(DateTime.now()).inDays;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                              daysUntilExpiry > 0
                                  ? 'Expires in $daysUntilExpiry days'
                                  : 'Expired!',
                            ),
                            trailing: Icon(
                              Icons.access_time,
                              color:
                                  daysUntilExpiry <= 0
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showActionMenu(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.inventory_2),
                title: const Text('Add Inventory Item'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InventoryScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Add Recipe'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecipeScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt),
                title: const Text('Create Order'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

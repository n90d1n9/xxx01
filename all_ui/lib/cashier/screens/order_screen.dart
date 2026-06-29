import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/cashier_provider.dart';
import '../widgets/order_card.dart';
import '../widgets/order_stats.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(recentOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recent Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrdersStats(orders: orders),
            const SizedBox(height: 24),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  orders.isEmpty
                      ? const Center(child: Text('No orders yet'))
                      : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return OrderCard(
                            order: order,
                            onStatusChanged: (status) {
                              ref
                                  .read(recentOrdersProvider.notifier)
                                  .updateOrderStatus(order.id, status);
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

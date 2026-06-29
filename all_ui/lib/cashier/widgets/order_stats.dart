import 'package:flutter/material.dart';

import '../models/order.dart';
import 'stat_card.dart';

class OrdersStats extends StatelessWidget {
  final List<Order> orders;

  const OrdersStats({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    int totalOrders = orders.length;
    double totalRevenue = orders.fold(0, (sum, order) => sum + order.total);
    double averageOrder = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    return Row(
      children: [
        StatCard(
          title: 'Total Orders',
          value: '$totalOrders',
          icon: Icons.receipt,
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        StatCard(
          title: 'Revenue',
          value: '\$${totalRevenue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        const SizedBox(width: 16),
        StatCard(
          title: 'Avg. Order',
          value: '\$${averageOrder.toStringAsFixed(2)}',
          icon: Icons.bar_chart,
          color: Colors.orange,
        ),
      ],
    );
  }
}

// Dynamic content provider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_content.dart';
import '../models/stat_card.dart';

// Current page provider
final currentPageProvider = StateProvider<String>((ref) => 'Dashboard');

final dashboardContentProvider = Provider((ref) {
  final currentPage = ref.watch(currentPageProvider);

  switch (currentPage) {
    case 'Dashboard':
      return DashboardContent(
        title: 'Dashboard Overview',
        stats: [
          StatCard(
            title: 'Total Users',
            value: '3,456',
            icon: Icons.people,
            color: Colors.blue,
          ),
          StatCard(
            title: 'Revenue',
            value: '\$23,489',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
          StatCard(
            title: 'Tasks',
            value: '67',
            icon: Icons.task_alt,
            color: Colors.orange,
          ),
          StatCard(
            title: 'Messages',
            value: '24',
            icon: Icons.message,
            color: Colors.purple,
          ),
        ],
      );
    case 'Analytics':
      return DashboardContent(
        title: 'Analytics',
        stats: [
          StatCard(
            title: 'Page Views',
            value: '12,456',
            icon: Icons.visibility,
            color: Colors.indigo,
          ),
          StatCard(
            title: 'Bounce Rate',
            value: '32%',
            icon: Icons.trending_down,
            color: Colors.red,
          ),
          StatCard(
            title: 'Avg. Time',
            value: '2m 34s',
            icon: Icons.timer,
            color: Colors.teal,
          ),
          StatCard(
            title: 'Conversions',
            value: '534',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ],
      );
    case 'Orders':
      return DashboardContent(
        title: 'Orders Management',
        stats: [
          StatCard(
            title: 'New Orders',
            value: '34',
            icon: Icons.shopping_cart,
            color: Colors.amber,
          ),
          StatCard(
            title: 'Processing',
            value: '12',
            icon: Icons.hourglass_bottom,
            color: Colors.blue,
          ),
          StatCard(
            title: 'Shipped',
            value: '78',
            icon: Icons.local_shipping,
            color: Colors.green,
          ),
          StatCard(
            title: 'Returned',
            value: '5',
            icon: Icons.assignment_return,
            color: Colors.red,
          ),
        ],
      );
    default:
      return DashboardContent(
        title: currentPage,
        stats: [
          StatCard(
            title: 'Sample Stat',
            value: '100',
            icon: Icons.star,
            color: Colors.amber,
          ),
          StatCard(
            title: 'Sample Stat',
            value: '200',
            icon: Icons.star,
            color: Colors.blue,
          ),
          StatCard(
            title: 'Sample Stat',
            value: '300',
            icon: Icons.star,
            color: Colors.green,
          ),
          StatCard(
            title: 'Sample Stat',
            value: '400',
            icon: Icons.star,
            color: Colors.purple,
          ),
        ],
      );
  }
});

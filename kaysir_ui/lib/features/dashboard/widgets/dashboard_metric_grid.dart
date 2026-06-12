import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ky_admin/widgets/admin_metric_grid.dart';

import '../models/dashboard_data.dart';

class DashboardMetricGrid extends StatelessWidget {
  const DashboardMetricGrid({super.key, required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final compactNumber = NumberFormat.compact();

    return AdminMetricGrid(
      metrics: [
        AdminMetricGridItem(
          title: 'Transactions',
          value: compactNumber.format(data.photos),
          change: data.photosChange,
          accentColor: colorScheme.primary,
          icon: Icons.receipt_long_outlined,
        ),
        AdminMetricGridItem(
          title: 'Items sold',
          value: compactNumber.format(data.video),
          change: data.videoChange,
          accentColor: const Color(0xFF2E7D32),
          icon: Icons.inventory_2_outlined,
        ),
        AdminMetricGridItem(
          title: 'Open orders',
          value: compactNumber.format(data.event),
          change: data.eventChange,
          accentColor: const Color(0xFFB26A00),
          icon: Icons.shopping_bag_outlined,
        ),
        AdminMetricGridItem(
          title: 'Growth',
          value: '${data.growth.toStringAsFixed(1)}%',
          change: data.growthChange,
          accentColor: const Color(0xFF6A4FB3),
          icon: Icons.show_chart,
        ),
      ],
    );
  }
}

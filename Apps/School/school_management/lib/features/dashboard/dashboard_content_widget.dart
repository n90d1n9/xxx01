import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytic_screen.dart';

import '../admin/states/dashboard_provider.dart';
import 'chart_section.dart';
import '../../app/widgets/default_section.dart';
import '../../app/widgets/recent_activity.dart';
import 'stat/stat_card_widget.dart';
import 'stat/stat_grid.dart';

class DashboardContentWidget extends ConsumerWidget {
  const DashboardContentWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(dashboardContentProvider);
    final currentPage = ref.watch(currentPageProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Stats cards grid
          StatGrid(content: content),

          const SizedBox(height: 24),

          // Charts and tables based on current page
          if (currentPage == 'Dashboard') ...[
            const ChartSection(),
            const SizedBox(height: 24),
            const RecenTActivity(),
          ],

          if (currentPage == 'Analytics') ...[const AnalyticScreen()],

          // if (currentPage == 'Orders') ...[const OrderScreen()],

          // Default content for other pages
          if (currentPage != 'Dashboard' &&
              currentPage != 'Analytics' &&
              currentPage != 'Orders') ...[
            DefaultSection(),
          ],
        ],
      ),
    );
  }
}

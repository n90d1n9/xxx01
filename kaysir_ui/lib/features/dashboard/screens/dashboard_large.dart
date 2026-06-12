import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ky_admin/widgets/admin_page_scaffold.dart';

import '../states/dashboard_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_metric_grid.dart';
import '../widgets/dashboard_panels.dart';
import '../widgets/dashboard_state_views.dart';
import '../widgets/top_products_list.dart';

class DashboardLargeScreen extends StatelessWidget {
  const DashboardLargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardOverview();
  }
}

class DashboardOverview extends ConsumerWidget {
  const DashboardOverview({
    super.key,
    this.padding = const EdgeInsets.all(24),
    this.compact = false,
  });

  final EdgeInsetsGeometry padding;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardDataProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);

    return dashboardData.when(
      skipLoadingOnReload: true,
      data:
          (data) => Stack(
            children: [
              AdminPageScaffold(
                padding: padding,
                header: DashboardHeader(
                  selectedFilter: selectedFilter,
                  compact: compact,
                  onFilterChanged: (value) {
                    ref.read(selectedFilterProvider.notifier).state = value;
                  },
                ),
                children: [
                  DashboardMetricGrid(data: data),
                  DashboardPanels(data: data, selectedFilter: selectedFilter),
                  TopProductsList(products: data.topProducts),
                ],
              ),
              if (dashboardData.isLoading) const DashboardUpdatingIndicator(),
            ],
          ),
      loading: () => const LoadingDashboard(),
      error: (error, stackTrace) => ErrorDashboard(error: error),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_item.dart';
import '../states/dashboard_provider.dart';
import '../widgets/chart_widget.dart';
import '../widgets/stat_card.dart';
import 'dashboard_builder.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardItems = ref.watch(dashboardItemsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modern Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardBuilder(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () => ref.read(dashboardItemsProvider.notifier).refreshData(),
          ),
        ],
      ),
      body:
          dashboardItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dashboard_customize,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your dashboard is empty',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create Dashboard'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardBuilder(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: () async {
                  await ref.read(dashboardItemsProvider.notifier).refreshData();
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 500,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: dashboardItems.length,
                  itemBuilder: (context, index) {
                    final item = dashboardItems[index];
                    return _buildDashboardItem(context, item, isDarkMode);
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DashboardBuilder()),
          );
        },
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    DashboardItem item,
    bool isDarkMode,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    // Handle menu actions
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildItemContent(item, isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemContent(DashboardItem item, bool isDarkMode) {
    switch (item.type) {
      case DashboardItemType.lineChart:
        return ChartWidget(
          chartType: ChartType.line,
          chartData: item.data,
          isDarkMode: isDarkMode,
        );
      case DashboardItemType.barChart:
        return ChartWidget(
          chartType: ChartType.bar,
          chartData: item.data,
          isDarkMode: isDarkMode,
        );
      case DashboardItemType.pieChart:
        return ChartWidget(
          chartType: ChartType.pie,
          chartData: item.data,
          isDarkMode: isDarkMode,
        );
      case DashboardItemType.statCard:
        return StatCard(data: item.data);
      default:
        return const Center(child: Text('Unknown item type'));
    }
  }
}

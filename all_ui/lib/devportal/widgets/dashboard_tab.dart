import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alert.dart';
import '../models/alert_model.dart';
import '../models/enums.dart';
import '../states/provider.dart';
import 'alert_card.dart';
import 'status_badge.dart';

class DashboardTab extends ConsumerWidget {
  final bool isDarkMode;

  const DashboardTab({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageData = ref.watch(usageDataProvider);
    final alerts = ref.watch(alertsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          // Quick Stats Row
          Row(
            children: [
              _buildStatCard(
                'Total API Calls',
                '42,950',
                Icons.compare_arrows,
                Colors.blue,
                '+15% this month',
                isDarkMode,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Active Projects',
                '3',
                Icons.folder,
                Colors.green,
                '2 updates pending',
                isDarkMode,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'API Keys',
                '3',
                Icons.vpn_key,
                Colors.orange,
                '1 expiring soon',
                isDarkMode,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'API Health',
                '99.9%',
                Icons.health_and_safety,
                Colors.purple,
                'All systems operational',
                isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // API Usage Chart and Alerts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // API Usage Chart
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2D2D42) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API Usage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last 30 days',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 250,
                        child: usageData.when(
                          data:
                              (data) => BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 20000,
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget:
                                            (value, meta) => Text(
                                              '${value ~/ 1000}k',
                                              style: TextStyle(
                                                color:
                                                    isDarkMode
                                                        ? Colors.white60
                                                        : Colors.black54,
                                                fontSize: 12,
                                              ),
                                            ),
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          if (value >= 0 &&
                                              value < data.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Text(
                                                data[value.toInt()].name!,
                                                style: TextStyle(
                                                  color:
                                                      isDarkMode
                                                          ? Colors.white60
                                                          : Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups:
                                      data.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final item = entry.value;
                                        return BarChartGroupData(
                                          x: index,
                                          barRods: [
                                            BarChartRodData(
                                              toY: item.calls.toDouble(),
                                              color: _getApiColor(index),
                                              width: 20,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(4),
                                                    topRight: Radius.circular(
                                                      4,
                                                    ),
                                                  ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              ),
                          loading:
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          error:
                              (_, __) => const Center(
                                child: Text('Failed to load API usage data'),
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        children: usageData.maybeWhen(
                          data:
                              (data) =>
                                  data.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: _getApiColor(index),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          item.name!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.growth > 0
                                              ? '+${item.growth}%'
                                              : '${item.growth}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                item.growth > 0
                                                    ? Colors.green
                                                    : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                          orElse: () => [],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Alerts Panel
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2D2D42) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Alerts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      alerts.when(
                        data:
                            (alertList) => Column(
                              children:
                                  alertList.map((alert) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: AlertCard(
                                        alert: Alert(
                                          id: alert.id,
                                          title: 'title',
                                          severity: AlertSeverity.error,
                                        ),
                                        isDarkMode: isDarkMode,
                                      ),
                                    );
                                  }).toList(),
                            ),
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (_, __) => const Center(
                              child: Text('Failed to load alerts'),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Projects
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D2D42) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Projects',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(selectedTabProvider.notifier).state = 1;
                      },
                      child: const Text('View All Projects'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final projects = ref.watch(projectsProvider);
                    return projects.when(
                      data:
                          (projectList) => Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                          isDarkMode
                                              ? Colors.white24
                                              : Colors.black12,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                children: [
                                  _buildTableHeader('Project Name', isDarkMode),
                                  _buildTableHeader('Status', isDarkMode),
                                  _buildTableHeader('Last Updated', isDarkMode),
                                  _buildTableHeader('Actions', isDarkMode),
                                ],
                              ),
                              ...projectList.map((project) {
                                return TableRow(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color:
                                            isDarkMode
                                                ? Colors.white12
                                                : Colors.black12,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  children: [
                                    _buildTableCell(
                                      Text(project.name),
                                      isDarkMode,
                                    ),
                                    _buildTableCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: StatusBadge(
                                          status: ProjectStatus.error,
                                          isDarkMode: isDarkMode,
                                        ),
                                      ),
                                      isDarkMode,
                                      alignment: Alignment.centerLeft,
                                    ),
                                    _buildTableCell(
                                      Text(
                                        'Updated ${_timeAgo(project.lastUpdated!)}',
                                      ),
                                      isDarkMode,
                                      textColor:
                                          isDarkMode
                                              ? Colors.white60
                                              : Colors.black54,
                                    ),
                                    _buildTableCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit_outlined,
                                              size: 20,
                                              color:
                                                  isDarkMode
                                                      ? Colors.white60
                                                      : Colors.black54,
                                            ),
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.bar_chart_outlined,
                                              size: 20,
                                              color:
                                                  isDarkMode
                                                      ? Colors.white60
                                                      : Colors.black54,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                      isDarkMode,
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (_, __) => const Center(
                            child: Text('Failed to load projects'),
                          ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2D2D42) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Icon(
                  Icons.more_horiz,
                  color: isDarkMode ? Colors.white60 : Colors.black45,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white60 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTableCell(
    Widget content,
    bool isDarkMode, {
    Alignment alignment = Alignment.centerLeft,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: alignment,
      child: content /* is String
              ? Text(
                content,
                style: TextStyle(
                  color:
                      textColor ?? (isDarkMode ? Colors.white : Colors.black87),
                ),
              )
              : content, */,
    );
  }

  Color _getApiColor(int index) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }

  String _timeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours ago';
    } else {
      return '${duration.inDays} days ago';
    }
  }
}

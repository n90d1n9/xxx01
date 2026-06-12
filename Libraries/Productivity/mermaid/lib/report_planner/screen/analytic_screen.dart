// Analytics Screen
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../model/analytics_data.dart';
import '../model/category.dart';
import '../model/daily_stats.dart';
import '../state/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Charts'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(analytics),
          _buildChartsTab(analytics),
          _buildReportsTab(analytics),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AnalyticsData analytics) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'Total Events',
          analytics.totalEvents.toString(),
          Icons.event_note,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Completed',
                analytics.completedEvents.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Upcoming',
                analytics.upcomingEvents.toString(),
                Icons.schedule,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Overdue',
                analytics.overdueEvents.toString(),
                Icons.warning,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completion Rate',
                '${analytics.completionRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildInsightsCard('Insights', [
          'Most productive day: ${analytics.mostProductiveDay}',
          'Most active category: ${analytics.mostActiveCategory}',
          'Total hours scheduled: ${analytics.totalHoursScheduled}h',
        ]),
      ],
    );
  }

  Widget _buildChartsTab(AnalyticsData analytics) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildChartCard(
          'Category Distribution',
          _buildPieChart(analytics.categoryDistribution),
          350,
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Weekly Activity',
          _buildWeeklyBarChart(analytics.weeklyStats),
          300,
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Completion Trend (30 Days)',
          _buildLineChart(analytics.monthlyStats),
          300,
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Priority Distribution',
          _buildPriorityChart(analytics.priorityDistribution),
          250,
        ),
      ],
    );
  }

  Widget _buildReportsTab(AnalyticsData analytics) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportSection(
          'Time by Category',
          analytics.timeByCategory.entries.map((e) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getCategoryColor(e.key),
                child: Text(
                  e.key[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(e.key),
              trailing: Text(
                '${e.value.toStringAsFixed(1)}h',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildReportSection(
          'Weekly Summary',
          analytics.weeklyStats.map((day) {
            return ListTile(
              leading: Text(
                DateFormat('EEE\nd').format(day.date),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              title: Text('${day.totalEvents} events'),
              subtitle: Text('${day.completedEvents} completed'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: day.totalEvents > 0
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${day.hoursScheduled.toStringAsFixed(1)}h',
                  style: TextStyle(
                    color: day.totalEvents > 0 ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(String title, List<String> insights) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    insight,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart, double height) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(height: height, child: chart),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final sections = data.entries.map((entry) {
      final color = _getCategoryColor(entry.key);
      final percentage =
          (entry.value / data.values.reduce((a, b) => a + b)) * 100;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: data.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(entry.key),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.key} (${entry.value})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWeeklyBarChart(List<DailyStats> stats) {
    if (stats.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            stats
                .map((s) => s.totalEvents)
                .reduce((a, b) => a > b ? a : b)
                .toDouble() +
            2,
        barGroups: stats.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.totalEvents.toDouble(),
                color: Theme.of(context).colorScheme.primary,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < stats.length) {
                  return Text(
                    DateFormat('E').format(stats[value.toInt()].date),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildLineChart(List<DailyStats> stats) {
    if (stats.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final spots = stats.asMap().entries.map((entry) {
      final completionRate = entry.value.totalEvents > 0
          ? (entry.value.completedEvents / entry.value.totalEvents) * 100
          : 0.0;
      return FlSpot(entry.key.toDouble(), completionRate);
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < stats.length) {
                  return Text(
                    DateFormat('d').format(stats[value.toInt()].date),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
      ),
    );
  }

  Widget _buildPriorityChart(Map<String, int> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final colors = {
      'low': Colors.green,
      'medium': Colors.orange,
      'high': Colors.red,
      'urgent': Colors.purple,
    };

    return Row(
      children: data.entries.map((entry) {
        final total = data.values.reduce((a, b) => a + b);
        final percentage = (entry.value / total) * 100;

        return Expanded(
          flex: entry.value,
          child: Container(
            height: 150,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: colors[entry.key] ?? Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  entry.key.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReportSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final cat = categories.firstWhere(
      (c) => c.name == category,
      orElse: () => categories.last,
    );
    return cat.color;
  }
}

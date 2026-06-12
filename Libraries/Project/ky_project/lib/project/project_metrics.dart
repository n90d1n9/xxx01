import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// MODELS
class ProjectMetrics {
  final List<DailyProgress> progressData;
  final List<BurndownData> burndownData;
  final List<WorkloadData> workloadData;
  final List<VelocityData> velocityData;

  ProjectMetrics({
    required this.progressData,
    required this.burndownData,
    required this.workloadData,
    required this.velocityData,
  });
}

class DailyProgress {
  final DateTime date;
  final double completedPercentage;

  DailyProgress({required this.date, required this.completedPercentage});
}

class BurndownData {
  final DateTime date;
  final int remainingTasks;
  final int idealBurndown;

  BurndownData({
    required this.date,
    required this.remainingTasks,
    required this.idealBurndown,
  });
}

class WorkloadData {
  final String teamMember;
  final int assignedTasks;
  final int completedTasks;

  WorkloadData({
    required this.teamMember,
    required this.assignedTasks,
    required this.completedTasks,
  });
}

class VelocityData {
  final String sprint;
  final double plannedPoints;
  final double completedPoints;

  VelocityData({
    required this.sprint,
    required this.plannedPoints,
    required this.completedPoints,
  });
}

// PROVIDERS
final projectMetricsProvider = StateProvider<ProjectMetrics>((ref) {
  // Mock data
  return ProjectMetrics(
    progressData: List.generate(
      14,
      (index) => DailyProgress(
        date: DateTime.now().subtract(Duration(days: 13 - index)),
        completedPercentage: (index + 1) * 5.0 > 70 ? 70 : (index + 1) * 5.0,
      ),
    ),
    burndownData: List.generate(
      14,
      (index) => BurndownData(
        date: DateTime.now().subtract(Duration(days: 13 - index)),
        remainingTasks: 100 - (index * 7),
        idealBurndown: (100 - (index * (100 / 13))).round(),
      ),
    ),
    workloadData: [
      WorkloadData(teamMember: "Alex", assignedTasks: 12, completedTasks: 8),
      WorkloadData(teamMember: "Blake", assignedTasks: 15, completedTasks: 10),
      WorkloadData(teamMember: "Casey", assignedTasks: 9, completedTasks: 7),
      WorkloadData(teamMember: "Dana", assignedTasks: 14, completedTasks: 9),
      WorkloadData(teamMember: "Jamie", assignedTasks: 11, completedTasks: 5),
    ],
    velocityData: [
      VelocityData(sprint: "Sprint 1", plannedPoints: 45, completedPoints: 35),
      VelocityData(sprint: "Sprint 2", plannedPoints: 50, completedPoints: 48),
      VelocityData(sprint: "Sprint 3", plannedPoints: 60, completedPoints: 52),
      VelocityData(sprint: "Sprint 4", plannedPoints: 55, completedPoints: 58),
      VelocityData(sprint: "Sprint 5", plannedPoints: 65, completedPoints: 60),
    ],
  );
});

// UI COMPONENTS
class ProjectDashboard extends ConsumerWidget {
  const ProjectDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final metrics = ref.watch(projectMetricsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              backgroundColor: theme.scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Project Analytics',
                  style: TextStyle(
                    color: theme.textTheme.headlineSmall?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: false,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded),
                  onPressed: () {},
                  tooltip: 'Filter',
                ),
                IconButton(
                  icon: const Icon(Icons.date_range_rounded),
                  onPressed: () {},
                  tooltip: 'Date Range',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () {},
                  tooltip: 'Refresh',
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    MetricsSummaryCards(),
                    const SizedBox(height: 24),
                    ProgressChart(progressData: metrics.progressData),
                    const SizedBox(height: 24),
                    BurndownChart(burndownData: metrics.burndownData),
                    const SizedBox(height: 24),
                    WorkloadDistributionChart(
                      workloadData: metrics.workloadData,
                    ),
                    const SizedBox(height: 24),
                    VelocityChart(velocityData: metrics.velocityData),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }
}

class MetricsSummaryCards extends ConsumerWidget {
  const MetricsSummaryCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard(
          context,
          'Project Completion',
          '70%',
          Icons.check_circle_outline_rounded,
          Colors.green,
        ),
        _buildMetricCard(
          context,
          'Tasks Remaining',
          '23',
          Icons.list_alt_rounded,
          Colors.amber,
        ),
        _buildMetricCard(
          context,
          'Team Velocity',
          '60 pts',
          Icons.speed_rounded,
          Colors.blue,
        ),
        _buildMetricCard(
          context,
          'Days Left',
          '8',
          Icons.calendar_today_rounded,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressChart extends StatelessWidget {
  final List<DailyProgress> progressData;

  const ProgressChart({Key? key, required this.progressData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Progress Trend',
      chart: AspectRatio(
        aspectRatio: 1.7,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value % 3 != 0) return const Text('');
                    final date = progressData[value.toInt()].date;
                    return Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
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
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  progressData.length,
                  (index) => FlSpot(
                    index.toDouble(),
                    progressData[index].completedPercentage,
                  ),
                ),
                isCurved: true,
                color: Colors.green,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.green.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BurndownChart extends StatelessWidget {
  final List<BurndownData> burndownData;

  const BurndownChart({Key? key, required this.burndownData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Burndown Chart',
      chart: AspectRatio(
        aspectRatio: 1.7,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value % 3 != 0) return const Text('');
                    final date = burndownData[value.toInt()].date;
                    return Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              // Actual Burndown
              LineChartBarData(
                spots: List.generate(
                  burndownData.length,
                  (index) => FlSpot(
                    index.toDouble(),
                    burndownData[index].remainingTasks.toDouble(),
                  ),
                ),
                isCurved: true,
                color: Colors.red,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
              ),
              // Ideal Burndown
              LineChartBarData(
                spots: List.generate(
                  burndownData.length,
                  (index) => FlSpot(
                    index.toDouble(),
                    burndownData[index].idealBurndown.toDouble(),
                  ),
                ),
                isCurved: false,
                color: Colors.grey,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                dashArray: [5, 5],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkloadDistributionChart extends StatelessWidget {
  final List<WorkloadData> workloadData;

  const WorkloadDistributionChart({Key? key, required this.workloadData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Workload Distribution',
      chart: AspectRatio(
        aspectRatio: 1.5,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY:
                workloadData
                    .map((e) => e.assignedTasks.toDouble())
                    .reduce((a, b) => a > b ? a : b) *
                1.2,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value < 0 || value >= workloadData.length)
                      return const Text('');
                    return Text(
                      workloadData[value.toInt()].teamMember,
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: false),
            barGroups: List.generate(
              workloadData.length,
              (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: workloadData[index].assignedTasks.toDouble(),
                    color: Colors.blue.withValues(alpha: 0.7),
                    width: 16,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    rodStackItems: [
                      BarChartRodStackItem(
                        0,
                        workloadData[index].completedTasks.toDouble(),
                        Colors.green.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      legend: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.blue.withValues(alpha: 0.7), 'Assigned'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.green.withValues(alpha: 0.7), 'Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class VelocityChart extends StatelessWidget {
  final List<VelocityData> velocityData;

  const VelocityChart({Key? key, required this.velocityData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Team Velocity',
      chart: AspectRatio(
        aspectRatio: 1.5,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY:
                velocityData
                    .map((e) => e.plannedPoints)
                    .reduce((a, b) => a > b ? a : b) *
                1.2,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value < 0 || value >= velocityData.length)
                      return const Text('');
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        velocityData[value.toInt()].sprint,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: false),
            barGroups: List.generate(
              velocityData.length,
              (index) => BarChartGroupData(
                x: index,
                groupVertically: true,
                barRods: [
                  BarChartRodData(
                    toY: velocityData[index].plannedPoints,
                    color: Colors.blue.withValues(alpha: 0.5),
                    width: 22,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  BarChartRodData(
                    toY: velocityData[index].completedPoints,
                    color: Colors.blue,
                    width: 14,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      legend: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.blue.withValues(alpha: 0.5), 'Planned'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.blue, 'Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final Widget chart;
  final Widget? legend;

  const _ChartContainer({
    Key? key,
    required this.title,
    required this.chart,
    this.legend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'download',
                      child: Text('Download as PNG'),
                    ),
                    const PopupMenuItem(
                      value: 'details',
                      child: Text('View Details'),
                    ),
                    const PopupMenuItem(value: 'share', child: Text('Share')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            chart,
            if (legend != null) legend!,
          ],
        ),
      ),
    );
  }
}

// Main app
void main() {
  runApp(const ProviderScope(child: ProjectManagementApp()));
}

class ProjectManagementApp extends StatelessWidget {
  const ProjectManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Analytics',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const ProjectDashboard(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class HRMetric {
  final String title;
  final double value;
  final double previousValue;
  final String unit;
  final Color color;

  HRMetric({
    required this.title,
    required this.value,
    required this.previousValue,
    required this.unit,
    required this.color,
  });

  double get percentChange =>
      previousValue > 0 ? ((value - previousValue) / previousValue) * 100 : 0;

  bool get isPositive =>
      unit == '%' ? value > previousValue : percentChange > 0;
}

class ReportType {
  final String name;
  final String description;
  final IconData icon;

  ReportType({
    required this.name,
    required this.description,
    required this.icon,
  });
}

// Providers
final selectedPeriodProvider = StateProvider<String>((ref) => 'This Month');
final isLoadingProvider = StateProvider<bool>((ref) => false);

final hrMetricsProvider = Provider<List<HRMetric>>((ref) {
  final selectedPeriod = ref.watch(selectedPeriodProvider);

  // In a real app, you would fetch this data from an API based on the selected period
  return [
    HRMetric(
      title: 'Turnover Rate',
      value: selectedPeriod == 'This Month' ? 5.2 : 4.8,
      previousValue: 6.3,
      unit: '%',
      color: Colors.orange,
    ),
    HRMetric(
      title: 'Recruitment Efficiency',
      value: selectedPeriod == 'This Month' ? 82.5 : 79.0,
      previousValue: 75.8,
      unit: '%',
      color: Colors.blue,
    ),
    HRMetric(
      title: 'Employee Satisfaction',
      value: selectedPeriod == 'This Month' ? 4.2 : 4.0,
      previousValue: 3.9,
      unit: '/5',
      color: Colors.green,
    ),
    HRMetric(
      title: 'Avg. Time to Hire',
      value: selectedPeriod == 'This Month' ? 24 : 27,
      previousValue: 29,
      unit: ' days',
      color: Colors.purple,
    ),
  ];
});

final reportTypesProvider = Provider<List<ReportType>>((ref) {
  return [
    ReportType(
      name: 'Turnover Report',
      description: 'Employee turnover rates by department and time period',
      icon: Icons.people_alt_outlined,
    ),
    ReportType(
      name: 'Recruitment Report',
      description: 'Time to hire and hiring funnel conversion rates',
      icon: Icons.person_search_outlined,
    ),
    ReportType(
      name: 'Performance Report',
      description: 'Team and individual performance metrics',
      icon: Icons.assessment_outlined,
    ),
    ReportType(
      name: 'Training Report',
      description: 'Training completion rates and effectiveness',
      icon: Icons.school_outlined,
    ),
  ];
});

// Department performance chart data provider
final departmentPerformanceProvider = Provider<List<BarChartGroupData>>((ref) {
  return [
    makeBarGroup(0, 'Sales', 92, 86),
    makeBarGroup(1, 'Marketing', 78, 72),
    makeBarGroup(2, 'Engineering', 85, 82),
    makeBarGroup(3, 'HR', 88, 80),
    makeBarGroup(4, 'Finance', 90, 85),
  ];
});

BarChartGroupData makeBarGroup(
  int x,
  String department,
  double current,
  double previous,
) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: current,
        color: Colors.blue,
        width: 15,
        borderRadius: BorderRadius.circular(2),
      ),
      BarChartRodData(
        toY: previous,
        color: Colors.blueGrey,
        width: 15,
        borderRadius: BorderRadius.circular(2),
      ),
    ],
  );
}

// Monthly hiring data provider
final hiringTrendsProvider = Provider<List<FlSpot>>((ref) {
  return [
    FlSpot(0, 12),
    FlSpot(1, 10),
    FlSpot(2, 14),
    FlSpot(3, 19),
    FlSpot(4, 15),
    FlSpot(5, 25),
  ];
});

class HRDashboardScreen extends ConsumerWidget {
  const HRDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hrMetrics = ref.watch(hrMetricsProvider);
    final reportTypes = ref.watch(reportTypesProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final departmentPerformance = ref.watch(departmentPerformanceProvider);
    final hiringTrends = ref.watch(hiringTrendsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/women/44.jpg',
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(ref),
                    const SizedBox(height: 20),
                    _buildMetricsGrid(hrMetrics),
                    const SizedBox(height: 24),
                    _buildDepartmentPerformanceChart(
                      context,
                      departmentPerformance,
                    ),
                    const SizedBox(height: 24),
                    _buildHiringTrendsChart(context, hiringTrends),
                    const SizedBox(height: 24),
                    _buildReportSection(context, reportTypes, ref),
                  ],
                ),
              ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HR Analytics Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Last updated: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        DropdownButton<String>(
          value: selectedPeriod,
          items:
              ['This Month', 'Last Month', 'Last Quarter', 'Last Year']
                  .map(
                    (period) =>
                        DropdownMenuItem(value: period, child: Text(period)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(selectedPeriodProvider.notifier).state = value;
              ref.read(isLoadingProvider.notifier).state = true;

              // Simulate loading data
              Future.delayed(const Duration(milliseconds: 800), () {
                ref.read(isLoadingProvider.notifier).state = false;
              });
            }
          },
          underline: Container(height: 2, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(List<HRMetric> metrics) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      metric.title,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Icon(
                      metric.isPositive
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: metric.isPositive ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${metric.value}${metric.unit}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${metric.percentChange >= 0 ? '+' : ''}${metric.percentChange.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: metric.isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value:
                      metric.unit == '%'
                          ? metric.value / 100
                          : metric.value / 5,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(metric.color),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDepartmentPerformanceChart(
    BuildContext context,
    List<BarChartGroupData> departmentData,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Department Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.blue,
                      margin: const EdgeInsets.only(right: 4),
                    ),
                    Text('Current', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.blueGrey,
                      margin: const EdgeInsets.only(right: 4),
                    ),
                    Text('Previous', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      //tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String departmentName;
                        switch (group.x.toInt()) {
                          case 0:
                            departmentName = 'Sales';
                            break;
                          case 1:
                            departmentName = 'Marketing';
                            break;
                          case 2:
                            departmentName = 'Engineering';
                            break;
                          case 3:
                            departmentName = 'HR';
                            break;
                          case 4:
                            departmentName = 'Finance';
                            break;
                          default:
                            departmentName = '';
                        }
                        return BarTooltipItem(
                          '$departmentName\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${rod.toY.round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Sales';
                              break;
                            case 1:
                              text = 'Mktg';
                              break;
                            case 2:
                              text = 'Eng';
                              break;
                            case 3:
                              text = 'HR';
                              break;
                            case 4:
                              text = 'Fin';
                              break;
                            default:
                              text = '';
                          }
                          return SideTitleWidget(
                            meta: meta,
                            //axisSide: meta.axisSide,
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              '${value.toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.grey[200], strokeWidth: 1),
                  ),
                  barGroups: departmentData,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiringTrendsChart(
    BuildContext context,
    List<FlSpot> hiringData,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Hiring Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      //tooltipBgColor: Colors.blueAccent,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final month = _getMonthName(spot.x.toInt());
                          return LineTooltipItem(
                            '$month: ${spot.y.toStringAsFixed(0)} hires',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.grey[200], strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              _getMonthShortName(value.toInt()),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                      left: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  minX: 0,
                  maxX: 5,
                  minY: 0,
                  maxY: 30,
                  lineBarsData: [
                    LineChartBarData(
                      spots: hiringData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSection(
    BuildContext context,
    List<ReportType> reportTypes,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generate Reports',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemCount: reportTypes.length,
          itemBuilder: (context, index) {
            final report = reportTypes[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _showReportDialog(context, report, ref),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(report.icon, size: 32, color: Colors.blue),
                      const SizedBox(height: 12),
                      Text(
                        report.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showReportDialog(
    BuildContext context,
    ReportType report,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Generate ${report.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select parameters for your report:'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Time Period',
                    border: OutlineInputBorder(),
                  ),
                  value: 'Last 30 days',
                  items:
                      [
                            'Last 30 days',
                            'Last Quarter',
                            'Last Year',
                            'Year to Date',
                          ]
                          .map(
                            (period) => DropdownMenuItem(
                              value: period,
                              child: Text(period),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  value: 'All Departments',
                  items:
                      [
                            'All Departments',
                            'Sales',
                            'Marketing',
                            'Engineering',
                            'HR',
                            'Finance',
                          ]
                          .map(
                            (dept) => DropdownMenuItem(
                              value: dept,
                              child: Text(dept),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'File Format',
                    border: OutlineInputBorder(),
                  ),
                  value: 'PDF',
                  items:
                      ['PDF', 'Excel', 'CSV']
                          .map(
                            (format) => DropdownMenuItem(
                              value: format,
                              child: Text(format),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {},
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showGeneratingReport(context);
                },
                icon: Icon(Icons.file_download),
                label: Text('Generate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  void _showGeneratingReport(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Generating report...'),
              ],
            ),
          ),
    );

    // Simulate report generation
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report generated successfully!'),
          action: SnackBarAction(label: 'VIEW', onPressed: () {}),
        ),
      );
    });
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month % 12];
  }

  String _getMonthShortName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month % 12];
  }
}

// Main app to demonstrate the dashboard
class HRAnalyticsApp extends StatelessWidget {
  const HRAnalyticsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'HR Analytics Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: const HRDashboardScreen(),
      ),
    );
  }
}

void main() {
  runApp(const HRAnalyticsApp());
}

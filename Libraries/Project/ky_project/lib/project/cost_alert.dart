import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Tracking Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5BFF),
          secondary: const Color(0xFF6FCF97),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5BFF),
          secondary: const Color(0xFF6FCF97),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const BudgetProgressWidget(),
            const SizedBox(height: 24),
            const Text(
              'Financial Comparison',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const FinancialComparisonWidget(),
            const SizedBox(height: 24),
            const Text(
              'Cost Control Alerts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const CostControlAlertsWidget(),
          ],
        ),
      ),
    );
  }
}

// 1. Budget Progress Bars Widget
class BudgetProgressWidget extends StatelessWidget {
  const BudgetProgressWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample budget data
    final budgetItems = [
      BudgetItem(
        category: 'Marketing',
        spent: 4200,
        budget: 5000,
        color: const Color(0xFF4A6FFF),
      ),
      BudgetItem(
        category: 'Development',
        spent: 12800,
        budget: 15000,
        color: const Color(0xFF6FCF97),
      ),
      BudgetItem(
        category: 'Operations',
        spent: 9300,
        budget: 8000,
        color: const Color(0xFFF2994A),
        isOverBudget: true,
      ),
      BudgetItem(
        category: 'Research',
        spent: 3900,
        budget: 6000,
        color: const Color(0xFF9B51E0),
      ),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (var item in budgetItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: BudgetProgressBar(item: item),
              ),
          ],
        ),
      ),
    );
  }
}

class BudgetItem {
  final String category;
  final double spent;
  final double budget;
  final Color color;
  final bool isOverBudget;

  const BudgetItem({
    required this.category,
    required this.spent,
    required this.budget,
    required this.color,
    this.isOverBudget = false,
  });

  double get percentage => (spent / budget) * 100;

  String get formattedPercentage => percentage.toStringAsFixed(1) + '%';

  String get formattedSpent => '\$${NumberFormat('#,###').format(spent)}';

  String get formattedBudget => '\$${NumberFormat('#,###').format(budget)}';
}

class BudgetProgressBar extends StatelessWidget {
  final BudgetItem item;

  const BudgetProgressBar({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.category,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            Row(
              children: [
                Text(
                  item.formattedSpent,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: item.isOverBudget ? Colors.red : Colors.black87,
                  ),
                ),
                Text(
                  ' / ${item.formattedBudget}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Background track
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Progress indicator
            LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;
                double progressWidth = (item.spent / item.budget) * width;

                // Cap at 100% for visual display
                progressWidth = progressWidth > width ? width : progressWidth;

                return Container(
                  height: 8,
                  width: progressWidth,
                  decoration: BoxDecoration(
                    color:
                        item.isOverBudget && item.percentage > 100
                            ? Colors.red
                            : item.percentage > 90
                            ? Colors.orange
                            : item.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  item.percentage > 90
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  size: 16,
                  color: item.percentage > 90 ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  item.percentage > 90 ? 'Near threshold' : 'Within budget',
                  style: TextStyle(
                    fontSize: 12,
                    color: item.percentage > 90 ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
            Text(
              item.formattedPercentage,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: item.isOverBudget ? Colors.red : Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 2. Financial Comparison Charts Widget
class FinancialComparisonWidget extends StatelessWidget {
  const FinancialComparisonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Planned vs. Actual Spending',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(height: 200, child: PlannedVsActualChart()),
            const SizedBox(height: 24),
            const Text(
              'Monthly Comparison',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(height: 200, child: MonthlyComparisonChart()),
          ],
        ),
      ),
    );
  }
}

class PlannedVsActualChart extends StatelessWidget {
  PlannedVsActualChart({Key? key}) : super(key: key);

  final List<String> categories = [
    'Marketing',
    'Dev',
    'Operations',
    'Research',
  ];
  final List<double> planned = [5000, 15000, 8000, 6000];
  final List<double> actual = [4200, 12800, 9300, 3900];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 16000,
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= categories.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    categories[value.toInt()],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                );
                if (value == 0) {
                  return Text('\$0', style: style);
                } else if (value == 5000) {
                  return Text('\$5K', style: style);
                } else if (value == 10000) {
                  return Text('\$10K', style: style);
                } else if (value == 15000) {
                  return Text('\$15K', style: style);
                }
                return const SizedBox();
              },
              reservedSize: 28,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(categories.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: planned[index],
                color: Colors.blue.withOpacity(0.7),
                width: 12,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: actual[index],
                color:
                    index == 2 && actual[index] > planned[index]
                        ? Colors.red.withOpacity(0.7)
                        : Colors.greenAccent,
                width: 12,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5000,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
          },
        ),
      ),
    );
  }
}

class MonthlyComparisonChart extends StatelessWidget {
  MonthlyComparisonChart({Key? key}) : super(key: key);

  final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
  final List<double> thisYear = [22000, 25000, 28000, 32000, 30000];
  final List<double> lastYear = [20000, 22000, 24000, 25000, 26000];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            //tooltipBgColor: Colors.blueGrey.shade800,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot spot) {
                final isCurrent = spot.barIndex == 0;
                return LineTooltipItem(
                  '${isCurrent ? 'This Year' : 'Last Year'}: \$${NumberFormat('#,###').format(spot.y)}',
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= months.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    months[value.toInt()],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                );
                if (value == 20000) {
                  return Text('\$20K', style: style);
                } else if (value == 25000) {
                  return Text('\$25K', style: style);
                } else if (value == 30000) {
                  return Text('\$30K', style: style);
                }
                return const SizedBox();
              },
              reservedSize: 28,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5000,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: months.length - 1.0,
        minY: 18000,
        maxY: 35000,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(months.length, (index) {
              return FlSpot(index.toDouble(), thisYear[index]);
            }),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
          LineChartBarData(
            spots: List.generate(months.length, (index) {
              return FlSpot(index.toDouble(), lastYear[index]);
            }),
            isCurved: true,
            color: Colors.grey,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            dashArray: [5, 5],
          ),
        ],
      ),
    );
  }
}

// 3. Cost Control Alerts Widget
class CostControlAlertsWidget extends StatelessWidget {
  const CostControlAlertsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample alert data
    final alerts = [
      CostAlert(
        title: 'Budget Threshold Exceeded',
        message: 'Operations budget has exceeded the 100% threshold',
        severity: AlertSeverity.high,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        category: 'Operations',
      ),
      CostAlert(
        title: 'Anomaly Detected',
        message: 'Unusual spending pattern detected in Marketing department',
        severity: AlertSeverity.medium,
        date: DateTime.now().subtract(const Duration(hours: 5)),
        category: 'Marketing',
      ),
      CostAlert(
        title: 'Forecasted Overrun',
        message:
            'Development project "Mobile App" is projected to exceed budget by 15%',
        severity: AlertSeverity.medium,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Development',
      ),
      CostAlert(
        title: 'Resource Cost Escalation',
        message:
            'Cloud computing costs increased by 22% compared to last month',
        severity: AlertSeverity.low,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Infrastructure',
      ),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (var alert in alerts)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CostAlertItem(alert: alert),
              ),
          ],
        ),
      ),
    );
  }
}

enum AlertSeverity { low, medium, high }

class CostAlert {
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime date;
  final String category;

  const CostAlert({
    required this.title,
    required this.message,
    required this.severity,
    required this.date,
    required this.category,
  });

  Color get severityColor {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.blue;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
    }
  }

  IconData get severityIcon {
    switch (severity) {
      case AlertSeverity.low:
        return Icons.info_outline;
      case AlertSeverity.medium:
        return Icons.warning_amber_rounded;
      case AlertSeverity.high:
        return Icons.error_outline;
    }
  }

  String get timeAgo {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class CostAlertItem extends StatelessWidget {
  final CostAlert alert;

  const CostAlertItem({Key? key, required this.alert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: alert.severityColor.withOpacity(0.05),
        border: Border.all(
          color: alert.severityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: alert.severityColor.withOpacity(0.1),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              alert.severityIcon,
              color: alert.severityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alert.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      alert.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Dismiss',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

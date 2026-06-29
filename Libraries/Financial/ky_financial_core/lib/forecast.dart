import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class FinancialProjection {
  final String period;
  final double revenue;
  final double expenses;
  final double cashflow;

  FinancialProjection({
    required this.period,
    required this.revenue,
    required this.expenses,
    required this.cashflow,
  });

  double get profit => revenue - expenses;
}

// Providers
final projectionsProvider =
    StateNotifierProvider<ProjectionsNotifier, List<FinancialProjection>>((
      ref,
    ) {
      return ProjectionsNotifier();
    });

final selectedTimeRangeProvider = StateProvider<TimeRange>(
  (ref) => TimeRange.monthly,
);

final filteredProjectionsProvider = Provider<List<FinancialProjection>>((ref) {
  final projections = ref.watch(projectionsProvider);
  final timeRange = ref.watch(selectedTimeRangeProvider);

  // Apply filtering based on time range
  // This is simplified for demo purposes
  return projections;
});

enum TimeRange { monthly, quarterly, yearly }

class ProjectionsNotifier extends StateNotifier<List<FinancialProjection>> {
  ProjectionsNotifier()
    : super([
        FinancialProjection(
          period: 'Jan',
          revenue: 25000,
          expenses: 20000,
          cashflow: 22000,
        ),
        FinancialProjection(
          period: 'Feb',
          revenue: 28000,
          expenses: 21000,
          cashflow: 24000,
        ),
        FinancialProjection(
          period: 'Mar',
          revenue: 32000,
          expenses: 22000,
          cashflow: 28000,
        ),
        FinancialProjection(
          period: 'Apr',
          revenue: 38000,
          expenses: 24000,
          cashflow: 32000,
        ),
        FinancialProjection(
          period: 'May',
          revenue: 45000,
          expenses: 28000,
          cashflow: 36000,
        ),
        FinancialProjection(
          period: 'Jun',
          revenue: 52000,
          expenses: 32000,
          cashflow: 40000,
        ),
      ]);

  void addProjection(FinancialProjection projection) {
    state = [...state, projection];
  }

  void updateProjection(int index, FinancialProjection projection) {
    final newState = [...state];
    newState[index] = projection;
    state = newState;
  }
}

// Main Screen
class FinancialProjectionScreen extends ConsumerWidget {
  const FinancialProjectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projections = ref.watch(filteredProjectionsProvider);
    final selectedTimeRange = ref.watch(selectedTimeRangeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Financial Projections',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Show add projection dialog
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Show settings
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: projections.isEmpty
          ? const Center(child: Text('No projections available'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeRangeSelector(context, ref),
                    const SizedBox(height: 20),
                    _buildSummaryCards(context, projections),
                    const SizedBox(height: 24),
                    _buildCashFlowChart(context, projections),
                    const SizedBox(height: 24),
                    _buildProfitLossChart(context, projections),
                    const SizedBox(height: 24),
                    _buildProjectionsTable(context, projections),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add/edit projection bottom sheet
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SegmentedButton<TimeRange>(
        segments: const [
          ButtonSegment(value: TimeRange.monthly, label: Text('Monthly')),
          ButtonSegment(value: TimeRange.quarterly, label: Text('Quarterly')),
          ButtonSegment(value: TimeRange.yearly, label: Text('Yearly')),
        ],
        selected: {ref.watch(selectedTimeRangeProvider)},
        onSelectionChanged: (newSelection) {
          ref.read(selectedTimeRangeProvider.notifier).state =
              newSelection.first;
        },
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    List<FinancialProjection> projections,
  ) {
    // Calculate totals
    final totalRevenue = projections.fold(
      0.0,
      (sum, item) => sum + item.revenue,
    );
    final totalExpenses = projections.fold(
      0.0,
      (sum, item) => sum + item.expenses,
    );
    final totalProfit = totalRevenue - totalExpenses;
    final totalCashflow = projections.fold(
      0.0,
      (sum, item) => sum + item.cashflow,
    );

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          context,
          'Total Revenue',
          totalRevenue,
          Icons.trending_up,
          Colors.blue,
        ),
        _buildSummaryCard(
          context,
          'Total Expenses',
          totalExpenses,
          Icons.trending_down,
          Colors.red,
        ),
        _buildSummaryCard(
          context,
          'Net Profit',
          totalProfit,
          Icons.account_balance_wallet,
          Colors.green,
        ),
        _buildSummaryCard(
          context,
          'Cash Flow',
          totalCashflow,
          Icons.waves,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double value,
    IconData icon,
    Color color,
  ) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(value),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value > 0
                ? '+${value.toStringAsFixed(2)}%'
                : '${value.toStringAsFixed(2)}%',
            style: TextStyle(
              color: value > 0 ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowChart(
    BuildContext context,
    List<FinancialProjection> projections,
  ) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Flow',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < projections.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              projections[value.toInt()].period,
                              style: const TextStyle(
                                color: Color(0xff68737d),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final formatter = NumberFormat.compact();
                        return Text(
                          formatter.format(value),
                          style: const TextStyle(
                            color: Color(0xff68737d),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: projections.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.cashflow);
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
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
    );
  }

  Widget _buildProfitLossChart(
    BuildContext context,
    List<FinancialProjection> projections,
  ) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue vs. Expenses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    projections.fold(
                      0.0,
                      (max, item) => item.revenue > max ? item.revenue : max,
                    ) *
                    1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < projections.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              projections[value.toInt()].period,
                              style: const TextStyle(
                                color: Color(0xff68737d),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final formatter = NumberFormat.compact();
                        return Text(
                          formatter.format(value),
                          style: const TextStyle(
                            color: Color(0xff68737d),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: projections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.revenue,
                        color: Colors.green,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: data.expenses,
                        color: Colors.red,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 4),
              const Text('Revenue'),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 4),
              const Text('Expenses'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionsTable(
    BuildContext context,
    List<FinancialProjection> projections,
  ) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                'Detailed Projections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export'),
                onPressed: () {
                  // Export functionality
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              horizontalMargin: 0,
              columns: const [
                DataColumn(label: Text('Period')),
                DataColumn(label: Text('Revenue')),
                DataColumn(label: Text('Expenses')),
                DataColumn(label: Text('Profit')),
                DataColumn(label: Text('Cash Flow')),
              ],
              rows: projections.map((projection) {
                return DataRow(
                  cells: [
                    DataCell(Text(projection.period)),
                    DataCell(Text(formatter.format(projection.revenue))),
                    DataCell(Text(formatter.format(projection.expenses))),
                    DataCell(
                      Text(
                        formatter.format(projection.profit),
                        style: TextStyle(
                          color: projection.profit >= 0
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(Text(formatter.format(projection.cashflow))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Main app
void main() {
  runApp(const ProviderScope(child: FinancialProjectionApp()));
}

class FinancialProjectionApp extends StatelessWidget {
  const FinancialProjectionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Financial Projections',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
      home: const FinancialProjectionScreen(),
    );
  }
}

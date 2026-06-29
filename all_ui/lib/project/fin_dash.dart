import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Models
class FinancialData {
  final double planned;
  final double actual;
  final String category;
  final String period;

  FinancialData({
    required this.planned,
    required this.actual,
    required this.category,
    required this.period,
  });
}

class CashFlowData {
  final String date;
  final double inflow;
  final double outflow;

  CashFlowData({
    required this.date,
    required this.inflow,
    required this.outflow,
  });

  double get netFlow => inflow - outflow;
}

class ProfitData {
  final String period;
  final double revenue;
  final double expenses;

  ProfitData({
    required this.period,
    required this.revenue,
    required this.expenses,
  });

  double get profit => revenue - expenses;
  double get margin => profit / revenue * 100;
}

class Alert {
  final String title;
  final String description;
  final AlertSeverity severity;
  final DateTime timestamp;

  Alert({
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
  });
}

enum AlertSeverity { low, medium, high }

// Providers
final financialDataProvider = Provider<List<FinancialData>>((ref) {
  return [
    FinancialData(
      planned: 45000,
      actual: 42500,
      category: 'Development',
      period: 'Q1',
    ),
    FinancialData(
      planned: 30000,
      actual: 33000,
      category: 'Marketing',
      period: 'Q1',
    ),
    FinancialData(
      planned: 15000,
      actual: 14000,
      category: 'Operations',
      period: 'Q1',
    ),
    FinancialData(planned: 10000, actual: 7500, category: 'Misc', period: 'Q1'),
  ];
});

final cashFlowProvider = Provider<List<CashFlowData>>((ref) {
  return [
    CashFlowData(date: 'Jan', inflow: 25000, outflow: 18000),
    CashFlowData(date: 'Feb', inflow: 28000, outflow: 21000),
    CashFlowData(date: 'Mar', inflow: 32000, outflow: 24000),
    CashFlowData(date: 'Apr', inflow: 35000, outflow: 28000),
    CashFlowData(date: 'May', inflow: 27000, outflow: 22000),
    CashFlowData(date: 'Jun', inflow: 31000, outflow: 25000),
  ];
});

final profitDataProvider = Provider<List<ProfitData>>((ref) {
  return [
    ProfitData(period: 'Jan', revenue: 25000, expenses: 18000),
    ProfitData(period: 'Feb', revenue: 28000, expenses: 21000),
    ProfitData(period: 'Mar', revenue: 32000, expenses: 24000),
    ProfitData(period: 'Apr', revenue: 35000, expenses: 28000),
    ProfitData(period: 'May', revenue: 27000, expenses: 22000),
    ProfitData(period: 'Jun', revenue: 31000, expenses: 25000),
  ];
});

final alertsProvider = Provider<List<Alert>>((ref) {
  return [
    Alert(
      title: 'Development Costs Under Budget',
      description:
          'Development costs are 5.6% under the planned budget for Q1.',
      severity: AlertSeverity.low,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Alert(
      title: 'Marketing Budget Exceeded',
      description: 'Marketing costs exceeded the planned budget by 10% for Q1.',
      severity: AlertSeverity.medium,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Alert(
      title: 'Significant Variance in Misc Expenses',
      description:
          'Misc expenses are 25% under the planned budget. Please reviefw allocations.',
      severity: AlertSeverity.high,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];
});

// Health Score Provider
final financialHealthProvider = Provider<double>((ref) {
  final financialData = ref.watch(financialDataProvider);
  final cashFlow = ref.watch(cashFlowProvider);
  final profitData = ref.watch(profitDataProvider);

  // Calculate health score based on various metrics
  double budgetAdherence = 0;
  double totalPlanned = 0;
  double totalActual = 0;

  for (var item in financialData) {
    totalPlanned += item.planned;
    totalActual += item.actual;
  }

  budgetAdherence =
      (1 - ((totalActual - totalPlanned).abs() / totalPlanned)) * 100;

  double cashFlowScore = 0;
  double totalNetFlow = 0;
  double totalInflow = 0;

  for (var item in cashFlow) {
    totalNetFlow += item.netFlow;
    totalInflow += item.inflow;
  }

  cashFlowScore =
      totalNetFlow > 0 ? 100 : (totalNetFlow / totalInflow * 100) + 100;

  double profitScore = 0;
  double avgMargin = 0;

  for (var item in profitData) {
    avgMargin += item.margin;
  }

  avgMargin /= profitData.length;
  profitScore = avgMargin > 20 ? 100 : avgMargin * 5;

  // Combine scores with weights
  double healthScore =
      budgetAdherence * 0.4 + cashFlowScore * 0.3 + profitScore * 0.3;
  return healthScore > 100 ? 100 : healthScore;
});

// UI
void main() {
  runApp(const ProviderScope(child: FinancialDashboardApp()));
}

class FinancialDashboardApp extends StatelessWidget {
  const FinancialDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Project Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3366FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3366FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      themeMode: ThemeMode.system,
      home: const FinancialDashboardScreen(),
    );
  }
}

class FinancialDashboardScreen extends ConsumerWidget {
  const FinancialDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 1200;
    final isMediumScreen = screenSize.width > 800 && screenSize.width <= 1200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Project Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: screenSize.width < 800 ? const DashboardDrawer() : null,
      body: Row(
        children: [
          if (screenSize.width >= 800)
            const SizedBox(width: 250, child: DashboardDrawer(isDrawer: false)),
          Expanded(
            child: Container(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    isLargeScreen
                        ? _buildLargeScreenLayout(context, ref)
                        : isMediumScreen
                        ? _buildMediumScreenLayout(context, ref)
                        : _buildSmallScreenLayout(context, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDashboardHeader(context, ref),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildCard(
                              context,
                              'Budget Overview',
                              const BudgetOverviewChart(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildCard(
                              context,
                              'Profit Margin',
                              const ProfitMarginChart(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildCard(
                        context,
                        'Cash Flow',
                        const CashFlowChart(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildCard(
                      context,
                      'Financial Health',
                      const FinancialHealthIndicator(),
                      height: 300,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildCard(
                        context,
                        'Cost Variance Alerts',
                        const CostVarianceAlerts(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediumScreenLayout(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDashboardHeader(context, ref),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCard(
                        context,
                        'Budget Overview',
                        const BudgetOverviewChart(),
                        height: 300,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCard(
                        context,
                        'Profit Margin',
                        const ProfitMarginChart(),
                        height: 300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildCard(
                        context,
                        'Cash Flow',
                        const CashFlowChart(),
                        height: 300,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCard(
                        context,
                        'Financial Health',
                        const FinancialHealthIndicator(),
                        height: 300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  'Cost Variance Alerts',
                  const CostVarianceAlerts(),
                  height: 300,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDashboardHeader(context, ref),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCard(
                  context,
                  'Budget Overview',
                  const BudgetOverviewChart(),
                  height: 300,
                ),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  'Profit Margin',
                  const ProfitMarginChart(),
                  height: 300,
                ),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  'Cash Flow',
                  const CashFlowChart(),
                  height: 300,
                ),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  'Financial Health',
                  const FinancialHealthIndicator(),
                  height: 200,
                ),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  'Cost Variance Alerts',
                  const CostVarianceAlerts(),
                  height: 300,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Dashboard',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Overview of your project finances for Q1 2025',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_outlined),
          label: const Text('Export Report'),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    Widget content, {
    double? height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(padding: const EdgeInsets.all(16.0), child: content),
          ),
        ],
      ),
    );
  }
}

class DashboardDrawer extends StatelessWidget {
  final bool isDrawer;

  const DashboardDrawer({super.key, this.isDrawer = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDrawer ? null : Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      'FM',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Finance Manager',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Pro Plan',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildMenuItem(
              context,
              'Dashboard',
              Icons.dashboard_outlined,
              true,
            ),
            _buildMenuItem(context, 'Projects', Icons.folder_outlined, false),
            _buildMenuItem(
              context,
              'Budgets',
              Icons.account_balance_wallet_outlined,
              false,
            ),
            _buildMenuItem(context, 'Reports', Icons.analytics_outlined, false),
            _buildMenuItem(context, 'Invoices', Icons.receipt_outlined, false),
            _buildMenuItem(context, 'Team', Icons.people_outline, false),
            const Spacer(),
            const Divider(),
            _buildMenuItem(context, 'Settings', Icons.settings_outlined, false),
            _buildMenuItem(
              context,
              'Help & Support',
              Icons.help_outline,
              false,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration:
          isSelected
              ? BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              )
              : null,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Chart Widgets
class BudgetOverviewChart extends ConsumerWidget {
  const BudgetOverviewChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financialData = ref.watch(financialDataProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            financialData
                .map((e) => e.planned > e.actual ? e.planned : e.actual)
                .reduce((a, b) => a > b ? a : b) *
            1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            //tooltipBgColor: colorScheme.surfaceVariant,
            tooltipRoundedRadius: 8,
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = financialData[groupIndex];
              final value = rodIndex == 0 ? item.planned : item.actual;
              return BarTooltipItem(
                '${item.category}\n\$${NumberFormat('#,###').format(value)}',
                TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value < financialData.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      financialData[value.toInt()].category,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '\$${NumberFormat.compact().format(value)}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                );
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
          horizontalInterval: 10000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outlineVariant.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups:
            financialData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data.planned,
                    color: colorScheme.primary.withOpacity(0.7),
                    width: 16,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  BarChartRodData(
                    toY: data.actual,
                    color: colorScheme.tertiary,
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
    );
  }
}

class ProfitMarginChart extends ConsumerWidget {
  const ProfitMarginChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profitData = ref.watch(profitDataProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(context, 'Revenue', colorScheme.primary),
            const SizedBox(width: 16),
            _buildLegendItem(context, 'Expenses', colorScheme.tertiary),
            const SizedBox(width: 16),
            _buildLegendItem(context, 'Profit', colorScheme.secondary),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  //tooltipBgColor: colorScheme.surfaceVariant,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      final item = profitData[spot.x.toInt()];
                      String text;
                      switch (spot.barIndex) {
                        case 0:
                          text =
                              'Revenue: \$${NumberFormat('#,###').format(item.revenue)}';
                          break;
                        case 1:
                          text =
                              'Expenses: \$${NumberFormat('#,###').format(item.expenses)}';
                          break;
                        case 2:
                          text =
                              'Profit: \$${NumberFormat('#,###').format(item.profit)}';
                          break;
                        default:
                          text = '';
                      }
                      return LineTooltipItem(
                        '${item.period}\n$text',
                        TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value >= 0 && value < profitData.length) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            profitData[value.toInt()].period,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          '\$${NumberFormat.compact().format(value)}',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      );
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
                horizontalInterval: 10000,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: colorScheme.outlineVariant.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots:
                      profitData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.revenue,
                        );
                      }).toList(),
                  isCurved: true,
                  color: colorScheme.primary,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                LineChartBarData(
                  spots:
                      profitData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.expenses,
                        );
                      }).toList(),
                  isCurved: true,
                  color: colorScheme.tertiary,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorScheme.tertiary.withOpacity(0.1),
                  ),
                ),
                LineChartBarData(
                  spots:
                      profitData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.profit);
                      }).toList(),
                  isCurved: true,
                  color: colorScheme.secondary,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorScheme.secondary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
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
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class CashFlowChart extends ConsumerWidget {
  const CashFlowChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashFlowData = ref.watch(cashFlowProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(context, 'Cash In', colorScheme.primary),
            const SizedBox(width: 16),
            _buildLegendItem(context, 'Cash Out', colorScheme.error),
            const SizedBox(width: 16),
            _buildLegendItem(context, 'Net Flow', colorScheme.secondary),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  //tooltipBgColor: colorScheme.surfaceVariant,
                  tooltipRoundedRadius: 8,
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final item = cashFlowData[groupIndex];
                    String value;
                    if (rodIndex == 0) {
                      value = '\$${NumberFormat('#,###').format(item.inflow)}';
                    } else if (rodIndex == 1) {
                      value = '\$${NumberFormat('#,###').format(item.outflow)}';
                    } else {
                      value = '\$${NumberFormat('#,###').format(item.netFlow)}';
                    }
                    return BarTooltipItem(
                      '${item.date}\n$value',
                      TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value >= 0 && value < cashFlowData.length) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            cashFlowData[value.toInt()].date,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          '\$${NumberFormat.compact().format(value)}',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      );
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
                horizontalInterval: 10000,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: colorScheme.outlineVariant.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups:
                  cashFlowData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.inflow,
                          color: colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: data.outflow,
                          color: colorScheme.error,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: data.netFlow,
                          color: colorScheme.secondary,
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
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
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
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class FinancialHealthIndicator extends ConsumerWidget {
  const FinancialHealthIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthScore = ref.watch(financialHealthProvider);
    final colorScheme = Theme.of(context).colorScheme;

    Color healthColor;
    String healthStatus;

    if (healthScore >= 85) {
      healthColor = Colors.green;
      healthStatus = 'Excellent';
    } else if (healthScore >= 70) {
      healthColor = Colors.lightGreen;
      healthStatus = 'Good';
    } else if (healthScore >= 50) {
      healthColor = Colors.amber;
      healthStatus = 'Fair';
    } else if (healthScore >= 30) {
      healthColor = Colors.orange;
      healthStatus = 'Poor';
    } else {
      healthColor = Colors.red;
      healthStatus = 'Critical';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: healthScore / 100,
                    strokeWidth: 12,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${healthScore.toStringAsFixed(1)}%',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: healthColor,
                      ),
                    ),
                    Text(
                      healthStatus,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: healthColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildHealthMetric(
          context,
          'Budget Adherence',
          Icons.account_balance_wallet_outlined,
          '${(healthScore * 0.4).toStringAsFixed(1)}%',
          40,
        ),
        const SizedBox(height: 8),
        _buildHealthMetric(
          context,
          'Cash Flow Status',
          Icons.trending_up,
          '${(healthScore * 0.3).toStringAsFixed(1)}%',
          30,
        ),
        const SizedBox(height: 8),
        _buildHealthMetric(
          context,
          'Profit Margins',
          Icons.attach_money,
          '${(healthScore * 0.3).toStringAsFixed(1)}%',
          30,
        ),
      ],
    );
  }

  Widget _buildHealthMetric(
    BuildContext context,
    String label,
    IconData icon,
    String value,
    int weight,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          '($weight%)',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class CostVarianceAlerts extends ConsumerWidget {
  const CostVarianceAlerts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);

    return ListView.separated(
      itemCount: alerts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        final colorScheme = Theme.of(context).colorScheme;

        Color severityColor;
        IconData severityIcon;

        switch (alert.severity) {
          case AlertSeverity.low:
            severityColor = Colors.green;
            severityIcon = Icons.check_circle_outline;
            break;
          case AlertSeverity.medium:
            severityColor = Colors.amber;
            severityIcon = Icons.warning_amber_outlined;
            break;
          case AlertSeverity.high:
            severityColor = Colors.red;
            severityIcon = Icons.error_outline;
            break;
        }

        final timeAgo = _getTimeAgo(alert.timestamp);

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(severityIcon, color: severityColor, size: 32),
          title: Text(
            alert.title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                alert.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                timeAgo,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        );
      },
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

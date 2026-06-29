import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// MODELS
class BudgetCategory {
  final String id;
  final String name;
  final Color color;

  BudgetCategory({required this.id, required this.name, required this.color});
}

class BudgetItem {
  final String id;
  final String categoryId;
  final String name;
  final double amount;
  final DateTime date;
  final bool isExpense;

  BudgetItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.date,
    required this.isExpense,
  });
}

class Budget {
  final String month;
  final double plannedIncome;
  final double plannedExpenses;
  final double actualIncome;
  final double actualExpenses;

  Budget({
    required this.month,
    required this.plannedIncome,
    required this.plannedExpenses,
    required this.actualIncome,
    required this.actualExpenses,
  });
}

class ForecastData {
  final String month;
  final double projectedIncome;
  final double projectedExpenses;
  final double projectedSavings;

  ForecastData({
    required this.month,
    required this.projectedIncome,
    required this.projectedExpenses,
    required this.projectedSavings,
  });
}

// PROVIDERS
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<BudgetCategory>>((ref) {
      return CategoriesNotifier();
    });

class CategoriesNotifier extends StateNotifier<List<BudgetCategory>> {
  CategoriesNotifier()
    : super([
        BudgetCategory(id: '1', name: 'Housing', color: Colors.blue),
        BudgetCategory(id: '2', name: 'Food', color: Colors.green),
        BudgetCategory(id: '3', name: 'Transportation', color: Colors.orange),
        BudgetCategory(id: '4', name: 'Utilities', color: Colors.purple),
        BudgetCategory(id: '5', name: 'Entertainment', color: Colors.red),
        BudgetCategory(id: '6', name: 'Health', color: Colors.teal),
        BudgetCategory(id: '7', name: 'Income', color: Colors.amber),
      ]);

  void addCategory(BudgetCategory category) {
    state = [...state, category];
  }

  void removeCategory(String id) {
    state = state.where((category) => category.id != id).toList();
  }
}

final budgetItemsProvider =
    StateNotifierProvider<BudgetItemsNotifier, List<BudgetItem>>((ref) {
      return BudgetItemsNotifier();
    });

class BudgetItemsNotifier extends StateNotifier<List<BudgetItem>> {
  BudgetItemsNotifier()
    : super([
        BudgetItem(
          id: '1',
          categoryId: '1',
          name: 'Rent',
          amount: 1200,
          date: DateTime(2025, 3, 1),
          isExpense: true,
        ),
        BudgetItem(
          id: '2',
          categoryId: '2',
          name: 'Groceries',
          amount: 400,
          date: DateTime(2025, 3, 5),
          isExpense: true,
        ),
        BudgetItem(
          id: '3',
          categoryId: '7',
          name: 'Salary',
          amount: 3500,
          date: DateTime(2025, 3, 15),
          isExpense: false,
        ),
      ]);

  void addBudgetItem(BudgetItem item) {
    state = [...state, item];
  }

  void removeBudgetItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void updateBudgetItem(BudgetItem updatedItem) {
    state =
        state
            .map((item) => item.id == updatedItem.id ? updatedItem : item)
            .toList();
  }
}

final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final budgetsProvider = StateNotifierProvider<BudgetsNotifier, List<Budget>>((
  ref,
) {
  return BudgetsNotifier();
});

class BudgetsNotifier extends StateNotifier<List<Budget>> {
  BudgetsNotifier()
    : super([
        Budget(
          month: 'Jan 2025',
          plannedIncome: 4000,
          plannedExpenses: 3500,
          actualIncome: 4200,
          actualExpenses: 3300,
        ),
        Budget(
          month: 'Feb 2025',
          plannedIncome: 4000,
          plannedExpenses: 3500,
          actualIncome: 3800,
          actualExpenses: 3600,
        ),
        Budget(
          month: 'Mar 2025',
          plannedIncome: 4000,
          plannedExpenses: 3500,
          actualIncome: 2000,
          actualExpenses: 1500,
        ),
      ]);

  void addBudget(Budget budget) {
    state = [...state, budget];
  }

  void updateBudget(String month, Budget updatedBudget) {
    state =
        state
            .map((budget) => budget.month == month ? updatedBudget : budget)
            .toList();
  }
}

final forecastProvider =
    StateNotifierProvider<ForecastNotifier, List<ForecastData>>((ref) {
      return ForecastNotifier(ref);
    });

class ForecastNotifier extends StateNotifier<List<ForecastData>> {
  final Ref ref;

  ForecastNotifier(this.ref)
    : super([
        ForecastData(
          month: 'Apr 2025',
          projectedIncome: 4000,
          projectedExpenses: 3500,
          projectedSavings: 500,
        ),
        ForecastData(
          month: 'May 2025',
          projectedIncome: 4000,
          projectedExpenses: 3400,
          projectedSavings: 600,
        ),
        ForecastData(
          month: 'Jun 2025',
          projectedIncome: 4100,
          projectedExpenses: 3400,
          projectedSavings: 700,
        ),
        ForecastData(
          month: 'Jul 2025',
          projectedIncome: 4100,
          projectedExpenses: 3300,
          projectedSavings: 800,
        ),
        ForecastData(
          month: 'Aug 2025',
          projectedIncome: 4100,
          projectedExpenses: 3300,
          projectedSavings: 800,
        ),
        ForecastData(
          month: 'Sep 2025',
          projectedIncome: 4200,
          projectedExpenses: 3300,
          projectedSavings: 900,
        ),
      ]);

  void updateForecast() {
    // In a real app, this would use historical data to predict future values
    List<Budget> budgets = ref.read(budgetsProvider);
    List<BudgetItem> items = ref.read(budgetItemsProvider);

    // Simple implementation for demonstration
    state = List.generate(6, (index) {
      final month = DateTime.now().add(Duration(days: 30 * (index + 1)));
      final monthName = DateFormat('MMM yyyy').format(month);

      final projectedIncome = 4000 + (Random().nextDouble() * 500 * index / 10);
      final projectedExpenses =
          3500 - (Random().nextDouble() * 300 * index / 10);
      final projectedSavings = projectedIncome - projectedExpenses;

      return ForecastData(
        month: monthName,
        projectedIncome: projectedIncome,
        projectedExpenses: projectedExpenses,
        projectedSavings: projectedSavings,
      );
    });
  }
}

final monthlyExpensesProvider = Provider<Map<String, double>>((ref) {
  final items = ref.watch(budgetItemsProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);

  final monthlyExpenses = <String, double>{};

  for (var item in items) {
    if (item.isExpense &&
        item.date.month == selectedMonth.month &&
        item.date.year == selectedMonth.year) {
      if (monthlyExpenses.containsKey(item.categoryId)) {
        monthlyExpenses[item.categoryId] =
            monthlyExpenses[item.categoryId]! + item.amount;
      } else {
        monthlyExpenses[item.categoryId] = item.amount;
      }
    }
  }

  return monthlyExpenses;
});

final monthlyIncomeProvider = Provider<double>((ref) {
  final items = ref.watch(budgetItemsProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);

  return items
      .where(
        (item) =>
            !item.isExpense &&
            item.date.month == selectedMonth.month &&
            item.date.year == selectedMonth.year,
      )
      .fold(0, (sum, item) => sum + item.amount);
});

// MAIN APP
void main() {
  runApp(const ProviderScope(child: BudgetApp()));
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget & Forecast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const BudgetAppHome(),
    );
  }
}

class BudgetAppHome extends ConsumerWidget {
  const BudgetAppHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget & Forecast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(forecastProvider.notifier).updateForecast();
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Side navigation
          Container(
            width: 250,
            color: Theme.of(context).colorScheme.surface,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  selected: true,
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('Transactions'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Categories'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('Reports'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.trending_up),
                  title: const Text('Forecasting'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date selector and summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_MonthSelector(), _SummaryCards()],
                  ),

                  const SizedBox(height: 24),

                  // Charts section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expense breakdown
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Expense Breakdown',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 300,
                                  child: _ExpensePieChart(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Budget progress
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Budget Progress',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(height: 300, child: _BudgetBarChart()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Forecast section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Financial Forecast (6 Months)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Recalculate'),
                                onPressed: () {
                                  ref
                                      .read(forecastProvider.notifier)
                                      .updateForecast();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(height: 300, child: _ForecastLineChart()),
                          const SizedBox(height: 16),
                          _ForecastTable(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recent transactions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _RecentTransactionsTable(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => AddTransactionDialog());
  }
}

class _MonthSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            ref.read(selectedMonthProvider.notifier).state = DateTime(
              selectedMonth.year,
              selectedMonth.month - 1,
              1,
            );
          },
        ),
        Text(
          DateFormat('MMMM yyyy').format(selectedMonth),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            ref.read(selectedMonthProvider.notifier).state = DateTime(
              selectedMonth.year,
              selectedMonth.month + 1,
              1,
            );
          },
        ),
      ],
    );
  }
}

class _SummaryCards extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyExpenses = ref
        .watch(monthlyExpensesProvider)
        .values
        .fold(0.0, (sum, amount) => sum + amount);
    final monthlyIncome = ref.watch(monthlyIncomeProvider);
    final balance = monthlyIncome - monthlyExpenses;

    return Row(
      children: [
        _SummaryCard(
          title: 'Income',
          amount: monthlyIncome,
          icon: Icons.arrow_downward,
          color: Colors.green,
        ),
        const SizedBox(width: 16),
        _SummaryCard(
          title: 'Expenses',
          amount: monthlyExpenses,
          icon: Icons.arrow_upward,
          color: Colors.red,
        ),
        const SizedBox(width: 16),
        _SummaryCard(
          title: 'Balance',
          amount: balance,
          icon: Icons.account_balance_wallet,
          color: balance >= 0 ? Colors.blue : Colors.orange,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
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

class _ExpensePieChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyExpenses = ref.watch(monthlyExpensesProvider);
    final categories = ref.watch(categoriesProvider);

    if (monthlyExpenses.isEmpty) {
      return const Center(child: Text('No expenses for selected month'));
    }

    final expenseList =
        monthlyExpenses.entries.map((entry) {
          final category = categories.firstWhere(
            (cat) => cat.id == entry.key,
            orElse:
                () => BudgetCategory(
                  id: 'unknown',
                  name: 'Unknown',
                  color: Colors.grey,
                ),
          );
          return MapEntry(category, entry.value);
        }).toList();

    final totalExpenses = expenseList.fold(
      0.0,
      (sum, entry) => sum + entry.value,
    );

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections:
                  expenseList.map((entry) {
                    return PieChartSectionData(
                      color: entry.key.color,
                      value: entry.value,
                      title:
                          '${(entry.value / totalExpenses * 100).toStringAsFixed(1)}%',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                expenseList.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: entry.key.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${entry.value.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

class _BudgetBarChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            budgets
                .map(
                  (b) => [
                    b.plannedIncome,
                    b.plannedExpenses,
                    b.actualIncome,
                    b.actualExpenses,
                  ].reduce(max),
                )
                .reduce(max) *
            1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < budgets.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      budgets[value.toInt()].month,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(budgets.length, (index) {
          final budget = budgets[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: budget.plannedIncome,
                color: Colors.blue.shade200,
                width: 12,
              ),
              BarChartRodData(
                toY: budget.actualIncome,
                color: Colors.blue.shade600,
                width: 12,
              ),
              BarChartRodData(
                toY: budget.plannedExpenses,
                color: Colors.red.shade200,
                width: 12,
              ),
              BarChartRodData(
                toY: budget.actualExpenses,
                color: Colors.red.shade600,
                width: 12,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ForecastLineChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecast = ref.watch(forecastProvider);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 500,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < forecast.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      forecast[value.toInt()].month,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(forecast.length, (index) {
              return FlSpot(index.toDouble(), forecast[index].projectedIncome);
            }),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: List.generate(forecast.length, (index) {
              return FlSpot(
                index.toDouble(),
                forecast[index].projectedExpenses,
              );
            }),
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: List.generate(forecast.length, (index) {
              return FlSpot(index.toDouble(), forecast[index].projectedSavings);
            }),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

class _ForecastTable extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecast = ref.watch(forecastProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Month')),
          DataColumn(label: Text('Projected Income'), numeric: true),
          DataColumn(label: Text('Projected Expenses'), numeric: true),
          DataColumn(label: Text('Projected Savings'), numeric: true),
          DataColumn(label: Text('Savings Rate'), numeric: true),
        ],
        rows:
            forecast.map((data) {
              final savingsRate = (data.projectedSavings /
                      data.projectedIncome *
                      100)
                  .toStringAsFixed(1);

              return DataRow(
                cells: [
                  DataCell(Text(data.month)),
                  DataCell(
                    Text('\$${data.projectedIncome.toStringAsFixed(2)}'),
                  ),
                  DataCell(
                    Text('\$${data.projectedExpenses.toStringAsFixed(2)}'),
                  ),
                  DataCell(
                    Text('\$${data.projectedSavings.toStringAsFixed(2)}'),
                  ),
                  DataCell(Text('$savingsRate%')),
                ],
              );
            }).toList(),
      ),
    );
  }
}

class _RecentTransactionsTable extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(budgetItemsProvider);
    final categories = ref.watch(categoriesProvider);

    // Sort by date, most recent first
    final sortedItems = List.of(items)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Take only the 5 most recent
    final recentItems = sortedItems.take(5).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Amount'), numeric: true),
          DataColumn(label: Text('Actions')),
        ],
        rows:
            recentItems.map((item) {
              final category = categories.firstWhere(
                (cat) => cat.id == item.categoryId,
                orElse:
                    () => BudgetCategory(
                      id: 'unknown',
                      name: 'Unknown',
                      color: Colors.grey,
                    ),
              );

              return DataRow(
                cells: [
                  DataCell(Text(DateFormat('MM/dd/yyyy').format(item.date))),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: category.color,
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        Text(category.name),
                      ],
                    ),
                  ),
                  DataCell(Text(item.name)),
                  DataCell(
                    Text(
                      '\$${item.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: item.isExpense ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            // Edit transaction
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () {
                            ref
                                .read(budgetItemsProvider.notifier)
                                .removeBudgetItem(item.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

class AddTransactionDialog extends ConsumerStatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  ConsumerState<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  String _selectedCategoryId = '';
  bool _isExpense = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _selectedDate = DateTime.now();

    // Set default category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categories = ref.read(categoriesProvider);
      if (categories.isNotEmpty) {
        setState(() {
          _selectedCategoryId = categories.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref
            .watch(categoriesProvider)
            .where((cat) => cat.name != 'Income' || !_isExpense)
            .toList();

    return AlertDialog(
      title: Text(_isExpense ? 'Add Expense' : 'Add Income'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Transaction type toggle
              Row(
                children: [
                  const Text('Transaction Type:'),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('Expense'),
                    selected: _isExpense,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _isExpense = true;
                          // Set default category for expense
                          if (categories.isNotEmpty) {
                            _selectedCategoryId = categories.first.id;
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Income'),
                    selected: !_isExpense,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _isExpense = false;
                          // Set income category
                          final incomeCategory = ref
                              .read(categoriesProvider)
                              .firstWhere(
                                (cat) => cat.name == 'Income',
                                orElse: () => categories.first,
                              );
                          _selectedCategoryId = incomeCategory.id;
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value:
                    categories.isNotEmpty
                        ? (categories.any(
                              (cat) => cat.id == _selectedCategoryId,
                            )
                            ? _selectedCategoryId
                            : categories.first.id)
                        : null,
                items:
                    categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: category.color,
                              margin: const EdgeInsets.only(right: 8),
                            ),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(
                  DateFormat('MMMM dd, yyyy').format(_selectedDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Generate a unique ID
              final id = DateTime.now().millisecondsSinceEpoch.toString();

              // Create new budget item
              final newItem = BudgetItem(
                id: id,
                categoryId: _selectedCategoryId,
                name: _nameController.text,
                amount: double.parse(_amountController.text),
                date: _selectedDate,
                isExpense: _isExpense,
              );

              // Add to provider
              ref.read(budgetItemsProvider.notifier).addBudgetItem(newItem);

              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Settings and customization views (to be implemented)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Theme Settings'),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notification Settings'),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Account Settings'),
          ),
          ListTile(leading: Icon(Icons.backup), title: Text('Data Backup')),
          ListTile(
            leading: Icon(Icons.import_export),
            title: Text('Import/Export Data'),
          ),
        ],
      ),
    );
  }
}

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            leading: Container(width: 24, height: 24, color: category.color),
            title: Text(category.name),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Edit category
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new category
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Spending'),
              Tab(text: 'Income'),
              Tab(text: 'Savings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text('Spending Report')),
            Center(child: Text('Income Report')),
            Center(child: Text('Savings Report')),
          ],
        ),
      ),
    );
  }
}

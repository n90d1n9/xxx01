import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });
}

enum TransactionType { income, expense }

// State Providers
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
      return TransactionsNotifier();
    });

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final filter = ref.watch(filterProvider);

  if (filter.isEmpty) return transactions;

  return transactions
      .where(
        (transaction) =>
            transaction.description.toLowerCase().contains(
              filter.toLowerCase(),
            ) ||
            transaction.category.toLowerCase().contains(filter.toLowerCase()),
      )
      .toList();
});

final filterProvider = StateProvider<String>((ref) => '');

final selectedDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month, 1),
    end: DateTime(now.year, now.month + 1, 0),
  );
});

final currentBalanceProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.fold(
    0,
    (total, transaction) =>
        transaction.type == TransactionType.income
            ? total + transaction.amount
            : total - transaction.amount,
  );
});

final monthlyRevenueProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);

  return transactions
      .where(
        (t) =>
            t.type == TransactionType.income &&
            t.date.isAfter(dateRange.start) &&
            t.date.isBefore(dateRange.end),
      )
      .fold(0, (total, t) => total + t.amount);
});

final monthlyExpensesProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);

  return transactions
      .where(
        (t) =>
            t.type == TransactionType.expense &&
            t.date.isAfter(dateRange.start) &&
            t.date.isBefore(dateRange.end),
      )
      .fold(0, (total, t) => total + t.amount);
});

final categorySummaryProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  final expensesByCategory = <String, double>{};

  for (var t in transactions.where(
    (t) =>
        t.type == TransactionType.expense &&
        t.date.isAfter(dateRange.start) &&
        t.date.isBefore(dateRange.end),
  )) {
    expensesByCategory[t.category] =
        (expensesByCategory[t.category] ?? 0) + t.amount;
  }

  return expensesByCategory;
});

// Notifier
class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  TransactionsNotifier() : super(_generateDemoTransactions());

  void addTransaction(Transaction transaction) {
    state = [...state, transaction];
  }

  void deleteTransaction(String id) {
    state = state.where((transaction) => transaction.id != id).toList();
  }

  static List<Transaction> _generateDemoTransactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: '1',
        description: 'Client Payment - XYZ Corp',
        amount: 5000,
        date: DateTime(now.year, now.month, 5),
        type: TransactionType.income,
        category: 'Sales',
      ),
      Transaction(
        id: '2',
        description: 'Office Rent',
        amount: 1200,
        date: DateTime(now.year, now.month, 1),
        type: TransactionType.expense,
        category: 'Rent',
      ),
      Transaction(
        id: '3',
        description: 'Software Subscription',
        amount: 49.99,
        date: DateTime(now.year, now.month, 15),
        type: TransactionType.expense,
        category: 'Software',
      ),
      Transaction(
        id: '4',
        description: 'Client Payment - ABC Inc',
        amount: 3500,
        date: DateTime(now.year, now.month, 20),
        type: TransactionType.income,
        category: 'Consulting',
      ),
      Transaction(
        id: '5',
        description: 'Office Supplies',
        amount: 120.50,
        date: DateTime(now.year, now.month, 8),
        type: TransactionType.expense,
        category: 'Supplies',
      ),
      Transaction(
        id: '6',
        description: 'Utility Bills',
        amount: 180.25,
        date: DateTime(now.year, now.month, 10),
        type: TransactionType.expense,
        category: 'Utilities',
      ),
      Transaction(
        id: '7',
        description: 'Employee Salary',
        amount: 2500,
        date: DateTime(now.year, now.month, 28),
        type: TransactionType.expense,
        category: 'Payroll',
      ),
      Transaction(
        id: '8',
        description: 'Client Deposit',
        amount: 1000,
        date: DateTime(now.year, now.month, 25),
        type: TransactionType.income,
        category: 'Sales',
      ),
    ];
  }
}

// Main App
void main() {
  runApp(const ProviderScope(child: AccountingApp()));
}

class AccountingApp extends StatelessWidget {
  const AccountingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SME Accounting',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade800,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}

// Dashboard Screen
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBalance = ref.watch(currentBalanceProvider);
    final monthlyRevenue = ref.watch(monthlyRevenueProvider);
    final monthlyExpenses = ref.watch(monthlyExpensesProvider);
    final categorySummary = ref.watch(categorySummaryProvider);
    final dateRange = ref.watch(selectedDateRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                initialDateRange: dateRange,
                firstDate: DateTime(2020),
                lastDate: DateTime(2025),
              );
              if (picked != null) {
                ref.read(selectedDateRangeProvider.notifier).state = picked;
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddTransactionModal(context, ref);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // In a real app, this would refresh data from the backend
            await Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      Row(
                        children: [
                          _buildSummaryCard(
                            context,
                            'Current Balance',
                            currentBalance,
                            Icons.account_balance_wallet,
                            Colors.blue,
                          ),
                          const SizedBox(width: 16),
                          _buildSummaryCard(
                            context,
                            'Monthly Revenue',
                            monthlyRevenue,
                            Icons.trending_up,
                            Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildSummaryCard(
                            context,
                            'Monthly Expenses',
                            monthlyExpenses,
                            Icons.trending_down,
                            Colors.red,
                          ),
                          const SizedBox(width: 16),
                          _buildSummaryCard(
                            context,
                            'Net Profit',
                            monthlyRevenue - monthlyExpenses,
                            Icons.savings,
                            Colors.purple,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Date range display
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${DateFormat('MMM d, y').format(dateRange.start)} - ${DateFormat('MMM d, y').format(dateRange.end)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Revenue vs Expenses Chart
                      const Text(
                        'Revenue vs Expenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildRevenueExpensesChart(
                          context,
                          monthlyRevenue,
                          monthlyExpenses,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Expense by Category
                      const Text(
                        'Expenses by Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: _buildCategoryPieChart(context, categorySummary),
                      ),

                      const SizedBox(height: 24),

                      // Recent Transactions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const TransactionsScreen(),
                                ),
                              );
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildRecentTransactionsList(ref),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.insert_chart),
            label: 'Reports',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TransactionsScreen(),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddTransactionModal(context, ref);
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                NumberFormat.currency(symbol: '\$').format(amount),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:
                      amount < 0
                          ? Colors.red
                          : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueExpensesChart(
    BuildContext context,
    double revenue,
    double expenses,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: math.max(revenue, expenses) * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                //tooltipBgColor: Colors.blueGrey.shade800,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String label = groupIndex == 0 ? 'Revenue' : 'Expenses';
                  return BarTooltipItem(
                    '$label\n${NumberFormat.currency(symbol: '\$').format(rod.toY)}',
                    const TextStyle(color: Colors.white),
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
                    String text = '';
                    if (value == 0) {
                      text = 'Revenue';
                    } else if (value == 1) {
                      text = 'Expenses';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Theme.of(context).dividerColor,
                  strokeWidth: 0.5,
                  dashArray: [4, 4],
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: revenue,
                    color: Colors.green,
                    width: 40,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: expenses,
                    color: Colors.red,
                    width: 40,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(
    BuildContext context,
    Map<String, double> categorySummary,
  ) {
    if (categorySummary.isEmpty) {
      return const Card(
        child: Center(child: Text('No expense data available')),
      );
    }

    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: List.generate(categorySummary.length, (i) {
                    final entry = categorySummary.entries.elementAt(i);
                    final total = categorySummary.values.fold(
                      0.0,
                      (sum, e) => sum + e,
                    );
                    final percentage =
                        total > 0 ? entry.value / total * 100 : 0.0;

                    return PieChartSectionData(
                      color: colors[i % colors.length],
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(categorySummary.length, (i) {
                  final entry = categorySummary.entries.elementAt(i);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: colors[i % colors.length],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsList(WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final recentTransactions =
        transactions.length > 5 ? transactions.sublist(0, 5) : transactions;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final transaction = recentTransactions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  transaction.type == TransactionType.income
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
              child: Icon(
                transaction.type == TransactionType.income
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color:
                    transaction.type == TransactionType.income
                        ? Colors.green
                        : Colors.red,
                size: 20,
              ),
            ),
            title: Text(
              transaction.description,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${transaction.category} • ${DateFormat('MMM d, y').format(transaction.date)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            trailing: Text(
              NumberFormat.currency(symbol: '\$').format(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    transaction.type == TransactionType.income
                        ? Colors.green
                        : Colors.red,
              ),
            ),
          ),
        );
      }, childCount: recentTransactions.length),
    );
  }

  void _showAddTransactionModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: const AddTransactionForm(),
          ),
    );
  }
}

// Transactions Screen
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final filter = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              onChanged: (value) {
                ref.read(filterProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    filter.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            ref.read(filterProvider.notifier).state = '';
                          },
                        )
                        : null,
              ),
            ),
          ),
        ),
      ),
      body:
          transactions.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions found',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Dismissible(
                    key: Key(transaction.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      ref
                          .read(transactionsProvider.notifier)
                          .deleteTransaction(transaction.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Transaction deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              ref
                                  .read(transactionsProvider.notifier)
                                  .addTransaction(transaction);
                            },
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              transaction.type == TransactionType.income
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.red.withValues(alpha: 0.2),
                          child: Icon(
                            transaction.type == TransactionType.income
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color:
                                transaction.type == TransactionType.income
                                    ? Colors.green
                                    : Colors.red,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          transaction.description,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${transaction.category} • ${DateFormat('MMM d, y').format(transaction.date)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        trailing: Text(
                          NumberFormat.currency(
                            symbol: '\$',
                          ).format(transaction.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                transaction.type == TransactionType.income
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder:
                (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: const AddTransactionForm(),
                ),
          );
        },
      ),
    );
  }
}

// Add Transaction Form
class AddTransactionForm extends ConsumerStatefulWidget {
  const AddTransactionForm({Key? key}) : super(key: key);

  @override
  _AddTransactionFormState createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends ConsumerState<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Sales';
  TransactionType _type = TransactionType.income;
  DateTime _date = DateTime.now();

  final List<String> _incomeCategories = [
    'Sales',
    'Consulting',
    'Investment',
    'Other Income',
  ];
  final List<String> _expenseCategories = [
    'Rent',
    'Utilities',
    'Payroll',
    'Supplies',
    'Software',
    'Marketing',
    'Travel',
    'Other Expense',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Transaction',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Transaction Type
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment<TransactionType>(
                  value: TransactionType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment<TransactionType>(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<TransactionType> selection) {
                setState(() {
                  _type = selection.first;
                  // Reset category when type changes
                  _category =
                      _type == TransactionType.income
                          ? _incomeCategories.first
                          : _expenseCategories.first;
                });
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              value: _category,
              items:
                  (_type == TransactionType.income
                          ? _incomeCategories
                          : _expenseCategories)
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Date
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2025),
                );
                if (picked != null && picked != _date) {
                  setState(() {
                    _date = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('MMMM d, y').format(_date)),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final transaction = Transaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    description: _descriptionController.text,
                    amount: double.parse(_amountController.text),
                    date: _date,
                    type: _type,
                    category: _category,
                  );

                  ref
                      .read(transactionsProvider.notifier)
                      .addTransaction(transaction);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction added successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Save Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

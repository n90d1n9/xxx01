// Reports Page (Enhanced)
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../models/payment.dart';
import '../states/budget_provider.dart';
import '../states/expense_provider.dart';
import '../states/recuring_expense_provider.dart';
import 'recurring_expense_page.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(budgetProvider);
    final expenses = ref.watch(expensesProvider);
    final recurringExpenses = ref.watch(recurringExpensesProvider);

    // Calculate monthly expenses
    final now = DateTime.now();
    final monthlyExpenses = expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);

    // Calculate category distribution
    final categoryExpenses = <String, double>{};
    for (var expense in expenses) {
      categoryExpenses[expense.category] =
          (categoryExpenses[expense.category] ?? 0) + expense.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.repeat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecurringExpensesPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'This Month',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(now),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Total Spent',
                          value: '\${monthlyExpenses.toStringAsFixed(2)}',
                          icon: Icons.payments,
                          color: Colors.blue,
                        ),
                        _StatItem(
                          label: 'Transactions',
                          value: expenses
                              .where(
                                (e) =>
                                    e.date.month == now.month &&
                                    e.date.year == now.year,
                              )
                              .length
                              .toString(),
                          icon: Icons.receipt_long,
                          color: Colors.green,
                        ),
                        _StatItem(
                          label: 'Avg/Day',
                          value:
                              '\${(monthlyExpenses / now.day).toStringAsFixed(2)}',
                          icon: Icons.trending_up,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Spending by Category Chart
            const Text(
              'Spending by Category',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (categories.any((cat) => cat.spent > 0))
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: categories.where((cat) => cat.spent > 0).map((
                      cat,
                    ) {
                      return PieChartSectionData(
                        value: cat.spent,
                        title: '${cat.name}\n\${cat.spent.toStringAsFixed(0)}',
                        color: cat.color,
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No expenses yet'),
                ),
              ),
            const SizedBox(height: 32),

            // Budget vs Actual
            const Text(
              'Budget vs Actual',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...categories.map((cat) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(cat.icon, color: cat.color, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '\${cat.spent.toStringAsFixed(0)} / \${cat.budget.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: cat.spent > cat.budget
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: cat.budget > 0
                            ? (cat.spent / cat.budget).clamp(0.0, 1.0)
                            : 0,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          cat.spent > cat.budget ? Colors.red : cat.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 32),

            // Recent Expenses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Expenses',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _showAllExpenses(context, ref),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (expenses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No expenses yet'),
                ),
              )
            else
              ...expenses.reversed.take(10).map((expense) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(expense.category),
                      child: const Icon(
                        Icons.attach_money,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      expense.description.isEmpty
                          ? expense.category
                          : expense.description,
                    ),
                    subtitle: Text(
                      '${expense.category} • ${DateFormat('MMM dd, HH:mm').format(expense.date)}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatPaymentMethod(expense.paymentMethod),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

            // Recurring Expenses Summary
            if (recurringExpenses.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'Recurring Expenses',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Monthly Recurring',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '\${recurringExpenses.where((e) => e.isActive && e.recurrence == RecurrenceType.monthly).fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Active Subscriptions',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            recurringExpenses
                                .where((e) => e.isActive)
                                .length
                                .toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllExpenses(BuildContext context, WidgetRef ref) {
    final expenses = ref.read(expensesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Expenses',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses.reversed.toList()[index];
                  return Dismissible(
                    key: Key(expense.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      ref
                          .read(expensesProvider.notifier)
                          .deleteExpense(expense.id);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCategoryColor(expense.category),
                        child: const Icon(
                          Icons.attach_money,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        expense.description.isEmpty
                            ? expense.category
                            : expense.description,
                      ),
                      subtitle: Text(
                        '${expense.category} • ${DateFormat('MMM dd, yyyy HH:mm').format(expense.date)}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatPaymentMethod(expense.paymentMethod),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Groceries':
        return Colors.green;
      case 'Utilities':
        return Colors.blue;
      case 'Entertainment':
        return Colors.purple;
      case 'Transportation':
        return Colors.orange;
      case 'Healthcare':
        return Colors.red;
      case 'Education':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _formatPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.ewallet:
        return 'E-Wallet';
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

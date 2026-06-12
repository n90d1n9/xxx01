// Recurring Expenses Page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/recurring_expense.dart';
import '../states/recuring_expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class RecurringExpensesPage extends ConsumerWidget {
  const RecurringExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringExpenses = ref.watch(recurringExpensesProvider);
    final activeExpenses = recurringExpenses.where((e) => e.isActive).toList();
    final inactiveExpenses = recurringExpenses
        .where((e) => !e.isActive)
        .toList();

    final totalMonthly = activeExpenses
        .where((e) => e.recurrence == RecurrenceType.monthly)
        .fold(0.0, (sum, e) => sum + e.amount);

    final totalWeekly = activeExpenses
        .where((e) => e.recurrence == RecurrenceType.weekly)
        .fold(0.0, (sum, e) => sum + e.amount);

    final totalYearly = activeExpenses
        .where((e) => e.recurrence == RecurrenceType.yearly)
        .fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Expenses'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRecurringExpenseDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Section
          _buildSummarySection(totalMonthly, totalWeekly, totalYearly),

          // Expenses List
          Expanded(
            child: recurringExpenses.isEmpty
                ? _buildEmptyState()
                : _buildExpensesList(
                    activeExpenses,
                    inactiveExpenses,
                    ref,
                    context,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecurringExpenseDialog(context, ref),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummarySection(double monthly, double weekly, double yearly) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.indigo.shade50,
      child: Column(
        children: [
          // Monthly Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${monthly.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Other Recurrence Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRecurrenceTotal('Weekly', weekly, RecurrenceType.weekly),
              _buildRecurrenceTotal('Yearly', yearly, RecurrenceType.yearly),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecurrenceTotal(
    String label,
    double amount,
    RecurrenceType type,
  ) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _getRecurrenceColor(type),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.autorenew, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Recurring Expenses',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Add your monthly subscriptions, bills, and other recurring expenses to track them automatically',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(
    List<RecurringExpense> activeExpenses,
    List<RecurringExpense> inactiveExpenses,
    WidgetRef ref,
    BuildContext context,
  ) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        if (activeExpenses.isNotEmpty) ...[
          _buildSectionHeader('Active Expenses', Colors.indigo),
          ...activeExpenses.map(
            (expense) => _buildRecurringExpenseCard(context, ref, expense),
          ),
        ],
        if (inactiveExpenses.isNotEmpty) ...[
          _buildSectionHeader('Inactive Expenses', Colors.grey),
          ...inactiveExpenses.map(
            (expense) => _buildRecurringExpenseCard(context, ref, expense),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRecurringExpenseCard(
    BuildContext context,
    WidgetRef ref,
    RecurringExpense expense,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      color: expense.isActive ? null : Colors.grey.shade100,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getRecurrenceColor(expense.recurrence).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getRecurrenceIcon(expense.recurrence),
            color: _getRecurrenceColor(expense.recurrence),
            size: 20,
          ),
        ),
        title: Text(
          expense.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: expense.isActive ? null : TextDecoration.lineThrough,
            color: expense.isActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    expense.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.indigo.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getRecurrenceText(expense.recurrence),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            if (!expense.isActive) ...[
              const SizedBox(height: 2),
              Text(
                'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: expense.isActive ? Colors.indigo : Colors.grey,
              ),
            ),
            Text(
              _getNextOccurrenceText(expense),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        onTap: () => _showExpenseDetails(context, ref, expense),
        onLongPress: () => _showExpenseActions(context, ref, expense),
      ),
    );
  }

  Color _getRecurrenceColor(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return Colors.blue;
      case RecurrenceType.weekly:
        return Colors.green;
      case RecurrenceType.monthly:
        return Colors.indigo;
      case RecurrenceType.yearly:
        return Colors.orange;
    }
  }

  IconData _getRecurrenceIcon(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return Icons.calendar_today;
      case RecurrenceType.weekly:
        return Icons.calendar_view_week;
      case RecurrenceType.monthly:
        return Icons.calendar_view_month;
      case RecurrenceType.yearly:
        return Icons.calendar_today;
    }
  }

  String _getRecurrenceText(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
    }
  }

  String _getNextOccurrenceText(RecurringExpense expense) {
    if (!expense.isActive) return 'Paused';

    final now = DateTime.now();
    switch (expense.recurrence) {
      case RecurrenceType.daily:
        return 'Every day';
      case RecurrenceType.weekly:
        return 'Every week';
      case RecurrenceType.monthly:
        final nextDate = DateTime(
          now.year,
          now.month + 1,
          expense.startDate.day,
        );
        final daysLeft = nextDate.difference(now).inDays;
        return '$daysLeft days left';
      case RecurrenceType.yearly:
        final nextDate = DateTime(
          now.year + 1,
          expense.startDate.month,
          expense.startDate.day,
        );
        final monthsLeft = (nextDate.difference(now).inDays / 30).ceil();
        return '$monthsLeft months left';
    }
  }

  void _showAddRecurringExpenseDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Utilities';
    RecurrenceType recurrence = RecurrenceType.monthly;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Recurring Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Expense Name',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      [
                            'Utilities',
                            'Subscription',
                            'Rent/Mortgage',
                            'Insurance',
                            'Loan Payment',
                            'Entertainment',
                            'Transportation',
                            'Healthcare',
                            'Education',
                            'Other',
                          ]
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      category = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RecurrenceType>(
                  value: recurrence,
                  decoration: const InputDecoration(
                    labelText: 'Recurrence',
                    border: OutlineInputBorder(),
                  ),
                  items: RecurrenceType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_getRecurrenceText(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      recurrence = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  ref
                      .read(recurringExpensesProvider.notifier)
                      .addRecurring(
                        nameController.text,
                        double.tryParse(amountController.text) ?? 0,
                        category,
                        recurrence,
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added ${nameController.text} as recurring expense',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text(
                'Add Expense',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseDetails(
    BuildContext context,
    WidgetRef ref,
    RecurringExpense expense,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Amount', '\$${expense.amount.toStringAsFixed(2)}'),
            _buildDetailRow('Category', expense.category),
            _buildDetailRow(
              'Recurrence',
              _getRecurrenceText(expense.recurrence),
            ),
            _buildDetailRow('Status', expense.isActive ? 'Active' : 'Inactive'),
            _buildDetailRow('Started', _formatDate(expense.startDate)),
            if (expense.endDate != null)
              _buildDetailRow('Ends', _formatDate(expense.endDate!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showExpenseActions(
    BuildContext context,
    WidgetRef ref,
    RecurringExpense expense,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              expense.isActive ? Icons.pause : Icons.play_arrow,
              color: expense.isActive ? Colors.orange : Colors.green,
            ),
            title: Text(
              expense.isActive ? 'Pause Expense' : 'Activate Expense',
            ),
            onTap: () {
              ref
                  .read(recurringExpensesProvider.notifier)
                  .toggleActive(expense.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${expense.name} ${expense.isActive ? 'paused' : 'activated'}',
                  ),
                  backgroundColor: expense.isActive
                      ? Colors.orange
                      : Colors.green,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Expense'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, ref, expense);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    RecurringExpense expense,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Expense'),
        content: Text('Are you sure you want to delete "${expense.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(recurringExpensesProvider.notifier)
                  .deleteRecurring(expense.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted ${expense.name}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

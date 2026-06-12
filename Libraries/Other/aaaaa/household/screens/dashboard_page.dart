// Dashboard Page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../models/daily_task.dart';
import '../models/payment.dart';
import '../states/budget_provider.dart';
import '../states/daily_task_provider.dart';
import '../states/expense_provider.dart';
import '../states/recuring_expense_provider.dart';
import '../states/shopping_list_provider.dart';
import 'calendar_view_page.dart';
import 'recurring_expense_page.dart';
import 'report_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(dailyTasksProvider);
    final completedTasks = tasks.where((t) => t.completed).length;
    final totalSpent = ref.watch(totalSpentProvider);
    final totalBudget = ref.watch(totalBudgetProvider);
    final monthlyExpenses = ref.watch(monthlyExpensesProvider);
    final shoppingTotal = ref.watch(shoppingTotalProvider);
    final recurringExpenses = ref.watch(recurringExpensesProvider);
    final activeRecurring = recurringExpenses.where((e) => e.isActive).length;

    // Calculate budget usage percentage safely
    final budgetUsagePercentage = totalBudget > 0
        ? (totalSpent / totalBudget) * 100
        : 0;
    final budgetRemaining = totalBudget - totalSpent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(dailyTasksProvider),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context, ref),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyTasksProvider);
          ref.invalidate(shoppingListProvider);
          ref.invalidate(budgetProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context),
              const SizedBox(height: 24),

              // Stats Grid
              _buildStatsGrid(
                context,
                tasks.length,
                completedTasks,
                shoppingTotal,
                monthlyExpenses,
                budgetUsagePercentage.toDouble(),
                budgetRemaining,
                activeRecurring,
              ),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActionsSection(context, ref),
              const SizedBox(height: 24),

              // Recent Activity
              _buildRecentActivitySection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back!',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Text(
          _getGreetingMessage(),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.teal.shade700),
        ),
      ],
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! 🌅';
    if (hour < 17) return 'Good afternoon! ☀️';
    return 'Good evening! 🌙';
  }

  Widget _buildStatsGrid(
    BuildContext context,
    int totalTasks,
    int completedTasks,
    double shoppingTotal,
    double monthlyExpenses,
    double budgetUsagePercentage,
    double budgetRemaining,
    int activeRecurring,
  ) {
    return Column(
      children: [
        // First Row
        Row(
          children: [
            Expanded(
              child: _DashboardCard(
                title: 'Tasks',
                value: '$completedTasks/$totalTasks',
                icon: Icons.check_circle,
                color: Colors.blue,
                subtitle: 'completed',
                progress: totalTasks > 0 ? completedTasks / totalTasks : 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DashboardCard(
                title: 'Shopping List',
                value: '\$${shoppingTotal.toStringAsFixed(0)}',
                icon: Icons.shopping_cart,
                color: Colors.orange,
                subtitle: 'remaining',
                progress: shoppingTotal > 100 ? 1.0 : shoppingTotal / 100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Second Row
        Row(
          children: [
            Expanded(
              child: _DashboardCard(
                title: 'Monthly Spend',
                value: '\$${monthlyExpenses.toStringAsFixed(0)}',
                icon: Icons.calendar_month,
                color: Colors.purple,
                subtitle: 'this month',
                progress: monthlyExpenses > 1000 ? 1.0 : monthlyExpenses / 1000,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DashboardCard(
                title: 'Budget',
                value: '${budgetUsagePercentage.toStringAsFixed(0)}%',
                icon: Icons.pie_chart,
                color: budgetUsagePercentage > 100
                    ? Colors.red
                    : budgetUsagePercentage > 80
                    ? Colors.orange
                    : Colors.green,
                subtitle: budgetRemaining >= 0
                    ? '\$${budgetRemaining.toStringAsFixed(0)} left'
                    : '\$${budgetRemaining.abs().toStringAsFixed(0)} over',
                progress: budgetUsagePercentage.clamp(0.0, 1.0) / 100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Third Row - Additional Stats
        Row(
          children: [
            Expanded(
              child: _DashboardCard(
                title: 'Recurring',
                value: '$activeRecurring',
                icon: Icons.autorenew,
                color: Colors.indigo,
                subtitle: 'active bills',
                progress: activeRecurring > 0 ? 0.5 : 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DashboardCard(
                title: 'Daily Goal',
                value:
                    '${((completedTasks / totalTasks) * 100).toStringAsFixed(0)}%',
                icon: Icons.flag,
                color: Colors.green,
                subtitle: 'tasks completed',
                progress: totalTasks > 0 ? completedTasks / totalTasks : 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your household tasks quickly',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickActionButton(
              icon: Icons.add_task,
              label: 'Add Task',
              color: Colors.blue,
              onTap: () => _showAddTaskDialog(context, ref),
            ),
            _QuickActionButton(
              icon: Icons.add_shopping_cart,
              label: 'Add Item',
              color: Colors.orange,
              onTap: () => _showAddItemDialog(context, ref),
            ),
            _QuickActionButton(
              icon: Icons.attach_money,
              label: 'Add Expense',
              color: Colors.purple,
              onTap: () => _showAddExpenseQuickDialog(context, ref),
            ),
            _QuickActionButton(
              icon: Icons.repeat,
              label: 'Recurring',
              color: Colors.indigo,
              onTap: () => _showRecurringDialog(context, ref),
            ),
            _QuickActionButton(
              icon: Icons.calendar_today,
              label: 'Calendar',
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarViewPage(),
                ),
              ),
            ),
            _QuickActionButton(
              icon: Icons.analytics,
              label: 'Reports',
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddExpenseQuickDialog(BuildContext context, WidgetRef ref) {
    final categories = ref.read(budgetProvider);
    final amountController = TextEditingController();
    final descController = TextEditingController();
    String category = categories.isNotEmpty
        ? categories.first.name
        : 'Groceries';
    PaymentMethod method = PaymentMethod.cash;
    DateTime expenseDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat.name,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      category = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount *',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    hintText: 'What was this expense for?',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today, size: 20),
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(expenseDate)),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: expenseDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        expenseDate = pickedDate;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PaymentMethod>(
                  value: method,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                  ),
                  items: PaymentMethod.values
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(_formatPaymentMethod(m)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      method = value!;
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
                if (amountController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount > 0) {
                    // Add to budget
                    ref
                        .read(budgetProvider.notifier)
                        .addExpense(
                          category,
                          amount,
                          descController.text.isEmpty
                              ? 'Expense'
                              : descController.text,
                          expenseDate,
                        );

                    // Add to expenses list
                    ref
                        .read(expensesProvider.notifier)
                        .addExpense(
                          category,
                          amount,
                          descController.text.isEmpty
                              ? 'Expense'
                              : descController.text,
                          method,
                          expenseDate,
                        );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Expense of \$${amount.toStringAsFixed(2)} added to $category',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
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

  String _formatPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.ewallet:
        return 'E-Wallet';
    }
  }

  void _showRecurringDialog(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecurringExpensesPage()),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarViewPage(),
                ),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Latest household activities',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        _RecentActivityWidget(),
      ],
    );
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete_sweep, color: Colors.orange.shade700),
              title: const Text('Clear Completed Tasks'),
              subtitle: const Text('Remove all completed tasks'),
              onTap: () {
                ref.read(dailyTasksProvider.notifier).clearCompleted();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Completed tasks cleared'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.cleaning_services,
                color: Colors.red.shade700,
              ),
              title: const Text('Clear Purchased Items'),
              subtitle: const Text('Remove bought items from shopping list'),
              onTap: () {
                ref.read(shoppingListProvider.notifier).clearPurchased();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Purchased items cleared'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh, color: Colors.blue.shade700),
              title: const Text('Reset Monthly Budget'),
              subtitle: const Text('Start fresh for new month'),
              onTap: () {
                ref.read(budgetProvider.notifier).resetSpending();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget spending reset for new month'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
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

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    DateTime dueDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Task Description *',
                    border: OutlineInputBorder(),
                    hintText: 'What needs to be done?',
                  ),
                  autofocus: true,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskPriority>(
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: TaskPriority.values
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              Icon(
                                _getPriorityIcon(p),
                                color: _getPriorityColor(p),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(p.name.toUpperCase()),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      priority = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Due Date'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(dueDate)),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dueDate = pickedDate;
                      });
                    }
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
                if (controller.text.isNotEmpty) {
                  ref
                      .read(dailyTasksProvider.notifier)
                      .addTask(controller.text, priority, dueDate.timeZoneName);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${controller.text}" added to tasks'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                'Add Task',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    String category = 'Groceries';
    String? budgetCategory;

    // Get available budget categories
    final budgetCategories = ref.read(budgetProvider);
    final availableBudgetCategories = budgetCategories
        .map((cat) => cat.name)
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Shopping Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Item Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    border: OutlineInputBorder(),
                    hintText: 'Enter item name',
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Price and Quantity Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price *',
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                          hintText: '0.00',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Qty',
                          border: OutlineInputBorder(),
                          hintText: '1',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),

                // Total Price Preview
                if (priceController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Total: \$${_calculateTotal(priceController.text, quantityController.text).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Notes
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Additional details...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Shopping Category
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Shopping Category *',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      [
                            'Groceries',
                            'Utilities',
                            'Entertainment',
                            'Transportation',
                            'Healthcare',
                            'Education',
                            'Household',
                            'Personal Care',
                            'Clothing',
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

                // Budget Category (Optional)
                DropdownButtonFormField<String>(
                  value: budgetCategory,
                  decoration: const InputDecoration(
                    labelText: 'Link to Budget Category (optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('No budget category'),
                    ),
                    ...availableBudgetCategories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      budgetCategory = value;
                    });
                  },
                ),

                // Budget Info if linked
                if (budgetCategory != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildBudgetInfo(ref, budgetCategory!),
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
                if (_validateForm(nameController.text, priceController.text)) {
                  _addShoppingItem(
                    ref,
                    nameController.text,
                    priceController.text,
                    quantityController.text,
                    category,
                    notesController.text,
                    budgetCategory,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal(String priceText, String quantityText) {
    final price = double.tryParse(priceText) ?? 0;
    final quantity = int.tryParse(quantityText) ?? 1;
    return price * quantity;
  }

  bool _validateForm(String name, String price) {
    if (name.isEmpty) {
      ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Please enter an item name'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (price.isEmpty || double.tryParse(price) == null) {
      ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final priceValue = double.tryParse(price) ?? 0;
    if (priceValue <= 0) {
      ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Price must be greater than 0'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  void _addShoppingItem(
    WidgetRef ref,
    String name,
    String priceText,
    String quantityText,
    String category,
    String notes,
    String? budgetCategory,
  ) {
    final price = double.tryParse(priceText) ?? 0;
    final quantity = int.tryParse(quantityText) ?? 1;

    ref
        .read(shoppingListProvider.notifier)
        .addItem(
          name,
          price,
          quantity,
          category,
          notes.isEmpty ? null : notes,
          budgetCategory,
        );

    // Show success message
    ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
      SnackBar(
        content: Text('"$name" added to shopping list'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // If linked to budget category, show budget info
    if (budgetCategory != null) {
      final budgetCategories = ref.read(budgetProvider);
      final budgetCat = budgetCategories.firstWhere(
        (cat) => cat.name == budgetCategory,
        orElse: () => budgetCategories.first,
      );

      final totalCost = price * quantity;
      final remaining = budgetCat.budget - budgetCat.spent;

      if (totalCost > remaining) {
        ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
          SnackBar(
            content: Text(
              'Warning: This item exceeds your $budgetCategory budget by \$${(totalCost - remaining).toStringAsFixed(2)}',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildBudgetInfo(WidgetRef ref, String budgetCategoryName) {
    final budgetCategories = ref.read(budgetProvider);
    final budgetCategory = budgetCategories.firstWhere(
      (cat) => cat.name == budgetCategoryName,
      orElse: () => budgetCategories.first,
    );

    final remaining = budgetCategory.budget - budgetCategory.spent;
    final percentage = budgetCategory.budget > 0
        ? (budgetCategory.spent / budgetCategory.budget) * 100
        : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget: $budgetCategoryName',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: \$${budgetCategory.spent.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(
                'Remaining: \$${remaining.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: remaining < 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0).toDouble(),
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(
              percentage > 100
                  ? Colors.red
                  : percentage > 80
                  ? Colors.orange
                  : Colors.green,
            ),
            minHeight: 6,
          ),
          const SizedBox(height: 2),
          Text(
            '${percentage.toStringAsFixed(1)}% used',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  final double progress;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);
    final recentExpenses = expenses.reversed.take(5).toList();

    if (recentExpenses.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No recent activity'),
        ),
      );
    }

    return Column(
      children: recentExpenses.map((expense) {
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
            subtitle: Text(DateFormat('MMM dd, HH:mm').format(expense.date)),
            trailing: Text(
              '\${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
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
  /* 
  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    String category = 'Groceries';
    String? budgetCategory;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Shopping Item'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Item Name *',
                            border: OutlineInputBorder(),
                          ),
                          autofocus: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: priceController,
                                decoration: const InputDecoration(
                                  labelText: 'Price *',
                                  border: OutlineInputBorder(),
                                  prefixText: '\$',
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'Qty',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              [
                                    'Groceries',
                                    'Utilities',
                                    'Entertainment',
                                    'Transportation',
                                    'Healthcare',
                                    'Education',
                                    'Household',
                                    'Other',
                                  ]
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              category = value!;
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
                            priceController.text.isNotEmpty) {
                          ref
                              .read(shoppingListProvider.notifier)
                              .addItem(
                                nameController.text,
                                double.tryParse(priceController.text) ?? 0,
                                int.tryParse(quantityController.text) ?? 1,
                                category,
                                notesController.text.isEmpty
                                    ? null
                                    : notesController.text,
                              );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '"${nameController.text}" added to shopping list',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text(
                        'Add Item',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showAddExpenseQuickDialog(BuildContext context, WidgetRef ref) {
    final categories = ref.read(budgetProvider);
    final amountController = TextEditingController();
    final descController = TextEditingController();
    String category =
        categories.isNotEmpty ? categories.first.name : 'Groceries';
    PaymentMethod method = PaymentMethod.cash;
    DateTime expenseDate = DateTime.now();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Expense'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              categories
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat.name,
                                      child: Text(cat.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              category = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount *',
                            border: OutlineInputBorder(),
                            prefixText: '\$',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          autofocus: true,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            hintText: 'What was this expense for?',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.calendar_today, size: 20),
                          title: const Text('Date'),
                          subtitle: Text(
                            DateFormat('MMM d, yyyy').format(expenseDate),
                          ),
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: expenseDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                expenseDate = pickedDate;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<PaymentMethod>(
                          value: method,
                          decoration: const InputDecoration(
                            labelText: 'Payment Method',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              PaymentMethod.values
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(_formatPaymentMethod(m)),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              method = value!;
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
                        if (amountController.text.isNotEmpty) {
                          final amount =
                              double.tryParse(amountController.text) ?? 0;
                          if (amount > 0) {
                            // Add to budget
                            ref
                                .read(budgetProvider.notifier)
                                .addExpense(
                                  category,
                                  amount,
                                  descController.text.isEmpty
                                      ? 'Expense'
                                      : descController.text,
                                  expenseDate,
                                );

                            // Add to expenses list
                            ref
                                .read(expensesProvider.notifier)
                                .addExpense(
                                  category,
                                  amount,
                                  descController.text.isEmpty
                                      ? 'Expense'
                                      : descController.text,
                                  method,
                                  expenseDate,
                                );

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Expense of \$${amount.toStringAsFixed(2)} added to $category',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                      ),
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

  void _showRecurringDialog(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecurringExpensesPage()),
    );
  } */

  String _formatPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.ewallet:
        return 'E-Wallet';
    }
  }
}

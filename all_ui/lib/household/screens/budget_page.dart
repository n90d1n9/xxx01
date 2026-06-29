// Budget Page (Enhanced)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/budget_category.dart';
import '../models/payment.dart';
import '../states/budget_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(budgetProvider);
    final totalBudget = ref.watch(totalBudgetProvider);
    final totalSpent = ref.watch(totalSpentProvider);
    final remaining = totalBudget - totalSpent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showResetBudgetDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Budget Summary Section
          _buildBudgetSummary(totalBudget, totalSpent, remaining),

          // Categories List
          Expanded(
            child:
                categories.isEmpty
                    ? _buildEmptyBudgetState(ref, context)
                    : _buildCategoriesList(categories, ref, context),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary(
    double totalBudget,
    double totalSpent,
    double remaining,
  ) {
    final progressValue =
        totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0;
    final isOverBudget = totalSpent > totalBudget;
    final isNegativeRemaining = remaining < 0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.purple.shade50,
      child: Column(
        children: [
          // Budget Overview Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBudgetColumn(
                'Total Budget',
                '\$${totalBudget.toStringAsFixed(2)}',
                Colors.black,
              ),
              _buildBudgetColumn(
                'Remaining',
                '\$${remaining.toStringAsFixed(2)}',
                isNegativeRemaining ? Colors.red : Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Spent Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Spent:', style: TextStyle(fontSize: 16)),
              Text(
                '\$${totalSpent.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isOverBudget ? Colors.red : Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          LinearProgressIndicator(
            value: progressValue.toDouble(),
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(
              isOverBudget ? Colors.red : Colors.green,
            ),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 4),

          // Progress Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progressValue * 100).toStringAsFixed(1)}% used',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                isOverBudget
                    ? 'Over budget by \$${(totalSpent - totalBudget).abs().toStringAsFixed(2)}'
                    : 'On track',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverBudget ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetColumn(String title, String amount, Color amountColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBudgetState(WidgetRef ref, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Budget Categories',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add budget categories to get started',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showAddCategoryDialog(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
    List<BudgetCategory> categories,
    WidgetRef ref,
    BuildContext context,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return _buildCategoryCard(cat, ref, context);
      },
    );
  }

  Widget _buildCategoryCard(
    BudgetCategory cat,
    WidgetRef ref,
    BuildContext context,
  ) {
    final percentage = cat.budget > 0 ? cat.spent / cat.budget : 0;
    final remaining = cat.budget - cat.spent;
    final isOverBudget = percentage > 1;
    final isWarning = percentage > 0.8;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Remaining: \$${remaining.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              remaining < 0 ? Colors.red : Colors.grey.shade700,
                          fontWeight:
                              remaining < 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () => _showEditBudgetDialog(context, ref, cat),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        size: 20,
                        color: Colors.purple,
                      ),
                      onPressed:
                          () => _showAddExpenseDialog(context, ref, cat.name),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Budget Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${cat.spent.toStringAsFixed(2)} spent',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '\$${cat.budget.toStringAsFixed(2)} budget',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0).toDouble(),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(
                  isOverBudget
                      ? Colors.red
                      : isWarning
                      ? Colors.orange
                      : cat.color,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),

            // Progress Text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}% used',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverBudget ? Colors.red : Colors.grey.shade600,
                    fontWeight:
                        isOverBudget ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isOverBudget)
                  Text(
                    'Over budget!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showResetBudgetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Budget'),
            content: const Text('Reset all spending to zero for new month?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(budgetProvider.notifier).resetSpending();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Budget spending reset to zero'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Reset', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showEditBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    BudgetCategory cat,
  ) {
    final budgetController = TextEditingController(
      text: cat.budget.toStringAsFixed(2),
    );
    BudgetPeriod selectedPeriod = cat.period;
    DateTime startDate = cat.startDate;
    DateTime endDate = cat.endDate;
    bool isCustomDate = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Edit ${cat.name} Budget'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Budget Amount
                        TextField(
                          controller: budgetController,
                          decoration: const InputDecoration(
                            labelText: 'Budget Amount *',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                            hintText: '0.00',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),

                        // Budget Period
                        DropdownButtonFormField<BudgetPeriod>(
                          value: selectedPeriod,
                          decoration: const InputDecoration(
                            labelText: 'Budget Period *',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              BudgetPeriod.values
                                  .map(
                                    (period) => DropdownMenuItem(
                                      value: period,
                                      child: Text(_getBudgetPeriodText(period)),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPeriod = value!;
                              if (selectedPeriod != BudgetPeriod.custom) {
                                // Auto-calculate dates for standard periods
                                final now = DateTime.now();
                                switch (selectedPeriod) {
                                  case BudgetPeriod.weekly:
                                    startDate = DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                    );
                                    endDate = startDate.add(
                                      const Duration(days: 6),
                                    );
                                    break;
                                  case BudgetPeriod.monthly:
                                    startDate = DateTime(
                                      now.year,
                                      now.month,
                                      1,
                                    );
                                    endDate = DateTime(
                                      now.year,
                                      now.month + 1,
                                      0,
                                    );
                                    break;
                                  case BudgetPeriod.yearly:
                                    startDate = DateTime(now.year, 1, 1);
                                    endDate = DateTime(now.year, 12, 31);
                                    break;
                                  case BudgetPeriod.custom:
                                    break;
                                }
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date Range Selector
                        if (selectedPeriod == BudgetPeriod.custom) ...[
                          Column(
                            children: [
                              // Start Date
                              ListTile(
                                leading: const Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                ),
                                title: const Text('Start Date'),
                                subtitle: Text(
                                  DateFormat('MMM d, yyyy').format(startDate),
                                ),
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: startDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      startDate = pickedDate;
                                      if (endDate.isBefore(startDate)) {
                                        endDate = startDate.add(
                                          const Duration(days: 30),
                                        );
                                      }
                                    });
                                  }
                                },
                              ),

                              // End Date
                              ListTile(
                                leading: const Icon(Icons.event, size: 20),
                                title: const Text('End Date'),
                                subtitle: Text(
                                  DateFormat('MMM d, yyyy').format(endDate),
                                ),
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: endDate,
                                    firstDate: startDate,
                                    lastDate: DateTime(2030),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      endDate = pickedDate;
                                    });
                                  }
                                },
                              ),

                              // Days Remaining
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Duration:'),
                                    Text(
                                      '${endDate.difference(startDate).inDays + 1} days',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Current Period Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Period:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('MMM d').format(cat.startDate)} - ${DateFormat('MMM d, yyyy').format(cat.endDate)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Spent: \$${cat.spent.toStringAsFixed(2)} / \$${cat.budget.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      cat.spent > cat.budget
                                          ? Colors.red
                                          : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
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
                        if (_validateBudgetForm(budgetController.text)) {
                          final amount =
                              double.tryParse(budgetController.text) ??
                              cat.budget;
                          ref
                              .read(budgetProvider.notifier)
                              .updateBudget(
                                cat.name,
                                amount,
                                selectedPeriod,
                                startDate,
                                endDate,
                              );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${cat.name} budget updated to \$${amount.toStringAsFixed(2)}',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                      ),
                      child: const Text(
                        'Save Budget',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showAddExpenseDialog(
    BuildContext context,
    WidgetRef ref,
    String category,
  ) {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    PaymentMethod method = PaymentMethod.cash;
    DateTime expenseDate = DateTime.now();

    // Get current budget info
    final budgetCategories = ref.read(budgetProvider);
    final currentBudget = budgetCategories.firstWhere(
      (cat) => cat.name == category,
      orElse: () => budgetCategories.first,
    );

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Add Expense - $category'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Budget Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Budget: \$${currentBudget.budget.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Spent: \$${currentBudget.spent.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Remaining: \$${(currentBudget.budget - currentBudget.spent).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color:
                                          (currentBudget.budget -
                                                      currentBudget.spent) <
                                                  0
                                              ? Colors.red
                                              : Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value:
                                    currentBudget.budget > 0
                                        ? (currentBudget.spent /
                                                currentBudget.budget)
                                            .clamp(0.0, 1.0)
                                        : 0,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation(
                                  currentBudget.spent > currentBudget.budget
                                      ? Colors.red
                                      : Colors.purple,
                                ),
                                minHeight: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Amount
                        TextField(
                          controller: amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount *',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                            hintText: '0.00',
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),

                        // Expense Date
                        ListTile(
                          leading: const Icon(Icons.calendar_today, size: 20),
                          title: const Text('Expense Date'),
                          subtitle: Text(
                            DateFormat('MMM d, yyyy').format(expenseDate),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () async {
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
                        ),
                        const SizedBox(height: 8),

                        // Description
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

                        // Payment Method
                        DropdownButtonFormField<PaymentMethod>(
                          value: method,
                          decoration: const InputDecoration(
                            labelText: 'Payment Method',
                            border: OutlineInputBorder(),
                          ),
                          items:
                              PaymentMethod.values
                                  .map(
                                    (method) => DropdownMenuItem(
                                      value: method,
                                      child: Text(
                                        _getPaymentMethodText(method),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              method = value!;
                            });
                          },
                        ),

                        // Budget Impact Preview
                        if (amountController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _buildBudgetImpactPreview(
                              currentBudget,
                              double.tryParse(amountController.text) ?? 0,
                            ),
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
                        if (_validateExpenseForm(amountController.text)) {
                          final amount =
                              double.tryParse(amountController.text) ?? 0;
                          final description =
                              descController.text.isEmpty
                                  ? 'Expense'
                                  : descController.text;

                          _addExpenseWithValidation(
                            context,
                            ref,
                            category,
                            amount,
                            description,
                            method,
                            expenseDate,
                          );
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

  // Helper Methods
  String _getBudgetPeriodText(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.yearly:
        return 'Yearly';
      case BudgetPeriod.custom:
        return 'Custom Date Range';
    }
  }

  bool _validateBudgetForm(String budgetText) {
    if (budgetText.isEmpty) {
      ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Please enter a budget amount'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final amount = double.tryParse(budgetText);
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid budget amount'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  bool _validateExpenseForm(String amountText) {
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(FlutterErrorDetails as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than 0'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Widget _buildBudgetImpactPreview(
    BudgetCategory budget,
    double expenseAmount,
  ) {
    final newSpent = budget.spent + expenseAmount;
    final remaining = budget.budget - newSpent;
    final newPercentage =
        budget.budget > 0 ? (newSpent / budget.budget) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: remaining < 0 ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: remaining < 0 ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            remaining < 0 ? 'Over Budget!' : 'Budget Impact',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: remaining < 0 ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Total:',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(
                '\$${newSpent.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: remaining < 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining:',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              Text(
                '\$${remaining.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: remaining < 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          if (remaining < 0)
            const Text(
              'This expense will exceed your budget',
              style: TextStyle(fontSize: 10, color: Colors.red),
            ),
        ],
      ),
    );
  }

  void _addExpenseWithValidation(
    BuildContext context,
    WidgetRef ref,
    String category,
    double amount,
    String description,
    PaymentMethod method,
    DateTime date,
  ) {
    // Check if expense date is within budget period
    final budgetCategories = ref.read(budgetProvider);
    final currentBudget = budgetCategories.firstWhere(
      (cat) => cat.name == category,
      orElse: () => budgetCategories.first,
    );

    if (!_isDateInRange(date, currentBudget.startDate, currentBudget.endDate)) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Date Warning'),
              content: Text(
                'The selected date (${DateFormat('MMM d, yyyy').format(date)}) '
                'is outside the current budget period '
                '(${DateFormat('MMM d').format(currentBudget.startDate)} - '
                '${DateFormat('MMM d, yyyy').format(currentBudget.endDate)}).\n\n'
                'Do you want to add it anyway?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _addExpenseAndClose(
                      context,
                      ref,
                      category,
                      amount,
                      description,
                      method,
                      date,
                    );
                  },
                  child: const Text('Add Anyway'),
                ),
              ],
            ),
      );
    } else {
      _addExpenseAndClose(
        context,
        ref,
        category,
        amount,
        description,
        method,
        date,
      );
    }
  }

  void _addExpenseAndClose(
    BuildContext context,
    WidgetRef ref,
    String category,
    double amount,
    String description,
    PaymentMethod method,
    DateTime date,
  ) {
    ref
        .read(budgetProvider.notifier)
        .addExpense(category, amount, description, date);
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

  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    // This would need to be implemented based on your budget provider capabilities
    // For now, showing a placeholder dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Category'),
            content: const Text('Category management feature coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String _getPaymentMethodText(PaymentMethod method) {
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

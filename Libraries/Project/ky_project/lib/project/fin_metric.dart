// FINANCIAL HEALTH SCORECARDS

// Import required packages
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class FinancialMetric {
  final String name;
  final double value;
  final double target;
  final double previousValue;
  final List<double> historicalData;

  FinancialMetric({
    required this.name,
    required this.value,
    required this.target,
    required this.previousValue,
    required this.historicalData,
  });
}

// Providers
final financialMetricsProvider =
    StateNotifierProvider<FinancialMetricsNotifier, List<FinancialMetric>>((
      ref,
    ) {
      return FinancialMetricsNotifier();
    });

class FinancialMetricsNotifier extends StateNotifier<List<FinancialMetric>> {
  FinancialMetricsNotifier()
    : super([
        FinancialMetric(
          name: 'Gross Profit Margin',
          value: 0.32,
          target: 0.35,
          previousValue: 0.29,
          historicalData: [0.28, 0.29, 0.31, 0.32],
        ),
        FinancialMetric(
          name: 'ROI',
          value: 0.18,
          target: 0.20,
          previousValue: 0.15,
          historicalData: [0.12, 0.14, 0.15, 0.18],
        ),
        FinancialMetric(
          name: 'CPI',
          value: 0.95,
          target: 1.0,
          previousValue: 0.90,
          historicalData: [0.85, 0.88, 0.90, 0.95],
        ),
        FinancialMetric(
          name: 'SPI',
          value: 0.98,
          target: 1.0,
          previousValue: 0.92,
          historicalData: [0.90, 0.91, 0.92, 0.98],
        ),
      ]);

  void updateMetric(String name, double newValue) {
    state = state.map((metric) {
      if (metric.name == name) {
        final historicalData = [...metric.historicalData, newValue];
        if (historicalData.length > 10) {
          historicalData.removeAt(0);
        }
        return FinancialMetric(
          name: metric.name,
          value: newValue,
          target: metric.target,
          previousValue: metric.value,
          historicalData: historicalData,
        );
      }
      return metric;
    }).toList();
  }
}

// Widgets
class FinancialHealthScorecard extends ConsumerWidget {
  const FinancialHealthScorecard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(financialMetricsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Financial Health',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    // Implement refresh logic
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: metrics
                  .map((metric) => MetricCard(metric: metric))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final FinancialMetric metric;

  const MetricCard({Key? key, required this.metric}) : super(key: key);

  Color _getStatusColor() {
    final ratio = metric.value / metric.target;
    if (ratio >= 1) return Colors.green;
    if (ratio >= 0.8) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final percentChange =
        ((metric.value - metric.previousValue) / metric.previousValue) * 100;
    final isPositive = percentChange > 0;
    final formatter = NumberFormat.percentPattern();

    return SizedBox(
      width: 250,
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(metric.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    formatter.format(metric.value),
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 14,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${percentChange.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 80,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          metric.historicalData.length,
                          (index) => FlSpot(
                            index.toDouble(),
                            metric.historicalData[index],
                          ),
                        ),
                        isCurved: true,
                        color: _getStatusColor(),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: _getStatusColor().withOpacity(0.1),
                        ),
                      ),
                    ],
                    minX: 0,
                    maxX: (metric.historicalData.length - 1).toDouble(),
                    minY: 0,
                    maxY:
                        metric.historicalData.reduce((a, b) => a > b ? a : b) *
                        1.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Target: ${formatter.format(metric.target)}'),
                  Container(
                    width: 100,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: metric.value / metric.target > 1
                          ? 1
                          : metric.value / metric.target,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
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
}

// EXPENSE APPROVAL WORKFLOW

// Models
enum ApprovalStatus { pending, approved, rejected }

class ExpenseItem {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String submittedBy;
  final List<String> approvers;
  final List<String> receipts;
  final ApprovalStatus status;
  final int currentApprovalLevel;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.submittedBy,
    required this.approvers,
    required this.receipts,
    required this.status,
    required this.currentApprovalLevel,
  });
}

// Providers
final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<ExpenseItem>>((ref) {
      return ExpensesNotifier();
    });

class ExpensesNotifier extends StateNotifier<List<ExpenseItem>> {
  ExpensesNotifier()
    : super([
        ExpenseItem(
          id: 'exp-001',
          title: 'Client Meeting Lunch',
          amount: 120.50,
          date: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Meals & Entertainment',
          submittedBy: 'John Doe',
          approvers: ['Linda Manager', 'Finance Dept'],
          receipts: ['receipt_001.jpg'],
          status: ApprovalStatus.pending,
          currentApprovalLevel: 0,
        ),
        ExpenseItem(
          id: 'exp-002',
          title: 'Office Supplies',
          amount: 85.75,
          date: DateTime.now().subtract(const Duration(days: 5)),
          category: 'Office Expenses',
          submittedBy: 'Jane Smith',
          approvers: ['Linda Manager', 'Finance Dept'],
          receipts: ['receipt_002.jpg', 'receipt_003.jpg'],
          status: ApprovalStatus.approved,
          currentApprovalLevel: 2,
        ),
      ]);

  void addExpense(ExpenseItem expense) {
    state = [...state, expense];
  }

  void updateExpenseStatus(
    String id,
    ApprovalStatus status,
    int approvalLevel,
  ) {
    state = state.map((expense) {
      if (expense.id == id) {
        return ExpenseItem(
          id: expense.id,
          title: expense.title,
          amount: expense.amount,
          date: expense.date,
          category: expense.category,
          submittedBy: expense.submittedBy,
          approvers: expense.approvers,
          receipts: expense.receipts,
          status: status,
          currentApprovalLevel: approvalLevel,
        );
      }
      return expense;
    }).toList();
  }
}

// Widgets
class ExpenseApprovalFlow extends ConsumerWidget {
  const ExpenseApprovalFlow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Approvals',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New Expense'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ExpenseSubmissionForm(),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              return ExpenseCard(expense: expenses[index]);
            },
          ),
        ),
      ],
    );
  }
}

class ExpenseCard extends StatelessWidget {
  final ExpenseItem expense;

  const ExpenseCard({Key? key, required this.expense}) : super(key: key);

  Color _getStatusColor() {
    switch (expense.status) {
      case ApprovalStatus.approved:
        return Colors.green;
      case ApprovalStatus.rejected:
        return Colors.red;
      case ApprovalStatus.pending:
        return Colors.amber;
    }
  }

  String _getStatusText() {
    switch (expense.status) {
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
      case ApprovalStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(expense.date),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(expense.amount),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Submitted by ${expense.submittedBy}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Approval Flow',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ApprovalProgressIndicator(
              approvers: expense.approvers,
              currentLevel: expense.currentApprovalLevel,
              status: expense.status,
            ),
            const SizedBox(height: 16),
            if (expense.receipts.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receipts (${expense.receipts.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: expense.receipts.length,
                      itemBuilder: (context, index) {
                        return ReceiptThumbnail(
                          receiptUrl: expense.receipts[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ApprovalProgressIndicator extends StatelessWidget {
  final List<String> approvers;
  final int currentLevel;
  final ApprovalStatus status;

  const ApprovalProgressIndicator({
    Key? key,
    required this.approvers,
    required this.currentLevel,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(approvers.length * 2 - 1, (index) {
        // Node
        if (index % 2 == 0) {
          final approverIndex = index ~/ 2;
          final isCompleted =
              approverIndex < currentLevel || status == ApprovalStatus.approved;
          final isCurrent =
              approverIndex == currentLevel && status == ApprovalStatus.pending;
          final isRejected =
              status == ApprovalStatus.rejected &&
              approverIndex == currentLevel;

          Color nodeColor;
          IconData nodeIcon;

          if (isRejected) {
            nodeColor = Colors.red;
            nodeIcon = Icons.close;
          } else if (isCompleted) {
            nodeColor = Colors.green;
            nodeIcon = Icons.check;
          } else if (isCurrent) {
            nodeColor = Colors.amber;
            nodeIcon = Icons.hourglass_top;
          } else {
            nodeColor = Colors.grey;
            nodeIcon = Icons.circle_outlined;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: nodeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: nodeColor),
                ),
                child: Icon(nodeIcon, color: nodeColor),
              ),
              const SizedBox(height: 4),
              Text(
                approvers[approverIndex],
                style: TextStyle(
                  color: isCurrent || isCompleted || isRejected
                      ? nodeColor
                      : Colors.grey,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }
        // Connector
        else {
          final beforeNodeIndex = index ~/ 2;
          final isCompleted =
              beforeNodeIndex < currentLevel ||
              status == ApprovalStatus.approved;

          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? Colors.green : Colors.grey.withOpacity(0.5),
            ),
          );
        }
      }),
    );
  }
}

class ReceiptThumbnail extends StatelessWidget {
  final String receiptUrl;

  const ReceiptThumbnail({Key? key, required this.receiptUrl})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show full-size receipt
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: const Text('Receipt'),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/receipts/$receiptUrl',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: 80,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/receipts/$receiptUrl', fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class ExpenseSubmissionForm extends ConsumerStatefulWidget {
  const ExpenseSubmissionForm({Key? key}) : super(key: key);

  @override
  ConsumerState<ExpenseSubmissionForm> createState() =>
      _ExpenseSubmissionFormState();
}

class _ExpenseSubmissionFormState extends ConsumerState<ExpenseSubmissionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Meals & Entertainment';
  final List<String> _categories = [
    'Meals & Entertainment',
    'Travel',
    'Office Expenses',
    'Software',
    'Hardware',
    'Other',
  ];
  DateTime _selectedDate = DateTime.now();
  final List<String> _receipts = [];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addReceipt() {
    // In a real app, this would trigger file selection
    setState(() {
      _receipts.add('receipt_${DateTime.now().millisecondsSinceEpoch}.jpg');
    });
  }

  void _submitExpense() {
    if (_formKey.currentState!.validate()) {
      final expensesNotifier = ref.read(expensesProvider.notifier);
      final newExpense = ExpenseItem(
        id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory,
        submittedBy: 'Current User',
        approvers: ['Line Manager', 'Finance Dept'],
        receipts: _receipts,
        status: ApprovalStatus.pending,
        currentApprovalLevel: 0,
      );
      expensesNotifier.addExpense(newExpense);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Submit Expense',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Expense Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                  ),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Receipts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: _receipts.isEmpty
                      ? Center(
                          child: Text(
                            'No receipts attached',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _receipts.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Receipt ${index + 1}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _receipts.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add Receipt'),
                  onPressed: _addReceipt,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _submitExpense,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// INVOICE MANAGEMENT

// Models
enum InvoiceStatus { draft, sent, paid, overdue, cancelled }

class Invoice {
  final String id;
  final String clientName;
  final double amount;
  final DateTime issuedDate;
  final DateTime dueDate;
  final InvoiceStatus status;
  final List<InvoiceItem> items;
  final double paidAmount;

  Invoice({
    required this.id,
    required this.clientName,
    required this.amount,
    required this.issuedDate,
    required this.dueDate,
    required this.status,
    required this.items,
    required this.paidAmount,
  });

  double get remainingAmount => amount - paidAmount;
  bool get isFullyPaid => paidAmount >= amount;
  int get daysOverdue => status == InvoiceStatus.overdue
      ? DateTime.now().difference(dueDate).inDays
      : 0;
  int get daysUntilDue => status == InvoiceStatus.sent
      ? dueDate.difference(DateTime.now()).inDays
      : 0;
}

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class ClientPaymentHistory {
  final String clientName;
  final List<DateTime> paymentDates;
  final List<double> paymentAmounts;
  final double totalPaid;
  final int onTimePayments;
  final int latePayments;

  ClientPaymentHistory({
    required this.clientName,
    required this.paymentDates,
    required this.paymentAmounts,
    required this.totalPaid,
    required this.onTimePayments,
    required this.latePayments,
  });

  double get averagePaymentAmount =>
      paymentAmounts.isEmpty ? 0 : totalPaid / paymentAmounts.length;
  double get onTimeRate =>
      paymentDates.isEmpty ? 0 : onTimePayments / paymentDates.length;
}

// Providers
final invoicesProvider = StateNotifierProvider<InvoicesNotifier, List<Invoice>>(
  (ref) {
    return InvoicesNotifier();
  },
);

class InvoicesNotifier extends StateNotifier<List<Invoice>> {
  InvoicesNotifier()
    : super([
        Invoice(
          id: 'INV-2025-001',
          clientName: 'Acme Corp',
          amount: 2500.00,
          issuedDate: DateTime.now().subtract(const Duration(days: 15)),
          dueDate: DateTime.now().add(const Duration(days: 15)),
          status: InvoiceStatus.sent,
          items: [
            InvoiceItem(
              description: 'Web Development Services',
              quantity: 1,
              unitPrice: 2000.00,
            ),
            InvoiceItem(
              description: 'Hosting (Annual)',
              quantity: 1,
              unitPrice: 500.00,
            ),
          ],
          paidAmount: 0,
        ),
        Invoice(
          id: 'INV-2025-002',
          clientName: 'TechStart Inc',
          amount: 3750.00,
          issuedDate: DateTime.now().subtract(const Duration(days: 45)),
          dueDate: DateTime.now().subtract(const Duration(days: 15)),
          status: InvoiceStatus.overdue,
          items: [
            InvoiceItem(
              description: 'Mobile App Development',
              quantity: 1,
              unitPrice: 3500.00,
            ),
            InvoiceItem(
              description: 'App Store Submission',
              quantity: 1,
              unitPrice: 250.00,
            ),
          ],
          paidAmount: 0,
        ),
        Invoice(
          id: 'INV-2025-003',
          clientName: 'GlobalMedia Ltd',
          amount: 1250.00,
          issuedDate: DateTime.now().subtract(const Duration(days: 30)),
          dueDate: DateTime.now().subtract(const Duration(days: 5)),
          status: InvoiceStatus.paid,
          items: [
            InvoiceItem(
              description: 'SEO Services',
              quantity: 1,
              unitPrice: 750.00,
            ),
            InvoiceItem(
              description: 'Content Creation',
              quantity: 5,
              unitPrice: 100.00,
            ),
          ],
          paidAmount: 1250.00,
        ),
      ]);

  void addInvoice(Invoice invoice) {
    state = [...state, invoice];
  }

  void updateInvoiceStatus(String id, InvoiceStatus status) {
    state = state.map((invoice) {
      if (invoice.id == id) {
        return Invoice(
          id: invoice.id,
          clientName: invoice.clientName,
          amount: invoice.amount,
          issuedDate: invoice.issuedDate,
          dueDate: invoice.dueDate,
          status: status,
          items: invoice.items,
          paidAmount: invoice.paidAmount,
        );
      }
      return invoice;
    }).toList();
  }

  void recordPayment(String id, double amount) {
    state = state.map((invoice) {
      if (invoice.id == id) {
        final newPaidAmount = invoice.paidAmount + amount;
        final newStatus = newPaidAmount >= invoice.amount
            ? InvoiceStatus.paid
            : invoice.status == InvoiceStatus.overdue
            ? InvoiceStatus.overdue
            : InvoiceStatus.sent;

        return Invoice(
          id: invoice.id,
          clientName: invoice.clientName,
          amount: invoice.amount,
          issuedDate: invoice.issuedDate,
          dueDate: invoice.dueDate,
          status: newStatus,
          items: invoice.items,
          paidAmount: newPaidAmount,
        );
      }
      return invoice;
    }).toList();
  }
}

final clientPaymentHistoryProvider =
    StateProvider<Map<String, ClientPaymentHistory>>((ref) {
      return {
        'Acme Corp': ClientPaymentHistory(
          clientName: 'Acme Corp',
          paymentDates: [
            DateTime.now().subtract(const Duration(days: 90)),
            DateTime.now().subtract(const Duration(days: 60)),
            DateTime.now().subtract(const Duration(days: 30)),
          ],
          paymentAmounts: [1500.00, 2200.00, 950.00],
          totalPaid: 4650.00,
          onTimePayments: 2,
          latePayments: 1,
        ),
        'TechStart Inc': ClientPaymentHistory(
          clientName: 'TechStart Inc',
          paymentDates: [
            DateTime.now().subtract(const Duration(days: 120)),
            DateTime.now().subtract(const Duration(days: 75)),
          ],
          paymentAmounts: [3000.00, 2750.00],
          totalPaid: 5750.00,
          onTimePayments: 1,
          latePayments: 1,
        ),
        'GlobalMedia Ltd': ClientPaymentHistory(
          clientName: 'GlobalMedia Ltd',
          paymentDates: [
            DateTime.now().subtract(const Duration(days: 60)),
            DateTime.now().subtract(const Duration(days: 5)),
          ],
          paymentAmounts: [1800.00, 1250.00],
          totalPaid: 3050.00,
          onTimePayments: 2,
          latePayments: 0,
        ),
      };
    });

// Widgets
class InvoiceManagementDashboard extends ConsumerWidget {
  const InvoiceManagementDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);

    // Calculate summary metrics
    final totalOutstanding = invoices
        .where(
          (inv) =>
              inv.status != InvoiceStatus.paid &&
              inv.status != InvoiceStatus.cancelled,
        )
        .fold(0.0, (sum, inv) => sum + inv.remainingAmount);

    final overdue = invoices
        .where((inv) => inv.status == InvoiceStatus.overdue)
        .length;

    final dueThisWeek = invoices
        .where(
          (inv) =>
              inv.status == InvoiceStatus.sent &&
              inv.dueDate.difference(DateTime.now()).inDays <= 7,
        )
        .length;

    final paid = invoices
        .where((inv) => inv.status == InvoiceStatus.paid)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Show invoice creation form
              showDialog(
                context: context,
                builder: (context) => const InvoiceCreationForm(),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Summary Cards
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Outstanding',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              NumberFormat.currency(
                                symbol: '\$',
                              ).format(totalOutstanding),
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      color: Colors.red.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overdue',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$overdue Invoices',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      color: Colors.amber.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Due This Week',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$dueThisWeek Invoices',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      color: Colors.green.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paid',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$paid Invoices',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Invoices', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Expanded(child: InvoiceList()),
          ],
        ),
      ),
    );
  }
}

class InvoiceList extends ConsumerWidget {
  const InvoiceList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);

    return ListView.builder(
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        return InvoiceCard(invoice: invoices[index]);
      },
    );
  }
}

class InvoiceCard extends ConsumerWidget {
  final Invoice invoice;

  const InvoiceCard({Key? key, required this.invoice}) : super(key: key);

  Color _getStatusColor() {
    switch (invoice.status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.blueGrey;
    }
  }

  String _getStatusText() {
    switch (invoice.status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => InvoiceDetailDialog(invoice: invoice),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.id,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        invoice.clientName,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Issued: ${dateFormat.format(invoice.issuedDate)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Due: ${dateFormat.format(invoice.dueDate)}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: invoice.status == InvoiceStatus.overdue
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: invoice.status == InvoiceStatus.overdue
                              ? Colors.red
                              : null,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(invoice.amount),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (invoice.paidAmount > 0 && !invoice.isFullyPaid)
                        Text(
                          'Remaining: ${currencyFormat.format(invoice.remainingAmount)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ],
              ),
              if (invoice.status == InvoiceStatus.overdue)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${invoice.daysOverdue} days overdue',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              if (invoice.status == InvoiceStatus.sent &&
                  invoice.dueDate.difference(DateTime.now()).inDays <= 7)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due in ${invoice.daysUntilDue} days',
                        style: TextStyle(color: Colors.amber[800]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvoiceDetailDialog extends ConsumerWidget {
  final Invoice invoice;

  const InvoiceDetailDialog({Key? key, required this.invoice})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.id,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invoice.clientName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Issued: ${dateFormat.format(invoice.issuedDate)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      'Due: ${dateFormat.format(invoice.dueDate)}',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: invoice.status == InvoiceStatus.overdue
                            ? Colors.red
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Items', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invoice.items.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = invoice.items[index];
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(item.description)),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            currencyFormat.format(item.unitPrice),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            currencyFormat.format(item.total),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total: ${currencyFormat.format(invoice.amount)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (invoice.paidAmount > 0)
                      Text(
                        'Paid: ${currencyFormat.format(invoice.paidAmount)}',
                        style: TextStyle(color: Colors.green),
                      ),
                    if (invoice.remainingAmount > 0)
                      Text(
                        'Remaining: ${currencyFormat.format(invoice.remainingAmount)}',
                        style: invoice.status == InvoiceStatus.overdue
                            ? TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              )
                            : null,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (invoice.status != InvoiceStatus.paid &&
                invoice.status != InvoiceStatus.cancelled)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      // Show payment recording dialog
                      showDialog(
                        context: context,
                        builder: (context) =>
                            RecordPaymentDialog(invoice: invoice),
                      );
                    },
                    child: const Text('Record Payment'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Send/Resend invoice logic
                      ref
                          .read(invoicesProvider.notifier)
                          .updateInvoiceStatus(
                            invoice.id,
                            invoice.status == InvoiceStatus.draft
                                ? InvoiceStatus.sent
                                : invoice.status,
                          );
                      Navigator.pop(context);
                    },
                    child: Text(
                      invoice.status == InvoiceStatus.draft
                          ? 'Send Invoice'
                          : 'Resend Invoice',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class RecordPaymentDialog extends ConsumerStatefulWidget {
  final Invoice invoice;

  const RecordPaymentDialog({Key? key, required this.invoice})
    : super(key: key);

  @override
  ConsumerState<RecordPaymentDialog> createState() =>
      _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<RecordPaymentDialog> {
  final _amountController = TextEditingController();
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.invoice.remainingAmount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record Payment',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Invoice ${widget.invoice.id} - ${widget.invoice.clientName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Amount',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                prefixText: '\$ ',
                hintText: 'Enter amount',
                suffixText:
                    '/ ${currencyFormat.format(widget.invoice.remainingAmount)}',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Date',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _paymentDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _paymentDate = pickedDate;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateFormat.format(_paymentDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text);
                    if (amount != null && amount > 0) {
                      ref
                          .read(invoicesProvider.notifier)
                          .recordPayment(widget.invoice.id, amount);
                      Navigator.pop(context);
                      Navigator.pop(context); // Close both dialogs
                    }
                  },
                  child: const Text('Record Payment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InvoiceCreationForm extends ConsumerStatefulWidget {
  const InvoiceCreationForm({Key? key}) : super(key: key);

  @override
  ConsumerState<InvoiceCreationForm> createState() =>
      _InvoiceCreationFormState();
}

class _InvoiceCreationFormState extends ConsumerState<InvoiceCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final List<InvoiceItem> _items = [];
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _clientController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(InvoiceItem(description: '', quantity: 1, unitPrice: 0));
    });
  }

  void _updateItem(
    int index,
    String description,
    int quantity,
    double unitPrice,
  ) {
    setState(() {
      _items[index] = InvoiceItem(
        description: description,
        quantity: quantity,
        unitPrice: unitPrice,
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double get _totalAmount {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  void _createInvoice() {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      final invoicesNotifier = ref.read(invoicesProvider.notifier);
      final newInvoice = Invoice(
        id: 'INV-${DateTime.now().year}-${ref.read(invoicesProvider).length + 1}',
        clientName: _clientController.text,
        amount: _totalAmount,
        issuedDate: DateTime.now(),
        dueDate: _dueDate,
        status: InvoiceStatus.draft,
        items: _items,
        paidAmount: 0,
      );
      invoicesNotifier.addInvoice(newInvoice);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Invoice'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: _createInvoice,
              child: const Text('Save as Draft'),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Client Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientController,
                decoration: const InputDecoration(
                  labelText: 'Client Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a client name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due Date',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _dueDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dueDate = pickedDate;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(dateFormat.format(_dueDate)),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Items', style: Theme.of(context).textTheme.titleLarge),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                    onPressed: _addItem,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_items.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No items added yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return InvoiceItemEditor(
                      item: _items[index],
                      onUpdate: (description, quantity, unitPrice) {
                        _updateItem(index, description, quantity, unitPrice);
                      },
                      onRemove: () {
                        _removeItem(index);
                      },
                    );
                  },
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total: ${currencyFormat.format(_totalAmount)}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createInvoice,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Create Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvoiceItemEditor extends StatefulWidget {
  final InvoiceItem item;
  final Function(String description, int quantity, double unitPrice) onUpdate;
  final VoidCallback onRemove;

  const InvoiceItemEditor({
    Key? key,
    required this.item,
    required this.onUpdate,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<InvoiceItemEditor> createState() => _InvoiceItemEditorState();
}

class _InvoiceItemEditorState extends State<InvoiceItemEditor> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitPriceController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.item.description,
    );
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _unitPriceController = TextEditingController(
      text: widget.item.unitPrice.toString(),
    );

    _descriptionController.addListener(_updateItem);
    _quantityController.addListener(_updateItem);
    _unitPriceController.addListener(_updateItem);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _updateItem() {
    final description = _descriptionController.text;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
    widget.onUpdate(description, quantity, unitPrice);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Item Description',
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
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Remove'),
                  onPressed: widget.onRemove,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
                Text(
                  'Total: ${currencyFormat.format((int.tryParse(_quantityController.text) ?? 0) * (double.tryParse(_unitPriceController.text) ?? 0.0))}',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
}

// AGING RECEIVABLES VISUALIZATION

class AgingReceivablesVisualization extends ConsumerWidget {
  const AgingReceivablesVisualization({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Calculate aging buckets
    final Map<String, double> agingBuckets = {
      'Current': 0,
      '1-30 days': 0,
      '31-60 days': 0,
      '61-90 days': 0,
      '90+ days': 0,
    };

    for (final invoice in invoices) {
      if (invoice.status != InvoiceStatus.paid &&
          invoice.status != InvoiceStatus.cancelled) {
        final daysOverdue = DateTime.now().difference(invoice.dueDate).inDays;

        if (daysOverdue <= 0) {
          agingBuckets['Current'] =
              (agingBuckets['Current'] ?? 0) + invoice.remainingAmount;
        } else if (daysOverdue <= 30) {
          agingBuckets['1-30 days'] =
              (agingBuckets['1-30 days'] ?? 0) + invoice.remainingAmount;
        } else if (daysOverdue <= 60) {
          agingBuckets['31-60 days'] =
              (agingBuckets['31-60 days'] ?? 0) + invoice.remainingAmount;
        } else if (daysOverdue <= 90) {
          agingBuckets['61-90 days'] =
              (agingBuckets['61-90 days'] ?? 0) + invoice.remainingAmount;
        } else {
          agingBuckets['90+ days'] =
              (agingBuckets['90+ days'] ?? 0) + invoice.remainingAmount;
        }
      }
    }

    final totalReceivables = agingBuckets.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    // Generate chart data
    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.green,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.red,
    ];

    int i = 0;
    agingBuckets.forEach((key, value) {
      if (value > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[i],
            value: value,
            title: '${(value / totalReceivables * 100).toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      i++;
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aging Receivables',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${currencyFormat.format(totalReceivables)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: totalReceivables > 0
                  ? Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: sections,
                              centerSpaceRadius: 40,
                              sectionsSpace: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(agingBuckets.length, (
                              index,
                            ) {
                              final entry = agingBuckets.entries.elementAt(
                                index,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: colors[index],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(entry.key),
                                    const Spacer(),
                                    Text(
                                      currencyFormat.format(entry.value),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        'No receivables data to display',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// CLIENT PAYMENT HISTORY VISUALIZATION

class ClientPaymentHistoryWidget extends ConsumerWidget {
  final String clientName;

  const ClientPaymentHistoryWidget({Key? key, required this.clientName})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsHistory = ref.watch(clientPaymentHistoryProvider);
    final clientHistory = clientsHistory[clientName];

    if (clientHistory == null) {
      return Center(
        child: Text('No payment history available for $clientName'),
      );
    }

    final dateFormat = DateFormat.yMMMd();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Generate chart data for payment trends
    final List<FlSpot> spots = [];
    for (int i = 0; i < clientHistory.paymentDates.length; i++) {
      spots.add(FlSpot(i.toDouble(), clientHistory.paymentAmounts[i]));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$clientName Payment History',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${clientHistory.paymentDates.length} payments recorded',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: clientHistory.onTimeRate >= 0.8
                        ? Colors.green.withOpacity(0.1)
                        : clientHistory.onTimeRate >= 0.6
                        ? Colors.amber.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'On-time: ${(clientHistory.onTimeRate * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: clientHistory.onTimeRate >= 0.8
                          ? Colors.green
                          : clientHistory.onTimeRate >= 0.6
                          ? Colors.amber[800]
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Paid',
                    value: currencyFormat.format(clientHistory.totalPaid),
                    icon: Icons.payments,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    title: 'Average Payment',
                    value: currencyFormat.format(
                      clientHistory.averagePaymentAmount,
                    ),
                    icon: Icons.trending_up,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'On-time Payments',
                    value: clientHistory.onTimePayments.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    title: 'Late Payments',
                    value: clientHistory.latePayments.toString(),
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Trend',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: clientHistory.averagePaymentAmount / 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() <
                                  clientHistory.paymentDates.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                dateFormat.format(
                                  clientHistory.paymentDates[value.toInt()],
                                ),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            currencyFormat.format(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 60,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      left: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  minX: 0,
                  maxX: (clientHistory.paymentDates.length - 1).toDouble(),
                  minY: 0,
                  maxY:
                      clientHistory.paymentAmounts.reduce(
                        (a, b) => a > b ? a : b,
                      ) *
                      1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Payments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: Math.min(clientHistory.paymentDates.length, 5),
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final date = clientHistory.paymentDates[index];
                final amount = clientHistory.paymentAmounts[index];

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payment,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    currencyFormat.format(amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(dateFormat.format(date)),
                  trailing: index == 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Latest',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Main Application
class FinancialApp extends StatelessWidget {
  const FinancialApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FinancialHealthPage(),
    const ExpenseApprovalFlow(),
    const InvoiceManagementDashboard(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Financials',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.description),
            label: 'Invoices',
          ),
        ],
      ),
    );
  }
}

class FinancialHealthPage extends StatelessWidget {
  const FinancialHealthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Health')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FinancialHealthScorecard(),
            const SizedBox(height: 24),
            const AgingReceivablesVisualization(),
            const SizedBox(height: 24),
            Text(
              'Client Payment History',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const ClientPaymentHistoryWidget(clientName: 'Acme Corp'),
            const SizedBox(height: 24),
            const ClientPaymentHistoryWidget(clientName: 'TechStart Inc'),
          ],
        ),
      ),
    );
  }
}

// Main entry point
void main() {
  runApp(const ProviderScope(child: FinancialApp()));
}

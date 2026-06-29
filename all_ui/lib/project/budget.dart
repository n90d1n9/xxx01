import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Providers
final budgetDataProvider =
    StateNotifierProvider<BudgetNotifier, List<BudgetCategory>>((ref) {
      return BudgetNotifier();
    });

final expenseDataProvider =
    StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
      return ExpenseNotifier();
    });

final currentTabProvider = StateProvider<int>((ref) => 0);

// Models
class BudgetCategory {
  final String name;
  final double allocated;
  final double spent;
  final Color color;
  final List<PhasedBudget> phases;

  BudgetCategory({
    required this.name,
    required this.allocated,
    required this.spent,
    required this.color,
    required this.phases,
  });
}

class PhasedBudget {
  final String phase;
  final double amount;

  PhasedBudget({required this.phase, required this.amount});
}

class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final String vendor;
  final ApprovalStatus approvalStatus;
  final bool hasReceipt;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    required this.vendor,
    required this.approvalStatus,
    required this.hasReceipt,
  });
}

enum ApprovalStatus { pending, approved, rejected }

// Notifiers
class BudgetNotifier extends StateNotifier<List<BudgetCategory>> {
  BudgetNotifier()
    : super([
        BudgetCategory(
          name: 'Personnel',
          allocated: 120000,
          spent: 45000,
          color: Colors.blue,
          phases: [
            PhasedBudget(phase: 'Planning', amount: 20000),
            PhasedBudget(phase: 'Execution', amount: 60000),
            PhasedBudget(phase: 'Monitoring', amount: 30000),
            PhasedBudget(phase: 'Closure', amount: 10000),
          ],
        ),
        BudgetCategory(
          name: 'Equipment',
          allocated: 75000,
          spent: 61000,
          color: Colors.orange,
          phases: [
            PhasedBudget(phase: 'Planning', amount: 40000),
            PhasedBudget(phase: 'Execution', amount: 25000),
            PhasedBudget(phase: 'Monitoring', amount: 5000),
            PhasedBudget(phase: 'Closure', amount: 5000),
          ],
        ),
        BudgetCategory(
          name: 'Software',
          allocated: 45000,
          spent: 22000,
          color: Colors.green,
          phases: [
            PhasedBudget(phase: 'Planning', amount: 15000),
            PhasedBudget(phase: 'Execution', amount: 20000),
            PhasedBudget(phase: 'Monitoring', amount: 5000),
            PhasedBudget(phase: 'Closure', amount: 5000),
          ],
        ),
        BudgetCategory(
          name: 'Services',
          allocated: 35000,
          spent: 12000,
          color: Colors.purple,
          phases: [
            PhasedBudget(phase: 'Planning', amount: 5000),
            PhasedBudget(phase: 'Execution', amount: 15000),
            PhasedBudget(phase: 'Monitoring', amount: 10000),
            PhasedBudget(phase: 'Closure', amount: 5000),
          ],
        ),
        BudgetCategory(
          name: 'Contingency',
          allocated: 25000,
          spent: 0,
          color: Colors.red,
          phases: [
            PhasedBudget(phase: 'Planning', amount: 5000),
            PhasedBudget(phase: 'Execution', amount: 10000),
            PhasedBudget(phase: 'Monitoring', amount: 5000),
            PhasedBudget(phase: 'Closure', amount: 5000),
          ],
        ),
      ]);

  void updateBudget(int index, double allocated) {
    state = [
      ...state.sublist(0, index),
      BudgetCategory(
        name: state[index].name,
        allocated: allocated,
        spent: state[index].spent,
        color: state[index].color,
        phases: state[index].phases,
      ),
      ...state.sublist(index + 1),
    ];
  }
}

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier()
    : super([
        Expense(
          id: 'EXP001',
          category: 'Personnel',
          amount: 12500,
          date: DateTime.now().subtract(const Duration(days: 15)),
          description: 'Team salaries - March',
          vendor: 'Internal',
          approvalStatus: ApprovalStatus.approved,
          hasReceipt: true,
        ),
        Expense(
          id: 'EXP002',
          category: 'Equipment',
          amount: 8750,
          date: DateTime.now().subtract(const Duration(days: 10)),
          description: 'Development workstations',
          vendor: 'TechStore Inc.',
          approvalStatus: ApprovalStatus.approved,
          hasReceipt: true,
        ),
        Expense(
          id: 'EXP003',
          category: 'Software',
          amount: 5200,
          date: DateTime.now().subtract(const Duration(days: 7)),
          description: 'Design software licenses',
          vendor: 'CreativeCloud',
          approvalStatus: ApprovalStatus.pending,
          hasReceipt: true,
        ),
        Expense(
          id: 'EXP004',
          category: 'Services',
          amount: 3600,
          date: DateTime.now().subtract(const Duration(days: 3)),
          description: 'Cloud infrastructure - March',
          vendor: 'CloudProvider',
          approvalStatus: ApprovalStatus.pending,
          hasReceipt: false,
        ),
      ]);

  void addExpense(Expense expense) {
    state = [...state, expense];
  }

  void updateApprovalStatus(String id, ApprovalStatus status) {
    state = [
      for (final expense in state)
        if (expense.id == id)
          Expense(
            id: expense.id,
            category: expense.category,
            amount: expense.amount,
            date: expense.date,
            description: expense.description,
            vendor: expense.vendor,
            approvalStatus: status,
            hasReceipt: expense.hasReceipt,
          )
        else
          expense,
    ];
  }

  void uploadReceipt(String id) {
    state = [
      for (final expense in state)
        if (expense.id == id)
          Expense(
            id: expense.id,
            category: expense.category,
            amount: expense.amount,
            date: expense.date,
            description: expense.description,
            vendor: expense.vendor,
            approvalStatus: expense.approvalStatus,
            hasReceipt: true,
          )
        else
          expense,
    ];
  }
}

// Main App
void main() {
  runApp(const ProviderScope(child: FinancialManagementApp()));
}

class FinancialManagementApp extends StatelessWidget {
  const FinancialManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Finance Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Poppins',
      ),
      themeMode: ThemeMode.system,
      home: const ProjectFinanceScreen(),
    );
  }
}

class ProjectFinanceScreen extends ConsumerWidget {
  const ProjectFinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Financial Management'),
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
      body: Row(
        children: [
          // Side Navigation
          NavigationRail(
            selectedIndex: currentTab,
            onDestinationSelected: (index) {
              ref.read(currentTabProvider.notifier).state = index;
            },
            extended: true,
            elevation: 2,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: Text('Budget Planning'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('Expense Tracking'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.show_chart_outlined),
                selectedIcon: Icon(Icons.show_chart),
                label: Text('Financial Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          // Main Content
          Expanded(
            child: IndexedStack(
              index: currentTab,
              children: const [
                BudgetPlanningScreen(),
                ExpenseTrackingScreen(),
                Center(child: Text('Financial Reports (Coming Soon)')),
                Center(child: Text('Settings (Coming Soon)')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Budget Planning Screen
class BudgetPlanningScreen extends ConsumerWidget {
  const BudgetPlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetData = ref.watch(budgetDataProvider);
    final totalBudget = budgetData.fold(
      0.0,
      (sum, category) => sum + category.allocated,
    );
    final totalSpent = budgetData.fold(
      0.0,
      (sum, category) => sum + category.spent,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Budget Summary
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project Budget Overview',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current project financial status and allocation',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  BudgetSummaryWidget(
                    totalBudget: totalBudget,
                    totalSpent: totalSpent,
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('Export'),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Budget'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Main content with charts and tables
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Budget allocation and distribution
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Budget allocation by category
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Budget Allocation by Category',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 250,
                                width: double.infinity,
                                child: CategoryBudgetChart(
                                  budgetData: budgetData,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Legend
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children:
                                    budgetData.map((category) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: category.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(category.name),
                                          const SizedBox(width: 4),
                                          Text(
                                            '(${NumberFormat.currency(symbol: '\$').format(category.allocated)})',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Phased budget distribution
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phased Budget Distribution',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 250,
                                width: double.infinity,
                                child: PhasedBudgetChart(
                                  budgetData: budgetData,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right column - Contingency and resource costs
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contingency allocation
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contingency Allocation',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: ContingencyWidget(
                                  contingencyAmount:
                                      budgetData
                                          .firstWhere(
                                            (cat) => cat.name == 'Contingency',
                                          )
                                          .allocated,
                                  totalBudget: totalBudget,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Resource cost planning
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Resource Cost Planning',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Resource'),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ListView(
                                shrinkWrap: true,
                                children: const [
                                  ResourceCostItem(
                                    name: 'Senior Developer',
                                    rate: 85.0,
                                    hours: 160,
                                    totalCost: 13600.0,
                                  ),
                                  ResourceCostItem(
                                    name: 'UI/UX Designer',
                                    rate: 75.0,
                                    hours: 120,
                                    totalCost: 9000.0,
                                  ),
                                  ResourceCostItem(
                                    name: 'Project Manager',
                                    rate: 95.0,
                                    hours: 80,
                                    totalCost: 7600.0,
                                  ),
                                  ResourceCostItem(
                                    name: 'QA Engineer',
                                    rate: 65.0,
                                    hours: 100,
                                    totalCost: 6500.0,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Resources Cost'),
                                  Text(
                                    '\$36,700.00',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Expense Tracking Screen
class ExpenseTrackingScreen extends ConsumerWidget {
  const ExpenseTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseData = ref.watch(expenseDataProvider);
    final budgetData = ref.watch(budgetDataProvider);

    final formatter = NumberFormat.currency(symbol: '\$');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expense summary
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expense Tracking',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Monitor project expenses and vendor payments',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  ExpenseSummaryWidget(expenses: expenseData),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('Export'),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('New Expense'),
                    onPressed: () => _showAddExpenseDialog(context, ref),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Main content with expense tables and charts
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Expense log
                Expanded(
                  flex: 3,
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Expense Logs',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.filter_list),
                                    label: const Text('Filter'),
                                    onPressed: () {},
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.sort),
                                    label: const Text('Sort'),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Expense table
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    columnSpacing: 16,
                                    headingRowColor: MaterialStateProperty.all(
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text('ID')),
                                      DataColumn(label: Text('Date')),
                                      DataColumn(label: Text('Category')),
                                      DataColumn(label: Text('Description')),
                                      DataColumn(label: Text('Vendor')),
                                      DataColumn(
                                        label: Text('Amount'),
                                        numeric: true,
                                      ),
                                      DataColumn(label: Text('Receipt')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows:
                                        expenseData.map((expense) {
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(expense.id)),
                                              DataCell(
                                                Text(
                                                  DateFormat(
                                                    'MM/dd/yyyy',
                                                  ).format(expense.date),
                                                ),
                                              ),
                                              DataCell(Text(expense.category)),
                                              DataCell(
                                                Text(expense.description),
                                              ),
                                              DataCell(Text(expense.vendor)),
                                              DataCell(
                                                Text(
                                                  formatter.format(
                                                    expense.amount,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                expense.hasReceipt
                                                    ? IconButton(
                                                      icon: const Icon(
                                                        Icons.receipt,
                                                        color: Colors.green,
                                                      ),
                                                      onPressed: () {},
                                                      tooltip: 'View Receipt',
                                                    )
                                                    : IconButton(
                                                      icon: const Icon(
                                                        Icons.upload_file,
                                                        color: Colors.orange,
                                                      ),
                                                      onPressed: () {
                                                        ref
                                                            .read(
                                                              expenseDataProvider
                                                                  .notifier,
                                                            )
                                                            .uploadReceipt(
                                                              expense.id,
                                                            );
                                                      },
                                                      tooltip: 'Upload Receipt',
                                                    ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        expense.approvalStatus ==
                                                                ApprovalStatus
                                                                    .approved
                                                            ? Colors.green
                                                                .withOpacity(
                                                                  0.1,
                                                                )
                                                            : expense
                                                                    .approvalStatus ==
                                                                ApprovalStatus
                                                                    .pending
                                                            ? Colors.orange
                                                                .withOpacity(
                                                                  0.1,
                                                                )
                                                            : Colors.red
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    expense.approvalStatus.name
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      color:
                                                          expense.approvalStatus ==
                                                                  ApprovalStatus
                                                                      .approved
                                                              ? Colors.green
                                                              : expense
                                                                      .approvalStatus ==
                                                                  ApprovalStatus
                                                                      .pending
                                                              ? Colors.orange
                                                              : Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (expense
                                                            .approvalStatus ==
                                                        ApprovalStatus.pending)
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons
                                                              .check_circle_outline,
                                                          color: Colors.green,
                                                        ),
                                                        onPressed: () {
                                                          ref
                                                              .read(
                                                                expenseDataProvider
                                                                    .notifier,
                                                              )
                                                              .updateApprovalStatus(
                                                                expense.id,
                                                                ApprovalStatus
                                                                    .approved,
                                                              );
                                                        },
                                                        tooltip: 'Approve',
                                                      ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit_outlined,
                                                      ),
                                                      onPressed: () {},
                                                      tooltip: 'Edit',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Right column - Stats and approvals
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category expenses chart
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expenses by Category',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: ExpensesByCategoryChart(
                                  expenses: expenseData,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Approval workflows
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Approval Workflow',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              const ApprovalWorkflowVisualization(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Vendor payment status
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Vendor Payment Status',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Refresh'),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ListView(
                                shrinkWrap: true,
                                children: const [
                                  VendorPaymentItem(
                                    vendor: 'TechStore Inc.',
                                    invoiceId: 'INV-2023-001',
                                    amount: 8750.0,
                                    dueDate: '04/30/2025',
                                    status: 'Paid',
                                  ),
                                  VendorPaymentItem(
                                    vendor: 'CreativeCloud',
                                    invoiceId: 'INV-2023-002',
                                    amount: 5200.0,
                                    dueDate: '05/15/2025',
                                    status: 'Pending',
                                  ),
                                  VendorPaymentItem(
                                    vendor: 'CloudProvider',
                                    invoiceId: 'INV-2023-003',
                                    amount: 3600.0,
                                    dueDate: '05/10/2025',
                                    status: 'Processing',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String category = 'Personnel';
        final TextEditingController amountController = TextEditingController();
        final TextEditingController descriptionController =
            TextEditingController();
        final TextEditingController vendorController = TextEditingController();

        return AlertDialog(
          title: const Text('Add New Expense'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      [
                        'Personnel',
                        'Equipment',
                        'Software',
                        'Services',
                        'Contingency',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      category = newValue;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: vendorController,
                  decoration: const InputDecoration(
                    labelText: 'Vendor/Supplier',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.attach_file),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Attach Receipt'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (amountController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    vendorController.text.isNotEmpty) {
                  ref
                      .read(expenseDataProvider.notifier)
                      .addExpense(
                        Expense(
                          id:
                              'EXP${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
                          category: category,
                          amount: double.parse(amountController.text),
                          date: DateTime.now(),
                          description: descriptionController.text,
                          vendor: vendorController.text,
                          approvalStatus: ApprovalStatus.pending,
                          hasReceipt: false,
                        ),
                      );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Expense'),
            ),
          ],
        );
      },
    );
  }
}

// Widgets for Budget Planning Screen
class BudgetSummaryWidget extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;

  const BudgetSummaryWidget({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    final percentSpent = (totalSpent / totalBudget * 100).round();
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Budget Summary'),
          const SizedBox(height: 8),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Budget',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    formatter.format(totalBudget),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spent', style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    formatter.format(totalSpent),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    formatter.format(totalBudget - totalSpent),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          /* Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalSpent / totalBudget,
                    minHeight: 8,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$percentSpent%'),
            ],
          ), */
        ],
      ),
    );
  }
}

class CategoryBudgetChart extends StatelessWidget {
  final List<BudgetCategory> budgetData;

  const CategoryBudgetChart({super.key, required this.budgetData});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections:
            budgetData.map((category) {
              return PieChartSectionData(
                value: category.allocated,
                title: '',
                color: category.color,
                radius: 100,
              );
            }).toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, PieTouchResponse? response) {},
        ),
      ),
    );
  }
}

class PhasedBudgetChart extends StatelessWidget {
  final List<BudgetCategory> budgetData;

  const PhasedBudgetChart({super.key, required this.budgetData});

  @override
  Widget build(BuildContext context) {
    // Extract phase names
    final phases = budgetData.first.phases.map((p) => p.phase).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            budgetData.fold(
              0.0,
              (max, category) => math.max(
                max,
                category.phases.fold(0.0, (sum, phase) => sum + phase.amount),
              ),
            ) *
            1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            //tooltipBgColor: Theme.of(context).colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final category = budgetData[rodIndex];
              final phase = phases[groupIndex];
              final amount =
                  category.phases.firstWhere((p) => p.phase == phase).amount;
              return BarTooltipItem(
                '${category.name}\n\$${amount.toStringAsFixed(2)}',
                TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '\$${value ~/ 1000}K',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value < phases.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      phases[value.toInt()],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: 20000,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
            left: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        barGroups: List.generate(
          phases.length,
          (phaseIndex) => BarChartGroupData(
            x: phaseIndex,
            barRods: List.generate(
              budgetData.length,
              (categoryIndex) => BarChartRodData(
                toY: budgetData[categoryIndex].phases[phaseIndex].amount,
                color: budgetData[categoryIndex].color,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ContingencyWidget extends StatelessWidget {
  final double contingencyAmount;
  final double totalBudget;

  const ContingencyWidget({
    super.key,
    required this.contingencyAmount,
    required this.totalBudget,
  });

  @override
  Widget build(BuildContext context) {
    final contingencyPercentage =
        (contingencyAmount / totalBudget * 100).round();
    final formatter = NumberFormat.currency(symbol: '\$');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    value: contingencyAmount / totalBudget,
                    strokeWidth: 12,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$contingencyPercentage%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Contingency',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contingency Budget',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  formatter.format(contingencyAmount),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Of Total Budget',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  formatter.format(totalBudget),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ResourceCostItem extends StatelessWidget {
  final String name;
  final double rate;
  final int hours;
  final double totalCost;

  const ResourceCostItem({
    super.key,
    required this.name,
    required this.rate,
    required this.hours,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name)),
          Expanded(flex: 2, child: Text('${formatter.format(rate)}/hr')),
          Expanded(flex: 2, child: Text('$hours hrs')),
          Expanded(
            flex: 2,
            child: Text(
              formatter.format(totalCost),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// Widgets for Expense Tracking Screen
class ExpenseSummaryWidget extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseSummaryWidget({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final totalExpenses = expenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    final pendingExpenses = expenses
        .where((expense) => expense.approvalStatus == ApprovalStatus.pending)
        .fold(0.0, (sum, expense) => sum + expense.amount);
    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Expenses',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                formatter.format(totalExpenses),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pending Approval',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                formatter.format(pendingExpenses),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpensesByCategoryChart extends StatelessWidget {
  final List<Expense> expenses;

  const ExpensesByCategoryChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    // Group expenses by category
    final Map<String, double> categoryExpenses = {};
    for (final expense in expenses) {
      categoryExpenses[expense.category] =
          (categoryExpenses[expense.category] ?? 0) + expense.amount;
    }

    // Define colors for categories
    final Map<String, Color> categoryColors = {
      'Personnel': Colors.blue,
      'Equipment': Colors.orange,
      'Software': Colors.green,
      'Services': Colors.purple,
      'Contingency': Colors.red,
    };

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            categoryExpenses.values.fold(
              0.0,
              (max, value) => max > value ? max : value,
            ) *
            1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            //tooltipBgColor: Theme.of(context).colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final category = categoryExpenses.keys.elementAt(groupIndex);
              final amount = categoryExpenses[category]!;
              return BarTooltipItem(
                '${category}\n\$${amount.toStringAsFixed(2)}',
                TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '\$${value ~/ 1000}K',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value < categoryExpenses.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      categoryExpenses.keys.elementAt(value.toInt()),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: 5000,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
            left: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        barGroups: List.generate(
          categoryExpenses.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: categoryExpenses.values.elementAt(index),
                color: categoryColors[categoryExpenses.keys.elementAt(index)],
                width: 22,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApprovalWorkflowVisualization extends StatelessWidget {
  const ApprovalWorkflowVisualization({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWorkflowStep(
          context,
          icon: Icons.receipt_long,
          title: 'Receipt Submission',
          description: 'Team member submits expense with receipt',
          isCompleted: true,
          isActive: false,
        ),
        _buildArrow(context),
        _buildWorkflowStep(
          context,
          icon: Icons.fact_check,
          title: 'Manager Review',
          description: 'Department manager approves expense',
          isCompleted: true,
          isActive: false,
        ),
        _buildArrow(context),
        _buildWorkflowStep(
          context,
          icon: Icons.verified_user,
          title: 'Financial Verification',
          description: 'Financial team verifies expense is within budget',
          isCompleted: false,
          isActive: true,
        ),
        _buildArrow(context),
        _buildWorkflowStep(
          context,
          icon: Icons.payments,
          title: 'Payment Processing',
          description: 'Expense is processed for payment',
          isCompleted: false,
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildWorkflowStep(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : isActive
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color:
                isCompleted
                    ? Theme.of(context).colorScheme.onPrimary
                    : isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArrow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: SizedBox(
        height: 24,
        child: Center(
          child: Container(
            width: 2,
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
      ),
    );
  }
}

class VendorPaymentItem extends StatelessWidget {
  final String vendor;
  final String invoiceId;
  final double amount;
  final String dueDate;
  final String status;

  const VendorPaymentItem({
    super.key,
    required this.vendor,
    required this.invoiceId,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'Paid':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Processing':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    final formatter = NumberFormat.currency(symbol: '\$');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Invoice: $invoiceId',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatter.format(amount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Due: $dueDate',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
    );
  }
}

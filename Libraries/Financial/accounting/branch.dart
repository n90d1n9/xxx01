// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const ProviderScope(child: MultiBranchFinanceApp()));
}

class MultiBranchFinanceApp extends ConsumerWidget {
  const MultiBranchFinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Multi-Branch Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}

// lib/theme/app_theme.dart

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

// lib/models/branch.dart
class Branch {
  final String id;
  final String name;
  final String location;
  final String manager;
  final DateTime establishedDate;

  Branch({
    required this.id,
    required this.name,
    required this.location,
    required this.manager,
    required this.establishedDate,
  });

  Branch copyWith({
    String? id,
    String? name,
    String? location,
    String? manager,
    DateTime? establishedDate,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      manager: manager ?? this.manager,
      establishedDate: establishedDate ?? this.establishedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'manager': manager,
      'establishedDate': establishedDate.toIso8601String(),
    };
  }

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      manager: json['manager'],
      establishedDate: DateTime.parse(json['establishedDate']),
    );
  }
}

// lib/models/transaction.dart
enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String branchId;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String category;

  Transaction({
    required this.id,
    required this.branchId,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
  });

  Transaction copyWith({
    String? id,
    String? branchId,
    String? description,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'description': description,
      'amount': amount,
      'type': type.toString(),
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      branchId: json['branchId'],
      description: json['description'],
      amount: json['amount'],
      type: json['type'] == 'TransactionType.income'
          ? TransactionType.income
          : TransactionType.expense,
      date: DateTime.parse(json['date']),
      category: json['category'],
    );
  }
}

// lib/models/financial_summary.dart
class FinancialSummary {
  final String branchId;
  final double totalIncome;
  final double totalExpenses;
  final double profit;
  final Map<String, double> categoryExpenses;
  final DateTime fromDate;
  final DateTime toDate;

  FinancialSummary({
    required this.branchId,
    required this.totalIncome,
    required this.totalExpenses,
    required this.profit,
    required this.categoryExpenses,
    required this.fromDate,
    required this.toDate,
  });

  factory FinancialSummary.empty(String branchId) {
    return FinancialSummary(
      branchId: branchId,
      totalIncome: 0.0,
      totalExpenses: 0.0,
      profit: 0.0,
      categoryExpenses: {},
      fromDate: DateTime.now(),
      toDate: DateTime.now(),
    );
  }
}

// lib/services/branch_service.dart

class BranchService {
  // In a real app, this would be connected to a database or API
  final List<Branch> _branches = [];
  final _uuid = Uuid();

  Future<List<Branch>> getBranches() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    return [..._branches];
  }

  Future<Branch> getBranchById(String id) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 200));

    final branch = _branches.firstWhere(
      (branch) => branch.id == id,
      orElse: () => throw Exception('Branch not found'),
    );

    return branch;
  }

  Future<Branch> addBranch(Branch branch) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 400));

    final newBranch = Branch(
      id: _uuid.v4(),
      name: branch.name,
      location: branch.location,
      manager: branch.manager,
      establishedDate: branch.establishedDate,
    );

    _branches.add(newBranch);
    return newBranch;
  }

  Future<Branch> updateBranch(Branch branch) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _branches.indexWhere((b) => b.id == branch.id);
    if (index == -1) {
      throw Exception('Branch not found');
    }

    _branches[index] = branch;
    return branch;
  }

  Future<void> deleteBranch(String id) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));

    _branches.removeWhere((branch) => branch.id == id);
  }
}

final branchServiceProvider = Provider<BranchService>((ref) => BranchService());

// lib/services/transaction_service.dart

class TransactionService {
  // In a real app, this would be connected to a database or API
  final List<Transaction> _transactions = [];
  final _uuid = Uuid();

  Future<List<Transaction>> getTransactionsByBranch(String branchId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));

    return _transactions
        .where((transaction) => transaction.branchId == branchId)
        .toList();
  }

  Future<List<Transaction>> getAllTransactions() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));

    return [..._transactions];
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 400));

    final newTransaction = Transaction(
      id: _uuid.v4(),
      branchId: transaction.branchId,
      description: transaction.description,
      amount: transaction.amount,
      type: transaction.type,
      date: transaction.date,
      category: transaction.category,
    );

    _transactions.add(newTransaction);
    return newTransaction;
  }

  Future<Transaction> updateTransaction(Transaction transaction) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index == -1) {
      throw Exception('Transaction not found');
    }

    _transactions[index] = transaction;
    return transaction;
  }

  Future<void> deleteTransaction(String id) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));

    _transactions.removeWhere((transaction) => transaction.id == id);
  }

  Future<FinancialSummary> getFinancialSummary(
    String branchId, {
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    final branchTransactions = _transactions.where(
      (transaction) =>
          transaction.branchId == branchId &&
          transaction.date.isAfter(
            fromDate.subtract(const Duration(days: 1)),
          ) &&
          transaction.date.isBefore(toDate.add(const Duration(days: 1))),
    );

    double totalIncome = 0.0;
    double totalExpenses = 0.0;
    Map<String, double> categoryExpenses = {};

    for (final transaction in branchTransactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;

        categoryExpenses.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return FinancialSummary(
      branchId: branchId,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      profit: totalIncome - totalExpenses,
      categoryExpenses: categoryExpenses,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}

final transactionServiceProvider = Provider<TransactionService>(
  (ref) => TransactionService(),
);

// lib/providers/branch_providers.dart

final branchesProvider = FutureProvider<List<Branch>>((ref) async {
  final branchService = ref.watch(branchServiceProvider);
  return branchService.getBranches();
});

final selectedBranchIdProvider = StateProvider<String?>((ref) => null);

final selectedBranchProvider = FutureProvider<Branch?>((ref) async {
  final branchService = ref.watch(branchServiceProvider);
  final selectedBranchId = ref.watch(selectedBranchIdProvider);

  if (selectedBranchId == null) {
    return null;
  }

  try {
    return await branchService.getBranchById(selectedBranchId);
  } catch (e) {
    ref.read(selectedBranchIdProvider.notifier).state = null;
    throw e;
  }
});

final branchFormProvider = StateProvider<Branch?>((ref) => null);

// lib/providers/transaction_providers.dart

final branchTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, branchId) async {
      final transactionService = ref.watch(transactionServiceProvider);
      return transactionService.getTransactionsByBranch(branchId);
    });

final selectedBranchTransactionsProvider = FutureProvider<List<Transaction>>((
  ref,
) async {
  final transactionService = ref.watch(transactionServiceProvider);
  final selectedBranchId = ref.watch(selectedBranchIdProvider);

  if (selectedBranchId == null) {
    return [];
  }

  return transactionService.getTransactionsByBranch(selectedBranchId);
});

final allTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getAllTransactions();
});

final transactionFormProvider = StateProvider<Transaction?>((ref) => null);

// Continuing from lib/providers/transaction_providers.dart
final dateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month, 1),
    end: DateTime(now.year, now.month + 1, 0),
  );
});

final financialSummaryProvider = FutureProvider<FinancialSummary?>((ref) async {
  final transactionService = ref.watch(transactionServiceProvider);
  final selectedBranchId = ref.watch(selectedBranchIdProvider);
  final dateRange = ref.watch(dateRangeProvider);

  if (selectedBranchId == null) {
    return null;
  }

  return transactionService.getFinancialSummary(
    selectedBranchId,
    fromDate: dateRange.start,
    toDate: dateRange.end,
  );
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const BranchesScreen(),
    const TransactionsScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Branches',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBranchAsync = ref.watch(selectedBranchProvider);
    final dateRange = ref.watch(dateRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDateRange: dateRange,
              );

              if (picked != null) {
                ref.read(dateRangeProvider.notifier).state = picked;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const BranchSelector(),
          Expanded(
            child: selectedBranchAsync.when(
              data: (selectedBranch) {
                if (selectedBranch == null) {
                  return const Center(
                    child: Text('Select a branch to view dashboard'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(financialSummaryProvider);
                    ref.invalidate(selectedBranchTransactionsProvider);
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(dateRange.start),
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const FinancialSummaryCard(),
                      const SizedBox(height: 24),
                      Text(
                        'Expense Categories',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const ExpenseCategoryChart(),
                      const SizedBox(height: 24),
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const RecentTransactionsList(),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Error: ${error.toString()}')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Branches')),
      body: branchesAsync.when(
        data: (branches) {
          if (branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No branches added yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Branch'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BranchFormScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(branchesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                return BranchListItem(
                  branch: branch,
                  onTap: () {
                    ref.read(selectedBranchIdProvider.notifier).state =
                        branch.id;
                    ref.read(branchFormProvider.notifier).state = branch;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BranchFormScreen(isEditing: true),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error: ${error.toString()}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(branchFormProvider.notifier).state = null;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BranchFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BranchFormScreen extends ConsumerStatefulWidget {
  final bool isEditing;

  const BranchFormScreen({super.key, this.isEditing = false});

  @override
  ConsumerState<BranchFormScreen> createState() => _BranchFormScreenState();
}

class _BranchFormScreenState extends ConsumerState<BranchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _managerController = TextEditingController();
  DateTime _establishedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final branch = ref.read(branchFormProvider);
      if (branch != null) {
        _nameController.text = branch.name;
        _locationController.text = branch.location;
        _managerController.text = branch.manager;
        _establishedDate = branch.establishedDate;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _managerController.dispose();
    super.dispose();
  }

  Future<void> _saveBranch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final branchService = ref.read(branchServiceProvider);
      final branch = ref.read(branchFormProvider);

      final newBranch = Branch(
        id: branch?.id ?? '',
        name: _nameController.text,
        location: _locationController.text,
        manager: _managerController.text,
        establishedDate: _establishedDate,
      );

      if (widget.isEditing) {
        await branchService.updateBranch(newBranch);
      } else {
        await branchService.addBranch(newBranch);
      }

      ref.invalidate(branchesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Branch' : 'Add Branch'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Branch Name',
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter branch name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _managerController,
              decoration: const InputDecoration(
                labelText: 'Manager',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter manager name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _establishedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    _establishedDate = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Established Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(_establishedDate),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveBranch,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(widget.isEditing ? 'Update Branch' : 'Add Branch'),
            ),
            if (widget.isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Branch'),
                              content: const Text(
                                'Are you sure you want to delete this branch? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            try {
                              final branchService = ref.read(
                                branchServiceProvider,
                              );
                              final branch = ref.read(branchFormProvider);
                              await branchService.deleteBranch(branch!.id);
                              ref.invalidate(branchesProvider);
                              if (mounted) Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                ),
                              );
                            }
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Delete Branch'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BranchListItem extends StatelessWidget {
  final Branch branch;
  final VoidCallback onTap;

  const BranchListItem({super.key, required this.branch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      branch.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
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
                          branch.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          branch.location,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 8),
              Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Manager: ${branch.manager}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Est: ${DateFormat('MMM yyyy').format(branch.establishedDate)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
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

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactionsAsync = ref.watch(allTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          const BranchSelector(),
          Expanded(
            child: allTransactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text('No transactions recorded yet'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Transaction'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TransactionFormScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                final selectedBranchId = ref.watch(selectedBranchIdProvider);
                final filteredTransactions = selectedBranchId == null
                    ? transactions
                    : transactions
                          .where((t) => t.branchId == selectedBranchId)
                          .toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allTransactionsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return TransactionListItem(
                        transaction: transaction,
                        onTap: () {
                          ref.read(transactionFormProvider.notifier).state =
                              transaction;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TransactionFormScreen(isEditing: true),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Error: ${error.toString()}')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(transactionFormProvider.notifier).state = null;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TransactionFormScreen extends ConsumerStatefulWidget {
  final bool isEditing;

  const TransactionFormScreen({super.key, this.isEditing = false});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedBranchId;
  TransactionType _transactionType = TransactionType.income;
  DateTime _date = DateTime.now();
  String _category = 'General';
  bool _isLoading = false;

  final List<String> _incomeCategories = [
    'Sales',
    'Services',
    'Investments',
    'Other Income',
  ];

  final List<String> _expenseCategories = [
    'Rent',
    'Utilities',
    'Salaries',
    'Inventory',
    'Marketing',
    'Maintenance',
    'Office Supplies',
    'Travel',
    'Miscellaneous',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transaction = ref.read(transactionFormProvider);
      if (transaction != null) {
        _descriptionController.text = transaction.description;
        _amountController.text = transaction.amount.toString();
        _selectedBranchId = transaction.branchId;
        _transactionType = transaction.type;
        _date = transaction.date;
        _category = transaction.category;
      } else {
        _selectedBranchId = ref.read(selectedBranchIdProvider);
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    return _transactionType == TransactionType.income
        ? _incomeCategories
        : _expenseCategories;
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranchId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a branch')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transactionService = ref.read(transactionServiceProvider);
      final transaction = ref.read(transactionFormProvider);

      final newTransaction = Transaction(
        id: transaction?.id ?? '',
        branchId: _selectedBranchId!,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        type: _transactionType,
        date: _date,
        category: _category,
      );

      if (widget.isEditing) {
        await transactionService.updateTransaction(newTransaction);
      } else {
        await transactionService.addTransaction(newTransaction);
      }

      ref.invalidate(allTransactionsProvider);
      ref.invalidate(selectedBranchTransactionsProvider);
      ref.invalidate(financialSummaryProvider);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final branchesAsync = ref.watch(branchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: branchesAsync.when(
        data: (branches) {
          if (branches.isEmpty) {
            return const Center(child: Text('Please add a branch first'));
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Branch Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Branch',
                    prefixIcon: Icon(Icons.store),
                  ),
                  value: _selectedBranchId,
                  items: branches.map((branch) {
                    return DropdownMenuItem<String>(
                      value: branch.id,
                      child: Text(branch.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBranchId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a branch';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Type Selector
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<TransactionType>(
                        title: const Text('Income'),
                        value: TransactionType.income,
                        groupValue: _transactionType,
                        onChanged: (value) {
                          setState(() {
                            _transactionType = TransactionType.income;
                            _category = _incomeCategories.first;
                          });
                        },
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<TransactionType>(
                        title: const Text('Expense'),
                        value: TransactionType.expense,
                        groupValue: _transactionType,
                        onChanged: (value) {
                          setState(() {
                            _transactionType = TransactionType.expense;
                            _category = _expenseCategories.first;
                          });
                        },
                        dense: true,
                      ),
                    ),
                  ],
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
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    try {
                      final amount = double.parse(value);
                      if (amount <= 0) {
                        return 'Amount must be greater than zero';
                      }
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category
                // Category
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  value: _categories.contains(_category)
                      ? _category
                      : _categories.first,
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _category = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );

                    if (picked != null) {
                      setState(() {
                        _date = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Transaction Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat('MMM dd, yyyy').format(_date)),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          widget.isEditing
                              ? 'Update Transaction'
                              : 'Add Transaction',
                        ),
                ),

                // Delete Button (only for editing)
                if (widget.isEditing)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Transaction'),
                                  content: const Text(
                                    'Are you sure you want to delete this transaction? This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                try {
                                  final transactionService = ref.read(
                                    transactionServiceProvider,
                                  );
                                  final transaction = ref.read(
                                    transactionFormProvider,
                                  );
                                  await transactionService.deleteTransaction(
                                    transaction!.id,
                                  );
                                  ref.invalidate(allTransactionsProvider);
                                  ref.invalidate(
                                    selectedBranchTransactionsProvider,
                                  );
                                  ref.invalidate(financialSummaryProvider);
                                  if (mounted) Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                    ),
                                  );
                                }
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Delete Transaction'),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction.type == TransactionType.income;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isIncome
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 14,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.category,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(transaction.date),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'} \$${transaction.amount.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BranchSelector extends ConsumerWidget {
  const BranchSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesProvider);
    final selectedBranchId = ref.watch(selectedBranchIdProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: branchesAsync.when(
        data: (branches) {
          if (branches.isEmpty) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BranchFormScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add a branch',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return DropdownButtonFormField<String?>(
            decoration: InputDecoration(
              labelText: 'Select Branch',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.store_outlined),
            ),
            value: selectedBranchId,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Branches')),
              ...branches.map((branch) {
                return DropdownMenuItem(
                  value: branch.id,
                  child: Text(branch.name),
                );
              }).toList(),
            ],
            onChanged: (value) {
              ref.read(selectedBranchIdProvider.notifier).state = value;
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }
}

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(dateRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDateRange: dateRange,
              );

              if (picked != null) {
                ref.read(dateRangeProvider.notifier).state = picked;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const BranchSelector(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${DateFormat('MMM dd, yyyy').format(dateRange.start)} - ${DateFormat('MMM dd, yyyy').format(dateRange.end)}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Summary'),
                      Tab(text: 'Chart'),
                      Tab(text: 'Comparison'),
                    ],
                    labelColor: Theme.of(context).colorScheme.primary,
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        FinancialSummaryTab(),
                        FinancialChartTab(),
                        BranchComparisonTab(),
                      ],
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
}

class FinancialSummaryTab extends ConsumerWidget {
  const FinancialSummaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(financialSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        if (summary == null) {
          return const Center(
            child: Text('Select a branch to view financial summary'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const FinancialSummaryCard(),
            const SizedBox(height: 24),
            Text(
              'Expense Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const ExpenseCategoryChart(),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Export functionality here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report exported successfully')),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Export Report'),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Error: ${error.toString()}')),
    );
  }
}

class FinancialSummaryCard extends ConsumerWidget {
  const FinancialSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(financialSummaryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: summaryAsync.when(
          data: (summary) {
            if (summary == null) {
              return const Center(child: Text('No data available'));
            }

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SummaryItem(
                      title: 'Total Income',
                      value: '\$${summary.totalIncome.toStringAsFixed(2)}',
                      icon: Icons.arrow_downward,
                      iconColor: Colors.green,
                    ),
                    _SummaryItem(
                      title: 'Total Expenses',
                      value: '\$${summary.totalExpenses.toStringAsFixed(2)}',
                      icon: Icons.arrow_upward,
                      iconColor: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _SummaryItem(
                  title: 'Net Profit',
                  value: '\$${summary.profit.toStringAsFixed(2)}',
                  icon: Icons.account_balance,
                  iconColor: summary.profit >= 0 ? Colors.green : Colors.red,
                  isLarge: true,
                ),
              ],
            );
          },
          loading: () =>
              const Center(heightFactor: 2, child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Error: ${error.toString()}')),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isLarge;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: isLarge
              ? theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}

class ExpenseCategoryChart extends ConsumerWidget {
  const ExpenseCategoryChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(financialSummaryProvider);

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: summaryAsync.when(
        data: (summary) {
          if (summary == null || summary.categoryExpenses.isEmpty) {
            return const Center(child: Text('No expense data available'));
          }

          // Sort categories by amount
          final sortedCategories = summary.categoryExpenses.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return _buildPieChart(context, sortedCategories);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }

  Widget _buildPieChart(
    BuildContext context,
    List<MapEntry<String, double>> categories,
  ) {
    // Note: In a real app, you would use a charting library like fl_chart
    // This is a simple placeholder to represent the chart
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              'Pie Chart Placeholder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(categories.length, (index) {
            final category = categories[index];
            final color = Colors.primaries[index % Colors.primaries.length];

            return Chip(
              label: Text(
                '${category.key}: \$${category.value.toStringAsFixed(2)}',
              ),
              backgroundColor: color.withValues(alpha: 0.2),
              side: BorderSide(color: color, width: 1),
            );
          }),
        ),
      ],
    );
  }
}

class FinancialChartTab extends ConsumerWidget {
  const FinancialChartTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBranchId = ref.watch(selectedBranchIdProvider);

    if (selectedBranchId == null) {
      return const Center(
        child: Text('Select a branch to view financial charts'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: Text('Income vs Expenses Chart')),
        ),
        const SizedBox(height: 24),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: Text('Monthly Profit Trend')),
        ),
      ],
    );
  }
}

class BranchComparisonTab extends ConsumerWidget {
  const BranchComparisonTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesProvider);

    return branchesAsync.when(
      data: (branches) {
        if (branches.length < 2) {
          return const Center(
            child: Text('Add at least two branches to compare'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                heightFactor: 5,
                child: Text('Branch Comparison Chart'),
              ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: branches.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        branches[index].name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(branches[index].name),
                    subtitle: const Text('Profit: \$0.00'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      final index =
                          ref.read(homeScreenIndexProvider.notifier).state = 0;
                      ref.read(selectedBranchIdProvider.notifier).state =
                          branches[index].id;
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Error: ${error.toString()}')),
    );
  }
}

class RecentTransactionsList extends ConsumerWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(selectedBranchTransactionsProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(child: Text('No transactions recorded'));
        }

        // Sort by date and take most recent 5
        final recentTransactions = List<Transaction>.from(transactions)
          ..sort((a, b) => b.date.compareTo(a.date))
          ..take(5);

        return Column(
          children: [
            ...recentTransactions.map(
              (transaction) => TransactionListItem(
                transaction: transaction,
                onTap: () {
                  ref.read(transactionFormProvider.notifier).state =
                      transaction;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const TransactionFormScreen(isEditing: true),
                    ),
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () {
                final index = ref.read(homeScreenIndexProvider.notifier).state =
                    2;
              },
              child: const Text('View All Transactions'),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Error: ${error.toString()}')),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Theme'),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                    onChanged: (ThemeMode? newThemeMode) {
                      if (newThemeMode != null) {
                        ref.read(themeModeProvider.notifier).state =
                            newThemeMode;
                      }
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Security'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to security settings
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to notification settings
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Account'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to account settings
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Backup & Restore'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to backup settings
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to help & support
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Multi-Branch Finance',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 Multi-Branch Finance',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add a provider to keep track of the selected index in the HomeScreen
final homeScreenIndexProvider = StateProvider<int>((ref) => 0);

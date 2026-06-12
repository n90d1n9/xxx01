import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class Branch {
  final String id;
  final String name;
  final String address;
  final String managerName;
  final String phoneNumber;
  final bool isActive;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.managerName,
    required this.phoneNumber,
    this.isActive = true,
  });
}

class BranchMenu {
  final String id;
  final String branchId;
  final String itemName;
  final double price;
  final bool isAvailable;
  final String category;

  BranchMenu({
    required this.id,
    required this.branchId,
    required this.itemName,
    required this.price,
    this.isAvailable = true,
    required this.category,
  });
}

class BranchExpense {
  final String id;
  final String branchId;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  BranchExpense({
    required this.id,
    required this.branchId,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}

// Repository
class BranchRepository {
  Future<List<Branch>> fetchBranches() async {
    // Simulating API call
    await Future.delayed(const Duration(seconds: 1));
    return [
      Branch(
        id: '1',
        name: 'Downtown Branch',
        address: '123 Main St, City Center',
        managerName: 'Alex Johnson',
        phoneNumber: '(555) 123-4567',
      ),
      Branch(
        id: '2',
        name: 'Westside Branch',
        address: '456 Park Ave, Westside',
        managerName: 'Sam Smith',
        phoneNumber: '(555) 987-6543',
      ),
      Branch(
        id: '3',
        name: 'Eastside Branch',
        address: '789 Oak Rd, Eastside',
        managerName: 'Jamie Lee',
        phoneNumber: '(555) 456-7890',
      ),
    ];
  }

  Future<List<BranchMenu>> fetchBranchMenu(String branchId) async {
    // Simulating API call
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      BranchMenu(
        id: '1',
        branchId: branchId,
        itemName: 'Signature Burger',
        price: 12.99,
        category: 'Main Course',
      ),
      BranchMenu(
        id: '2',
        branchId: branchId,
        itemName: 'Truffle Fries',
        price: 6.99,
        category: 'Sides',
      ),
      BranchMenu(
        id: '3',
        branchId: branchId,
        itemName: 'Chocolate Mousse',
        price: 8.99,
        category: 'Dessert',
      ),
    ];
  }

  Future<List<BranchExpense>> fetchBranchExpenses(String branchId) async {
    // Simulating API call
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      BranchExpense(
        id: '1',
        branchId: branchId,
        title: 'Utilities',
        amount: 450.00,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Operational',
      ),
      BranchExpense(
        id: '2',
        branchId: branchId,
        title: 'Ingredients Stock',
        amount: 1250.00,
        date: DateTime.now().subtract(const Duration(days: 5)),
        category: 'Inventory',
      ),
      BranchExpense(
        id: '3',
        branchId: branchId,
        title: 'Staff Salary',
        amount: 3200.00,
        date: DateTime.now().subtract(const Duration(days: 7)),
        category: 'Personnel',
      ),
    ];
  }
}

// Providers
final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return BranchRepository();
});

final branchesProvider = FutureProvider<List<Branch>>((ref) {
  final repository = ref.watch(branchRepositoryProvider);
  return repository.fetchBranches();
});

final selectedBranchProvider = StateProvider<Branch?>((ref) => null);

final branchMenuProvider = FutureProvider.family<List<BranchMenu>, String>((
  ref,
  branchId,
) {
  final repository = ref.watch(branchRepositoryProvider);
  return repository.fetchBranchMenu(branchId);
});

final branchExpensesProvider =
    FutureProvider.family<List<BranchExpense>, String>((ref, branchId) {
      final repository = ref.watch(branchRepositoryProvider);
      return repository.fetchBranchExpenses(branchId);
    });

// Main Screen
class BranchManagementScreen extends ConsumerWidget {
  const BranchManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(branchesProvider);
    final selectedBranch = ref.watch(selectedBranchProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Branch Management'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add new branch
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(branchesProvider);
            },
          ),
        ],
      ),
      body: branches.when(
        data: (data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBranchSelector(context, ref, data),
              if (selectedBranch != null)
                _buildSelectedBranchDetails(context, ref, selectedBranch),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchSelector(
    BuildContext context,
    WidgetRef ref,
    List<Branch> branches,
  ) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: branches.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final branch = branches[index];
          final isSelected = ref.watch(selectedBranchProvider)?.id == branch.id;

          return GestureDetector(
            onTap: () {
              ref.read(selectedBranchProvider.notifier).state = branch;
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurple : Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      branch.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      branch.managerName,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedBranchDetails(
    BuildContext context,
    WidgetRef ref,
    Branch branch,
  ) {
    return Expanded(
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.deepPurple,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Menu'),
                  Tab(text: 'Expenses'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBranchOverview(context, branch),
                  _buildBranchMenu(context, ref, branch),
                  _buildBranchExpenses(context, ref, branch),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchOverview(BuildContext context, Branch branch) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Branch Information'),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            child: Column(
              children: [
                _buildInfoRow('Branch Name', branch.name),
                _buildInfoRow('Address', branch.address),
                _buildInfoRow('Manager', branch.managerName),
                _buildInfoRow('Contact', branch.phoneNumber),
                _buildInfoRow(
                  'Status',
                  branch.isActive ? 'Active' : 'Inactive',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Quick Stats'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Menu Items',
                  value: '24',
                  icon: Icons.restaurant_menu,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Staff',
                  value: '12',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Monthly Revenue',
                  value: '\$24,500',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Expenses',
                  value: '\$9,200',
                  icon: Icons.account_balance_wallet,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBranchMenu(BuildContext context, WidgetRef ref, Branch branch) {
    final menuProvider = ref.watch(branchMenuProvider(branch.id));

    return menuProvider.when(
      data: (menuItems) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu Items (${menuItems.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add new menu item
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        item.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        item.category,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Switch(
                            value: item.isAvailable,
                            activeColor: Colors.deepPurple,
                            onChanged: (value) {
                              // Update availability
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error loading menu: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildBranchExpenses(
    BuildContext context,
    WidgetRef ref,
    Branch branch,
  ) {
    final expensesProvider = ref.watch(branchExpensesProvider(branch.id));

    return expensesProvider.when(
      data: (expenses) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expenses (${expenses.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add new expense
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            expense.category,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCategoryIcon(expense.category),
                          color: _getCategoryColor(expense.category),
                        ),
                      ),
                      title: Text(
                        expense.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${DateFormat('MMM dd, yyyy').format(expense.date)} • ${expense.category}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error loading expenses: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'operational':
        return Colors.blue;
      case 'inventory':
        return Colors.orange;
      case 'personnel':
        return Colors.purple;
      case 'maintenance':
        return Colors.green;
      case 'marketing':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'operational':
        return Icons.business;
      case 'inventory':
        return Icons.inventory;
      case 'personnel':
        return Icons.people;
      case 'maintenance':
        return Icons.build;
      case 'marketing':
        return Icons.campaign;
      default:
        return Icons.attach_money;
    }
  }
}

// Main app
class RestaurantManagementApp extends StatelessWidget {
  const RestaurantManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Restaurant Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.grey[100],
          fontFamily: 'Poppins',
        ),
        home: const BranchManagementScreen(),
      ),
    );
  }
}

void main() {
  runApp(const RestaurantManagementApp());
}

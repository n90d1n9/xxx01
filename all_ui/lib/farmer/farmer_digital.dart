import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';

// Models
class Stakeholder {
  final String id;
  final String name;
  final String role;
  final String imageUrl;
  final List<String> connectedTo;
  final Map<String, dynamic> metrics;

  Stakeholder({
    required this.id,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.connectedTo,
    required this.metrics,
  });
}

class Transaction {
  final String id;
  final String fromId;
  final String toId;
  final String itemName;
  final double amount;
  final DateTime timestamp;
  final String status;

  Transaction({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.itemName,
    required this.amount,
    required this.timestamp,
    required this.status,
  });
}

// State notifiers
class EcosystemNotifier extends StateNotifier<List<Stakeholder>> {
  EcosystemNotifier() : super([]) {
    _initializeEcosystem();
  }

  void _initializeEcosystem() {
    state = [
      Stakeholder(
        id: '1',
        name: 'Green Farms Co.',
        role: 'Farmer',
        imageUrl: 'assets/farmer.png',
        connectedTo: ['2', '3'],
        metrics: {
          'crops': 5,
          'yield': '3.5 tons',
          'sales': '\$12,500',
          'sustainability': 4.2,
        },
      ),
      Stakeholder(
        id: '2',
        name: 'OceanHarvest Ltd.',
        role: 'Aquaculture',
        imageUrl: 'assets/aqua.png',
        connectedTo: ['3', '5'],
        metrics: {
          'species': 3,
          'yield': '2.8 tons',
          'sales': '\$18,300',
          'sustainability': 4.5,
        },
      ),
      Stakeholder(
        id: '3',
        name: 'FastTrans Logistics',
        role: 'Logistics',
        imageUrl: 'assets/logistics.png',
        connectedTo: ['1', '2', '4', '5'],
        metrics: {
          'vehicles': 12,
          'deliveries': '43/day',
          'on_time': '92%',
          'efficiency': 4.1,
        },
      ),
      Stakeholder(
        id: '4',
        name: 'Market Connect',
        role: 'Middleman',
        imageUrl: 'assets/middleman.png',
        connectedTo: ['1', '3', '5'],
        metrics: {
          'transactions': '87/week',
          'volume': '\$45,200',
          'products': 18,
          'rating': 4.0,
        },
      ),
      Stakeholder(
        id: '5',
        name: 'FreshDistribute Inc.',
        role: 'Distributor',
        imageUrl: 'assets/distributor.png',
        connectedTo: ['3', '4', '6'],
        metrics: {
          'retailers': 28,
          'volume': '\$128,500',
          'products': 32,
          'freshness': '96%',
        },
      ),
      Stakeholder(
        id: '6',
        name: 'Urban Markets',
        role: 'Consumer',
        imageUrl: 'assets/consumer.png',
        connectedTo: ['5'],
        metrics: {
          'purchases': '235/day',
          'spend': '\$18,700',
          'satisfaction': 4.7,
          'retention': '88%',
        },
      ),
    ];
  }

  void filterByRole(String? role) {
    if (role == null || role == 'All') {
      _initializeEcosystem();
    } else {
      _initializeEcosystem();
      state = state.where((stakeholder) => stakeholder.role == role).toList();
    }
  }

  void searchStakeholders(String query) {
    if (query.isEmpty) {
      _initializeEcosystem();
    } else {
      _initializeEcosystem();
      state = state.where((stakeholder) => 
        stakeholder.name.toLowerCase().contains(query.toLowerCase()) ||
        stakeholder.role.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }
}

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super([]) {
    _initializeTransactions();
  }

  void _initializeTransactions() {
    state = [
      Transaction(
        id: 't1',
        fromId: '1',
        toId: '3',
        itemName: 'Organic Vegetables',
        amount: 2500.00,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'Completed',
      ),
      Transaction(
        id: 't2',
        fromId: '2',
        toId: '3',
        itemName: 'Fresh Fish',
        amount: 3800.00,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        status: 'In Transit',
      ),
      Transaction(
        id: 't3',
        fromId: '3',
        toId: '5',
        itemName: 'Mixed Produce',
        amount: 6200.00,
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        status: 'Delivered',
      ),
      Transaction(
        id: 't4',
        fromId: '5',
        toId: '6',
        itemName: 'Assorted Seafood',
        amount: 4750.00,
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        status: 'Completed',
      ),
      Transaction(
        id: 't5',
        fromId: '4',
        toId: '5',
        itemName: 'Organic Fruits',
        amount: 3300.00,
        timestamp: DateTime.now().subtract(const Duration(hours: 24)),
        status: 'Processing',
      ),
    ];
  }

  void filterByStatus(String? status) {
    if (status == null || status == 'All') {
      _initializeTransactions();
    } else {
      _initializeTransactions();
      state = state.where((transaction) => transaction.status == status).toList();
    }
  }
}

// Providers
final tabIndexProvider = StateProvider<int>((ref) => 0);

final ecosystemProvider = StateNotifierProvider<EcosystemNotifier, List<Stakeholder>>((ref) {
  return EcosystemNotifier();
});

final transactionsProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  return TransactionNotifier();
});

final roleFilterProvider = StateProvider<String?>((ref) => 'All');
final transactionStatusFilterProvider = StateProvider<String?>((ref) => 'All');
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredEcosystemProvider = Provider<List<Stakeholder>>((ref) {
  final stakeholders = ref.watch(ecosystemProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final roleFilter = ref.watch(roleFilterProvider);
  
  if (searchQuery.isNotEmpty) {
    return stakeholders.where((stakeholder) => 
      stakeholder.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
      stakeholder.role.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }
  
  if (roleFilter != null && roleFilter != 'All') {
    return stakeholders.where((stakeholder) => stakeholder.role == roleFilter).toList();
  }
  
  return stakeholders;
});

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final statusFilter = ref.watch(transactionStatusFilterProvider);
  
  if (statusFilter != null && statusFilter != 'All') {
    return transactions.where((transaction) => transaction.status == statusFilter).toList();
  }
  
  return transactions;
});

// Theme
final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.green,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: Colors.grey[100],
  fontFamily: 'Roboto',
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green[700],
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

// Main App
void main() {
  runApp(const ProviderScope(child: AgriAquaEcosystemApp()));
}

class AgriAquaEcosystemApp extends StatelessWidget {
  const AgriAquaEcosystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agri-Aqua Ecosystem',
      theme: appTheme,
      home: const EcosystemHubScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EcosystemHubScreen extends ConsumerWidget {
  const EcosystemHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(tabIndexProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri-Aqua Ecosystem Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile coming soon!')),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: tabIndex,
        children: const [
          StakeholderNetworkTab(),
          TransactionsTab(),
          AnalyticsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIndex,
        onTap: (index) => ref.read(tabIndexProvider.notifier).state = index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.hub),
            label: 'Ecosystem',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
        selectedItemColor: Colors.green[700],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const NewActionSheet(),
          );
        },
      ),
    );
  }
}

// Tabs
class StakeholderNetworkTab extends ConsumerWidget {
  const StakeholderNetworkTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stakeholders = ref.watch(filteredEcosystemProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final roleFilter = ref.watch(roleFilterProvider);

    return Column(
      children: [
        // Filter and Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Role Filter
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: roleFilter,
                      isExpanded: true,
                      hint: const Text('Filter by Role'),
                      items: [
                        'All',
                        'Farmer',
                        'Aquaculture',
                        'Logistics',
                        'Middleman',
                        'Distributor',
                        'Consumer',
                      ].map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      )).toList(),
                      onChanged: (value) {
                        ref.read(roleFilterProvider.notifier).state = value;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Search
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search stakeholders',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Network Visualization
        Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // This would ideally be a proper network visualization
              // Using a placeholder for now
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/network_visualization.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hub, size: 60, color: Colors.green[300]),
                          const SizedBox(height: 8),
                          Text(
                            'Ecosystem Network',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${stakeholders.length} stakeholders',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Full network view coming soon!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Stakeholder List
        Expanded(
          child: stakeholders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No stakeholders found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stakeholders.length,
                  itemBuilder: (context, index) {
                    final stakeholder = stakeholders[index];
                    return StakeholderCard(stakeholder: stakeholder);
                  },
                ),
        ),
      ],
    );
  }
}

class StakeholderCard extends ConsumerWidget {
  final Stakeholder stakeholder;
  
  const StakeholderCard({super.key, required this.stakeholder});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStakeholders = ref.watch(ecosystemProvider);
    
    // Find connected stakeholders
    final connectedStakeholders = allStakeholders
        .where((s) => stakeholder.connectedTo.contains(s.id))
        .toList();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StakeholderDetailScreen(stakeholder: stakeholder),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.green[100],
                    child: Icon(
                      _getIconForRole(stakeholder.role),
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stakeholder.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          stakeholder.role,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Key Metrics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMetricItem(
                    stakeholder.metrics.keys.elementAt(0),
                    stakeholder.metrics.values.elementAt(0).toString(),
                  ),
                  _buildMetricItem(
                    stakeholder.metrics.keys.elementAt(1),
                    stakeholder.metrics.values.elementAt(1).toString(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Connected With',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: connectedStakeholders.length,
                  itemBuilder: (context, index) {
                    final connected = connectedStakeholders[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getIconForRole(connected.role),
                            size: 16,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            connected.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForRole(String role) {
    switch (role) {
      case 'Farmer':
        return Icons.agriculture;
      case 'Aquaculture':
        return Icons.water;
      case 'Logistics':
        return Icons.local_shipping;
      case 'Middleman':
        return Icons.swap_horiz;
      case 'Distributor':
        return Icons.store;
      case 'Consumer':
        return Icons.shopping_cart;
      default:
        return Icons.business;
    }
  }
}

class TransactionsTab extends ConsumerWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final statusFilter = ref.watch(transactionStatusFilterProvider);
    final stakeholders = ref.watch(ecosystemProvider);

    // Helper function to find stakeholder name by ID
    String getStakeholderName(String id) {
      return stakeholders.firstWhere((s) => s.id == id).name;
    }

    return Column(
      children: [
        // Filter Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Status Filter
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: statusFilter,
                      isExpanded: true,
                      hint: const Text('Filter by Status'),
                      items: [
                        'All',
                        'Completed',
                        'In Transit',
                        'Processing',
                        'Delivered',
                      ].map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      )).toList(),
                      onChanged: (value) {
                        ref.read(transactionStatusFilterProvider.notifier).state = value;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Date filter coming soon!')),
                  );
                },
                tooltip: 'Filter by date',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ],
          ),
        ),

        // Transaction Summary
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Last 24 Hours',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildSummaryItem(
                    'Total Volume',
                    '\${transactions.fold(0.0, (sum, tx) => sum + tx.amount).toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                  _buildSummaryItem(
                    'Transactions',
                    transactions.length.toString(),
                    Icons.swap_horiz,
                  ),
                  _buildSummaryItem(
                    'Completed',
                    '${transactions.where((tx) => tx.status == 'Completed').length}',
                    Icons.check_circle_outline,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Transaction List
        Expanded(
          child: transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swap_horiz, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (statusFilter != 'All')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextButton(
                            onPressed: () {
                              ref.read(transactionStatusFilterProvider.notifier).state = 'All';
                            },
                            child: const Text('Clear Filter'),
                          ),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => TransactionDetailSheet(
                              transaction: transaction,
                              fromName: getStakeholderName(transaction.fromId),
                              toName: getStakeholderName(transaction.toId),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ID: ${transaction.id}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  _buildStatusChip(transaction.status),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                transaction.itemName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.swap_horiz, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${getStakeholderName(transaction.fromId)} → ${getStakeholderName(transaction.toId)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_money, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        '\${transaction.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(transaction.timestamp),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
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
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.green[700]),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (status) {
      case 'Completed':
        backgroundColor = Colors.green[700]!;
        icon = Icons.check_circle;
        break;
      case 'In Transit':
        backgroundColor = Colors.blue[700]!;
        icon = Icons.local_shipping;
        break;
      case 'Processing':
        backgroundColor = Colors.orange[700]!;
        icon = Icons.sync;
        break;
      case 'Delivered':
        backgroundColor = Colors.purple[700]!;
        icon = Icons.inventory;
        break;
      default:
        backgroundColor = Colors.grey[700]!;
        icon = Icons.circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
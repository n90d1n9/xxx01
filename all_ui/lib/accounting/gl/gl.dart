import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// Models
class Transaction {
  final String id;
  final DateTime date;
  final String description;
  final String account;
  final double amount;
  final bool isDebit;
  final String reference;

  Transaction({
    required this.id,
    required this.date,
    required this.description,
    required this.account,
    required this.amount,
    required this.isDebit,
    required this.reference,
  });
}

class AccountBalance {
  final String account;
  final double balance;

  AccountBalance({required this.account, required this.balance});
}

// Providers
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
      return TransactionsNotifier();
    });

final filteredTransactionsProvider = StateProvider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final filter = ref.watch(transactionFilterProvider);

  if (filter.isEmpty) return transactions;

  return transactions.where((transaction) {
    return transaction.description.toLowerCase().contains(
          filter.toLowerCase(),
        ) ||
        transaction.account.toLowerCase().contains(filter.toLowerCase()) ||
        transaction.reference.toLowerCase().contains(filter.toLowerCase());
  }).toList();
});

final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final transactionFilterProvider = StateProvider<String>((ref) => '');

final accountBalancesProvider = Provider<List<AccountBalance>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final Map<String, double> balances = {};

  for (final transaction in transactions) {
    balances.update(
      transaction.account,
      (value) =>
          value +
          (transaction.isDebit ? transaction.amount : -transaction.amount),
      ifAbsent:
          () => transaction.isDebit ? transaction.amount : -transaction.amount,
    );
  }

  return balances.entries
      .map((entry) => AccountBalance(account: entry.key, balance: entry.value))
      .toList();
});

// Notifiers
class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  TransactionsNotifier() : super(_generateSampleTransactions());

  static List<Transaction> _generateSampleTransactions() {
    // Sample data for demonstration
    return [
      Transaction(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Office Supplies Purchase',
        account: 'Expenses:Office Supplies',
        amount: 250.00,
        isDebit: true,
        reference: 'INV-2023-001',
      ),
      Transaction(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 5)),
        description: 'Office Supplies Purchase',
        account: 'Assets:Checking Account',
        amount: 250.00,
        isDebit: false,
        reference: 'INV-2023-001',
      ),
      Transaction(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Client Payment',
        account: 'Assets:Checking Account',
        amount: 5000.00,
        isDebit: true,
        reference: 'PAY-2023-042',
      ),
      Transaction(
        id: '4',
        date: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Client Payment',
        account: 'Revenue:Consulting Services',
        amount: 5000.00,
        isDebit: false,
        reference: 'PAY-2023-042',
      ),
      Transaction(
        id: '5',
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Rent Payment',
        account: 'Expenses:Rent',
        amount: 2000.00,
        isDebit: true,
        reference: 'RENT-2023-03',
      ),
      Transaction(
        id: '6',
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Rent Payment',
        account: 'Assets:Checking Account',
        amount: 2000.00,
        isDebit: false,
        reference: 'RENT-2023-03',
      ),
    ];
  }

  void addTransaction(Transaction transaction) {
    state = [...state, transaction];
  }

  void removeTransaction(String id) {
    state = state.where((transaction) => transaction.id != id).toList();
  }
}

// UI Components
class GeneralLedgerScreen extends ConsumerWidget {
  const GeneralLedgerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final filter = ref.watch(transactionFilterProvider);
    final accountBalances = ref.watch(accountBalancesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'General Ledger',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDateRange(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportData(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(context, accountBalances),
          _buildSearchBar(context, ref, filter),
          _buildTransactionsList(context, transactions),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionModal(context, ref),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    List<AccountBalance> balances,
  ) {
    // Calculate total assets, liabilities, etc.
    double totalAssets = 0;
    double totalLiabilities = 0;
    double totalRevenue = 0;
    double totalExpenses = 0;

    for (final balance in balances) {
      if (balance.account.startsWith('Assets:')) {
        totalAssets += balance.balance;
      } else if (balance.account.startsWith('Liabilities:')) {
        totalLiabilities += balance.balance;
      } else if (balance.account.startsWith('Revenue:')) {
        totalRevenue += balance.balance;
      } else if (balance.account.startsWith('Expenses:')) {
        totalExpenses += balance.balance;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSummaryCard(
                  context,
                  'Total Assets',
                  totalAssets,
                  Colors.blue,
                  Icons.account_balance,
                ),
                _buildSummaryCard(
                  context,
                  'Total Liabilities',
                  totalLiabilities,
                  Colors.orange,
                  Icons.credit_card,
                ),
                _buildSummaryCard(
                  context,
                  'Total Revenue',
                  totalRevenue,
                  Colors.green,
                  Icons.trending_up,
                ),
                _buildSummaryCard(
                  context,
                  'Total Expenses',
                  totalExpenses,
                  Colors.red,
                  Icons.trending_down,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 150, child: _buildChart(balances)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    final formatter = NumberFormat.currency(symbol: '\$');
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<AccountBalance> balances) {
    // Get top accounts by balance magnitude
    final topAccounts = [...balances];
    topAccounts.sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
    final displayAccounts = topAccounts.take(5).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.center,
            maxY:
                displayAccounts.isEmpty
                    ? 1000
                    : displayAccounts
                            .map((a) => a.balance.abs())
                            .reduce((a, b) => a > b ? a : b) *
                        1.2,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= displayAccounts.length)
                      return const Text('');
                    final account = displayAccounts[value.toInt()];
                    final parts = account.account.split(':');
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        parts.last,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: false),
            barGroups: List.generate(
              displayAccounts.length,
              (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: displayAccounts[i].balance.abs(),
                    color:
                        displayAccounts[i].balance > 0
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                    width: 16,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref, String filter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged:
            (value) =>
                ref.read(transactionFilterProvider.notifier).state = value,
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              filter.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed:
                        () =>
                            ref.read(transactionFilterProvider.notifier).state =
                                '',
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    return Expanded(
      child:
          transactions.isEmpty
              ? const Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionItem(context, transaction);
                },
              ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final formatter = NumberFormat.currency(symbol: '\$');
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              transaction.isDebit
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
          child: Icon(
            transaction.isDebit ? Icons.add : Icons.remove,
            color: transaction.isDebit ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              transaction.account,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  dateFormatter.format(transaction.date),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(width: 12),
                Icon(Icons.receipt, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Ref: ${transaction.reference}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          formatter.format(transaction.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: transaction.isDebit ? Colors.green : Colors.red,
          ),
        ),
        onTap: () => _showTransactionDetails(context, transaction),
      ),
    );
  }

  void _selectDateRange(BuildContext context, WidgetRef ref) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(selectedDateRangeProvider.notifier).state = picked;
      // Implement date filtering logic here
    }
  }

  void _exportData(BuildContext context) {
    // Show export options dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Options'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: const Text('CSV'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exporting to CSV...')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('PDF'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exporting to PDF...')),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    final formatter = NumberFormat.currency(symbol: '\$');
    final dateFormatter = DateFormat('MMM dd, yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                _detailRow('Description', transaction.description),
                _detailRow('Account', transaction.account),
                _detailRow('Amount', formatter.format(transaction.amount)),
                _detailRow('Type', transaction.isDebit ? 'Debit' : 'Credit'),
                _detailRow('Date', dateFormatter.format(transaction.date)),
                _detailRow('Reference', transaction.reference),
                _detailRow('ID', transaction.id),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Implement editing logic
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Implement delete logic
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    String description = '';
    String account = '';
    double amount = 0;
    bool isDebit = true;
    String reference = '';

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
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Transaction',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => description = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Account',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => account = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Required';
                      if (double.tryParse(value) == null)
                        return 'Invalid amount';
                      return null;
                    },
                    onSaved: (value) => amount = double.parse(value!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Transaction Type:'),
                      const SizedBox(width: 16),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Row(
                            children: [
                              Radio<bool>(
                                value: true,
                                groupValue: isDebit,
                                onChanged: (value) {
                                  setState(() {
                                    isDebit = value!;
                                  });
                                },
                              ),
                              const Text('Debit'),
                              const SizedBox(width: 16),
                              Radio<bool>(
                                value: false,
                                groupValue: isDebit,
                                onChanged: (value) {
                                  setState(() {
                                    isDebit = value!;
                                  });
                                },
                              ),
                              const Text('Credit'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Reference',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSaved: (value) => reference = value!,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          final transaction = Transaction(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            date: DateTime.now(),
                            description: description,
                            account: account,
                            amount: amount,
                            isDebit: isDebit,
                            reference: reference,
                          );
                          ref
                              .read(transactionsProvider.notifier)
                              .addTransaction(transaction);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Transaction'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }
}

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'General Ledger',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const GeneralLedgerScreen(),
      ),
    ),
  );
}

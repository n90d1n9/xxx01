import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../states/transaction_provider.dart';
import '../widgets/add_trx_form.dart';

class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final dateFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Sort by date descending
    final sortedTransactions = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: sortedTransactions.isEmpty
          ? const Center(
              child: Text(
                'No transactions found.\nAdd a transaction using the + button.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: sortedTransactions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final transaction = sortedTransactions[index];
                return Dismissible(
                  key: Key(transaction.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm"),
                          content: const Text(
                            "Are you sure you want to delete this transaction?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("CANCEL"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("DELETE"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    ref
                        .read(transactionProvider.notifier)
                        .deleteTransaction(transaction.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Transaction deleted")),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          transaction.type == TransactionType.income
                          ? Colors.green[100]
                          : Colors.red[100],
                      child: Icon(
                        transaction.type == TransactionType.income
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: transaction.type == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(
                      transaction.description,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${_getCategoryName(transaction.category)} • ${dateFormat.format(transaction.date)}',
                    ),
                    trailing: Text(
                      currencyFormat.format(transaction.amount),
                      style: TextStyle(
                        color: transaction.type == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _editTransaction(context, transaction, ref),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddTransactionDialog(context, ref),
      ),
    );
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.sales:
        return 'Sales';
      case TransactionCategory.services:
        return 'Services';
      case TransactionCategory.investments:
        return 'Investments';
      case TransactionCategory.otherIncome:
        return 'Other Income';
      case TransactionCategory.costOfGoodsSold:
        return 'Cost of Goods Sold';
      case TransactionCategory.wages:
        return 'Wages & Salaries';
      case TransactionCategory.rent:
        return 'Rent';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.marketing:
        return 'Marketing';
      case TransactionCategory.supplies:
        return 'Supplies';
      case TransactionCategory.maintenance:
        return 'Maintenance';
      case TransactionCategory.insurance:
        return 'Insurance';
      case TransactionCategory.taxes:
        return 'Taxes';
      case TransactionCategory.otherExpense:
        return 'Other Expenses';
      default:
        return 'Unknown';
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.sort),
                title: const Text('Sort by Date (Newest First)'),
                onTap: () {
                  Navigator.pop(context);
                  // Already sorted this way
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort),
                title: const Text('Sort by Date (Oldest First)'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement reverse sorting
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Sort by Amount (Highest First)'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement amount sorting
                },
              ),
              ListTile(
                leading: const Icon(Icons.filter_list),
                title: const Text('Filter by Type'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement type filtering
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddTransactionForm(),
      ),
    );
  }

  void _editTransaction(
    BuildContext context,
    Transaction transaction,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddTransactionForm(transaction: transaction),
      ),
    );
  }
}

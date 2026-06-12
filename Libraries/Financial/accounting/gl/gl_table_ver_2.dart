import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import 'models/ledger_filter.dart';
import 'models/ledger_trx.dart';
import 'states/filter_provider.dart';
import 'states/ledger_provider.dart';

class GeneralLedgerScreen extends ConsumerWidget {
  const GeneralLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(ledgerFilterProvider);
    final transactions = ref.watch(filteredLedgerProvider(filter));
    final ledgerNotifier = ref.read(ledgerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('General Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref, filter),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Total Debits',
                    '\$${ledgerNotifier.getTotalDebit().toStringAsFixed(2)}',
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    'Total Credits',
                    '\$${ledgerNotifier.getTotalCredit().toStringAsFixed(2)}',
                    Colors.red,
                  ),
                  _buildSummaryItem(
                    'Net Balance',
                    '\$${ledgerNotifier.getNetBalance().toStringAsFixed(2)}',
                    ledgerNotifier.getNetBalance() >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
          ),

          // Ledger Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Account')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Reference')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: transactions.map((transaction) {
                    return DataRow(
                      cells: [
                        DataCell(Text(transaction.formattedDate)),
                        DataCell(Text(transaction.account)),
                        DataCell(Text(transaction.description)),
                        DataCell(Text(transaction.type.name)),
                        DataCell(
                          Text(
                            transaction.formattedAmount,
                            style: TextStyle(
                              color: transaction.type == TransactionType.debit
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(Text(transaction.reference)),
                        DataCell(Text(transaction.category)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditTransactionDialog(
                                  context,
                                  ref,
                                  transaction,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () =>
                                    _confirmDelete(context, ref, transaction),
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
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(
    BuildContext context,
    WidgetRef ref,
    LedgerFilter currentFilter,
  ) {
    DateTime? startDate = currentFilter.startDate;
    DateTime? endDate = currentFilter.endDate;
    String? account = currentFilter.account;
    String? category = currentFilter.category;
    String? searchTerm = currentFilter.searchTerm;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Transactions'),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Start Date'),
                            subtitle: Text(
                              startDate != null
                                  ? DateFormat('yyyy-MM-dd').format(startDate!)
                                  : 'Not set',
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => startDate = date);
                              }
                            },
                            trailing: startDate != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () =>
                                        setState(() => startDate = null),
                                  )
                                : null,
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('End Date'),
                            subtitle: Text(
                              endDate != null
                                  ? DateFormat('yyyy-MM-dd').format(endDate!)
                                  : 'Not set',
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() => endDate = date);
                              }
                            },
                            trailing: endDate != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () =>
                                        setState(() => endDate = null),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Account',
                        hintText: 'Filter by account name',
                      ),
                      controller: TextEditingController(text: account),
                      onChanged: (value) => account = value,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        hintText: 'Filter by category',
                      ),
                      controller: TextEditingController(text: category),
                      onChanged: (value) => category = value,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        hintText: 'Search in description or reference',
                      ),
                      controller: TextEditingController(text: searchTerm),
                      onChanged: (value) => searchTerm = value,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Clear All'),
                  onPressed: () {
                    setState(() {
                      startDate = null;
                      endDate = null;
                      account = null;
                      category = null;
                      searchTerm = null;
                    });
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    ref
                        .read(ledgerFilterProvider.notifier)
                        .state = LedgerFilter(
                      startDate: startDate,
                      endDate: endDate,
                      account: account,
                      category: category,
                      searchTerm: searchTerm,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final accountController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    final categoryController = TextEditingController();
    TransactionType type = TransactionType.debit;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Transaction'),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: dateController,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a date';
                          }
                          return null;
                        },
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            dateController.text = DateFormat(
                              'yyyy-MM-dd',
                            ).format(date);
                          }
                        },
                      ),
                      TextFormField(
                        controller: accountController,
                        decoration: const InputDecoration(labelText: 'Account'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an account';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<TransactionType>(
                        value: type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: TransactionType.values.map((
                          TransactionType type,
                        ) {
                          return DropdownMenuItem<TransactionType>(
                            value: type,
                            child: Text(type.name),
                          );
                        }).toList(),
                        onChanged: (TransactionType? newValue) {
                          if (newValue != null) {
                            setState(() {
                              type = newValue;
                            });
                          }
                        },
                      ),
                      TextFormField(
                        controller: amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: '\$ ',
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
                      TextFormField(
                        controller: referenceController,
                        decoration: const InputDecoration(
                          labelText: 'Reference',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a reference';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newTransaction = LedgerTransaction(
                        date: DateFormat(
                          'yyyy-MM-dd',
                        ).parse(dateController.text),
                        account: accountController.text,
                        description: descriptionController.text,
                        type: type,
                        amount: double.parse(amountController.text),
                        reference: referenceController.text,
                        category: categoryController.text,
                      );

                      ref
                          .read(ledgerProvider.notifier)
                          .addTransaction(newTransaction);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTransactionDialog(
    BuildContext context,
    WidgetRef ref,
    LedgerTransaction transaction,
  ) {
    final formKey = GlobalKey<FormState>();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(transaction.date),
    );
    final accountController = TextEditingController(text: transaction.account);
    final descriptionController = TextEditingController(
      text: transaction.description,
    );
    final amountController = TextEditingController(
      text: transaction.amount.toString(),
    );
    final referenceController = TextEditingController(
      text: transaction.reference,
    );
    final categoryController = TextEditingController(
      text: transaction.category,
    );
    var type = transaction.type;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Transaction'),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: dateController,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a date';
                          }
                          return null;
                        },
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: transaction.date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            dateController.text = DateFormat(
                              'yyyy-MM-dd',
                            ).format(date);
                          }
                        },
                      ),
                      TextFormField(
                        controller: accountController,
                        decoration: const InputDecoration(labelText: 'Account'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an account';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<TransactionType>(
                        value: type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: TransactionType.values.map((
                          TransactionType value,
                        ) {
                          return DropdownMenuItem<TransactionType>(
                            value: value,
                            child: Text(value.name),
                          );
                        }).toList(),
                        onChanged: (TransactionType? newValue) {
                          if (newValue != null) {
                            setState(() {
                              type = newValue;
                            });
                          }
                        },
                      ),
                      TextFormField(
                        controller: amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: '\$ ',
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
                      TextFormField(
                        controller: referenceController,
                        decoration: const InputDecoration(
                          labelText: 'Reference',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a reference';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updatedTransaction = transaction.copyWith(
                        date: DateFormat(
                          'yyyy-MM-dd',
                        ).parse(dateController.text),
                        account: accountController.text,
                        description: descriptionController.text,
                        type: type,
                        amount: double.parse(amountController.text),
                        reference: referenceController.text,
                        category: categoryController.text,
                      );

                      ref
                          .read(ledgerProvider.notifier)
                          .updateTransaction(updatedTransaction);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LedgerTransaction transaction,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete the transaction:\n"${transaction.description}" for ${transaction.formattedAmount}?',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
              onPressed: () {
                ref
                    .read(ledgerProvider.notifier)
                    .deleteTransaction(transaction.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// Main App

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'General Ledger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GeneralLedgerScreen(),
    );
  }
}

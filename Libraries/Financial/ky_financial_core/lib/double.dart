// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Double-Entry Accounting System',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AccountingScreen(),
    );
  }
}

// Models
class Account {
  final String id;
  final String name;
  final AccountType type;

  Account({required this.name, required this.type}) : id = const Uuid().v4();
}

enum AccountType { asset, liability, equity, revenue, expense }

class Transaction {
  final String id;
  final DateTime date;
  final String description;
  final List<Entry> entries;

  Transaction({
    required this.date,
    required this.description,
    required this.entries,
  }) : id = const Uuid().v4();

  bool get isBalanced {
    final totalDebits = entries
        .where((e) => e.isDebit)
        .fold(0.0, (sum, entry) => sum + entry.amount);
    final totalCredits = entries
        .where((e) => !e.isDebit)
        .fold(0.0, (sum, entry) => sum + entry.amount);
    return (totalDebits - totalCredits).abs() < 0.001;
  }
}

class Entry {
  final String id;
  final String accountId;
  final double amount;
  final bool isDebit;

  Entry({required this.accountId, required this.amount, required this.isDebit})
    : id = const Uuid().v4();
}

// Providers
final accountsProvider = StateNotifierProvider<AccountsNotifier, List<Account>>(
  (ref) {
    return AccountsNotifier();
  },
);

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
      return TransactionsNotifier(ref);
    });

final accountBalancesProvider = Provider<Map<String, double>>((ref) {
  final accounts = ref.watch(accountsProvider);
  final transactions = ref.watch(transactionsProvider);

  final balances = <String, double>{};

  for (final account in accounts) {
    balances[account.id] = 0.0;
  }

  for (final transaction in transactions) {
    for (final entry in transaction.entries) {
      final currentBalance = balances[entry.accountId] ?? 0.0;
      final amount = entry.amount;

      if (entry.isDebit) {
        balances[entry.accountId] = currentBalance + amount;
      } else {
        balances[entry.accountId] = currentBalance - amount;
      }
    }
  }

  return balances;
});

// Notifiers
class AccountsNotifier extends StateNotifier<List<Account>> {
  AccountsNotifier()
    : super([
        Account(name: 'Cash', type: AccountType.asset),
        Account(name: 'Accounts Receivable', type: AccountType.asset),
        Account(name: 'Inventory', type: AccountType.asset),
        Account(name: 'Accounts Payable', type: AccountType.liability),
        Account(name: 'Loans', type: AccountType.liability),
        Account(name: 'Capital', type: AccountType.equity),
        Account(name: 'Sales Revenue', type: AccountType.revenue),
        Account(name: 'Rent Expense', type: AccountType.expense),
        Account(name: 'Utilities Expense', type: AccountType.expense),
        Account(name: 'Salary Expense', type: AccountType.expense),
      ]);

  void addAccount(String name, AccountType type) {
    state = [...state, Account(name: name, type: type)];
  }

  void removeAccount(String id) {
    state = state.where((account) => account.id != id).toList();
  }
}

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final Ref _ref;

  TransactionsNotifier(this._ref) : super([]);

  void addTransaction(DateTime date, String description, List<Entry> entries) {
    final transaction = Transaction(
      date: date,
      description: description,
      entries: entries,
    );

    if (transaction.isBalanced) {
      state = [...state, transaction];
    }
  }

  void removeTransaction(String id) {
    state = state.where((transaction) => transaction.id != id).toList();
  }
}

// UI
class AccountingScreen extends ConsumerStatefulWidget {
  const AccountingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends ConsumerState<AccountingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  final List<EntryFormRow> _entryRows = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _entryRows.add(EntryFormRow(accountId: '', amount: 0, isDebit: true));
    _entryRows.add(EntryFormRow(accountId: '', amount: 0, isDebit: false));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _addEntryRow() {
    setState(() {
      _entryRows.add(
        EntryFormRow(
          accountId: '',
          amount: 0,
          isDebit: _entryRows.isEmpty ? true : !_entryRows.last.isDebit,
        ),
      );
    });
  }

  void _removeEntryRow(int index) {
    setState(() {
      _entryRows.removeAt(index);
    });
  }

  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final entries = _entryRows
          .map(
            (row) => Entry(
              accountId: row.accountId,
              amount: row.amount,
              isDebit: row.isDebit,
            ),
          )
          .toList();

      ref
          .read(transactionsProvider.notifier)
          .addTransaction(_selectedDate, _descriptionController.text, entries);

      // Reset form
      _descriptionController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _entryRows.clear();
        _entryRows.add(EntryFormRow(accountId: '', amount: 0, isDebit: true));
        _entryRows.add(EntryFormRow(accountId: '', amount: 0, isDebit: false));
      });
    }
  }

  double _calculateDebits() {
    return _entryRows
        .where((row) => row.isDebit)
        .fold(0.0, (sum, row) => sum + row.amount);
  }

  double _calculateCredits() {
    return _entryRows
        .where((row) => !row.isDebit)
        .fold(0.0, (sum, row) => sum + row.amount);
  }

  bool _isBalanced() {
    final debits = _calculateDebits();
    final credits = _calculateCredits();
    return (debits - credits).abs() < 0.001;
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);
    final balances = ref.watch(accountBalancesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Double-Entry Accounting System')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Form for new transactions
            Expanded(
              flex: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Transaction',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        // Transaction Date
                        Row(
                          children: [
                            const Text('Date:'),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2025),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                }
                              },
                              child: Text(
                                DateFormat('yyyy-MM-dd').format(_selectedDate),
                              ),
                            ),
                          ],
                        ),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
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
                        const SizedBox(height: 16),

                        // Entries table header
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Account',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Debit',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Credit',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                        const Divider(),

                        // Entries
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: _entryRows.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                children: [
                                  // Account dropdown
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String>(
                                      value: _entryRows[index].accountId.isEmpty
                                          ? null
                                          : _entryRows[index].accountId,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                      ),
                                      items: accounts.map((account) {
                                        return DropdownMenuItem<String>(
                                          value: account.id,
                                          child: Text(account.name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _entryRows[index].accountId =
                                              value ?? '';
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  // Debit field
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      child: TextFormField(
                                        initialValue: _entryRows[index].isDebit
                                            ? _entryRows[index].amount
                                                  .toString()
                                            : '',
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                        ),
                                        textAlign: TextAlign.right,
                                        keyboardType: TextInputType.number,
                                        enabled: _entryRows[index].isDebit,
                                        validator: (value) {
                                          if (_entryRows[index].isDebit) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Required';
                                            }
                                            if (double.tryParse(value) ==
                                                null) {
                                              return 'Invalid';
                                            }
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          if (_entryRows[index].isDebit &&
                                              value != null &&
                                              value.isNotEmpty) {
                                            _entryRows[index].amount =
                                                double.parse(value);
                                          }
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            if (_entryRows[index].isDebit &&
                                                value.isNotEmpty) {
                                              _entryRows[index].amount =
                                                  double.tryParse(value) ?? 0;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),

                                  // Credit field
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      child: TextFormField(
                                        initialValue: !_entryRows[index].isDebit
                                            ? _entryRows[index].amount
                                                  .toString()
                                            : '',
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                        ),
                                        textAlign: TextAlign.right,
                                        keyboardType: TextInputType.number,
                                        enabled: !_entryRows[index].isDebit,
                                        validator: (value) {
                                          if (!_entryRows[index].isDebit) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Required';
                                            }
                                            if (double.tryParse(value) ==
                                                null) {
                                              return 'Invalid';
                                            }
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          if (!_entryRows[index].isDebit &&
                                              value != null &&
                                              value.isNotEmpty) {
                                            _entryRows[index].amount =
                                                double.parse(value);
                                          }
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            if (!_entryRows[index].isDebit &&
                                                value.isNotEmpty) {
                                              _entryRows[index].amount =
                                                  double.tryParse(value) ?? 0;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),

                                  // Remove button
                                  SizedBox(
                                    width: 40,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: _entryRows.length <= 2
                                          ? null
                                          : () => _removeEntryRow(index),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Entry type selection buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Debit'),
                              onPressed: () {
                                setState(() {
                                  _entryRows.add(
                                    EntryFormRow(
                                      accountId: '',
                                      amount: 0,
                                      isDebit: true,
                                    ),
                                  );
                                });
                              },
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Credit'),
                              onPressed: () {
                                setState(() {
                                  _entryRows.add(
                                    EntryFormRow(
                                      accountId: '',
                                      amount: 0,
                                      isDebit: false,
                                    ),
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Totals
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Totals:'),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 100,
                              child: Text(
                                '\$${_calculateDebits().toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 100,
                              child: Text(
                                '\$${_calculateCredits().toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),

                        // Balance indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Balance:'),
                            const SizedBox(width: 16),
                            Text(
                              _isBalanced() ? 'Balanced' : 'Not Balanced',
                              style: TextStyle(
                                color: _isBalanced()
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Submit button
                        Center(
                          child: ElevatedButton(
                            onPressed: _isBalanced()
                                ? _submitTransaction
                                : null,
                            child: const Text('Add Transaction'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Right side - Ledger display
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accounts table
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accounts',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Account Name')),
                                DataColumn(label: Text('Type')),
                                DataColumn(
                                  label: Text('Balance'),
                                  numeric: true,
                                ),
                              ],
                              rows: accounts.map((account) {
                                final balance = balances[account.id] ?? 0.0;
                                final displayBalance =
                                    account.type == AccountType.asset ||
                                        account.type == AccountType.expense
                                    ? balance
                                    : -balance;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(account.name)),
                                    DataCell(
                                      Text(
                                        account.type.toString().split('.').last,
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '\$${displayBalance.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: displayBalance < 0
                                              ? Colors.red
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Transactions table
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transactions Journal',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: transactions.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No transactions recorded yet',
                                        ),
                                      )
                                    : ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: transactions.length,
                                        separatorBuilder: (context, index) =>
                                            const Divider(),
                                        itemBuilder: (context, index) {
                                          final transaction =
                                              transactions[transactions.length -
                                                  1 -
                                                  index];
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    DateFormat(
                                                      'yyyy-MM-dd',
                                                    ).format(transaction.date),
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.titleMedium,
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                      transaction.description,
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.titleMedium,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              DataTable(
                                                columnSpacing: 24,
                                                headingRowHeight: 0,
                                                columns: const [
                                                  DataColumn(label: Text('')),
                                                  DataColumn(label: Text('')),
                                                  DataColumn(label: Text('')),
                                                ],
                                                rows: transaction.entries.map((
                                                  entry,
                                                ) {
                                                  final account = accounts
                                                      .firstWhere(
                                                        (a) =>
                                                            a.id ==
                                                            entry.accountId,
                                                        orElse: () => Account(
                                                          name: 'Unknown',
                                                          type:
                                                              AccountType.asset,
                                                        ),
                                                      );

                                                  return DataRow(
                                                    cells: [
                                                      DataCell(
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                left:
                                                                    entry
                                                                        .isDebit
                                                                    ? 0
                                                                    : 24.0,
                                                              ),
                                                          child: Text(
                                                            account.name,
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        entry.isDebit
                                                            ? Text(
                                                                '\$${entry.amount.toStringAsFixed(2)}',
                                                              )
                                                            : const Text(''),
                                                      ),
                                                      DataCell(
                                                        !entry.isDebit
                                                            ? Text(
                                                                '\$${entry.amount.toStringAsFixed(2)}',
                                                              )
                                                            : const Text(''),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
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
          ],
        ),
      ),
    );
  }
}

class EntryFormRow {
  String accountId;
  double amount;
  bool isDebit;

  EntryFormRow({
    required this.accountId,
    required this.amount,
    required this.isDebit,
  });
}

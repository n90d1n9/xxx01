// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Currency Transactions',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TransactionScreen(),
    );
  }
}

// Models
class Currency {
  final String code;
  final String name;
  final String symbol;

  Currency({required this.code, required this.name, required this.symbol});
}

class ExchangeRate {
  final Currency baseCurrency;
  final Currency targetCurrency;
  final double rate;
  final DateTime lastUpdated;

  ExchangeRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.lastUpdated,
  });
}

class Transaction {
  final String id;
  final double amount;
  final Currency currency;
  final String description;
  final DateTime timestamp;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.description,
    required this.timestamp,
    required this.type,
  });
}

enum TransactionType { income, expense, transfer }

// Providers
final currenciesProvider =
    StateNotifierProvider<CurrenciesNotifier, List<Currency>>((ref) {
      return CurrenciesNotifier();
    });

final exchangeRatesProvider =
    StateNotifierProvider<ExchangeRatesNotifier, List<ExchangeRate>>((ref) {
      return ExchangeRatesNotifier();
    });

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
      return TransactionsNotifier();
    });

final baseCurrencyProvider = StateProvider<Currency?>((ref) {
  final currencies = ref.watch(currenciesProvider);
  return currencies.isNotEmpty ? currencies.first : null;
});

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);

  if (selectedCurrency == null) {
    return transactions;
  }

  return transactions
      .where((t) => t.currency.code == selectedCurrency.code)
      .toList();
});

final selectedCurrencyProvider = StateProvider<Currency?>((ref) {
  return null;
});

final balanceProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final balances = <String, double>{};

  for (final transaction in transactions) {
    final code = transaction.currency.code;
    balances[code] ??= 0;

    if (transaction.type == TransactionType.income) {
      balances[code] = (balances[code] ?? 0) + transaction.amount;
    } else if (transaction.type == TransactionType.expense) {
      balances[code] = (balances[code] ?? 0) - transaction.amount;
    }
  }

  return balances;
});

final convertedBalanceProvider = Provider.family<double, Currency>((
  ref,
  targetCurrency,
) {
  final balances = ref.watch(balanceProvider);
  final exchangeRates = ref.watch(exchangeRatesProvider);
  final baseCurrency = ref.watch(baseCurrencyProvider);

  if (baseCurrency == null) return 0.0;

  double totalInBase = 0.0;

  balances.forEach((currencyCode, amount) {
    if (currencyCode == baseCurrency.code) {
      totalInBase += amount;
    } else {
      final rate = exchangeRates.firstWhere(
        (rate) =>
            rate.baseCurrency.code == currencyCode &&
            rate.targetCurrency.code == baseCurrency.code,
        orElse: () => ExchangeRate(
          baseCurrency: Currency(code: currencyCode, name: '', symbol: ''),
          targetCurrency: baseCurrency,
          rate: 1.0,
          lastUpdated: DateTime.now(),
        ),
      );
      totalInBase += amount * rate.rate;
    }
  });

  if (targetCurrency.code == baseCurrency.code) {
    return totalInBase;
  }

  final rate = exchangeRates.firstWhere(
    (rate) =>
        rate.baseCurrency.code == baseCurrency.code &&
        rate.targetCurrency.code == targetCurrency.code,
    orElse: () => ExchangeRate(
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
      rate: 1.0,
      lastUpdated: DateTime.now(),
    ),
  );

  return totalInBase * rate.rate;
});

// Notifiers
class CurrenciesNotifier extends StateNotifier<List<Currency>> {
  CurrenciesNotifier() : super([]) {
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    // In a real app, load from API or local database
    state = [
      Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
      Currency(code: 'EUR', name: 'Euro', symbol: '€'),
      Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
      Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    ];
  }

  void addCurrency(Currency currency) {
    state = [...state, currency];
  }

  void removeCurrency(String code) {
    state = state.where((currency) => currency.code != code).toList();
  }
}

class ExchangeRatesNotifier extends StateNotifier<List<ExchangeRate>> {
  ExchangeRatesNotifier() : super([]) {
    _loadExchangeRates();
  }

  Future<void> _loadExchangeRates() async {
    // In a real app, fetch from an exchange rate API
    state = [
      ExchangeRate(
        baseCurrency: Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
        targetCurrency: Currency(code: 'EUR', name: 'Euro', symbol: '€'),
        rate: 0.85,
        lastUpdated: DateTime.now(),
      ),
      ExchangeRate(
        baseCurrency: Currency(code: 'EUR', name: 'Euro', symbol: '€'),
        targetCurrency: Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
        rate: 1.17,
        lastUpdated: DateTime.now(),
      ),
      ExchangeRate(
        baseCurrency: Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
        targetCurrency: Currency(
          code: 'GBP',
          name: 'British Pound',
          symbol: '£',
        ),
        rate: 0.74,
        lastUpdated: DateTime.now(),
      ),
      ExchangeRate(
        baseCurrency: Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
        targetCurrency: Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
        rate: 1.35,
        lastUpdated: DateTime.now(),
      ),
    ];
  }

  Future<void> updateExchangeRate(ExchangeRate rate) async {
    state = [
      ...state.where(
        (r) =>
            r.baseCurrency.code != rate.baseCurrency.code ||
            r.targetCurrency.code != rate.targetCurrency.code,
      ),
      rate,
    ];
  }

  Future<void> refreshRates() async {
    // In a real app, this would call an API
    // For now, just update the lastUpdated timestamp
    state = state
        .map(
          (rate) => ExchangeRate(
            baseCurrency: rate.baseCurrency,
            targetCurrency: rate.targetCurrency,
            rate: rate.rate,
            lastUpdated: DateTime.now(),
          ),
        )
        .toList();
  }
}

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  TransactionsNotifier() : super([]);

  void addTransaction(Transaction transaction) {
    state = [...state, transaction];
  }

  void removeTransaction(String id) {
    state = state.where((transaction) => transaction.id != id).toList();
  }

  void updateTransaction(Transaction updatedTransaction) {
    state = state
        .map(
          (transaction) => transaction.id == updatedTransaction.id
              ? updatedTransaction
              : transaction,
        )
        .toList();
  }
}

// UI
class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencies = ref.watch(currenciesProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final transactions = ref.watch(filteredTransactionsProvider);
    final balances = ref.watch(balanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Currency Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(exchangeRatesProvider.notifier).refreshRates();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exchange rates updated')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          BalanceSummaryWidget(balances: balances),
          CurrencyFilterWidget(
            currencies: currencies,
            selectedCurrency: selectedCurrency,
            onCurrencySelected: (currency) {
              ref.read(selectedCurrencyProvider.notifier).state = currency;
            },
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('No transactions found'))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return TransactionTile(transaction: transaction);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddTransactionForm(),
      ),
    );
  }
}

class BalanceSummaryWidget extends ConsumerWidget {
  final Map<String, double> balances;

  const BalanceSummaryWidget({super.key, required this.balances});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseCurrency = ref.watch(baseCurrencyProvider);

    if (baseCurrency == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Account Balances',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...balances.entries.map((entry) {
            final currencyCode = entry.key;
            final amount = entry.value;
            final currency = ref
                .read(currenciesProvider)
                .firstWhere(
                  (c) => c.code == currencyCode,
                  orElse: () =>
                      Currency(code: currencyCode, name: '', symbol: ''),
                );

            final numberFormat = NumberFormat.currency(
              symbol: currency.symbol,
              decimalDigits: currencyCode == 'JPY' ? 0 : 2,
            );

            final displayAmount = numberFormat.format(amount);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${currency.code}:'),
                  Text(
                    displayAmount,
                    style: TextStyle(
                      color: amount >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (in ${baseCurrency.code}):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final totalInBase = ref.watch(
                    convertedBalanceProvider(baseCurrency),
                  );
                  final numberFormat = NumberFormat.currency(
                    symbol: baseCurrency.symbol,
                    decimalDigits: baseCurrency.code == 'JPY' ? 0 : 2,
                  );
                  return Text(
                    numberFormat.format(totalInBase),
                    style: TextStyle(
                      color: totalInBase >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CurrencyFilterWidget extends StatelessWidget {
  final List<Currency> currencies;
  final Currency? selectedCurrency;
  final void Function(Currency?) onCurrencySelected;

  const CurrencyFilterWidget({
    super.key,
    required this.currencies,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('Filter by currency:'),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedCurrency?.code,
              hint: const Text('All currencies'),
              onChanged: (value) {
                if (value == null) {
                  onCurrencySelected(null);
                } else {
                  final currency = currencies.firstWhere(
                    (c) => c.code == value,
                  );
                  onCurrencySelected(currency);
                }
              },
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All currencies'),
                ),
                ...currencies.map(
                  (currency) => DropdownMenuItem<String>(
                    value: currency.code,
                    child: Text('${currency.code} (${currency.symbol})'),
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

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, yyyy • HH:mm');
    final amount = transaction.amount;
    final formattedAmount = NumberFormat.currency(
      symbol: transaction.currency.symbol,
      decimalDigits: transaction.currency.code == 'JPY' ? 0 : 2,
    ).format(amount);

    IconData iconData;
    Color iconColor;

    switch (transaction.type) {
      case TransactionType.income:
        iconData = Icons.arrow_downward;
        iconColor = Colors.green;
        break;
      case TransactionType.expense:
        iconData = Icons.arrow_upward;
        iconColor = Colors.red;
        break;
      case TransactionType.transfer:
        iconData = Icons.swap_horiz;
        iconColor = Colors.blue;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(transaction.description),
        subtitle: Text(formatter.format(transaction.timestamp)),
        trailing: Text(
          formattedAmount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: transaction.type == TransactionType.income
                ? Colors.green
                : transaction.type == TransactionType.expense
                ? Colors.red
                : Colors.blue,
          ),
        ),
      ),
    );
  }
}

class AddTransactionForm extends ConsumerStatefulWidget {
  const AddTransactionForm({super.key});

  @override
  ConsumerState<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends ConsumerState<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  Currency? _selectedCurrency;
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currencies = ref.read(currenciesProvider);
      if (currencies.isNotEmpty) {
        setState(() {
          _selectedCurrency = currencies.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencies = ref.watch(currenciesProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Transaction',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: TransactionType.transfer,
                  label: Text('Transfer'),
                  icon: Icon(Icons.swap_horiz),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<TransactionType> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<Currency>(
                    value: _selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: currencies.map((currency) {
                      return DropdownMenuItem<Currency>(
                        value: currency,
                        child: Text(currency.code),
                      );
                    }).toList(),
                    onChanged: (Currency? newValue) {
                      setState(() {
                        _selectedCurrency = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Select a currency';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedCurrency != null) {
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text),
        currency: _selectedCurrency!,
        description: _descriptionController.text,
        timestamp: DateTime.now(),
        type: _selectedType,
      );

      ref.read(transactionsProvider.notifier).addTransaction(transaction);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully')),
      );

      Navigator.pop(context);
    }
  }
}

// Exchange Rate Screen
class ExchangeRateScreen extends ConsumerWidget {
  const ExchangeRateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exchangeRates = ref.watch(exchangeRatesProvider);
    final currencies = ref.watch(currenciesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exchange Rates')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Current Exchange Rates',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exchangeRates.length,
              itemBuilder: (context, index) {
                final rate = exchangeRates[index];
                final formatter = DateFormat('MMM d, yyyy • HH:mm');

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${rate.baseCurrency.code} → ${rate.targetCurrency.code}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Text(
                              rate.rate.toStringAsFixed(4),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last updated: ${formatter.format(rate.lastUpdated)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExchangeRateDialog(context, ref, currencies),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExchangeRateDialog(
    BuildContext context,
    WidgetRef ref,
    List<Currency> currencies,
  ) {
    Currency? baseCurrency = currencies.isNotEmpty ? currencies.first : null;
    Currency? targetCurrency = currencies.length > 1
        ? currencies[1]
        : baseCurrency;
    final rateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Exchange Rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Currency>(
                    value: baseCurrency,
                    decoration: const InputDecoration(labelText: 'From'),
                    items: currencies.map((currency) {
                      return DropdownMenuItem<Currency>(
                        value: currency,
                        child: Text(currency.code),
                      );
                    }).toList(),
                    onChanged: (Currency? newValue) {
                      baseCurrency = newValue;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<Currency>(
                    value: targetCurrency,
                    decoration: const InputDecoration(labelText: 'To'),
                    items: currencies.map((currency) {
                      return DropdownMenuItem<Currency>(
                        value: currency,
                        child: Text(currency.code),
                      );
                    }).toList(),
                    onChanged: (Currency? newValue) {
                      targetCurrency = newValue;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: rateController,
              decoration: const InputDecoration(
                labelText: 'Rate',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (baseCurrency != null &&
                  targetCurrency != null &&
                  rateController.text.isNotEmpty) {
                final rate = double.parse(rateController.text);
                ref
                    .read(exchangeRatesProvider.notifier)
                    .updateExchangeRate(
                      ExchangeRate(
                        baseCurrency: baseCurrency!,
                        targetCurrency: targetCurrency!,
                        rate: rate,
                        lastUpdated: DateTime.now(),
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Analytics Screen
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final currencies = ref.watch(currenciesProvider);
    final baseCurrency =
        ref.watch(baseCurrencyProvider) ??
        (currencies.isNotEmpty ? currencies.first : null);

    if (transactions.isEmpty || baseCurrency == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: const Center(child: Text('No transaction data available')),
      );
    }

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    // Filter transactions for this month and last month
    final thisMonthTransactions = transactions
        .where(
          (t) =>
              t.timestamp.isAfter(thisMonth) ||
              (t.timestamp.year == thisMonth.year &&
                  t.timestamp.month == thisMonth.month),
        )
        .toList();

    final lastMonthTransactions = transactions
        .where(
          (t) =>
              t.timestamp.isAfter(lastMonth) && t.timestamp.isBefore(thisMonth),
        )
        .toList();

    // Calculate totals by currency
    Map<String, double> calculateTotalsByCurrency(List<Transaction> txns) {
      final Map<String, double> totals = {};

      for (final t in txns) {
        final code = t.currency.code;
        totals[code] ??= 0;

        if (t.type == TransactionType.income) {
          totals[code] = (totals[code] ?? 0) + t.amount;
        } else if (t.type == TransactionType.expense) {
          totals[code] = (totals[code] ?? 0) - t.amount;
        }
      }

      return totals;
    }

    final thisMonthTotals = calculateTotalsByCurrency(thisMonthTransactions);
    final lastMonthTotals = calculateTotalsByCurrency(lastMonthTransactions);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Monthly Comparison',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMonthSummary(
                  context,
                  'This Month',
                  thisMonthTotals,
                  baseCurrency,
                  ref,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMonthSummary(
                  context,
                  'Last Month',
                  lastMonthTotals,
                  baseCurrency,
                  ref,
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Transaction Breakdown',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildTransactionTypeBreakdown(context, thisMonthTransactions),
          const SizedBox(height: 24),
          Text(
            'Currency Distribution',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildCurrencyDistribution(context, thisMonthTransactions),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              // In a real app, this would generate a detailed report
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Generating full financial report...'),
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Export Full Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(
    BuildContext context,
    String title,
    Map<String, double> totals,
    Currency baseCurrency,
    WidgetRef ref,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...totals.entries.map((entry) {
            final currencyCode = entry.key;
            final amount = entry.value;
            final currency = ref
                .read(currenciesProvider)
                .firstWhere(
                  (c) => c.code == currencyCode,
                  orElse: () =>
                      Currency(code: currencyCode, name: '', symbol: ''),
                );

            final numberFormat = NumberFormat.currency(
              symbol: currency.symbol,
              decimalDigits: currencyCode == 'JPY' ? 0 : 2,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(currency.code),
                  Text(
                    numberFormat.format(amount),
                    style: TextStyle(
                      color: amount >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),

          if (totals.isNotEmpty) ...[
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${baseCurrency.code}):',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Builder(
                  builder: (context) {
                    double totalInBase = 0;
                    final exchangeRates = ref.read(exchangeRatesProvider);

                    totals.forEach((currencyCode, amount) {
                      if (currencyCode == baseCurrency.code) {
                        totalInBase += amount;
                      } else {
                        final rate = exchangeRates.firstWhere(
                          (r) =>
                              r.baseCurrency.code == currencyCode &&
                              r.targetCurrency.code == baseCurrency.code,
                          orElse: () => ExchangeRate(
                            baseCurrency: Currency(
                              code: currencyCode,
                              name: '',
                              symbol: '',
                            ),
                            targetCurrency: baseCurrency,
                            rate: 1.0,
                            lastUpdated: DateTime.now(),
                          ),
                        );
                        totalInBase += amount * rate.rate;
                      }
                    });

                    final numberFormat = NumberFormat.currency(
                      symbol: baseCurrency.symbol,
                      decimalDigits: baseCurrency.code == 'JPY' ? 0 : 2,
                    );

                    return Text(
                      numberFormat.format(totalInBase),
                      style: TextStyle(
                        color: totalInBase >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionTypeBreakdown(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    // Calculate totals by type
    double incomeTotal = 0;
    double expenseTotal = 0;
    double transferTotal = 0;

    for (final t in transactions) {
      switch (t.type) {
        case TransactionType.income:
          incomeTotal += t.amount;
          break;
        case TransactionType.expense:
          expenseTotal += t.amount;
          break;
        case TransactionType.transfer:
          transferTotal += t.amount;
          break;
      }
    }

    final total = incomeTotal + expenseTotal + transferTotal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildTypeIndicator('Income', Colors.green, incomeTotal, total),
                _buildTypeIndicator('Expense', Colors.red, expenseTotal, total),
                _buildTypeIndicator(
                  'Transfer',
                  Colors.blue,
                  transferTotal,
                  total,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: total > 0 ? 1.0 : 0.0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
              minHeight: 24,
            ),
            Stack(
              children: [
                if (total > 0) ...[
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width:
                        MediaQuery.of(context).size.width *
                        (incomeTotal / total) *
                        0.75,
                    child: Container(color: Colors.green),
                  ),
                  Positioned(
                    left:
                        MediaQuery.of(context).size.width *
                        (incomeTotal / total) *
                        0.75,
                    top: 0,
                    bottom: 0,
                    width:
                        MediaQuery.of(context).size.width *
                        (expenseTotal / total) *
                        0.75,
                    child: Container(color: Colors.red),
                  ),
                  Positioned(
                    left:
                        MediaQuery.of(context).size.width *
                        ((incomeTotal + expenseTotal) / total) *
                        0.75,
                    top: 0,
                    bottom: 0,
                    width:
                        MediaQuery.of(context).size.width *
                        (transferTotal / total) *
                        0.75,
                    child: Container(color: Colors.blue),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIndicator(
    String label,
    Color color,
    double amount,
    double total,
  ) {
    final percentage = total > 0
        ? (amount / total * 100).toStringAsFixed(1)
        : '0.0';

    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(label),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDistribution(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    // Calculate transaction count by currency
    final Map<String, int> currencyCounts = {};

    for (final t in transactions) {
      final code = t.currency.code;
      currencyCounts[code] = (currencyCounts[code] ?? 0) + 1;
    }

    final total = transactions.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...currencyCounts.entries.map((entry) {
              final currencyCode = entry.key;
              final count = entry.value;
              final percentage = total > 0 ? count / total * 100 : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(currencyCode),
                        Text('${percentage.toStringAsFixed(1)}% ($count)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final currencies = ref.watch(currenciesProvider);
    final baseCurrency = ref.watch(baseCurrencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Base Currency'),
            subtitle: Text(baseCurrency?.code ?? 'Not set'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () =>
                _showBaseCurrencyDialog(context, currencies, baseCurrency),
          ),
          const Divider(),
          ListTile(
            title: const Text('Manage Currencies'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () => _showManageCurrenciesDialog(context, currencies),
          ),
          const Divider(),
          ListTile(
            title: const Text('Exchange Rates'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExchangeRateScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Analytics'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const ListTile(title: Text('App Version'), subtitle: Text('1.0.0')),
        ],
      ),
    );
  }

  void _showBaseCurrencyDialog(
    BuildContext context,
    List<Currency> currencies,
    Currency? current,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Base Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              return ListTile(
                title: Text('${currency.code} (${currency.name})'),
                subtitle: Text(currency.symbol),
                trailing: currency.code == current?.code
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  ref.read(baseCurrencyProvider.notifier).state = currency;
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showManageCurrenciesDialog(
    BuildContext context,
    List<Currency> currencies,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Currencies'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currencies.length,
                  itemBuilder: (context, index) {
                    final currency = currencies[index];
                    return ListTile(
                      title: Text('${currency.code} (${currency.name})'),
                      subtitle: Text(currency.symbol),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref
                              .read(currenciesProvider.notifier)
                              .removeCurrency(currency.code);
                          Navigator.pop(context);
                          _showManageCurrenciesDialog(
                            context,
                            ref.read(currenciesProvider),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => _showAddCurrencyDialog(context),
                child: const Text('Add New Currency'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddCurrencyDialog(BuildContext context) {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final symbolController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Currency'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Currency Code (e.g. USD)',
                  border: OutlineInputBorder(),
                ),
                maxLength: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a currency code';
                  }
                  if (value.length != 3) {
                    return 'Currency code must be 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Currency Name (e.g. US Dollar)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a currency name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: symbolController,
                decoration: InputDecoration(
                  labelText: 'Currency Symbol (e.g. ${symbolController.value})',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a currency symbol';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newCurrency = Currency(
                  code: codeController.text.toUpperCase(),
                  name: nameController.text,
                  symbol: symbolController.text,
                );

                ref.read(currenciesProvider.notifier).addCurrency(newCurrency);

                // If this is the first currency, set it as base currency
                if (ref.read(baseCurrencyProvider) == null) {
                  ref.read(baseCurrencyProvider.notifier).state = newCurrency;
                }

                Navigator.pop(context);
                Navigator.pop(context);
                _showManageCurrenciesDialog(
                  context,
                  ref.read(currenciesProvider),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Main Navigation
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TransactionScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// Let's update the main app to use our navigation
/* class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Currency Transactions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
} */

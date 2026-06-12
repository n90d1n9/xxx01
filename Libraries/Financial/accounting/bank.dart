// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ProviderScope(child: BankReconciliationApp()));
}

class BankReconciliationApp extends StatelessWidget {
  const BankReconciliationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bank Reconciliation',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const BankReconciliationScreen(),
    );
  }
}

// Models
class Transaction {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final bool isDebit;
  final TransactionStatus status;
  final String? matchedStatementId;

  Transaction({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.isDebit,
    this.status = TransactionStatus.pending,
    this.matchedStatementId,
  });

  Transaction copyWith({
    String? id,
    DateTime? date,
    String? description,
    double? amount,
    bool? isDebit,
    TransactionStatus? status,
    String? matchedStatementId,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isDebit: isDebit ?? this.isDebit,
      status: status ?? this.status,
      matchedStatementId: matchedStatementId ?? this.matchedStatementId,
    );
  }
}

class BankStatement {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final bool isDebit;
  final StatementStatus status;
  final String? matchedTransactionId;

  BankStatement({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.isDebit,
    this.status = StatementStatus.unmatched,
    this.matchedTransactionId,
  });

  BankStatement copyWith({
    String? id,
    DateTime? date,
    String? description,
    double? amount,
    bool? isDebit,
    StatementStatus? status,
    String? matchedTransactionId,
  }) {
    return BankStatement(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isDebit: isDebit ?? this.isDebit,
      status: status ?? this.status,
      matchedTransactionId: matchedTransactionId ?? this.matchedTransactionId,
    );
  }
}

enum TransactionStatus { pending, matched, reconciled, disputed }

enum StatementStatus { unmatched, matched, reconciled, disputed }

// Repository
class BankReconciliationRepository {
  Future<List<Transaction>> fetchTransactions() async {
    // Mock data - in a real app, this would come from an API or database
    await Future.delayed(const Duration(seconds: 1));
    return [
      Transaction(
        id: 't1',
        date: DateTime(2025, 3, 1),
        description: 'Payroll Deposit',
        amount: 2500.00,
        isDebit: false,
      ),
      Transaction(
        id: 't2',
        date: DateTime(2025, 3, 2),
        description: 'Office Supplies',
        amount: 124.56,
        isDebit: true,
      ),
      Transaction(
        id: 't3',
        date: DateTime(2025, 3, 3),
        description: 'Client Payment',
        amount: 1750.00,
        isDebit: false,
      ),
      Transaction(
        id: 't4',
        date: DateTime(2025, 3, 5),
        description: 'Utilities Bill',
        amount: 235.40,
        isDebit: true,
      ),
      Transaction(
        id: 't5',
        date: DateTime(2025, 3, 7),
        description: 'Software Subscription',
        amount: 49.99,
        isDebit: true,
      ),
    ];
  }

  Future<List<BankStatement>> fetchBankStatements() async {
    // Mock data - in a real app, this would come from an API or database
    await Future.delayed(const Duration(seconds: 1));
    return [
      BankStatement(
        id: 's1',
        date: DateTime(2025, 3, 1),
        description: 'DEPOSIT: PAYROLL',
        amount: 2500.00,
        isDebit: false,
      ),
      BankStatement(
        id: 's2',
        date: DateTime(2025, 3, 2),
        description: 'PURCHASE: OFFICE DEPOT',
        amount: 124.56,
        isDebit: true,
      ),
      BankStatement(
        id: 's3',
        date: DateTime(2025, 3, 3),
        description: 'DEPOSIT: CLIENT ABC',
        amount: 1750.00,
        isDebit: false,
      ),
      BankStatement(
        id: 's4',
        date: DateTime(2025, 3, 6),
        description: 'UTILITIES COMPANY',
        amount: 235.40,
        isDebit: true,
      ),
      BankStatement(
        id: 's6',
        date: DateTime(2025, 3, 10),
        description: 'BANK FEE',
        amount: 15.00,
        isDebit: true,
      ),
    ];
  }
}

// Providers
final repositoryProvider = Provider<BankReconciliationRepository>((ref) {
  return BankReconciliationRepository();
});

final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repository = ref.read(repositoryProvider);
  return repository.fetchTransactions();
});

final bankStatementsProvider = FutureProvider<List<BankStatement>>((ref) async {
  final repository = ref.read(repositoryProvider);
  return repository.fetchBankStatements();
});

final reconciliationStateProvider =
    StateNotifierProvider<ReconciliationNotifier, ReconciliationState>((ref) {
      return ReconciliationNotifier(ref);
    });

// State Classes
class ReconciliationState {
  final List<Transaction> transactions;
  final List<BankStatement> bankStatements;
  final Map<String, String> matches; // transactionId -> statementId

  ReconciliationState({
    this.transactions = const [],
    this.bankStatements = const [],
    this.matches = const {},
  });

  ReconciliationState copyWith({
    List<Transaction>? transactions,
    List<BankStatement>? bankStatements,
    Map<String, String>? matches,
  }) {
    return ReconciliationState(
      transactions: transactions ?? this.transactions,
      bankStatements: bankStatements ?? this.bankStatements,
      matches: matches ?? this.matches,
    );
  }
}

class ReconciliationNotifier extends StateNotifier<ReconciliationState> {
  final Ref ref;

  ReconciliationNotifier(this.ref) : super(ReconciliationState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await ref.read(transactionsProvider.future);
    final statements = await ref.read(bankStatementsProvider.future);

    state = state.copyWith(
      transactions: transactions,
      bankStatements: statements,
    );

    // Auto-match transactions with bank statements
    autoMatchTransactions();
  }

  void autoMatchTransactions() {
    final Map<String, String> matches = {};
    final List<Transaction> updatedTransactions = [...state.transactions];
    final List<BankStatement> updatedStatements = [...state.bankStatements];

    // Simple matching algorithm based on amount and date
    for (int i = 0; i < updatedTransactions.length; i++) {
      final transaction = updatedTransactions[i];

      for (int j = 0; j < updatedStatements.length; j++) {
        final statement = updatedStatements[j];

        // Check if amounts match exactly, same debit/credit type, and dates are within 1 day
        if (transaction.amount == statement.amount &&
            transaction.isDebit == statement.isDebit &&
            (transaction.date.difference(statement.date).inDays.abs() <= 1) &&
            statement.matchedTransactionId == null) {
          // Match found!
          matches[transaction.id] = statement.id;

          // Update transaction status
          updatedTransactions[i] = transaction.copyWith(
            status: TransactionStatus.matched,
            matchedStatementId: statement.id,
          );

          // Update statement status
          updatedStatements[j] = statement.copyWith(
            status: StatementStatus.matched,
            matchedTransactionId: transaction.id,
          );

          break; // Move to next transaction
        }
      }
    }

    state = state.copyWith(
      transactions: updatedTransactions,
      bankStatements: updatedStatements,
      matches: matches,
    );
  }

  void manuallyMatchTransaction(String transactionId, String statementId) {
    final Map<String, String> updatedMatches = {...state.matches};
    final List<Transaction> updatedTransactions = [...state.transactions];
    final List<BankStatement> updatedStatements = [...state.bankStatements];

    // Find the indices
    final transactionIndex = updatedTransactions.indexWhere(
      (t) => t.id == transactionId,
    );
    final statementIndex = updatedStatements.indexWhere(
      (s) => s.id == statementId,
    );

    if (transactionIndex != -1 && statementIndex != -1) {
      // Remove any existing match for this transaction
      if (updatedMatches.containsKey(transactionId)) {
        final oldStatementId = updatedMatches[transactionId];
        final oldStatementIndex = updatedStatements.indexWhere(
          (s) => s.id == oldStatementId,
        );

        if (oldStatementIndex != -1) {
          updatedStatements[oldStatementIndex] =
              updatedStatements[oldStatementIndex].copyWith(
                status: StatementStatus.unmatched,
                matchedTransactionId: null,
              );
        }
      }

      // Remove any existing match for this statement
      final existingTransactionId =
          updatedStatements[statementIndex].matchedTransactionId;
      if (existingTransactionId != null) {
        updatedMatches.removeWhere(
          (key, value) => key == existingTransactionId,
        );

        final existingTransactionIndex = updatedTransactions.indexWhere(
          (t) => t.id == existingTransactionId,
        );
        if (existingTransactionIndex != -1) {
          updatedTransactions[existingTransactionIndex] =
              updatedTransactions[existingTransactionIndex].copyWith(
                status: TransactionStatus.pending,
                matchedStatementId: null,
              );
        }
      }

      // Create new match
      updatedMatches[transactionId] = statementId;

      // Update transaction
      updatedTransactions[transactionIndex] =
          updatedTransactions[transactionIndex].copyWith(
            status: TransactionStatus.matched,
            matchedStatementId: statementId,
          );

      // Update statement
      updatedStatements[statementIndex] = updatedStatements[statementIndex]
          .copyWith(
            status: StatementStatus.matched,
            matchedTransactionId: transactionId,
          );

      state = state.copyWith(
        transactions: updatedTransactions,
        bankStatements: updatedStatements,
        matches: updatedMatches,
      );
    }
  }

  void unmatchTransaction(String transactionId) {
    final Map<String, String> updatedMatches = {...state.matches};
    final List<Transaction> updatedTransactions = [...state.transactions];
    final List<BankStatement> updatedStatements = [...state.bankStatements];

    if (updatedMatches.containsKey(transactionId)) {
      final statementId = updatedMatches[transactionId];
      updatedMatches.remove(transactionId);

      // Update transaction
      final transactionIndex = updatedTransactions.indexWhere(
        (t) => t.id == transactionId,
      );
      if (transactionIndex != -1) {
        updatedTransactions[transactionIndex] =
            updatedTransactions[transactionIndex].copyWith(
              status: TransactionStatus.pending,
              matchedStatementId: null,
            );
      }

      // Update statement
      final statementIndex = updatedStatements.indexWhere(
        (s) => s.id == statementId,
      );
      if (statementIndex != -1) {
        updatedStatements[statementIndex] = updatedStatements[statementIndex]
            .copyWith(
              status: StatementStatus.unmatched,
              matchedTransactionId: null,
            );
      }

      state = state.copyWith(
        transactions: updatedTransactions,
        bankStatements: updatedStatements,
        matches: updatedMatches,
      );
    }
  }

  void reconcileMatch(String transactionId) {
    final List<Transaction> updatedTransactions = [...state.transactions];
    final List<BankStatement> updatedStatements = [...state.bankStatements];

    if (state.matches.containsKey(transactionId)) {
      final statementId = state.matches[transactionId];

      // Update transaction
      final transactionIndex = updatedTransactions.indexWhere(
        (t) => t.id == transactionId,
      );
      if (transactionIndex != -1) {
        updatedTransactions[transactionIndex] =
            updatedTransactions[transactionIndex].copyWith(
              status: TransactionStatus.reconciled,
            );
      }

      // Update statement
      final statementIndex = updatedStatements.indexWhere(
        (s) => s.id == statementId,
      );
      if (statementIndex != -1) {
        updatedStatements[statementIndex] = updatedStatements[statementIndex]
            .copyWith(status: StatementStatus.reconciled);
      }

      state = state.copyWith(
        transactions: updatedTransactions,
        bankStatements: updatedStatements,
      );
    }
  }
}

// UI
class BankReconciliationScreen extends ConsumerWidget {
  const BankReconciliationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconciliationState = ref.watch(reconciliationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Reconciliation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(transactionsProvider);
              ref.refresh(bankStatementsProvider);
              ref.refresh(reconciliationStateProvider);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: reconciliationState.transactions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const ReconciliationSummary(),
                  const SizedBox(height: 16),
                  Expanded(child: ReconciliationTable()),
                ],
              ),
      ),
    );
  }
}

class ReconciliationSummary extends ConsumerWidget {
  const ReconciliationSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconciliationState = ref.watch(reconciliationStateProvider);

    final totalTransactions = reconciliationState.transactions.length;
    final totalStatements = reconciliationState.bankStatements.length;
    final matchedCount = reconciliationState.matches.length;
    final reconciledCount = reconciliationState.transactions
        .where((t) => t.status == TransactionStatus.reconciled)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('Transactions', totalTransactions, Colors.blue),
            _buildSummaryItem('Bank Statements', totalStatements, Colors.green),
            _buildSummaryItem('Matched', matchedCount, Colors.orange),
            _buildSummaryItem('Reconciled', reconciledCount, Colors.purple),
            _buildSummaryItem(
              'Unmatched',
              totalTransactions - matchedCount,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class ReconciliationTable extends ConsumerWidget {
  ReconciliationTable({super.key});

  final currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconciliationState = ref.watch(reconciliationStateProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
          columns: const [
            DataColumn(label: Text('Transaction Date')),
            DataColumn(label: Text('Transaction Description')),
            DataColumn(label: Text('Transaction Amount')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Statement Date')),
            DataColumn(label: Text('Statement Description')),
            DataColumn(label: Text('Statement Amount')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _buildRows(reconciliationState, ref, context),
        ),
      ),
    );
  }

  List<DataRow> _buildRows(
    ReconciliationState state,
    WidgetRef ref,
    BuildContext context,
  ) {
    final rows = <DataRow>[];
    final notifier = ref.read(reconciliationStateProvider.notifier);

    // First add all matched transactions
    for (final transaction in state.transactions) {
      final matchedStatementId = transaction.matchedStatementId;
      BankStatement? matchedStatement;

      if (matchedStatementId != null) {
        matchedStatement = state.bankStatements.firstWhere(
          (s) => s.id == matchedStatementId,
          orElse: () => null as BankStatement,
        );
      }

      final statusColor = _getStatusColor(transaction.status);

      rows.add(
        DataRow(
          color: matchedStatement != null
              ? MaterialStateProperty.all(Colors.grey.shade100)
              : null,
          cells: [
            DataCell(Text(DateFormat('MM/dd/yyyy').format(transaction.date))),
            DataCell(Text(transaction.description)),
            DataCell(
              Text(
                currencyFormat.format(transaction.amount),
                style: TextStyle(
                  color: transaction.isDebit ? Colors.red : Colors.green,
                ),
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.status.toString().split('.').last,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Statement cells
            DataCell(
              matchedStatement != null
                  ? Text(DateFormat('MM/dd/yyyy').format(matchedStatement.date))
                  : const Text(''),
            ),
            DataCell(
              matchedStatement != null
                  ? Text(matchedStatement.description)
                  : const Text(''),
            ),
            DataCell(
              matchedStatement != null
                  ? Text(
                      currencyFormat.format(matchedStatement.amount),
                      style: TextStyle(
                        color: matchedStatement.isDebit
                            ? Colors.red
                            : Colors.green,
                      ),
                    )
                  : const Text(''),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (matchedStatement != null) ...[
                    if (transaction.status == TransactionStatus.matched)
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        tooltip: 'Reconcile',
                        onPressed: () {
                          notifier.reconcileMatch(transaction.id);
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.link_off, color: Colors.red),
                      tooltip: 'Unmatch',
                      onPressed: () {
                        notifier.unmatchTransaction(transaction.id);
                      },
                    ),
                  ] else ...[
                    IconButton(
                      icon: const Icon(Icons.link, color: Colors.blue),
                      tooltip: 'Match Manually',
                      onPressed: () {
                        _showMatchDialog(
                          context,
                          transaction,
                          state.bankStatements,
                          notifier,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Now add unmatched bank statements
    for (final statement in state.bankStatements) {
      if (statement.matchedTransactionId == null) {
        rows.add(
          DataRow(
            color: MaterialStateProperty.all(Colors.yellow.shade50),
            cells: [
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('Unmatched Statement')),
              DataCell(Text(DateFormat('MM/dd/yyyy').format(statement.date))),
              DataCell(Text(statement.description)),
              DataCell(
                Text(
                  currencyFormat.format(statement.amount),
                  style: TextStyle(
                    color: statement.isDebit ? Colors.red : Colors.green,
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.green,
                  ),
                  tooltip: 'Create Transaction',
                  onPressed: () {
                    // In a real app, this would show a dialog to create a new transaction
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This would create a new transaction in a real app',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    }

    return rows;
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.matched:
        return Colors.blue;
      case TransactionStatus.reconciled:
        return Colors.green;
      case TransactionStatus.disputed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showMatchDialog(
    BuildContext context,
    Transaction transaction,
    List<BankStatement> statements,
    ReconciliationNotifier notifier,
  ) {
    // Filter statements that are unmatched and have similar properties
    final eligibleStatements = statements
        .where((s) => s.matchedTransactionId == null)
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Match Transaction'),
          content: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction: ${transaction.description}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Amount: ${currencyFormat.format(transaction.amount)}',
                  style: TextStyle(
                    color: transaction.isDebit ? Colors.red : Colors.green,
                  ),
                ),
                Text(
                  'Date: ${DateFormat('MM/dd/yyyy').format(transaction.date)}',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select a bank statement to match:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: eligibleStatements.length,
                    itemBuilder: (context, index) {
                      final statement = eligibleStatements[index];
                      return ListTile(
                        title: Text(statement.description),
                        subtitle: Text(
                          '${DateFormat('MM/dd/yyyy').format(statement.date)} - ${currencyFormat.format(statement.amount)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.link),
                          onPressed: () {
                            notifier.manuallyMatchTransaction(
                              transaction.id,
                              statement.id,
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

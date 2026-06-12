import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/widgets/trx/trx_detail.dart';

import '../../models/ledger_trx.dart';
import '../../states/gl/ledger_provider.dart';
import 'trx_edit.dart';

class TrxTable extends ConsumerWidget {
  final List<LedgerTransaction> transactions;
  const TrxTable({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final runningBalances = _buildRunningBalances(transactions);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            horizontalMargin: 16,
            headingRowHeight: 50,
            dataRowMinHeight: 60,
            dataRowMaxHeight: 60,
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            dividerThickness: 1,
            showCheckboxColumn: false,
            columns: [
              DataColumn(
                label: _buildColumnHeader(context, 'Date'),
                tooltip: 'Transaction Date',
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Account'),
                tooltip: 'Account Name',
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Description'),
                tooltip: 'Transaction Description',
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Type'),
                tooltip: 'Transaction Type',
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Amount'),
                tooltip: 'Transaction Amount',
                numeric: true,
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Running Balance'),
                tooltip: 'Filtered running balance',
                numeric: true,
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Reference'),
                tooltip: 'Reference Number',
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Category'),
                tooltip: 'Transaction Category',
              ),
              DataColumn(
                label: _buildColumnHeader(context, 'Actions'),
                tooltip: 'Actions',
              ),
            ],
            rows:
                transactions.map((transaction) {
                  return DataRow(
                    onSelectChanged:
                        (_) =>
                            _showTransactionDetails(context, ref, transaction),
                    cells: [
                      DataCell(
                        Text(
                          DateFormat('MMM d, y').format(transaction.date),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      DataCell(
                        Text(
                          transaction.account,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            transaction.description,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      DataCell(
                        Chip(
                          label: Text(
                            transaction.type.name,
                            style: TextStyle(
                              color:
                                  transaction.type == TransactionType.debit
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor:
                              transaction.type == TransactionType.debit
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      DataCell(
                        Text(
                          transaction.formattedAmount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                transaction.type == TransactionType.debit
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          currencyFormat.format(
                            runningBalances[transaction.id] ?? 0,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color:
                                (runningBalances[transaction.id] ?? 0) >= 0
                                    ? Colors.blue.shade700
                                    : Colors.orange.shade700,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          transaction.reference,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              transaction.category,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getCategoryColor(transaction.category),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        transaction.isSystemGenerated
                            ? Tooltip(
                              message:
                                  'Posted journal lines are read-only here',
                              child: Icon(
                                Icons.lock_outline_rounded,
                                size: 20,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            )
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_rounded,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                  tooltip: 'Edit Transaction',
                                  onPressed:
                                      () =>
                                          _showEditDialog(context, transaction),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_rounded,
                                    size: 20,
                                    color: theme.colorScheme.error,
                                  ),
                                  tooltip: 'Delete Transaction',
                                  onPressed:
                                      () => _confirmDelete(
                                        context,
                                        ref,
                                        transaction,
                                      ),
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
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LedgerTransaction transaction,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.delete_forever_rounded,
                color: theme.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Confirm Deletion'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this transaction?',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: .5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM d, y').format(transaction.date),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Chip(
                            label: Text(
                              transaction.type.name,
                              style: TextStyle(
                                color:
                                    transaction.type == TransactionType.debit
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor:
                                transaction.type == TransactionType.debit
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                      const Divider(),
                      Text(
                        transaction.description,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Account: ${transaction.account}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount: ${transaction.formattedAmount}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              transaction.type == TransactionType.debit
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This action cannot be undone.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              icon: const Icon(Icons.delete_rounded, size: 18),
              label: const Text('Delete'),
              onPressed: () {
                ref
                    .read(ledgerProvider.notifier)
                    .deleteTransaction(transaction.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Transaction deleted'),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        ref
                            .read(ledgerProvider.notifier)
                            .addTransaction(transaction);
                      },
                    ),
                  ),
                );

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, LedgerTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => TrxEdit(transaction: transaction),
    );
  }

  Map<String, double> _buildRunningBalances(
    List<LedgerTransaction> transactions,
  ) {
    final sorted = [...transactions]..sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return a.id.compareTo(b.id);
    });

    var balance = 0.0;
    final balances = <String, double>{};
    for (final transaction in sorted) {
      balance +=
          transaction.type == TransactionType.debit
              ? transaction.amount
              : -transaction.amount;
      balances[transaction.id] = balance;
    }
    return balances;
  }

  Color _getCategoryColor(String category) {
    // Create a deterministic color based on the category name
    final int hash = category.hashCode;

    final List<Color> categoryColors = [
      Colors.blue.shade700,
      Colors.purple.shade700,
      Colors.indigo.shade700,
      Colors.teal.shade700,
      Colors.amber.shade700,
      Colors.deepOrange.shade700,
      Colors.pink.shade700,
      Colors.cyan.shade700,
    ];

    return categoryColors[hash.abs() % categoryColors.length];
  }

  Widget _buildColumnHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    WidgetRef ref,
    LedgerTransaction transaction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return TrxDetail(transaction: transaction);
      },
    );
  }
}

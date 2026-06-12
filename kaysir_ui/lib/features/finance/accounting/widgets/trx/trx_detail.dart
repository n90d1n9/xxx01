import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../models/ledger_trx.dart';
import '../../states/gl/ledger_provider.dart';
import 'trx_edit.dart';

class TrxDetail extends ConsumerWidget {
  final LedgerTransaction transaction;

  const TrxDetail({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction Details',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            'Date',
            DateFormat('MMMM d, y').format(transaction.date),
            Icons.calendar_today_rounded,
          ),
          _buildDetailRow(
            context,
            'Account',
            transaction.account,
            Icons.account_balance_rounded,
          ),
          _buildDetailRow(
            context,
            'Description',
            transaction.description,
            Icons.description_rounded,
          ),
          _buildDetailRow(
            context,
            'Type',
            transaction.type.name,
            transaction.type == TransactionType.debit
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            valueColor:
                transaction.type == TransactionType.debit
                    ? Colors.green.shade700
                    : Colors.red.shade700,
          ),
          _buildDetailRow(
            context,
            'Amount',
            transaction.formattedAmount,
            Icons.attach_money_rounded,
            valueColor:
                transaction.type == TransactionType.debit
                    ? Colors.green.shade700
                    : Colors.red.shade700,
          ),
          _buildDetailRow(
            context,
            'Reference',
            transaction.reference,
            Icons.numbers_rounded,
          ),
          _buildDetailRow(
            context,
            'Category',
            transaction.category,
            Icons.category_rounded,
            valueColor: _getCategoryColor(transaction.category),
          ),
          if (transaction.isSystemGenerated)
            _buildDetailRow(
              context,
              'Source',
              transaction.journalId == null
                  ? 'Posted journal'
                  : 'Posted journal ${transaction.journalId}',
              Icons.lock_outline_rounded,
              valueColor: theme.colorScheme.primary,
            ),
          const SizedBox(height: 24),
          transaction.isSystemGenerated
              ? Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Done'),
                  onPressed: () => Navigator.pop(context),
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditTransactionDialog(context, ref, transaction);
                    },
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Duplicate'),
                    onPressed: () {
                      Navigator.pop(context);
                      _duplicateTransaction(context, ref, transaction);
                    },
                  ),
                ],
              ),
        ],
      ),
    );
  }

  void _duplicateTransaction(
    BuildContext context,
    WidgetRef ref,
    LedgerTransaction transaction,
  ) {
    // Create a copy with today's date
    final duplicatedTransaction = transaction.copyWith(
      id: const Uuid().v4(),
      date: DateTime.now(),
      reference: '${transaction.reference} (Copy)',
    );

    ref.read(ledgerProvider.notifier).addTransaction(duplicatedTransaction);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction duplicated successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditTransactionDialog(
    BuildContext context,
    WidgetRef ref,
    LedgerTransaction transaction,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TrxEdit(transaction: transaction);
      },
    );
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

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

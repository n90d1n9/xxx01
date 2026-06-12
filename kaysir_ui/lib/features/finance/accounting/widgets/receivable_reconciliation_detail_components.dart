import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/receivable_reconciliation.dart';
import 'reconciliation_detail_components.dart';

class ReceivableReconciliationTotalsPanel extends StatelessWidget {
  const ReceivableReconciliationTotalsPanel({
    required this.reconciliation,
    required this.currency,
    super.key,
  });

  final ReceivableReconciliation reconciliation;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final varianceColor =
        reconciliation.isBalanced ? Colors.teal : Colors.deepOrange;

    return ReconciliationMetricStrip(
      metrics: [
        ReconciliationMetricData(
          label: 'Subledger',
          value: currency.format(reconciliation.subledgerBalance),
          helper: 'Open customer invoices',
          icon: Icons.receipt_long_outlined,
          accentColor: colorScheme.primary,
        ),
        ReconciliationMetricData(
          label: 'GL AR',
          value: currency.format(reconciliation.ledgerBalance),
          helper: 'Posted ledger activity',
          icon: Icons.account_balance_wallet_outlined,
          accentColor: colorScheme.tertiary,
        ),
        ReconciliationMetricData(
          label: 'Variance',
          value: currency.format(reconciliation.variance),
          helper:
              reconciliation.isBalanced ? 'Within tolerance' : 'Needs review',
          icon:
              reconciliation.isBalanced
                  ? Icons.verified_outlined
                  : Icons.warning_amber_rounded,
          accentColor: varianceColor,
        ),
        ReconciliationMetricData(
          label: 'Oldest Due',
          value: '${reconciliation.oldestDaysPastDue} days',
          helper: 'Collection exposure',
          icon: Icons.schedule_outlined,
          accentColor: Colors.indigo,
        ),
      ],
    );
  }
}

class ReceivableAgingBucketStrip extends StatelessWidget {
  const ReceivableAgingBucketStrip({
    required this.buckets,
    required this.currency,
    super.key,
  });

  final List<ReceivableAgingBucket> buckets;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) {
      return const ReconciliationEmptyState(
        title: 'No receivable aging buckets',
        message: 'Aging exposure will appear once open invoices are available.',
        icon: Icons.hourglass_empty_rounded,
      );
    }

    final maxAmount = buckets.fold<double>(
      0,
      (current, bucket) => bucket.amount > current ? bucket.amount : current,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 960.0;
        final columns = _bucketColumnCount(availableWidth, buckets.length);
        final itemWidth =
            ((availableWidth - (spacing * (columns - 1))) / columns)
                .clamp(0.0, availableWidth)
                .toDouble();

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final bucket in buckets)
              SizedBox(
                width: itemWidth,
                child: _ReceivableAgingBucketTile(
                  bucket: bucket,
                  currency: currency,
                  maxAmount: maxAmount,
                ),
              ),
          ],
        );
      },
    );
  }

  int _bucketColumnCount(double width, int itemCount) {
    final targetColumns =
        width < 440
            ? 1
            : width < 720
            ? 2
            : width < 980
            ? 3
            : 5;
    return itemCount < targetColumns ? itemCount : targetColumns;
  }
}

class ReceivableSubledgerReconciliationTable extends StatelessWidget {
  const ReceivableSubledgerReconciliationTable({
    required this.lines,
    required this.currency,
    required this.dateFormat,
    super.key,
  });

  final List<ReceivableSubledgerReconciliationLine> lines;
  final NumberFormat currency;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const ReconciliationEmptyState(
        title: 'No open customer invoices',
        message: 'Subledger detail will appear once receivables are open.',
        icon: Icons.receipt_long_outlined,
      );
    }

    return ReconciliationTableShell(
      child: DataTable(
        headingRowHeight: 38,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 52,
        columns: const [
          DataColumn(label: Text('Due Date')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Invoice')),
          DataColumn(label: Text('Days Late'), numeric: true),
          DataColumn(label: Text('Remaining'), numeric: true),
        ],
        rows: [
          for (final line in lines)
            DataRow(
              cells: [
                DataCell(Text(_dateOrDash(line.dueDate))),
                DataCell(Text(line.customerName)),
                DataCell(Text(line.reference)),
                DataCell(_DaysPastDuePill(daysPastDue: line.daysPastDue)),
                DataCell(Text(currency.format(line.remainingAmount))),
              ],
            ),
        ],
      ),
    );
  }

  String _dateOrDash(DateTime? date) {
    return date == null ? '-' : dateFormat.format(date);
  }
}

class ReceivableLedgerReconciliationTable extends StatelessWidget {
  const ReceivableLedgerReconciliationTable({
    required this.lines,
    required this.currency,
    required this.dateFormat,
    super.key,
  });

  final List<ReceivableLedgerReconciliationLine> lines;
  final NumberFormat currency;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const ReconciliationEmptyState(
        title: 'No AR ledger activity posted',
        message: 'Posted AR debits and credits will appear here.',
        icon: Icons.account_balance_wallet_outlined,
      );
    }

    return ReconciliationTableShell(
      child: DataTable(
        headingRowHeight: 38,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 52,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Reference')),
          DataColumn(label: Text('Source')),
          DataColumn(label: Text('Debit'), numeric: true),
          DataColumn(label: Text('Credit'), numeric: true),
          DataColumn(label: Text('Impact'), numeric: true),
        ],
        rows: [
          for (final line in lines)
            DataRow(
              cells: [
                DataCell(Text(dateFormat.format(line.date))),
                DataCell(Text(line.reference)),
                DataCell(Text(line.source)),
                DataCell(Text(_amountOrDash(line.debitAmount))),
                DataCell(Text(_amountOrDash(line.creditAmount))),
                DataCell(Text(currency.format(line.balanceImpact))),
              ],
            ),
        ],
      ),
    );
  }

  String _amountOrDash(double amount) {
    return amount == 0 ? '-' : currency.format(amount);
  }
}

class _ReceivableAgingBucketTile extends StatelessWidget {
  const _ReceivableAgingBucketTile({
    required this.bucket,
    required this.currency,
    required this.maxAmount,
  });

  final ReceivableAgingBucket bucket;
  final NumberFormat currency;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _bucketColor(bucket.id, colorScheme);
    final progress =
        maxAmount <= 0 ? 0.0 : (bucket.amount / maxAmount).clamp(0.0, 1.0);

    return Material(
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bucket.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${bucket.invoiceCount} inv.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                currency.format(bucket.amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: color.withValues(alpha: 0.14),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _bucketColor(String id, ColorScheme colorScheme) {
    switch (id) {
      case ReceivableAgingBucketIds.current:
        return Colors.teal;
      case ReceivableAgingBucketIds.overdue1To30:
        return Colors.amber.shade800;
      case ReceivableAgingBucketIds.overdue31To60:
        return Colors.deepOrange;
      case ReceivableAgingBucketIds.overdue61To90:
      case ReceivableAgingBucketIds.overdueOver90:
        return colorScheme.error;
      default:
        return colorScheme.primary;
    }
  }
}

class _DaysPastDuePill extends StatelessWidget {
  const _DaysPastDuePill({required this.daysPastDue});

  final int daysPastDue;

  @override
  Widget build(BuildContext context) {
    final color =
        daysPastDue <= 0
            ? Colors.teal
            : daysPastDue <= 30
            ? Colors.amber.shade800
            : daysPastDue <= 60
            ? Colors.deepOrange
            : Theme.of(context).colorScheme.error;

    return Container(
      constraints: const BoxConstraints(minWidth: 44),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.32)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        daysPastDue.toString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

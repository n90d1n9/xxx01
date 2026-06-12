import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/payable_reconciliation.dart';
import 'reconciliation_detail_components.dart';

class PayableReconciliationTotalsPanel extends StatelessWidget {
  const PayableReconciliationTotalsPanel({
    required this.reconciliation,
    required this.currency,
    super.key,
  });

  final PayableReconciliation reconciliation;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final varianceColor =
        reconciliation.isBalanced ? Colors.teal : Colors.deepOrange;

    return ReconciliationMetricStrip(
      maxColumns: 3,
      metrics: [
        ReconciliationMetricData(
          label: 'Subledger',
          value: currency.format(reconciliation.subledgerBalance),
          helper: 'Open vendor bills',
          icon: Icons.inventory_2_outlined,
          accentColor: colorScheme.primary,
        ),
        ReconciliationMetricData(
          label: 'GL AP',
          value: currency.format(reconciliation.ledgerBalance),
          helper: 'Posted liability activity',
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
      ],
    );
  }
}

class PayableSubledgerReconciliationTable extends StatelessWidget {
  const PayableSubledgerReconciliationTable({
    required this.lines,
    required this.currency,
    required this.dateFormat,
    super.key,
  });

  final List<PayableSubledgerReconciliationLine> lines;
  final NumberFormat currency;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const ReconciliationEmptyState(
        title: 'No open payable bills',
        message: 'Subledger detail will appear once vendor bills are open.',
        icon: Icons.inventory_2_outlined,
      );
    }

    return ReconciliationTableShell(
      child: DataTable(
        headingRowHeight: 38,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 52,
        columns: const [
          DataColumn(label: Text('Due Date')),
          DataColumn(label: Text('Vendor')),
          DataColumn(label: Text('Bill')),
          DataColumn(label: Text('Remaining'), numeric: true),
        ],
        rows: [
          for (final line in lines)
            DataRow(
              cells: [
                DataCell(Text(_dateOrDash(line.dueDate))),
                DataCell(Text(line.vendorName)),
                DataCell(Text(line.reference)),
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

class PayableLedgerReconciliationTable extends StatelessWidget {
  const PayableLedgerReconciliationTable({
    required this.lines,
    required this.currency,
    required this.dateFormat,
    super.key,
  });

  final List<PayableLedgerReconciliationLine> lines;
  final NumberFormat currency;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const ReconciliationEmptyState(
        title: 'No AP ledger activity posted',
        message: 'Posted AP debits and credits will appear here.',
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

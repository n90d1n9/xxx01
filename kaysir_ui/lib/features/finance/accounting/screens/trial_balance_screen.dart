import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../accounting_path.dart';
import '../models/ledger_trx.dart';
import '../models/trial_balance.dart';
import '../services/trial_balance_ledger_review_service.dart';
import '../states/gl/filter_provider.dart';
import '../states/gl/ledger_provider.dart';
import '../states/trial_balance_provider.dart';
import '../widgets/trial_balance_diagnostics_panel.dart';

enum _TrialPeriod { all, month, quarter, year, custom }

/// Trial balance workspace for reviewing ledger balances before close.
class TrialBalanceScreen extends ConsumerStatefulWidget {
  const TrialBalanceScreen({super.key});

  @override
  ConsumerState<TrialBalanceScreen> createState() => _TrialBalanceScreenState();
}

class _TrialBalanceScreenState extends ConsumerState<TrialBalanceScreen> {
  static const _ledgerReviewService = TrialBalanceLedgerReviewService();

  final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  DateTime? _startDate;
  DateTime? _endDate;
  _TrialPeriod _period = _TrialPeriod.all;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final report = ref
        .watch(trialBalanceServiceProvider)
        .buildReport(
          transactions: ref.watch(combinedLedgerProvider),
          startDate: _startDate,
          endDate: _endDate,
          query: _query,
        );
    final summary = report.summary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Trial Balance'),
        actions: [
          IconButton(
            tooltip: 'Export trial balance',
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _showExportSnackBar(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildControlBar(context),
            const SizedBox(height: 16),
            _buildSummaryCards(
              context,
              summary.accountCount,
              summary.totalDebits,
              summary.totalCredits,
              summary.variance,
              summary.isBalanced,
            ),
            const SizedBox(height: 16),
            TrialBalanceDiagnosticsPanel(
              report: report,
              onReviewLedger: _openDiagnosticInLedger,
            ),
            if (report.hasDiagnostics) const SizedBox(height: 16),
            _buildCloseChecklist(context, report.closeChecks),
            const SizedBox(height: 16),
            Expanded(
              child:
                  report.rows.isEmpty
                      ? _buildEmptyState(context)
                      : _buildTrialBalanceTable(context, report),
            ),
          ],
        ),
      ),
    );
  }

  void _openDiagnosticInLedger(TrialBalanceDiagnostic diagnostic) {
    final filter = _ledgerReviewService.filterForDiagnostic(
      diagnostic: diagnostic,
      startDate: _startDate,
      endDate: _endDate,
    );
    ref.read(ledgerFilterProvider.notifier).state = filter;

    if (!mounted) return;
    context.go(AccountingPath.gl);
  }

  Widget _buildControlBar(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search account, reference, or memo',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value.trim();
                  });
                },
              ),
            ),
            _periodChip('All', _TrialPeriod.all),
            _periodChip('This Month', _TrialPeriod.month),
            _periodChip('Quarter', _TrialPeriod.quarter),
            _periodChip('Year', _TrialPeriod.year),
            ActionChip(
              avatar: const Icon(Icons.date_range_rounded, size: 18),
              label: Text(_customPeriodLabel),
              onPressed: () => _pickCustomPeriod(context),
              backgroundColor:
                  _period == _TrialPeriod.custom
                      ? theme.colorScheme.primaryContainer
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodChip(String label, _TrialPeriod period) {
    return ChoiceChip(
      label: Text(label),
      selected: _period == period,
      onSelected: (_) => _applyPeriod(period),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    int accountCount,
    double totalDebits,
    double totalCredits,
    double variance,
    bool isBalanced,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 1100 ? 260.0 : 220.0;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _summaryCard(
              context,
              'Debit Balances',
              _currency.format(totalDebits),
              Icons.arrow_upward_rounded,
              Colors.green.shade700,
              width,
            ),
            _summaryCard(
              context,
              'Credit Balances',
              _currency.format(totalCredits),
              Icons.arrow_downward_rounded,
              Colors.red.shade700,
              width,
            ),
            _summaryCard(
              context,
              isBalanced ? 'Balanced' : 'Variance',
              _currency.format(variance.abs()),
              isBalanced ? Icons.verified_rounded : Icons.warning_rounded,
              isBalanced ? Colors.blue.shade700 : Colors.orange.shade700,
              width,
            ),
            _summaryCard(
              context,
              'Accounts With Activity',
              accountCount.toString(),
              Icons.account_tree_rounded,
              Colors.indigo.shade700,
              width,
            ),
          ],
        );
      },
    );
  }

  Widget _summaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    double width,
  ) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloseChecklist(
    BuildContext context,
    List<TrialBalanceCloseCheck> checks,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Close Readiness',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  checks.map((check) {
                    final color = check.passed ? Colors.green : Colors.orange;
                    return Chip(
                      avatar: Icon(
                        check.passed
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        color: color,
                        size: 18,
                      ),
                      label: Text(check.label),
                      side: BorderSide(color: color.withValues(alpha: 0.35)),
                      backgroundColor: color.withValues(alpha: 0.08),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialBalanceTable(
    BuildContext context,
    TrialBalanceReport report,
  ) {
    final theme = Theme.of(context);
    final rows = report.rows;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Account Balances',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _periodDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.45,
                    ),
                  ),
                  columns: const [
                    DataColumn(label: Text('Account')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Opening'), numeric: true),
                    DataColumn(label: Text('Debit Movement'), numeric: true),
                    DataColumn(label: Text('Credit Movement'), numeric: true),
                    DataColumn(label: Text('Closing Debit'), numeric: true),
                    DataColumn(label: Text('Closing Credit'), numeric: true),
                    DataColumn(label: Text('Normal Side')),
                    DataColumn(label: Text('Activity')),
                  ],
                  rows:
                      rows.map((row) {
                        return DataRow(
                          cells: [
                            DataCell(Text(row.account)),
                            DataCell(Text(row.category)),
                            DataCell(
                              Text(_currency.format(row.openingBalance)),
                            ),
                            DataCell(Text(_currency.format(row.debitMovement))),
                            DataCell(
                              Text(_currency.format(row.creditMovement)),
                            ),
                            DataCell(Text(_currency.format(row.debitBalance))),
                            DataCell(Text(_currency.format(row.creditBalance))),
                            DataCell(
                              Chip(
                                label: Text(row.normalSideLabel),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            DataCell(
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.receipt_long_rounded,
                                  size: 18,
                                ),
                                label: Text('${row.entryCount} entries'),
                                onPressed:
                                    () => _showAccountActivity(
                                      context,
                                      row,
                                      report.transactions,
                                    ),
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.balance_rounded,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            'No ledger activity for this period',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Adjust the period or search term to see account balances.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _applyPeriod(_TrialPeriod period) {
    final now = DateTime.now();
    setState(() {
      _period = period;
      switch (period) {
        case _TrialPeriod.all:
          _startDate = null;
          _endDate = null;
          break;
        case _TrialPeriod.month:
          _startDate = DateTime(now.year, now.month);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case _TrialPeriod.quarter:
          final firstMonth = ((now.month - 1) ~/ 3) * 3 + 1;
          _startDate = DateTime(now.year, firstMonth);
          _endDate = DateTime(now.year, firstMonth + 3, 0);
          break;
        case _TrialPeriod.year:
          _startDate = DateTime(now.year);
          _endDate = DateTime(now.year, 12, 31);
          break;
        case _TrialPeriod.custom:
          break;
      }
    });
  }

  Future<void> _pickCustomPeriod(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 5),
      initialDateRange:
          _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : DateTimeRange(
                start: DateTime(now.year, now.month),
                end: DateTime(now.year, now.month + 1, 0),
              ),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _period = _TrialPeriod.custom;
      _startDate = picked.start;
      _endDate = picked.end;
    });
  }

  void _showAccountActivity(
    BuildContext context,
    TrialBalanceRow row,
    List<LedgerTransaction> transactions,
  ) {
    final accountTransactions =
        transactions
            .where((transaction) => transaction.account == row.account)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(row.account),
          content: SizedBox(
            width: 560,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: accountTransactions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = accountTransactions[index];
                final isDebit = transaction.type == TransactionType.debit;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isDebit
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: isDebit ? Colors.green : Colors.red,
                  ),
                  title: Text(transaction.description),
                  subtitle: Text(
                    '${transaction.formattedDate} - ${transaction.reference}',
                  ),
                  trailing: Text(
                    _currency.format(transaction.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showExportSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trial balance export is queued.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String get _customPeriodLabel {
    if (_period != _TrialPeriod.custom ||
        _startDate == null ||
        _endDate == null) {
      return 'Custom';
    }

    final formatter = DateFormat('MMM d');
    return '${formatter.format(_startDate!)} - ${formatter.format(_endDate!)}';
  }

  String get _periodDescription {
    if (_startDate == null || _endDate == null) {
      return 'All ledger activity';
    }

    final formatter = DateFormat('MMM d, yyyy');
    return '${formatter.format(_startDate!)} - ${formatter.format(_endDate!)}';
  }
}

@Preview(name: 'Trial balance screen')
Widget trialBalanceScreenPreview() {
  return const ProviderScope(child: MaterialApp(home: TrialBalanceScreen()));
}

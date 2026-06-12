import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../accounting_core/adapters/accounting_entry_adapter.dart';
import '../accounting_core/services/ledger_posting_service.dart';
import '../models/account_entry.dart';
import '../states/accounting_core_provider.dart';
import '../states/adjusment/adjustment_provider.dart';
import '../states/entry_provider.dart';
import '../states/financial_period_posting_guard_provider.dart';
import '../widgets/add_entry_form.dart';
import '../widgets/closed_period_posting_notice.dart';
import '../widgets/edit_entry_dialog.dart';
import '../widgets/entry_balance_indicator.dart';
import '../widgets/entry_history_dialog.dart';
import '../widgets/entry_line_item.dart';
import '../widgets/adjusment/header_field.dart';

/// Desktop-specific layout for wider screens
class DesktopAccountingLayout extends ConsumerWidget {
  const DesktopAccountingLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEntry = ref.watch(entryNotifierProvider);
    final accounts = ref.watch(accountsProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final closeRecord = ref
        .watch(financialPeriodPostingGuardProvider)
        .closedRecordForDate(currentEntry.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Adjustment Entry'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const DesktopEntryHistoryDialog(),
              );
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Entry header and forms
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entry Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: HeaderField(
                                  label: 'Date',
                                  child: GestureDetector(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: currentEntry.date,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (date != null) {
                                        ref
                                            .read(
                                              entryNotifierProvider.notifier,
                                            )
                                            .setDate(date);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            DateFormat(
                                              'MM/dd/yyyy',
                                            ).format(currentEntry.date),
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge,
                                          ),
                                          const Spacer(),
                                          Icon(
                                            Icons.calendar_today,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: HeaderField(
                                  label: 'Reference',
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText: 'Reference Number',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    initialValue: currentEntry.referenceNumber,
                                    onChanged: (value) {
                                      ref
                                          .read(entryNotifierProvider.notifier)
                                          .setReferenceNumber(value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          HeaderField(
                            label: 'Description',
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Enter adjustment description',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              initialValue: currentEntry.description,
                              maxLines: 3,
                              onChanged: (value) {
                                ref
                                    .read(entryNotifierProvider.notifier)
                                    .setDescription(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPostingReadiness(context, currentEntry, currencyFormat),
                  ClosedPeriodPostingNotice(
                    closeRecord: closeRecord,
                    actionLabel: 'post this journal entry',
                  ),
                  const SizedBox(height: 24),

                  // Add line form directly on the left panel for desktop
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: DesktopAddEntryLineForm(accounts: accounts),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          Container(
            width: 1,
            color: Colors.grey.shade200,
            height: double.infinity,
          ),

          // Right side: Entry lines and totals
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Journal Entry Lines',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      EntryBalanceIndicator(entry: currentEntry),
                    ],
                  ),
                ),

                // Line header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Account',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Memo',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Debit',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Credit',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      const SizedBox(width: 90), // For action buttons
                    ],
                  ),
                ),

                // Entry lines list
                Expanded(
                  child:
                      currentEntry.lines.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No entry lines',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add lines using the form on the left',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: currentEntry.lines.length,
                            itemBuilder: (context, index) {
                              final line = currentEntry.lines[index];
                              return DesktopEntryLineItem(
                                line: line,
                                onEdit: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => DesktopEditEntryLineDialog(
                                          line: line,
                                          accounts: accounts,
                                        ),
                                  );
                                },
                                onDelete: () {
                                  ref
                                      .read(entryNotifierProvider.notifier)
                                      .removeLine(line.id);
                                },
                              );
                            },
                          ),
                ),

                // Entry totals
                if (currentEntry.lines.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: SizedBox(), // Account column
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Totals',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            currencyFormat.format(currentEntry.debitTotal),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            currencyFormat.format(currentEntry.creditTotal),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(width: 90),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Clear Entry'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onPressed: () {
                  // Confirm before clearing
                  if (currentEntry.lines.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Clear Entry?'),
                            content: const Text(
                              'This will remove all entry lines. Continue?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ref
                                      .read(entryNotifierProvider.notifier)
                                      .clear();
                                },
                                child: const Text('CLEAR'),
                              ),
                            ],
                          ),
                    );
                  } else {
                    ref.read(entryNotifierProvider.notifier).clear();
                  }
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Post Entry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onPressed:
                    !currentEntry.canPost || closeRecord != null
                        ? null
                        : () => _postEntry(context, ref, currentEntry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostingReadiness(
    BuildContext context,
    AccountingEntry entry,
    NumberFormat currencyFormat,
  ) {
    final theme = Theme.of(context);
    final requiredType = entry.requiredBalancingType;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Posting Readiness',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  entry.canPost
                      ? Icons.verified_rounded
                      : Icons.rule_folder_rounded,
                  color:
                      entry.canPost
                          ? Colors.green.shade700
                          : theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildReadinessChip(
                  context,
                  'Reference',
                  entry.referenceNumber.trim().isNotEmpty,
                ),
                _buildReadinessChip(
                  context,
                  'Description',
                  entry.description.trim().isNotEmpty,
                ),
                _buildReadinessChip(context, 'Lines', entry.lines.isNotEmpty),
                _buildReadinessChip(context, 'Balanced', entry.isBalanced),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMetricTile(
                  context,
                  'Debits',
                  currencyFormat.format(entry.debitTotal),
                  '${entry.debitLineCount} lines',
                  Colors.green.shade700,
                ),
                _buildMetricTile(
                  context,
                  'Credits',
                  currencyFormat.format(entry.creditTotal),
                  '${entry.creditLineCount} lines',
                  Colors.red.shade700,
                ),
                _buildMetricTile(
                  context,
                  requiredType == null
                      ? 'Difference'
                      : 'Needs ${requiredType.name}',
                  currencyFormat.format(entry.requiredBalancingAmount),
                  entry.canPost ? 'ready to post' : entry.postIssues.first,
                  entry.isBalanced
                      ? Colors.blue.shade700
                      : Colors.orange.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessChip(
    BuildContext context,
    String label,
    bool isComplete,
  ) {
    return Chip(
      avatar: Icon(
        isComplete ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
        color: isComplete ? Colors.green.shade700 : Colors.orange.shade700,
        size: 18,
      ),
      label: Text(label),
      backgroundColor:
          isComplete ? Colors.green.shade50 : Colors.orange.shade50,
      side: BorderSide(
        color: isComplete ? Colors.green.shade100 : Colors.orange.shade100,
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context,
    String label,
    String value,
    String helper,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _postEntry(
    BuildContext context,
    WidgetRef ref,
    AccountingEntry currentEntry,
  ) {
    try {
      ref
          .read(financialPeriodPostingGuardProvider)
          .ensureDateIsOpen(
            currentEntry.date,
            actionLabel: 'post journal adjustment',
          );
      final posting = ref
          .read(ledgerPostingServiceProvider)
          .post(
            currentEntry.toJournalDraft(),
            ref.read(accountingChartProvider),
          );
      ref.read(postedLedgerProvider.notifier).addPosting(posting);

      final historyNotifier = ref.read(entryHistoryProvider.notifier);
      historyNotifier.state = [
        ...ref.read(entryHistoryProvider),
        currentEntry.copyWith(isPosted: true),
      ];

      ref.read(entryNotifierProvider.notifier).clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journal entry posted to ledger'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on LedgerPostingException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.issues.join(' | ')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on StateError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

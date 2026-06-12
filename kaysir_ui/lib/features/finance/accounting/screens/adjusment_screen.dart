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
import '../widgets/closed_period_posting_notice.dart';
import '../widgets/adjusment/mobile_entry.dart';
import '../widgets/adjusment/mobile_entry_balance_status.dart';
import '../widgets/adjusment/mobile_entry_edit.dart';
import '../widgets/adjusment/mobile_entry_line_item.dart';
import 'entry_history_screen.dart';

/// Original mobile layout for accounting adjustment screen
class AccountingAdjustmentScreen extends ConsumerWidget {
  const AccountingAdjustmentScreen({super.key});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EntryHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Entry header section
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entry Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
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
                                  .read(entryNotifierProvider.notifier)
                                  .setDate(date);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat(
                                    'MM/dd/yyyy',
                                  ).format(currentEntry.date),
                                ),
                                const Icon(Icons.calendar_today, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Reference',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    initialValue: currentEntry.description,
                    onChanged: (value) {
                      ref
                          .read(entryNotifierProvider.notifier)
                          .setDescription(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildMobilePostingReadiness(
              context,
              currentEntry,
              currencyFormat,
            ),
          ),
          if (closeRecord != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClosedPeriodPostingNotice(
                closeRecord: closeRecord,
                actionLabel: 'post this journal entry',
                margin: EdgeInsets.zero,
              ),
            ),

          // Entry lines list
          Expanded(
            child: Card(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Entry Lines',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (currentEntry.lines.isNotEmpty)
                          MobileEntryBalanceStatus(entry: currentEntry),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        currentEntry.lines.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.article_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No entry lines',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap the + button to add a line',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            )
                            : ListView.separated(
                              itemCount: currentEntry.lines.length,
                              separatorBuilder:
                                  (context, index) => Divider(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                              itemBuilder: (context, index) {
                                final line = currentEntry.lines[index];
                                return MobileEntryLineItem(
                                  line: line,
                                  onEdit: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder:
                                          (context) => MobileEditEntryLineSheet(
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
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => MobileAddEntryLineSheet(accounts: accounts),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed:
                !currentEntry.canPost || closeRecord != null
                    ? null
                    : () => _postEntry(context, ref, currentEntry),
            child: const Text('Post Journal Entry'),
          ),
        ),
      ),
    );
  }

  Widget _buildMobilePostingReadiness(
    BuildContext context,
    AccountingEntry entry,
    NumberFormat currencyFormat,
  ) {
    final theme = Theme.of(context);
    final requiredType = entry.requiredBalancingType;
    final statusColor =
        entry.canPost
            ? Colors.green.shade700
            : entry.isBalanced
            ? theme.colorScheme.primary
            : Colors.orange.shade700;
    final statusText =
        entry.canPost
            ? 'Ready to post'
            : requiredType == null
            ? entry.postIssues.first
            : 'Needs ${requiredType.name} ${currencyFormat.format(entry.requiredBalancingAmount)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            entry.canPost ? Icons.verified_rounded : Icons.rule_rounded,
            color: statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.lines.length} lines | Debits ${currencyFormat.format(entry.debitTotal)} | Credits ${currencyFormat.format(entry.creditTotal)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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

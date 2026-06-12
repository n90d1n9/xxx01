import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../accounting_path.dart';
import '../models/financial_period_close_workflow.dart';
import '../states/accounting_core_provider.dart';
import '../states/fin_statement/financial_close_checklist_provider.dart';
import '../states/fin_statement/financial_period_close_audit_provider.dart';
import '../states/fin_statement/financial_period_close_provider.dart';
import '../states/fin_statement/financial_period_close_workflow_provider.dart';
import '../states/fin_statement/financial_provider.dart';
import '../states/fin_statement/financial_report_package_fingerprint_provider.dart';
import '../states/fin_statement/financial_report_package_integrity_provider.dart';
import '../states/fin_statement/period_closing_entry_provider.dart';
import '../widgets/financial_close_checklist_panel.dart';
import '../widgets/financial_period_close_workflow_components.dart';
import '../widgets/period_closing_entry_preview_panel.dart';

class PeriodCloseWorkflowScreen extends ConsumerWidget {
  const PeriodCloseWorkflowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(currentFinancialPeriodCloseWorkflowProvider);
    final closeChecklist = ref.watch(financialCloseChecklistProvider);
    final closeRecord = ref.watch(currentFinancialPeriodCloseRecordProvider);
    final closeAuditTrail = ref.watch(currentFinancialPeriodCloseAuditProvider);
    final packageIntegrity = ref.watch(
      currentFinancialReportPackageIntegrityProvider,
    );
    final closingEntryPreview = ref.watch(
      currentPeriodClosingEntryPreviewProvider,
    );
    final closingEntryPosted = ref.watch(
      currentPeriodClosingEntryPostedProvider,
    );
    final controller = ref.watch(financialStatementsControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Period Close'),
        actions: [
          IconButton(
            tooltip: 'Financial report pack',
            onPressed: () => context.go(AccountingPath.finStatement),
            icon: const Icon(Icons.summarize_rounded),
          ),
          IconButton(
            tooltip: 'General ledger',
            onPressed: () => context.go(AccountingPath.gl),
            icon: const Icon(Icons.menu_book_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _PeriodClosePeriodBar(controller: controller, isDarkMode: isDarkMode),
          const SizedBox(height: 14),
          FinancialPeriodCloseWorkflowHeader(
            snapshot: snapshot,
            onPostClosingEntry:
                () => _postCurrentPeriodClosingEntry(context, ref),
            onClosePeriod: () => _closeCurrentPeriod(context, ref, snapshot),
            onReopenPeriod: () => _reopenCurrentPeriod(context, ref),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          FinancialPeriodCloseStepTracker(
            snapshot: snapshot,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          FinancialPeriodCloseAttentionPanel(
            items: snapshot.attentionItems,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          PeriodClosingEntryPreviewPanel(
            preview: closingEntryPreview,
            isPosted: closingEntryPosted,
            onPostClosingEntry:
                snapshot.canPostClosingEntry
                    ? () => _postCurrentPeriodClosingEntry(context, ref)
                    : null,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          FinancialCloseChecklistPanel(
            checklist: closeChecklist,
            closeRecord: closeRecord,
            packageIntegrity: packageIntegrity,
            closeAuditTrail: closeAuditTrail,
            onClosePeriod:
                snapshot.canClosePeriod
                    ? () => _closeCurrentPeriod(context, ref, snapshot)
                    : null,
            onReopenPeriod: () => _reopenCurrentPeriod(context, ref),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 14),
          _PeriodCloseNavigationPanel(isDarkMode: isDarkMode),
        ],
      ),
    );
  }

  void _closeCurrentPeriod(
    BuildContext context,
    WidgetRef ref,
    FinancialPeriodCloseWorkflowSnapshot snapshot,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    if (!snapshot.canClosePeriod) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(snapshot.attentionItems.first),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final checklist = ref.read(financialCloseChecklistProvider);
    final period = ref.read(selectedFinancialPeriodProvider);
    final fingerprint = ref.read(
      currentFinancialReportPackageFingerprintProvider,
    );
    final closingEntryPosting = ref.read(
      currentPeriodClosingEntryPostingProvider,
    );

    try {
      final record = ref
          .read(financialPeriodCloseRecordsProvider.notifier)
          .closeCurrentPeriod(
            checklist: checklist,
            period: period,
            reportPackageHash: fingerprint.hash,
            reportPackageHashAlgorithm: fingerprint.algorithm,
            closingEntryPostingId: closingEntryPosting?.id,
            closingEntryReference: closingEntryPosting?.reference,
            closingEntryPostedAt: closingEntryPosting?.postedAt,
          );
      ref.read(financialPeriodCloseAuditProvider.notifier).recordClosed(record);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${record.periodLabel} is now closed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Close failed: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _reopenCurrentPeriod(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reopen Closed Period'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Example: add late vendor invoice',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Reopen'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (reason == null || !context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final period = ref.read(selectedFinancialPeriodProvider);
    try {
      final record = ref
          .read(financialPeriodCloseRecordsProvider.notifier)
          .reopenCurrentPeriod(period: period, reason: reason);
      ref
          .read(financialPeriodCloseAuditProvider.notifier)
          .recordReopened(record);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${record.periodLabel} was reopened.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Reopen failed: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _postCurrentPeriodClosingEntry(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final posting = ref
          .read(periodClosingEntryPostingServiceProvider)
          .post(
            preview: ref.read(currentPeriodClosingEntryPreviewProvider),
            chartOfAccounts: ref.read(accountingChartProvider),
            existingPostings: ref.read(postedLedgerProvider),
            closeRecords: ref.read(financialPeriodCloseRecordsProvider).values,
          );
      ref.read(postedLedgerProvider.notifier).addPosting(posting);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${posting.reference} closing entry posted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Posting failed: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _PeriodClosePeriodBar extends ConsumerWidget {
  final FinancialStatementsController controller;
  final bool isDarkMode;

  const _PeriodClosePeriodBar({
    required this.controller,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedFinancialPeriodProvider);
    final accent = isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF252538) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _periodChoice(
            ref,
            period,
            FinancialPeriodPreset.dataMonth,
            'Data Month',
          ),
          _periodChoice(
            ref,
            period,
            FinancialPeriodPreset.dataQuarter,
            'Quarter',
          ),
          _periodChoice(ref, period, FinancialPeriodPreset.dataYear, 'Year'),
          ActionChip(
            avatar: Icon(Icons.date_range_rounded, size: 18, color: accent),
            label: Text(
              period.preset == FinancialPeriodPreset.custom
                  ? period.label
                  : 'Custom Range',
            ),
            onPressed: () => _pickCustomPeriod(context, ref),
            backgroundColor:
                period.preset == FinancialPeriodPreset.custom
                    ? accent.withValues(alpha: 0.14)
                    : null,
          ),
          Chip(
            avatar: Icon(Icons.event_available_rounded, color: accent),
            label: Text(controller.periodLabel),
          ),
        ],
      ),
    );
  }

  Widget _periodChoice(
    WidgetRef ref,
    FinancialStatementPeriod current,
    FinancialPeriodPreset preset,
    String label,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: current.preset == preset,
      onSelected: (_) {
        ref.read(selectedFinancialPeriodProvider.notifier).state = controller
            .periodForPreset(preset);
      },
    );
  }

  Future<void> _pickCustomPeriod(BuildContext context, WidgetRef ref) async {
    final current = ref.read(selectedFinancialPeriodProvider);
    final fallbackStart = DateTime(
      controller.latestEntryDate.year,
      controller.latestEntryDate.month,
    );
    final fallbackEnd = DateTime(
      controller.latestEntryDate.year,
      controller.latestEntryDate.month + 1,
      0,
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(controller.earliestEntryDate.year - 1),
      lastDate: DateTime(controller.latestEntryDate.year + 1, 12, 31),
      initialDateRange: DateTimeRange(
        start: current.startDate ?? fallbackStart,
        end: current.endDate ?? fallbackEnd,
      ),
    );

    if (picked == null) {
      return;
    }

    ref
        .read(selectedFinancialPeriodProvider.notifier)
        .state = FinancialStatementPeriod(
      preset: FinancialPeriodPreset.custom,
      startDate: picked.start,
      endDate: picked.end,
    );
  }
}

class _PeriodCloseNavigationPanel extends StatelessWidget {
  final bool isDarkMode;

  const _PeriodCloseNavigationPanel({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF252538) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Close Workbench Links',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _linkChip(
                context,
                label: 'Report Pack',
                path: AccountingPath.finStatement,
                icon: Icons.summarize_rounded,
                color: color,
              ),
              _linkChip(
                context,
                label: 'General Ledger',
                path: AccountingPath.gl,
                icon: Icons.menu_book_rounded,
                color: color,
              ),
              _linkChip(
                context,
                label: 'Trial Balance',
                path: AccountingPath.trialBalance,
                icon: Icons.balance_rounded,
                color: color,
              ),
              _linkChip(
                context,
                label: 'Payables',
                path: AccountingPath.accPayable,
                icon: Icons.payments_rounded,
                color: color,
              ),
              _linkChip(
                context,
                label: 'Receivables',
                path: AccountingPath.accReceivable,
                icon: Icons.request_quote_rounded,
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _linkChip(
    BuildContext context, {
    required String label,
    required String path,
    required IconData icon,
    required Color color,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      onPressed: () => context.go(path),
    );
  }
}

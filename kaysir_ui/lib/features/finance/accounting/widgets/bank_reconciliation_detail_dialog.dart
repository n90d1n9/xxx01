import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

import '../accounting_core/services/ledger_posting_service.dart';
import '../models/bank_reconciliation_control_summary.dart';
import '../models/bank_reconciliation_journal_draft.dart';
import '../models/bank_reconciliation_timing_register.dart';
import '../models/bank_reconciliation_timing_register_filter.dart';
import '../models/bank_reconciliation_timing_review.dart';
import '../states/accounting_core_provider.dart';
import '../states/bank_reconciliation_provider.dart';
import '../states/financial_period_posting_guard_provider.dart';
import 'bank_reconciliation_detail_components.dart';
import 'bank_reconciliation_timing_register_section.dart';
import 'bank_reconciliation_timing_review_dialog.dart';
import 'reconciliation_detail_components.dart';

class BankReconciliationDetailDialog extends ConsumerWidget {
  final BankReconciliationTimingRegisterFilter initialTimingFilter;

  const BankReconciliationDetailDialog({
    super.key,
    this.initialTimingFilter = BankReconciliationTimingRegisterFilter.all,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconciliation = ref.watch(bankReconciliationProvider);
    final resolutionPlan = ref.watch(bankReconciliationResolutionProvider);
    final timingRegister = ref.watch(bankReconciliationTimingRegisterProvider);
    final timingReviews = ref.watch(bankReconciliationTimingReviewsProvider);
    final timingSummary = BankReconciliationTimingRegisterSummary.fromItems(
      timingRegister,
    );
    final timingReviewSummary = BankReconciliationTimingReviewSummary.fromItems(
      items: timingRegister,
      reviews: timingReviews,
    );
    final controlSummary = ref.watch(bankReconciliationControlSummaryProvider);
    final journalDraftSuggestions = ref.watch(
      bankReconciliationJournalDraftSuggestionsProvider,
    );
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final dateFormat = DateFormat('MM/dd/yyyy');
    final statusColor = _statusColor(controlSummary.severity);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReconciliationDetailHeader(
                title: 'Bank Reconciliation Detail',
                subtitle:
                    'Match imported bank statements to posted cash ledger activity and resolve timing evidence.',
                icon: Icons.account_balance_outlined,
                statusLabel: controlSummary.statusLabel,
                statusColor: statusColor,
                statusIcon: _statusIcon(controlSummary.severity),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BankReconciliationControlHealthPanel(
                        summary: controlSummary,
                        timingSummary: timingSummary,
                        timingReviewSummary: timingReviewSummary,
                        dateFormat: dateFormat,
                        statusColor: statusColor,
                      ),
                      const SizedBox(height: 14),
                      BankReconciliationTotalsPanel(
                        reconciliation: reconciliation,
                        currency: currency,
                        statusColor: statusColor,
                      ),
                      if (reconciliation.statementLines.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        BankReconciliationSectionHeader(
                          title: 'Statement Lines',
                          trailing:
                              '${reconciliation.statementLines.length} imported',
                          icon: Icons.receipt_long_outlined,
                        ),
                        const SizedBox(height: 10),
                        BankStatementManagementTable(
                          lines: reconciliation.statementLines,
                          currency: currency,
                          dateFormat: dateFormat,
                          onRemove:
                              (line) => ref
                                  .read(bankStatementLinesProvider.notifier)
                                  .removeLine(line.id),
                        ),
                      ],
                      if (resolutionPlan.hasActions) ...[
                        const SizedBox(height: 18),
                        BankReconciliationSectionHeader(
                          title: 'Resolution Workbench',
                          trailing:
                              '${resolutionPlan.suggestedJournalCount} journal, '
                              '${resolutionPlan.timingDifferenceCount} timing',
                          icon: Icons.construction_outlined,
                        ),
                        const SizedBox(height: 10),
                        BankResolutionActionTable(
                          actions: resolutionPlan.actions,
                          currency: currency,
                          dateFormat: dateFormat,
                        ),
                      ],
                      if (timingRegister.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        BankReconciliationTimingRegisterSection(
                          items: timingRegister,
                          reviews: timingReviews,
                          currency: currency,
                          dateFormat: dateFormat,
                          initialFilter: initialTimingFilter,
                          onReview:
                              (item) => _editTimingReview(
                                context,
                                ref,
                                item,
                                timingReviews[item.reference] ??
                                    BankReconciliationTimingReview.open(
                                      item.reference,
                                    ),
                                currency,
                                dateFormat,
                              ),
                        ),
                      ],
                      if (journalDraftSuggestions.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        BankReconciliationSectionHeader(
                          title: 'Suggested Journal Drafts',
                          trailing:
                              '${journalDraftSuggestions.where((item) => item.isPostable).length} ready',
                          icon: Icons.post_add_rounded,
                        ),
                        const SizedBox(height: 10),
                        BankJournalDraftSuggestionTable(
                          suggestions: journalDraftSuggestions,
                          currency: currency,
                          onPost:
                              (suggestion) =>
                                  _postJournalDraft(context, ref, suggestion),
                        ),
                      ],
                      const SizedBox(height: 18),
                      BankReconciliationSectionHeader(
                        title: 'Matched Activity',
                        trailing: '${reconciliation.matches.length} match(es)',
                        icon: Icons.link_rounded,
                      ),
                      const SizedBox(height: 10),
                      BankMatchReconciliationTable(
                        matches: reconciliation.matches,
                        currency: currency,
                        dateFormat: dateFormat,
                      ),
                      const SizedBox(height: 18),
                      BankReconciliationSectionHeader(
                        title: 'Unmatched Statement Lines',
                        trailing:
                            '${reconciliation.unmatchedStatementLines.length} item(s)',
                        icon: Icons.rule_folder_outlined,
                      ),
                      const SizedBox(height: 10),
                      BankStatementReconciliationTable(
                        lines: reconciliation.unmatchedStatementLines,
                        currency: currency,
                        dateFormat: dateFormat,
                      ),
                      const SizedBox(height: 18),
                      BankReconciliationSectionHeader(
                        title: 'Unmatched Cash Ledger',
                        trailing:
                            '${reconciliation.unmatchedLedgerLines.length} item(s)',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      const SizedBox(height: 10),
                      BankLedgerReconciliationTable(
                        lines: reconciliation.unmatchedLedgerLines,
                        currency: currency,
                        dateFormat: dateFormat,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppDialogActions(
                confirmLabel: 'Close',
                confirmIcon: Icons.close_rounded,
                confirmVariant: AppActionButtonVariant.text,
                onConfirm: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(BankReconciliationControlSeverity severity) {
    switch (severity) {
      case BankReconciliationControlSeverity.needsEvidence:
        return Colors.blueGrey;
      case BankReconciliationControlSeverity.ready:
        return Colors.teal;
      case BankReconciliationControlSeverity.postAdjustments:
        return Colors.deepOrange;
      case BankReconciliationControlSeverity.timingReview:
        return Colors.amber.shade800;
      case BankReconciliationControlSeverity.investigate:
        return Colors.redAccent;
    }
  }

  IconData _statusIcon(BankReconciliationControlSeverity severity) {
    switch (severity) {
      case BankReconciliationControlSeverity.needsEvidence:
        return Icons.upload_file_outlined;
      case BankReconciliationControlSeverity.ready:
        return Icons.verified_outlined;
      case BankReconciliationControlSeverity.postAdjustments:
        return Icons.post_add_rounded;
      case BankReconciliationControlSeverity.timingReview:
        return Icons.schedule_outlined;
      case BankReconciliationControlSeverity.investigate:
        return Icons.warning_amber_rounded;
    }
  }

  void _postJournalDraft(
    BuildContext context,
    WidgetRef ref,
    BankReconciliationJournalDraftSuggestion suggestion,
  ) {
    final draft = suggestion.draft;
    if (draft == null || !suggestion.isPostable) {
      return;
    }

    try {
      ref
          .read(financialPeriodPostingGuardProvider)
          .ensureDateIsOpen(
            draft.date,
            actionLabel: 'post bank reconciliation adjustment',
          );
      final posting = ref
          .read(ledgerPostingServiceProvider)
          .post(draft, ref.read(accountingChartProvider));
      ref.read(postedLedgerProvider.notifier).addPosting(posting);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Posted ${draft.reference} to ledger'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on LedgerPostingException catch (error) {
      _showPostingError(context, error.issues.join(', '));
    } on StateError catch (error) {
      _showPostingError(context, error.message);
    }
  }

  void _showPostingError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _editTimingReview(
    BuildContext context,
    WidgetRef ref,
    BankReconciliationTimingRegisterItem item,
    BankReconciliationTimingReview review,
    NumberFormat currency,
    DateFormat dateFormat,
  ) async {
    final updated = await showBankTimingReviewDialog(
      context,
      item: item,
      review: review,
      currency: currency,
      dateFormat: dateFormat,
    );
    if (updated == null) {
      return;
    }
    ref
        .read(bankReconciliationTimingReviewsProvider.notifier)
        .saveReview(updated);
  }
}

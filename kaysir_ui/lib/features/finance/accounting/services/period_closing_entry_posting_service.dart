import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/models/journal_entry.dart';
import '../accounting_core/models/ledger_posting.dart';
import '../accounting_core/services/ledger_posting_service.dart';
import '../models/financial_period_close.dart';
import '../models/period_closing_entry.dart';
import 'financial_period_posting_guard_service.dart';

class PeriodClosingEntryPostingService {
  final LedgerPostingService postingService;
  final FinancialPeriodPostingGuardService postingGuardService;

  const PeriodClosingEntryPostingService({
    required this.postingService,
    this.postingGuardService = const FinancialPeriodPostingGuardService(),
  });

  LedgerPosting post({
    required PeriodClosingEntryPreview preview,
    required List<AccountingAccount> chartOfAccounts,
    required Iterable<LedgerPosting> existingPostings,
    required Iterable<FinancialPeriodCloseRecord> closeRecords,
  }) {
    final draft = preview.draft;
    if (draft == null || !preview.canPost) {
      throw StateError('Closing entry is not ready to post.');
    }

    postingGuardService.ensureDateIsOpen(
      entryDate: draft.date,
      records: closeRecords,
      actionLabel: 'post the closing entry',
    );

    final existing = postedClosingEntryFor(
      draft: draft,
      postings: existingPostings,
    );
    if (existing != null) {
      throw StateError('Closing entry ${draft.reference} has already posted.');
    }

    return postingService.post(draft, chartOfAccounts);
  }

  LedgerPosting? postedClosingEntryFor({
    required JournalDraft draft,
    required Iterable<LedgerPosting> postings,
  }) {
    for (final posting in postings) {
      if (posting.source != JournalSource.periodClose) {
        continue;
      }
      if (posting.journalId == draft.id ||
          posting.reference == draft.reference) {
        return posting;
      }
    }
    return null;
  }
}

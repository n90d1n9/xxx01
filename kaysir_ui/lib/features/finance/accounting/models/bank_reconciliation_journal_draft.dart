import '../accounting_core/models/journal_entry.dart';
import '../accounting_core/models/ledger_posting.dart';
import 'bank_reconciliation_resolution.dart';

class BankReconciliationJournalDraftSuggestion {
  final BankReconciliationResolutionAction action;
  final JournalDraft? draft;
  final List<String> issues;
  final LedgerPosting? postedPosting;

  const BankReconciliationJournalDraftSuggestion({
    required this.action,
    required this.draft,
    required this.issues,
    this.postedPosting,
  });

  bool get isReady => draft != null && issues.isEmpty;

  bool get isPosted => postedPosting != null;

  bool get isPostable => isReady && !isPosted;

  String get statusLabel {
    if (isPosted) {
      return 'Posted';
    }
    if (isReady) {
      return 'Ready';
    }
    return 'Setup';
  }
}

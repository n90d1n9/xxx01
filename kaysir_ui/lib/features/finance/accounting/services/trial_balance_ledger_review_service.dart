import '../models/ledger_filter.dart';
import '../models/trial_balance.dart';

/// Builds General Ledger review filters from trial balance diagnostics.
class TrialBalanceLedgerReviewService {
  const TrialBalanceLedgerReviewService();

  LedgerFilter filterForDiagnostic({
    required TrialBalanceDiagnostic diagnostic,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final transactionTrace =
        diagnostic.affectedTransactionIds.isEmpty
            ? null
            : diagnostic.affectedTransactionIds.first;
    final account =
        diagnostic.affectedAccounts.isEmpty
            ? null
            : diagnostic.affectedAccounts.first;

    return LedgerFilter(
      startDate: startDate,
      endDate: endDate,
      account: transactionTrace == null ? account : null,
      searchTerm: transactionTrace,
    );
  }
}

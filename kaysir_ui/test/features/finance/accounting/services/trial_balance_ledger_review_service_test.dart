import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/trial_balance.dart';
import 'package:kaysir/features/finance/accounting/services/trial_balance_ledger_review_service.dart';

void main() {
  group('TrialBalanceLedgerReviewService', () {
    const service = TrialBalanceLedgerReviewService();

    test(
      'prioritizes ledger row trace when a diagnostic has transaction IDs',
      () {
        final filter = service.filterForDiagnostic(
          diagnostic: const TrialBalanceDiagnostic(
            id: 'missing-references',
            title: 'Missing references',
            message: 'Source references are missing.',
            severity: TrialBalanceDiagnosticSeverity.warning,
            affectedAccounts: ['1000 Cash'],
            affectedTransactionIds: ['JE-MISSING-1'],
          ),
          startDate: DateTime(2026, 6, 1),
          endDate: DateTime(2026, 6, 30),
        );

        expect(filter.searchTerm, 'JE-MISSING-1');
        expect(filter.account, isNull);
        expect(filter.startDate, DateTime(2026, 6, 1));
        expect(filter.endDate, DateTime(2026, 6, 30));
      },
    );

    test(
      'falls back to account focus when no ledger row trace is available',
      () {
        final filter = service.filterForDiagnostic(
          diagnostic: const TrialBalanceDiagnostic(
            id: 'unmapped-categories',
            title: 'Unmapped categories',
            message: 'Account category mapping is missing.',
            severity: TrialBalanceDiagnosticSeverity.warning,
            affectedAccounts: ['6100 Professional fees'],
          ),
        );

        expect(filter.searchTerm, isNull);
        expect(filter.account, '6100 Professional fees');
      },
    );
  });
}

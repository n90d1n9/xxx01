import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/services/bank_reconciliation_journal_draft_service.dart';

void main() {
  group('BankReconciliationJournalDraftService', () {
    const service = BankReconciliationJournalDraftService();

    test('builds a balanced bank fee adjustment draft', () {
      final suggestions = service.buildSuggestions(
        resolutionPlan: BankReconciliationResolutionPlan(
          actions: [_action(BankReconciliationResolutionType.bankFee, -15000)],
        ),
        chartOfAccounts: _chart(),
      );

      final suggestion = suggestions.single;
      final draft = suggestion.draft!;

      expect(suggestion.isPostable, isTrue);
      expect(draft.reference, 'ADM-001');
      expect(draft.source, JournalSource.manualAdjustment);
      expect(draft.debitTotal, 15000);
      expect(draft.creditTotal, 15000);
      expect(draft.lines.first.accountName, 'Bank Charges Expense');
      expect(draft.lines.first.side, JournalSide.debit);
      expect(draft.lines.last.accountName, 'Cash');
      expect(draft.lines.last.side, JournalSide.credit);
    });

    test('builds a balanced bank interest adjustment draft', () {
      final suggestions = service.buildSuggestions(
        resolutionPlan: BankReconciliationResolutionPlan(
          actions: [
            _action(BankReconciliationResolutionType.bankInterest, 25000),
          ],
        ),
        chartOfAccounts: _chart(),
      );

      final draft = suggestions.single.draft!;

      expect(draft.debitTotal, 25000);
      expect(draft.creditTotal, 25000);
      expect(draft.lines.first.accountName, 'Cash');
      expect(draft.lines.first.side, JournalSide.debit);
      expect(draft.lines.last.accountName, 'Bank Interest Income');
      expect(draft.lines.last.side, JournalSide.credit);
    });

    test('reports setup gaps when required accounts are missing', () {
      final suggestions = service.buildSuggestions(
        resolutionPlan: BankReconciliationResolutionPlan(
          actions: [_action(BankReconciliationResolutionType.bankFee, -15000)],
        ),
        chartOfAccounts: const [],
      );

      expect(suggestions.single.draft, isNull);
      expect(suggestions.single.isPostable, isFalse);
      expect(suggestions.single.issues, [
        'Cash/bank account is not configured',
        'Bank charges expense account is not configured',
      ]);
    });

    test('marks suggestions as posted when a matching adjustment exists', () {
      final action = _action(BankReconciliationResolutionType.bankFee, -15000);
      final firstPass = service.buildSuggestions(
        resolutionPlan: BankReconciliationResolutionPlan(actions: [action]),
        chartOfAccounts: _chart(),
      );
      final draft = firstPass.single.draft!;
      final posting = LedgerPosting(
        id: 'posted',
        journalId: draft.id,
        entryDate: draft.date,
        postedAt: DateTime(2026, 1, 6),
        reference: draft.reference,
        description: draft.description,
        source: JournalSource.manualAdjustment,
        lines: const [],
      );

      final suggestions = service.buildSuggestions(
        resolutionPlan: BankReconciliationResolutionPlan(actions: [action]),
        chartOfAccounts: _chart(),
        existingPostings: [posting],
      );

      expect(suggestions.single.isPosted, isTrue);
      expect(suggestions.single.isPostable, isFalse);
      expect(suggestions.single.statusLabel, 'Posted');
    });
  });
}

BankReconciliationResolutionAction _action(
  BankReconciliationResolutionType type,
  double amount,
) {
  return BankReconciliationResolutionAction(
    type: type,
    title: type.label,
    description: type.label,
    suggestedAction: 'Post adjustment',
    amount: amount,
    date: DateTime(2026, 1, 5),
    reference: 'ADM-001',
    suggestsJournal: true,
  );
}

List<AccountingAccount> _chart() {
  return const [
    AccountingAccount(
      id: 'cash',
      code: '1000',
      name: 'Cash',
      type: AccountingAccountType.asset,
    ),
    AccountingAccount(
      id: 'bank-fee',
      code: '5300',
      name: 'Bank Charges Expense',
      type: AccountingAccountType.expense,
    ),
    AccountingAccount(
      id: 'bank-interest',
      code: '4300',
      name: 'Bank Interest Income',
      type: AccountingAccountType.revenue,
    ),
  ];
}

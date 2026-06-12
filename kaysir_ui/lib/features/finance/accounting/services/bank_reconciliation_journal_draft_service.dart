import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/models/journal_entry.dart';
import '../accounting_core/models/ledger_posting.dart';
import '../models/bank_reconciliation_journal_draft.dart';
import '../models/bank_reconciliation_resolution.dart';

class BankReconciliationJournalDraftService {
  const BankReconciliationJournalDraftService();

  List<BankReconciliationJournalDraftSuggestion> buildSuggestions({
    required BankReconciliationResolutionPlan resolutionPlan,
    required List<AccountingAccount> chartOfAccounts,
    Iterable<LedgerPosting> existingPostings = const [],
  }) {
    return [
      for (final action in resolutionPlan.actions)
        if (_canDraft(action.type))
          _buildSuggestion(
            action: action,
            chartOfAccounts: chartOfAccounts,
            existingPostings: existingPostings,
          ),
    ];
  }

  bool _canDraft(BankReconciliationResolutionType type) {
    switch (type) {
      case BankReconciliationResolutionType.bankFee:
      case BankReconciliationResolutionType.bankInterest:
        return true;
      case BankReconciliationResolutionType.statementOnlyReceipt:
      case BankReconciliationResolutionType.statementOnlyPayment:
      case BankReconciliationResolutionType.depositInTransit:
      case BankReconciliationResolutionType.outstandingPayment:
        return false;
    }
  }

  BankReconciliationJournalDraftSuggestion _buildSuggestion({
    required BankReconciliationResolutionAction action,
    required List<AccountingAccount> chartOfAccounts,
    required Iterable<LedgerPosting> existingPostings,
  }) {
    final cashAccount = _cashAccount(chartOfAccounts);
    final offsetAccount = switch (action.type) {
      BankReconciliationResolutionType.bankFee => _bankFeeExpenseAccount(
        chartOfAccounts,
      ),
      BankReconciliationResolutionType.bankInterest =>
        _bankInterestIncomeAccount(chartOfAccounts),
      _ => null,
    };
    final issues = [
      if (cashAccount == null) 'Cash/bank account is not configured',
      if (offsetAccount == null) _offsetAccountIssue(action.type),
    ];

    final draft =
        issues.isEmpty
            ? _draftFor(
              action: action,
              cashAccount: cashAccount!,
              offsetAccount: offsetAccount!,
            )
            : null;

    return BankReconciliationJournalDraftSuggestion(
      action: action,
      draft: draft,
      issues: issues,
      postedPosting:
          draft == null
              ? null
              : postedPostingFor(draft: draft, postings: existingPostings),
    );
  }

  LedgerPosting? postedPostingFor({
    required JournalDraft draft,
    required Iterable<LedgerPosting> postings,
  }) {
    for (final posting in postings) {
      if (posting.source != JournalSource.manualAdjustment) {
        continue;
      }
      if (posting.journalId == draft.id ||
          posting.reference == draft.reference) {
        return posting;
      }
    }
    return null;
  }

  JournalDraft _draftFor({
    required BankReconciliationResolutionAction action,
    required AccountingAccount cashAccount,
    required AccountingAccount offsetAccount,
  }) {
    final amount = action.amount.abs();
    final lines = switch (action.type) {
      BankReconciliationResolutionType.bankFee => [
        JournalLineDraft(
          accountId: offsetAccount.id,
          accountName: offsetAccount.name,
          side: JournalSide.debit,
          amount: amount,
          memo: action.description,
        ),
        JournalLineDraft(
          accountId: cashAccount.id,
          accountName: cashAccount.name,
          side: JournalSide.credit,
          amount: amount,
          memo: action.description,
        ),
      ],
      BankReconciliationResolutionType.bankInterest => [
        JournalLineDraft(
          accountId: cashAccount.id,
          accountName: cashAccount.name,
          side: JournalSide.debit,
          amount: amount,
          memo: action.description,
        ),
        JournalLineDraft(
          accountId: offsetAccount.id,
          accountName: offsetAccount.name,
          side: JournalSide.credit,
          amount: amount,
          memo: action.description,
        ),
      ],
      _ => throw StateError('Unsupported bank reconciliation draft type'),
    };

    return JournalDraft(
      id: _draftId(action),
      date: action.date,
      reference: action.reference,
      description: 'Bank reconciliation - ${action.type.label}',
      source: JournalSource.manualAdjustment,
      lines: lines,
    );
  }

  AccountingAccount? _cashAccount(List<AccountingAccount> chartOfAccounts) {
    return _firstAccount(
      chartOfAccounts,
      (account) =>
          account.type == AccountingAccountType.asset &&
          (account.code == '1000' ||
              _containsAny(account.name, const [
                'cash',
                'bank',
                'kas',
                'giro',
              ])),
    );
  }

  AccountingAccount? _bankFeeExpenseAccount(
    List<AccountingAccount> chartOfAccounts,
  ) {
    return _firstAccount(
      chartOfAccounts,
      (account) =>
          account.type == AccountingAccountType.expense &&
          (account.code == '5300' ||
              _containsAny(account.name, const [
                'bank charge',
                'bank fee',
                'admin bank',
                'biaya bank',
              ])),
    );
  }

  AccountingAccount? _bankInterestIncomeAccount(
    List<AccountingAccount> chartOfAccounts,
  ) {
    return _firstAccount(
      chartOfAccounts,
      (account) =>
          account.type == AccountingAccountType.revenue &&
          (account.code == '4300' ||
              _containsAny(account.name, const [
                'bank interest',
                'interest income',
                'bunga bank',
                'jasa giro',
              ])),
    );
  }

  AccountingAccount? _firstAccount(
    List<AccountingAccount> chartOfAccounts,
    bool Function(AccountingAccount account) matches,
  ) {
    for (final account in chartOfAccounts) {
      if (account.isActive && matches(account)) {
        return account;
      }
    }
    return null;
  }

  bool _containsAny(String value, List<String> tokens) {
    final normalized = _normalize(value);
    return tokens.any((token) => normalized.contains(_normalize(token)));
  }

  String _offsetAccountIssue(BankReconciliationResolutionType type) {
    switch (type) {
      case BankReconciliationResolutionType.bankFee:
        return 'Bank charges expense account is not configured';
      case BankReconciliationResolutionType.bankInterest:
        return 'Bank interest income account is not configured';
      case BankReconciliationResolutionType.statementOnlyReceipt:
      case BankReconciliationResolutionType.statementOnlyPayment:
      case BankReconciliationResolutionType.depositInTransit:
      case BankReconciliationResolutionType.outstandingPayment:
        return 'Journal draft is not available for this resolution type';
    }
  }

  String _draftId(BankReconciliationResolutionAction action) {
    final dateKey =
        '${action.date.year.toString().padLeft(4, '0')}'
        '${action.date.month.toString().padLeft(2, '0')}'
        '${action.date.day.toString().padLeft(2, '0')}';
    final referenceKey = _normalize(action.reference);
    return 'bank-recon-${action.type.name}-$dateKey-$referenceKey';
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

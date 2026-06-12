import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/models/ledger_posting.dart';
import '../accounting_core/models/payable_posting_accounts.dart';
import '../accounting_core/models/receivable_posting_accounts.dart';
import '../accounting_core/services/ledger_posting_service.dart';
import '../accounting_core/services/payable_journal_factory.dart';
import '../accounting_core/services/receivable_journal_factory.dart';
import '../repositories/posted_ledger_repository_provider.dart';
import '../services/payable_posting_service.dart';
import '../services/receivable_payment_posting_service.dart';
import 'chart_of_accounts_provider.dart';

final accountingChartProvider = Provider<List<AccountingAccount>>((ref) {
  return ref.watch(chartOfAccountsProvider);
});

final ledgerPostingServiceProvider = Provider<LedgerPostingService>((ref) {
  return LedgerPostingService();
});

final receivableJournalFactoryProvider = Provider<ReceivableJournalFactory>((
  ref,
) {
  return const ReceivableJournalFactory();
});

final payableJournalFactoryProvider = Provider<PayableJournalFactory>((ref) {
  return const PayableJournalFactory();
});

final receivablePostingAccountsProvider = Provider<ReceivablePostingAccounts>((
  ref,
) {
  final chart = ref.watch(accountingChartProvider);
  return ReceivablePostingAccounts(
    accountsReceivable: _requiredAccount(chart, '1100'),
    salesRevenue: _requiredAccount(chart, '4000'),
    cash: _requiredAccount(chart, '1000'),
  );
});

final receivablePaymentPostingServiceProvider =
    Provider<ReceivablePaymentPostingService>((ref) {
      return ReceivablePaymentPostingService(
        journalFactory: ref.watch(receivableJournalFactoryProvider),
        postingService: ref.watch(ledgerPostingServiceProvider),
        chartOfAccounts: ref.watch(accountingChartProvider),
        accounts: ref.watch(receivablePostingAccountsProvider),
      );
    });

final payablePostingAccountsProvider = Provider<PayablePostingAccounts>((ref) {
  final chart = ref.watch(accountingChartProvider);
  return PayablePostingAccounts(
    cash: _requiredAccount(chart, '1000'),
    accountsPayable: _requiredAccount(chart, '2000'),
    defaultExpense: _requiredAccount(chart, '5000'),
  );
});

final payablePostingServiceProvider = Provider<PayablePostingService>((ref) {
  return PayablePostingService(
    journalFactory: ref.watch(payableJournalFactoryProvider),
    postingService: ref.watch(ledgerPostingServiceProvider),
    chartOfAccounts: ref.watch(accountingChartProvider),
    accounts: ref.watch(payablePostingAccountsProvider),
  );
});

final postedLedgerProvider =
    StateNotifierProvider<PostedLedgerNotifier, List<LedgerPosting>>((ref) {
      return PostedLedgerNotifier(
        repository: ref.watch(postedLedgerRepositoryProvider),
      );
    });

class PostedLedgerNotifier extends StateNotifier<List<LedgerPosting>> {
  final PostedLedgerRepository repository;
  var _isDisposed = false;

  PostedLedgerNotifier({required this.repository})
    : super(repository.loadPostings()) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratablePostedLedgerRepository) {
      return;
    }

    await repository.hydrate();
    if (!_isDisposed) {
      state = repository.loadPostings();
    }
  }

  void addPosting(LedgerPosting posting) {
    repository.appendPosting(posting);
    state = repository.loadPostings();
  }

  void clear() {
    repository.clear();
    state = repository.loadPostings();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

AccountingAccount _requiredAccount(List<AccountingAccount> chart, String code) {
  for (final account in chart) {
    if (account.code == code) {
      return account;
    }
  }
  throw StateError('Required accounting account $code is not configured');
}

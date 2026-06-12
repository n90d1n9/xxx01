import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/services/chart_of_accounts_validator.dart';
import '../models/account.dart';
import 'adjusment/adjustment_provider.dart';

/// Editable chart-of-accounts state used by posting and reporting screens.
final chartOfAccountsProvider =
    StateNotifierProvider<ChartOfAccountsNotifier, List<AccountingAccount>>((
      ref,
    ) {
      final legacyAccounts = ref.watch(accountsProvider);
      return ChartOfAccountsNotifier(
        initialAccounts: legacyAccounts.map(_accountFromLegacy),
      );
    });

/// Validation summary for the currently configured chart of accounts.
final chartOfAccountsValidationProvider =
    Provider<ChartOfAccountsValidationResult>((ref) {
      return const ChartOfAccountsValidator().validate(
        ref.watch(chartOfAccountsProvider),
      );
    });

/// Mutation controller for chart-of-accounts setup.
class ChartOfAccountsNotifier extends StateNotifier<List<AccountingAccount>> {
  ChartOfAccountsNotifier({
    required Iterable<AccountingAccount> initialAccounts,
  }) : super(List<AccountingAccount>.unmodifiable(initialAccounts));

  void addAccount(AccountingAccount account) {
    state = List<AccountingAccount>.unmodifiable([...state, account]);
  }

  void upsertAccount(AccountingAccount account) {
    var replaced = false;
    final nextAccounts = [
      for (final currentAccount in state)
        if (currentAccount.id == account.id) ...[
          account,
        ] else ...[
          currentAccount,
        ],
    ];
    replaced = state.any((currentAccount) => currentAccount.id == account.id);

    state = List<AccountingAccount>.unmodifiable(
      replaced ? nextAccounts : [...state, account],
    );
  }

  void deactivateAccount(String accountId) {
    state = List<AccountingAccount>.unmodifiable([
      for (final account in state)
        account.id == accountId ? account.copyWith(isActive: false) : account,
    ]);
  }

  void activateAccount(String accountId) {
    state = List<AccountingAccount>.unmodifiable([
      for (final account in state)
        account.id == accountId ? account.copyWith(isActive: true) : account,
    ]);
  }
}

AccountingAccount _accountFromLegacy(Account account) {
  final type = _typeFromLegacy(account.type);
  return AccountingAccount(
    id: account.id,
    code: account.code,
    name: account.name,
    type: type,
    reportSection: _reportSectionFor(account.code, type),
    cashFlowCategory: _cashFlowCategoryFor(account.code),
    taxTag: _taxTagFor(account.code),
    currencyCode: 'IDR',
  );
}

AccountingAccountType _typeFromLegacy(AccountType type) {
  switch (type) {
    case AccountType.asset:
      return AccountingAccountType.asset;
    case AccountType.liability:
      return AccountingAccountType.liability;
    case AccountType.equity:
      return AccountingAccountType.equity;
    case AccountType.revenue:
      return AccountingAccountType.revenue;
    case AccountType.expense:
      return AccountingAccountType.expense;
  }
}

AccountingReportSection _reportSectionFor(
  String code,
  AccountingAccountType type,
) {
  if (code.startsWith('50') || code.startsWith('51') || code.startsWith('52')) {
    return AccountingReportSection.operatingExpenses;
  }
  if (code.startsWith('53')) return AccountingReportSection.otherIncomeExpense;
  if (code.startsWith('43')) return AccountingReportSection.otherIncomeExpense;

  return type.defaultReportSection;
}

AccountingCashFlowCategory _cashFlowCategoryFor(String code) {
  if (code == '1000') return AccountingCashFlowCategory.operating;
  if (code.startsWith('21') || code.startsWith('30')) {
    return AccountingCashFlowCategory.financing;
  }

  return AccountingCashFlowCategory.none;
}

String? _taxTagFor(String code) {
  if (code.startsWith('40')) return 'PPN keluaran / revenue';
  if (code.startsWith('50') || code.startsWith('51') || code.startsWith('52')) {
    return 'Deductible expense review';
  }

  return null;
}

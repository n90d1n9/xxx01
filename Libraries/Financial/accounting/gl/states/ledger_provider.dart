import 'package:flutter_riverpod/legacy.dart';

import '../models/ledger_trx.dart';
import '../trx_dummy.dart';

class LedgerNotifier extends StateNotifier<List<LedgerTransaction>> {
  LedgerNotifier() : super(trx_dummy);

  void addTransaction(LedgerTransaction transaction) {
    state = [...state, transaction];
  }

  void updateTransaction(LedgerTransaction transaction) {
    state = state.map((t) => t.id == transaction.id ? transaction : t).toList();
  }

  void deleteTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  double getTotalDebit() {
    return state
        .where((transaction) => transaction.type == TransactionType.debit)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double getTotalCredit() {
    return state
        .where((transaction) => transaction.type == TransactionType.credit)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double getNetBalance() {
    return getTotalDebit() - getTotalCredit();
  }

  List<String> getUniqueAccounts() {
    final accounts = <String>{};
    for (final transaction in state) {
      accounts.add(transaction.account);
    }
    return accounts.toList()..sort();
  }

  List<String> getUniqueCategories() {
    final categories = <String>{};
    for (final transaction in state) {
      categories.add(transaction.category);
    }
    return categories.toList()..sort();
  }
}

final ledgerProvider =
    StateNotifierProvider<LedgerNotifier, List<LedgerTransaction>>((ref) {
      return LedgerNotifier();
    });

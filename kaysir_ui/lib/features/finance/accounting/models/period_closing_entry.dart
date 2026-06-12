import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/models/journal_entry.dart';

class PeriodClosingAccountBalance {
  final AccountingAccount account;
  final double balance;

  const PeriodClosingAccountBalance({
    required this.account,
    required this.balance,
  });

  double get absoluteBalance => balance.abs();
}

class PeriodClosingEntryPreview {
  final String periodLabel;
  final DateTime closingDate;
  final AccountingAccount? retainedEarningsAccount;
  final List<PeriodClosingAccountBalance> revenueBalances;
  final List<PeriodClosingAccountBalance> expenseBalances;
  final JournalDraft? draft;
  final List<String> warnings;
  final double tolerance;

  const PeriodClosingEntryPreview({
    required this.periodLabel,
    required this.closingDate,
    required this.retainedEarningsAccount,
    required this.revenueBalances,
    required this.expenseBalances,
    required this.draft,
    this.warnings = const [],
    this.tolerance = 0.01,
  });

  double get totalRevenue {
    return revenueBalances.fold(0, (sum, item) => sum + item.balance);
  }

  double get totalExpenses {
    return expenseBalances.fold(0, (sum, item) => sum + item.balance);
  }

  double get netIncome => totalRevenue - totalExpenses;

  bool get hasNominalActivity {
    return revenueBalances.isNotEmpty || expenseBalances.isNotEmpty;
  }

  bool get canPost => draft != null && warnings.isEmpty && isBalanced;

  bool get isBalanced {
    final draft = this.draft;
    if (draft == null) {
      return false;
    }
    return draft.difference.abs() <= tolerance;
  }
}

import 'accounting_account.dart';

class PayablePostingAccounts {
  final AccountingAccount cash;
  final AccountingAccount accountsPayable;
  final AccountingAccount defaultExpense;

  const PayablePostingAccounts({
    required this.cash,
    required this.accountsPayable,
    required this.defaultExpense,
  });
}

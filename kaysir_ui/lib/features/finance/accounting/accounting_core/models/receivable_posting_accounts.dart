import 'accounting_account.dart';

class ReceivablePostingAccounts {
  final AccountingAccount accountsReceivable;
  final AccountingAccount salesRevenue;
  final AccountingAccount cash;

  const ReceivablePostingAccounts({
    required this.accountsReceivable,
    required this.salesRevenue,
    required this.cash,
  });
}

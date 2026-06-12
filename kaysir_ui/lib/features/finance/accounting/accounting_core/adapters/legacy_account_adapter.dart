import '../../models/account.dart';
import '../models/accounting_account.dart';

extension LegacyAccountAdapter on Account {
  AccountingAccount toAccountingAccount() {
    return AccountingAccount(
      id: id,
      code: code,
      name: name,
      type: type.toAccountingAccountType(),
    );
  }
}

extension LegacyAccountTypeAdapter on AccountType {
  AccountingAccountType toAccountingAccountType() {
    switch (this) {
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
}

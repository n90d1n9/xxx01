import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/account.dart';
import '../../models/account_entry.dart';

final currentEntryProvider = StateProvider<AccountingEntry>((ref) {
  return AccountingEntry(
    date: DateTime.now(),
    description: '',
    referenceNumber: '',
    lines: [],
  );
});

final accountsProvider = Provider<List<Account>>((ref) {
  // In a real app, this would come from a repository or API
  return [
    Account(id: '1', name: 'Cash', code: '1000', type: AccountType.asset),
    Account(
      id: '2',
      name: 'Accounts Receivable',
      code: '1100',
      type: AccountType.asset,
    ),
    Account(id: '3', name: 'Inventory', code: '1200', type: AccountType.asset),
    Account(
      id: '4',
      name: 'Accounts Payable',
      code: '2000',
      type: AccountType.liability,
    ),
    Account(
      id: '5',
      name: 'Notes Payable',
      code: '2100',
      type: AccountType.liability,
    ),
    Account(
      id: '6',
      name: 'Retained Earnings',
      code: '3000',
      type: AccountType.equity,
    ),
    Account(
      id: '7',
      name: 'Sales Revenue',
      code: '4000',
      type: AccountType.revenue,
    ),
    Account(
      id: '11',
      name: 'Bank Interest Income',
      code: '4300',
      type: AccountType.revenue,
    ),
    Account(
      id: '8',
      name: 'Rent Expense',
      code: '5000',
      type: AccountType.expense,
    ),
    Account(
      id: '9',
      name: 'Utilities Expense',
      code: '5100',
      type: AccountType.expense,
    ),
    Account(
      id: '10',
      name: 'Salary Expense',
      code: '5200',
      type: AccountType.expense,
    ),
    Account(
      id: '12',
      name: 'Bank Charges Expense',
      code: '5300',
      type: AccountType.expense,
    ),
  ];
});

final entryHistoryProvider = StateProvider<List<AccountingEntry>>((ref) {
  // In a real app, this would come from a repository or API
  return [];
});

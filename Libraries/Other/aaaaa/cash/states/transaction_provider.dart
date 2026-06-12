import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/transaction.dart';

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
      return TransactionNotifier();
    });

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier()
    : super([
        // Sample data
        Transaction(
          id: '1',
          description: 'Product Sales',
          amount: 5000,
          date: DateTime.now().subtract(const Duration(days: 15)),
          type: TransactionType.income,
          category: TransactionCategory.sales,
        ),
        Transaction(
          id: '2',
          description: 'Consulting Services',
          amount: 3500,
          date: DateTime.now().subtract(const Duration(days: 10)),
          type: TransactionType.income,
          category: TransactionCategory.services,
        ),
        Transaction(
          id: '3',
          description: 'Office Rent',
          amount: 1200,
          date: DateTime.now().subtract(const Duration(days: 5)),
          type: TransactionType.expense,
          category: TransactionCategory.rent,
        ),
        Transaction(
          id: '4',
          description: 'Salaries',
          amount: 4800,
          date: DateTime.now().subtract(const Duration(days: 2)),
          type: TransactionType.expense,
          category: TransactionCategory.wages,
        ),
        Transaction(
          id: '5',
          description: 'Marketing Campaign',
          amount: 800,
          date: DateTime.now().subtract(const Duration(days: 1)),
          type: TransactionType.expense,
          category: TransactionCategory.marketing,
        ),
      ]);

  void addTransaction(Transaction transaction) {
    state = [...state, transaction];
  }

  void updateTransaction(String id, Transaction updatedTransaction) {
    state = [
      for (final transaction in state)
        if (transaction.id == id) updatedTransaction else transaction,
    ];
  }

  void deleteTransaction(String id) {
    state = state.where((transaction) => transaction.id != id).toList();
  }
}

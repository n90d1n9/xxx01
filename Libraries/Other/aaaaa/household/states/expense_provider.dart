import 'package:flutter_riverpod/legacy.dart';

import '../models/expense.dart';
import '../models/payment.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>(
  (ref) {
    return ExpensesNotifier(ref.watch(storageProvider));
  },
);

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  final StorageService storage;

  ExpensesNotifier(this.storage) : super([]) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    state = await storage.loadExpenses();
  }

  void addExpense(
    String category,
    double amount,
    String description,
    PaymentMethod method,
    DateTime date,
  ) {
    state = [
      ...state,
      Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        amount: amount,
        description: description,
        paymentMethod: method,
        date: date,
      ),
    ];
  }

  Future<void> deleteExpense(String id) async {
    state = state.where((e) => e.id != id).toList();
    await storage.saveExpenses(state);
  }
}

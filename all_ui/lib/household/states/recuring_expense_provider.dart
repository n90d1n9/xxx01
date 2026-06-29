import 'package:flutter_riverpod/legacy.dart';

import '../models/recurring_expense.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

final recurringExpensesProvider =
    StateNotifierProvider<RecurringExpensesNotifier, List<RecurringExpense>>((
      ref,
    ) {
      return RecurringExpensesNotifier(ref.watch(storageProvider));
    });

class RecurringExpensesNotifier extends StateNotifier<List<RecurringExpense>> {
  final StorageService storage;

  RecurringExpensesNotifier(this.storage) : super([]) {
    _loadRecurring();
  }

  Future<void> _loadRecurring() async {
    state = await storage.loadRecurringExpenses();
  }

  Future<void> addRecurring(
    String name,
    double amount,
    String category,
    RecurrenceType recurrence,
  ) async {
    state = [
      ...state,
      RecurringExpense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        amount: amount,
        category: category,
        recurrence: recurrence,
        startDate: DateTime.now(),
      ),
    ];
    await storage.saveRecurringExpenses(state);
  }

  Future<void> toggleActive(String id) async {
    state = [
      for (final expense in state)
        if (expense.id == id)
          expense.copyWith(isActive: !expense.isActive)
        else
          expense,
    ];
    await storage.saveRecurringExpenses(state);
  }

  Future<void> deleteRecurring(String id) async {
    state = state.where((e) => e.id != id).toList();
    await storage.saveRecurringExpenses(state);
  }
}

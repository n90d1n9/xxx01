import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/budget_category.dart';
import '../services/storage_service.dart';
import 'expense_provider.dart';
import 'shopping_list_provider.dart';
import 'storage_provider.dart';

final totalBudgetProvider = Provider<double>((ref) {
  final budget = ref.watch(budgetProvider);
  return budget.fold(0.0, (sum, cat) => sum + cat.budget);
});

final totalSpentProvider = Provider<double>((ref) {
  final budget = ref.watch(budgetProvider);
  return budget.fold(0.0, (sum, cat) => sum + cat.spent);
});

final shoppingTotalProvider = Provider<double>((ref) {
  final items = ref.watch(shoppingListProvider);
  return items
      .where((item) => !item.purchased)
      .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
});

final monthlyExpensesProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider);
  final now = DateTime.now();
  return expenses
      .where((e) => e.date.month == now.month && e.date.year == now.year)
      .fold(0.0, (sum, e) => sum + e.amount);
});

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, List<BudgetCategory>>((ref) {
      return BudgetNotifier(ref.watch(storageProvider));
    });

class BudgetNotifier extends StateNotifier<List<BudgetCategory>> {
  final StorageService storage;

  BudgetNotifier(this.storage) : super([]) {
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    state = await storage.loadBudget();
    // Initialize default categories if empty
    if (state.isEmpty) {
      await _initializeDefaultCategories();
    }
  }

  Future<void> _initializeDefaultCategories() async {
    final now = DateTime.now();
    final defaultCategories = [
      BudgetCategory(
        name: 'Groceries',
        budget: 0,
        spent: 0,
        icon: Icons.shopping_basket,
        color: Colors.green,
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        period: BudgetPeriod.monthly,
      ),
      BudgetCategory(
        name: 'Utilities',
        budget: 0,
        spent: 0,
        icon: Icons.electrical_services,
        color: Colors.blue,
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        period: BudgetPeriod.monthly,
      ),
      // Add more default categories...
    ];

    state = defaultCategories;
    await storage.saveBudget(state);
  }

  Future<void> updateBudget(
    String name,
    double budget,
    BudgetPeriod period,
    DateTime startDate,
    DateTime endDate,
  ) async {
    state = [
      for (final cat in state)
        if (cat.name == name)
          cat.copyWith(
            budget: budget,
            period: period,
            startDate: startDate,
            endDate: endDate,
          )
        else
          cat,
    ];
    await storage.saveBudget(state);
  }

  Future<void> resetSpending() async {
    state = [for (final cat in state) cat.copyWith(spent: 0)];
    await storage.saveBudget(state);
  }

  Future<void> addExpense(
    String category,
    double amount,
    String description,
    DateTime date,
  ) async {
    state = [
      for (final cat in state)
        if (cat.name == category &&
            _isDateInRange(date, cat.startDate, cat.endDate))
          cat.copyWith(spent: cat.spent + amount)
        else
          cat,
    ];
    await storage.saveBudget(state);
  }

  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }

  // Get current active budgets
  List<BudgetCategory> getActiveBudgets() {
    final now = DateTime.now();
    return state.where((cat) => cat.isActive).toList();
  }

  // Get budgets for specific date
  List<BudgetCategory> getBudgetsForDate(DateTime date) {
    return state
        .where((cat) => _isDateInRange(date, cat.startDate, cat.endDate))
        .toList();
  }

  // Roll over to next period
  Future<void> rolloverToNextPeriod(String categoryName) async {
    state = [
      for (final cat in state)
        if (cat.name == categoryName) cat.createNextPeriod() else cat,
    ];
    await storage.saveBudget(state);
  }
}

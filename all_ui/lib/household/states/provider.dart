// New providers for date-based queries
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/budget_category.dart';
import '../models/budget_summary.dart';
import '../models/expense.dart';
import '../models/shopping_item.dart';
import 'budget_provider.dart';
import 'expense_provider.dart';
import 'shopping_list_provider.dart';

// Required providers
final expensesByDateProvider = Provider.family<List<Expense>, DateTime>((
  ref,
  date,
) {
  final expenses = ref.watch(expensesProvider);
  return expenses
      .where(
        (expense) =>
            expense.date.year == date.year &&
            expense.date.month == date.month &&
            expense.date.day == date.day,
      )
      .toList();
});

final shoppingByDateProvider = Provider.family<List<ShoppingItem>, DateTime>((
  ref,
  date,
) {
  final shopping = ref.watch(shoppingListProvider);
  return shopping
      .where(
        (item) =>
            item.addedDate.year == date.year &&
            item.addedDate.month == date.month &&
            item.addedDate.day == date.day,
      )
      .toList();
});

final monthlyBudgetSummaryProvider = Provider.family<BudgetSummary, DateTime>((
  ref,
  date,
) {
  final budgets = ref.watch(budgetProvider);
  final monthlyBudgets =
      budgets
          .where(
            (budget) =>
                budget.period == BudgetPeriod.monthly &&
                budget.startDate.year == date.year &&
                budget.startDate.month == date.month,
          )
          .toList();

  final totalBudget = monthlyBudgets.fold(
    0.0,
    (sum, budget) => sum + budget.budget,
  );
  final totalSpent = monthlyBudgets.fold(
    0.0,
    (sum, budget) => sum + budget.spent,
  );

  return BudgetSummary(
    totalBudget: totalBudget,
    totalSpent: totalSpent,
    remaining: totalBudget - totalSpent,
  );
});

// Storage Service
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget_category.dart';
import '../models/daily_task.dart';
import '../models/expense.dart';
import '../models/recurring_expense.dart';
import '../models/shopping_item.dart';

class StorageService {
  static const String tasksKey = 'daily_tasks';
  static const String shoppingKey = 'shopping_list';
  static const String budgetKey = 'budget_categories';
  static const String expensesKey = 'expenses';
  static const String recurringKey = 'recurring_expenses';

  Future<void> saveTasks(List<DailyTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final json = tasks.map((t) => t.toJson()).toList();
    await prefs.setString(tasksKey, jsonEncode(json));
  }

  Future<List<DailyTask>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(tasksKey);
    if (data == null) return [];
    final List<dynamic> json = jsonDecode(data);
    return json.map((j) => DailyTask.fromJson(j)).toList();
  }

  Future<void> saveShoppingList(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final json = items.map((i) => i.toJson()).toList();
    await prefs.setString(shoppingKey, jsonEncode(json));
  }

  Future<List<ShoppingItem>> loadShoppingList() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(shoppingKey);
    if (data == null) return [];
    final List<dynamic> json = jsonDecode(data);
    return json.map((j) => ShoppingItem.fromJson(j)).toList();
  }

  Future<void> saveBudget(List<BudgetCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final json = categories.map((c) => c.toJson()).toList();
    await prefs.setString(budgetKey, jsonEncode(json));
  }

  Future<List<BudgetCategory>> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(budgetKey);
    if (data == null) return _getDefaultBudget();
    final List<dynamic> json = jsonDecode(data);
    return json.map((j) => BudgetCategory.fromJson(j)).toList();
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final json = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(expensesKey, jsonEncode(json));
  }

  Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(expensesKey);
    if (data == null) return [];
    final List<dynamic> json = jsonDecode(data);
    return json.map((j) => Expense.fromJson(j)).toList();
  }

  Future<void> saveRecurringExpenses(List<RecurringExpense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final json = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(recurringKey, jsonEncode(json));
  }

  Future<List<RecurringExpense>> loadRecurringExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(recurringKey);
    if (data == null) return [];
    final List<dynamic> json = jsonDecode(data);
    return json.map((j) => RecurringExpense.fromJson(j)).toList();
  }

  static List<BudgetCategory> _getDefaultBudget() => [
    BudgetCategory(
      name: 'Groceries',
      budget: 500,
      spent: 0,
      icon: Icons.shopping_basket,
      color: Colors.green,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      period: BudgetPeriod.monthly,
    ),
    BudgetCategory(
      name: 'Utilities',
      budget: 300,
      spent: 0,
      icon: Icons.electrical_services,
      color: Colors.blue,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      period: BudgetPeriod.monthly,
    ),
    BudgetCategory(
      name: 'Entertainment',
      budget: 200,
      spent: 0,
      icon: Icons.movie,
      color: Colors.purple,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      period: BudgetPeriod.monthly,
    ),
    BudgetCategory(
      name: 'Transportation',
      budget: 150,
      spent: 0,
      icon: Icons.directions_car,
      color: Colors.orange,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      period: BudgetPeriod.monthly,
    ),
    BudgetCategory(
      name: 'Healthcare',
      budget: 200,
      spent: 0,
      icon: Icons.medical_services,
      color: Colors.red,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      period: BudgetPeriod.monthly,
    ),
    BudgetCategory(
      name: 'Education',
      budget: 150,
      spent: 0,
      icon: Icons.school,
      color: Colors.indigo,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      period: BudgetPeriod.monthly,
    ),
  ];
}

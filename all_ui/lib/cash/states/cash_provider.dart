import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/transaction.dart';
import 'transaction_provider.dart';

final selectedDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month, 1),
    end: DateTime(now.year, now.month + 1, 0),
  );
});

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);

  return transactions.where((transaction) {
    return transaction.date.isAfter(dateRange.start) &&
        transaction.date.isBefore(dateRange.end.add(const Duration(days: 1)));
  }).toList();
});

final cashFlowReportProvider = Provider<Map<String, dynamic>>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);

  double totalIncome = 0;
  double totalExpense = 0;

  final Map<DateTime, double> dailyCashFlow = {};
  final Map<TransactionCategory, double> incomeByCategory = {};
  final Map<TransactionCategory, double> expenseByCategory = {};

  for (final transaction in transactions) {
    // Round date to day for daily grouping
    final day = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );

    if (transaction.type == TransactionType.income) {
      totalIncome += transaction.amount;
      incomeByCategory[transaction.category] =
          (incomeByCategory[transaction.category] ?? 0) + transaction.amount;

      dailyCashFlow[day] = (dailyCashFlow[day] ?? 0) + transaction.amount;
    } else {
      totalExpense += transaction.amount;
      expenseByCategory[transaction.category] =
          (expenseByCategory[transaction.category] ?? 0) + transaction.amount;

      dailyCashFlow[day] = (dailyCashFlow[day] ?? 0) - transaction.amount;
    }
  }

  // Calculate cumulative cash flow
  final List<MapEntry<DateTime, double>> sortedDailyCashFlow =
      dailyCashFlow.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

  double cumulativeBalance = 0;
  final Map<DateTime, double> cumulativeCashFlow = {};

  for (final entry in sortedDailyCashFlow) {
    cumulativeBalance += entry.value;
    cumulativeCashFlow[entry.key] = cumulativeBalance;
  }

  return {
    'totalIncome': totalIncome,
    'totalExpense': totalExpense,
    'netCashFlow': totalIncome - totalExpense,
    'dailyCashFlow': dailyCashFlow,
    'cumulativeCashFlow': cumulativeCashFlow,
    'incomeByCategory': incomeByCategory,
    'expenseByCategory': expenseByCategory,
  };
});

final profitLossReportProvider = Provider<Map<String, dynamic>>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);

  double revenue = 0;
  double costOfGoodsSold = 0;
  double operatingExpenses = 0;

  final Map<TransactionCategory, double> revenueByCategory = {};
  final Map<TransactionCategory, double> expensesByCategory = {};

  for (final transaction in transactions) {
    if (transaction.type == TransactionType.income) {
      revenue += transaction.amount;
      revenueByCategory[transaction.category] =
          (revenueByCategory[transaction.category] ?? 0) + transaction.amount;
    } else {
      if (transaction.category == TransactionCategory.costOfGoodsSold) {
        costOfGoodsSold += transaction.amount;
      } else {
        operatingExpenses += transaction.amount;
      }

      expensesByCategory[transaction.category] =
          (expensesByCategory[transaction.category] ?? 0) + transaction.amount;
    }
  }

  final grossProfit = revenue - costOfGoodsSold;
  final netProfit = grossProfit - operatingExpenses;

  return {
    'revenue': revenue,
    'costOfGoodsSold': costOfGoodsSold,
    'grossProfit': grossProfit,
    'grossProfitMargin': revenue > 0 ? (grossProfit / revenue) * 100 : 0,
    'operatingExpenses': operatingExpenses,
    'netProfit': netProfit,
    'netProfitMargin': revenue > 0 ? (netProfit / revenue) * 100 : 0,
    'revenueByCategory': revenueByCategory,
    'expensesByCategory': expensesByCategory,
  };
});

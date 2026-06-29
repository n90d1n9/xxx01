// Data Repository
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../fin_dummy.dart';
import '../models/financial_entry.dart';

class FinancialRepository {
  List<FinancialEntry> getEntries() {
    // This would typically come from a database or API
    return financeDummy;
  }
}

// Providers
final financialRepositoryProvider = Provider<FinancialRepository>((ref) {
  return FinancialRepository();
});

final financialEntriesProvider = Provider<List<FinancialEntry>>((ref) {
  final repository = ref.watch(financialRepositoryProvider);
  return repository.getEntries();
});

// Controllers
class FinancialStatementsController {
  final List<FinancialEntry> entries;

  FinancialStatementsController(this.entries);

  // Profit and Loss Statement
  Map<String, dynamic> generateProfitAndLossStatement() {
    final incomeEntries =
        entries.where((entry) => entry.type == 'income').toList();
    final expenseEntries =
        entries.where((entry) => entry.type == 'expense').toList();

    // Group by category
    Map<String, double> incomeByCategory = {};
    for (var entry in incomeEntries) {
      incomeByCategory[entry.category] =
          (incomeByCategory[entry.category] ?? 0) + entry.amount;
    }

    Map<String, double> expensesByCategory = {};
    for (var entry in expenseEntries) {
      expensesByCategory[entry.category] =
          (expensesByCategory[entry.category] ?? 0) + entry.amount;
    }

    // Calculate totals
    double totalIncome = incomeEntries.fold(
      0,
      (sum, entry) => sum + entry.amount,
    );
    double totalExpenses = expenseEntries.fold(
      0,
      (sum, entry) => sum + entry.amount,
    );
    double netIncome = totalIncome - totalExpenses;

    return {
      'incomeByCategory': incomeByCategory,
      'expensesByCategory': expensesByCategory,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netIncome': netIncome,
    };
  }

  // Balance Sheet
  Map<String, dynamic> generateBalanceSheet() {
    final assetEntries =
        entries.where((entry) => entry.type == 'asset').toList();
    final liabilityEntries =
        entries.where((entry) => entry.type == 'liability').toList();

    // Group by category
    Map<String, double> assetsByCategory = {};
    for (var entry in assetEntries) {
      assetsByCategory[entry.category] =
          (assetsByCategory[entry.category] ?? 0) + entry.amount;
    }

    Map<String, double> liabilitiesByCategory = {};
    for (var entry in liabilityEntries) {
      liabilitiesByCategory[entry.category] =
          (liabilitiesByCategory[entry.category] ?? 0) + entry.amount;
    }

    // Calculate totals
    double totalAssets = assetEntries.fold(
      0,
      (sum, entry) => sum + entry.amount,
    );
    double totalLiabilities = liabilityEntries.fold(
      0,
      (sum, entry) => sum + entry.amount,
    );
    double equity = totalAssets - totalLiabilities;

    return {
      'assetsByCategory': assetsByCategory,
      'liabilitiesByCategory': liabilitiesByCategory,
      'totalAssets': totalAssets,
      'totalLiabilities': totalLiabilities,
      'equity': equity,
    };
  }

  // Cash Flow Statement - Simplified approach
  Map<String, dynamic> generateCashFlowStatement() {
    // For a real app, you would need more data about cash movements
    final incomeEntries =
        entries.where((entry) => entry.type == 'income').toList();
    final expenseEntries =
        entries.where((entry) => entry.type == 'expense').toList();

    double operatingCashFlow =
        incomeEntries.fold(0.0, (sum, entry) => (sum + entry.amount)) -
        expenseEntries.fold(0, (sum, entry) => sum + entry.amount);

    // These would normally be based on actual data
    double investingCashFlow = -35000; // Example value: equipment purchases
    double financingCashFlow =
        10000; // Example value: loan proceeds - repayments

    double netCashFlow =
        operatingCashFlow + investingCashFlow + financingCashFlow;
    double beginningCashBalance = 65000; // Example starting balance
    double endingCashBalance = beginningCashBalance + netCashFlow;

    return {
      'operatingCashFlow': operatingCashFlow,
      'investingCashFlow': investingCashFlow,
      'financingCashFlow': financingCashFlow,
      'netCashFlow': netCashFlow,
      'beginningCashBalance': beginningCashBalance,
      'endingCashBalance': endingCashBalance,
    };
  }
}

final financialStatementsControllerProvider =
    Provider<FinancialStatementsController>((ref) {
      final entries = ref.watch(financialEntriesProvider);
      return FinancialStatementsController(entries);
    });

// Current statement type provider
final selectedStatementTypeProvider = StateProvider<String>((ref) {
  return 'profitAndLoss'; // Default selection
});

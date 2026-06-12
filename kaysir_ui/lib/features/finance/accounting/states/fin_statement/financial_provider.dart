// Financial statement providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../helper/format_currency.dart';
import '../../models/financial_entry.dart';
import '../../services/financial_statement_ledger_mapper.dart';
import '../accounting_core_provider.dart';
import '../gl/ledger_provider.dart';

final financialEntriesProvider = Provider<List<FinancialEntry>>((ref) {
  final mapper = ref.watch(financialStatementLedgerMapperProvider);
  return mapper.toFinancialEntries(
    ref.watch(combinedLedgerProvider),
    ref.watch(accountingChartProvider),
  );
});

final financialStatementLedgerMapperProvider =
    Provider<FinancialStatementLedgerMapper>((ref) {
      return const FinancialStatementLedgerMapper();
    });

enum FinancialPeriodPreset { all, dataMonth, dataQuarter, dataYear, custom }

class FinancialStatementPeriod {
  final FinancialPeriodPreset preset;
  final DateTime? startDate;
  final DateTime? endDate;

  const FinancialStatementPeriod({
    required this.preset,
    this.startDate,
    this.endDate,
  });

  const FinancialStatementPeriod.all()
    : preset = FinancialPeriodPreset.all,
      startDate = null,
      endDate = null;

  bool contains(DateTime date) {
    final startsAfter = startDate == null || !date.isBefore(startDate!);
    final endsBefore =
        endDate == null || date.isBefore(endDate!.add(const Duration(days: 1)));
    return startsAfter && endsBefore;
  }

  String get label {
    if (startDate == null || endDate == null) {
      return 'All periods';
    }

    final formatter = DateFormat('MMM d, yyyy');
    return '${formatter.format(startDate!)} - ${formatter.format(endDate!)}';
  }

  String get asOfLabel {
    final formatter = DateFormat('MMM d, yyyy');
    return endDate == null
        ? 'latest available period'
        : formatter.format(endDate!);
  }
}

final selectedFinancialPeriodProvider = StateProvider<FinancialStatementPeriod>(
  (ref) => const FinancialStatementPeriod.all(),
);

// Controllers
class FinancialStatementsController {
  final List<FinancialEntry> allEntries;
  final FinancialStatementPeriod period;

  FinancialStatementsController(this.allEntries, this.period);

  List<FinancialEntry> get entries =>
      allEntries.where((entry) => period.contains(entry.date)).toList();

  String get periodLabel => period.label;

  DateTime get latestEntryDate {
    if (allEntries.isEmpty) {
      return DateTime.now();
    }
    return allEntries
        .map((entry) => entry.date)
        .reduce((value, element) => value.isAfter(element) ? value : element);
  }

  DateTime get earliestEntryDate {
    if (allEntries.isEmpty) {
      return DateTime.now();
    }
    return allEntries
        .map((entry) => entry.date)
        .reduce((value, element) => value.isBefore(element) ? value : element);
  }

  FinancialStatementPeriod periodForPreset(FinancialPeriodPreset preset) {
    final anchor = latestEntryDate;

    switch (preset) {
      case FinancialPeriodPreset.all:
        return const FinancialStatementPeriod.all();
      case FinancialPeriodPreset.dataMonth:
        return FinancialStatementPeriod(
          preset: preset,
          startDate: DateTime(anchor.year, anchor.month),
          endDate: DateTime(anchor.year, anchor.month + 1, 0),
        );
      case FinancialPeriodPreset.dataQuarter:
        final firstMonth = ((anchor.month - 1) ~/ 3) * 3 + 1;
        return FinancialStatementPeriod(
          preset: preset,
          startDate: DateTime(anchor.year, firstMonth),
          endDate: DateTime(anchor.year, firstMonth + 3, 0),
        );
      case FinancialPeriodPreset.dataYear:
        return FinancialStatementPeriod(
          preset: preset,
          startDate: DateTime(anchor.year),
          endDate: DateTime(anchor.year, 12, 31),
        );
      case FinancialPeriodPreset.custom:
        return FinancialStatementPeriod(
          preset: preset,
          startDate: period.startDate,
          endDate: period.endDate,
        );
    }
  }

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
    final previousNetIncome = _previousPeriodNetIncome();

    return {
      'incomeByCategory': incomeByCategory,
      'expensesByCategory': expensesByCategory,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netIncome': netIncome,
      'periodLabel': periodLabel,
      'entryCount': incomeEntries.length + expenseEntries.length,
      'profitMargin': totalIncome == 0 ? 0.0 : netIncome / totalIncome,
      'largestExpenseCategory': _largestCategory(expensesByCategory),
      'previousNetIncome': previousNetIncome,
      'netIncomeChange':
          previousNetIncome == null ? null : netIncome - previousNetIncome,
    };
  }

  // Balance Sheet
  Map<String, dynamic> generateBalanceSheet() {
    final statementEntries =
        period.endDate == null
            ? allEntries
            : allEntries
                .where((entry) => !entry.date.isAfter(period.endDate!))
                .toList();
    final assetEntries =
        statementEntries.where((entry) => entry.type == 'asset').toList();
    final liabilityEntries =
        statementEntries.where((entry) => entry.type == 'liability').toList();

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
      'periodLabel': periodLabel,
      'asOfLabel': period.asOfLabel,
      'debtToAssetRatio':
          totalAssets == 0 ? 0.0 : totalLiabilities / totalAssets,
      'workingCapital':
          (assetsByCategory['Current Assets'] ?? 0) -
          (liabilitiesByCategory['Current Liabilities'] ?? 0),
    };
  }

  // Cash Flow Statement - Simplified approach
  Map<String, dynamic> generateCashFlowStatement() {
    final cashEntries = entries.where(_isCashEntry).toList();
    final operatingCashFlow = _cashFlowByBucket(
      cashEntries,
      _CashFlowBucket.operating,
    );
    final investingCashFlow = _cashFlowByBucket(
      cashEntries,
      _CashFlowBucket.investing,
    );
    final financingCashFlow = _cashFlowByBucket(
      cashEntries,
      _CashFlowBucket.financing,
    );

    final netCashFlow =
        operatingCashFlow + investingCashFlow + financingCashFlow;
    double beginningCashBalance = _cashBalanceBeforePeriod();
    double endingCashBalance = beginningCashBalance + netCashFlow;

    return {
      'operatingCashFlow': operatingCashFlow,
      'investingCashFlow': investingCashFlow,
      'financingCashFlow': financingCashFlow,
      'netCashFlow': netCashFlow,
      'beginningCashBalance': beginningCashBalance,
      'endingCashBalance': endingCashBalance,
      'periodLabel': periodLabel,
      'cashRunwayMonths':
          totalMonthlyBurn(operatingCashFlow) == 0
              ? null
              : endingCashBalance / totalMonthlyBurn(operatingCashFlow),
    };
  }

  List<String> generateReviewNotes(String type) {
    switch (type) {
      case 'profitAndLoss':
        final data = generateProfitAndLossStatement();
        final notes = <String>[];
        final margin = data['profitMargin'] as double;
        final largestExpense = data['largestExpenseCategory'] as String?;
        notes.add(
          margin >= 0.2
              ? 'Margin is healthy for the selected period.'
              : 'Margin is thin; review revenue mix and variable costs.',
        );
        if (largestExpense != null) {
          notes.add('Largest expense category: $largestExpense.');
        }
        if (data['netIncomeChange'] != null) {
          notes.add(
            'Net income moved ${formatCurrency((data['netIncomeChange'] as double).abs())} versus the previous comparable period.',
          );
        }
        return notes;
      case 'balanceSheet':
        final data = generateBalanceSheet();
        final ratio = data['debtToAssetRatio'] as double;
        return [
          ratio <= 0.5
              ? 'Leverage is within a conservative range.'
              : 'Debt-to-asset ratio is elevated; monitor obligations.',
          'Working capital: ${formatCurrency(data['workingCapital'] as double)}.',
        ];
      case 'cashFlow':
        final data = generateCashFlowStatement();
        return [
          (data['netCashFlow'] as double) >= 0
              ? 'Cash generation is positive for this period.'
              : 'Cash generation is negative; review operating spend.',
          'Ending cash: ${formatCurrency(data['endingCashBalance'] as double)}.',
        ];
      default:
        return const [];
    }
  }

  double totalMonthlyBurn(double operatingCashFlow) {
    if (operatingCashFlow >= 0) {
      return 0;
    }
    final days =
        period.startDate == null || period.endDate == null
            ? 30
            : period.endDate!.difference(period.startDate!).inDays + 1;
    return operatingCashFlow.abs() / (days / 30);
  }

  String? _largestCategory(Map<String, double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.entries
        .reduce(
          (value, element) => value.value >= element.value ? value : element,
        )
        .key;
  }

  double? _previousPeriodNetIncome() {
    if (period.startDate == null || period.endDate == null) {
      return null;
    }

    final periodDays = period.endDate!.difference(period.startDate!).inDays + 1;
    final previousEnd = period.startDate!.subtract(const Duration(days: 1));
    final previousStart = previousEnd.subtract(Duration(days: periodDays - 1));
    final previousEntries =
        allEntries.where((entry) {
          return !entry.date.isBefore(previousStart) &&
              !entry.date.isAfter(previousEnd);
        }).toList();

    if (previousEntries.isEmpty) {
      return null;
    }

    final previousIncome = previousEntries
        .where((entry) => entry.type == 'income')
        .fold(0.0, (sum, entry) => sum + entry.amount);
    final previousExpenses = previousEntries
        .where((entry) => entry.type == 'expense')
        .fold(0.0, (sum, entry) => sum + entry.amount);
    return previousIncome - previousExpenses;
  }

  double _cashBalanceBeforePeriod() {
    if (period.startDate == null) {
      return 0;
    }

    return allEntries
        .where(
          (entry) =>
              _isCashEntry(entry) && entry.date.isBefore(period.startDate!),
        )
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  double _cashFlowByBucket(
    List<FinancialEntry> cashEntries,
    _CashFlowBucket bucket,
  ) {
    return cashEntries
        .where((entry) => _cashFlowBucket(entry) == bucket)
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  bool _isCashEntry(FinancialEntry entry) {
    return entry.type == 'asset' && entry.name.toLowerCase() == 'cash';
  }

  _CashFlowBucket _cashFlowBucket(FinancialEntry entry) {
    final label =
        '${entry.name} ${entry.category} ${entry.sourceCategory ?? ''}'
            .toLowerCase();
    if (label.contains('loan') ||
        label.contains('capital') ||
        label.contains('equity') ||
        label.contains('financing')) {
      return _CashFlowBucket.financing;
    }
    if (label.contains('equipment') ||
        label.contains('fixed') ||
        label.contains('invest')) {
      return _CashFlowBucket.investing;
    }
    return _CashFlowBucket.operating;
  }
}

enum _CashFlowBucket { operating, investing, financing }

final financialStatementsControllerProvider =
    Provider<FinancialStatementsController>((ref) {
      final entries = ref.watch(financialEntriesProvider);
      final period = ref.watch(selectedFinancialPeriodProvider);
      return FinancialStatementsController(entries, period);
    });

// Current statement type provider
final selectedStatementTypeProvider = StateProvider<String>((ref) {
  return 'profitAndLoss'; // Default selection
});

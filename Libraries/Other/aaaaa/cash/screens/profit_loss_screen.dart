import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../states/cash_provider.dart';

class ProfitLossScreen extends ConsumerWidget {
  const ProfitLossScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateRange = ref.watch(selectedDateRangeProvider);
    final profitLossReport = ref.watch(profitLossReportProvider);

    final dateFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final percentFormat = NumberFormat.percentPattern();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss Statement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date Range: ${dateFormat.format(dateRange.start)} - ${dateFormat.format(dateRange.end)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Revenue',
                      currencyFormat.format(profitLossReport['revenue']),
                      Colors.black,
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Cost of Goods Sold',
                      '(${currencyFormat.format(profitLossReport['costOfGoodsSold'])})',
                      Colors.black,
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      'Gross Profit',
                      currencyFormat.format(profitLossReport['grossProfit']),
                      profitLossReport['grossProfit'] >= 0
                          ? Colors.green
                          : Colors.red,
                      isBold: true,
                    ),
                    const SizedBox(height: 4),
                    _buildSummaryRow(
                      'Gross Profit Margin',
                      '${profitLossReport['grossProfitMargin'].toStringAsFixed(1)}%',
                      profitLossReport['grossProfitMargin'] >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      'Operating Expenses',
                      '(${currencyFormat.format(profitLossReport['operatingExpenses'])})',
                      Colors.black,
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      'Net Profit',
                      currencyFormat.format(profitLossReport['netProfit']),
                      profitLossReport['netProfit'] >= 0
                          ? Colors.green
                          : Colors.red,
                      isBold: true,
                    ),
                    const SizedBox(height: 4),
                    _buildSummaryRow(
                      'Net Profit Margin',
                      '${profitLossReport['netProfitMargin'].toStringAsFixed(1)}%',
                      profitLossReport['netProfitMargin'] >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Revenue Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCategoryBreakdown(
              context,
              profitLossReport['revenueByCategory']
                  as Map<TransactionCategory, double>,
              profitLossReport['revenue'] as double,
              Colors.blue,
              currencyFormat,
            ),
            const SizedBox(height: 24),
            const Text(
              'Expense Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCategoryBreakdown(
              context,
              profitLossReport['expensesByCategory']
                  as Map<TransactionCategory, double>,
              profitLossReport['operatingExpenses'] +
                  profitLossReport['costOfGoodsSold'],
              Colors.orange,
              currencyFormat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    Map<TransactionCategory, double> categoryData,
    double total,
    Color color,
    NumberFormat currencyFormat,
  ) {
    if (categoryData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data available for this period'),
        ),
      );
    }

    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: sortedCategories.map((entry) {
            final percentage = total > 0 ? (entry.value / total) * 100 : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getCategoryName(entry.key),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${currencyFormat.format(entry.value)} (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.sales:
        return 'Sales';
      case TransactionCategory.services:
        return 'Services';
      case TransactionCategory.investments:
        return 'Investments';
      case TransactionCategory.otherIncome:
        return 'Other Income';
      case TransactionCategory.costOfGoodsSold:
        return 'Cost of Goods Sold';
      case TransactionCategory.wages:
        return 'Wages & Salaries';
      case TransactionCategory.rent:
        return 'Rent';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.marketing:
        return 'Marketing';
      case TransactionCategory.supplies:
        return 'Supplies';
      case TransactionCategory.maintenance:
        return 'Maintenance';
      case TransactionCategory.insurance:
        return 'Insurance';
      case TransactionCategory.taxes:
        return 'Taxes';
      case TransactionCategory.otherExpense:
        return 'Other Expenses';
      default:
        return 'Unknown';
    }
  }

  Future<void> _selectDateRange(BuildContext context, WidgetRef ref) async {
    final currentRange = ref.read(selectedDateRangeProvider);
    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: currentRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      ref.read(selectedDateRangeProvider.notifier).state = newDateRange;
    }
  }
}

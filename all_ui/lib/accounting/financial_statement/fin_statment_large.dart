// Here's an enhanced version of the Financial Statements screens
// focusing on large screen layout and professional, trendy design

// Add these imports at the top of your file
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fin_statement.dart';
import 'states/financial_provider.dart'; // You'll need to add this package to pubspec.yaml

// Enhanced FinancialStatementsScreen with better large screen layout
class FinancialStatementsScreen extends ConsumerWidget {
  const FinancialStatementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedStatementTypeProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1A1A2E) : Colors.white;
    final accentColor =
        isDarkMode ? const Color(0xFF4ECCA3) : const Color(0xFF0072B5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: Text(
          'Financial Statements',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedType,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(selectedStatementTypeProvider.notifier).state =
                        value;
                  }
                },
                icon: Icon(Icons.arrow_drop_down, color: accentColor),
                items: [
                  dropdownItem(
                    'profitAndLoss',
                    'Profit & Loss',
                    accentColor,
                    isDarkMode,
                  ),
                  dropdownItem(
                    'balanceSheet',
                    'Balance Sheet',
                    accentColor,
                    isDarkMode,
                  ),
                  dropdownItem(
                    'cashFlow',
                    'Cash Flow',
                    accentColor,
                    isDarkMode,
                  ),
                ],
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1200) {
            // Extra large screen - side-by-side layout with summary
            return _buildExtraLargeScreenLayout(selectedType, ref, isDarkMode);
          } else if (constraints.maxWidth > 800) {
            // Large screen layout with enhanced padding and decorations
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildLargeScreenContent(selectedType, ref, isDarkMode),
            );
          } else {
            // Medium to small screen layout - simplified version
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSelectedStatement(selectedType, ref),
              ),
            );
          }
        },
      ),
    );
  }

  // Dropdown helper
  DropdownMenuItem<String> dropdownItem(
    String value,
    String text,
    Color accentColor,
    bool isDarkMode,
  ) {
    return DropdownMenuItem(
      value: value,
      child: Text(
        text,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Extra large screen layout with side panel for summary
  Widget _buildExtraLargeScreenLayout(
    String type,
    WidgetRef ref,
    bool isDarkMode,
  ) {
    final controller = ref.watch(financialStatementsControllerProvider);
    final Color bgColor = isDarkMode ? const Color(0xFF252538) : Colors.white;
    final Color cardColor =
        isDarkMode ? const Color(0xFF2C2C44) : Colors.grey.shade50;

    // Get data based on selected statement type
    Map<String, dynamic> data;
    switch (type) {
      case 'profitAndLoss':
        data = controller.generateProfitAndLossStatement();
        break;
      case 'balanceSheet':
        data = controller.generateBalanceSheet();
        break;
      case 'cashFlow':
        data = controller.generateCashFlowStatement();
        break;
      default:
        data = {};
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content (70%)
        Expanded(
          flex: 7,
          child: Container(
            padding: const EdgeInsets.all(32.0),
            color: bgColor,
            child: _buildLargeScreenContent(type, ref, isDarkMode),
          ),
        ),

        // Side panel (30%)
        Expanded(
          flex: 3,
          child: Container(
            color: cardColor,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Summary',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Summary section based on statement type
                _buildSummarySection(type, data, isDarkMode),

                const SizedBox(height: 32),

                // Chart visualization
                Expanded(child: _buildVisualization(type, data, isDarkMode)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Summary section based on statement type
  Widget _buildSummarySection(
    String type,
    Map<String, dynamic> data,
    bool isDarkMode,
  ) {
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color positiveColor =
        isDarkMode ? const Color(0xFF4ECCA3) : Colors.green.shade700;
    final Color negativeColor =
        isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;

    switch (type) {
      case 'profitAndLoss':
        final double netIncome = data['netIncome'];
        final double totalIncome = data['totalIncome'];
        final double totalExpenses = data['totalExpenses'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryTile(
              'Net Income',
              formatCurrency(netIncome),
              netIncome >= 0 ? positiveColor : negativeColor,
              isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildSummaryTile(
              'Total Revenue',
              formatCurrency(totalIncome),
              textColor,
              isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildSummaryTile(
              'Total Expenses',
              formatCurrency(totalExpenses),
              textColor,
              isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildSummaryTile(
              'Profit Margin',
              '${(netIncome / totalIncome * 100).toStringAsFixed(1)}%',
              netIncome >= 0 ? positiveColor : negativeColor,
              isDarkMode,
            ),
          ],
        );

      case 'balanceSheet':
        final double totalAssets = data['totalAssets'];
        final double totalLiabilities = data['totalLiabilities'];
        final double equity = data['equity'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryTile(
              'Total Assets',
              formatCurrency(totalAssets),
              textColor,
              isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildSummaryTile(
              'Total Liabilities',
              formatCurrency(totalLiabilities),
              textColor,
              isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildSummaryTile(
              'Equity',
              formatCurrency(equity),
              equity >= 0 ? positiveColor : negativeColor,
              isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildSummaryTile(
              'Debt-to-Asset Ratio',
              (totalLiabilities / totalAssets).toStringAsFixed(2),
              textColor,
              isDarkMode,
            ),
          ],
        );

      case 'cashFlow':
        final double netCashFlow = data['netCashFlow'];
        final double beginningCashBalance = data['beginningCashBalance'];
        final double endingCashBalance = data['endingCashBalance'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryTile(
              'Net Cash Flow',
              formatCurrency(netCashFlow),
              netCashFlow >= 0 ? positiveColor : negativeColor,
              isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildSummaryTile(
              'Beginning Balance',
              formatCurrency(beginningCashBalance),
              textColor,
              isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildSummaryTile(
              'Ending Balance',
              formatCurrency(endingCashBalance),
              textColor,
              isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildSummaryTile(
              'Change %',
              '${((netCashFlow / beginningCashBalance) * 100).toStringAsFixed(1)}%',
              netCashFlow >= 0 ? positiveColor : negativeColor,
              isDarkMode,
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // Summary tile helper
  Widget _buildSummaryTile(
    String label,
    String value,
    Color valueColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF353552) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // Visualization helper - requires fl_chart package
  Widget _buildVisualization(
    String type,
    Map<String, dynamic> data,
    bool isDarkMode,
  ) {
    final Color accentColor =
        isDarkMode ? const Color(0xFF4ECCA3) : const Color(0xFF0072B5);
    final Color secondaryColor =
        isDarkMode ? const Color(0xFFFF6B6B) : Colors.orange;
    final Color tertiaryColor = isDarkMode ? Colors.amber : Colors.purple;
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;

    switch (type) {
      case 'profitAndLoss':
        // Income vs Expenses pie chart
        final double totalIncome = data['totalIncome'];
        final double totalExpenses = data['totalExpenses'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue vs Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: accentColor,
                      value: totalIncome,
                      title: 'Revenue',
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: secondaryColor,
                      value: totalExpenses,
                      title: 'Expenses',
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.white,
                      ),
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        );

      case 'balanceSheet':
        // Assets vs Liabilities vs Equity bar chart
        final double totalAssets = data['totalAssets'];
        final double totalLiabilities = data['totalLiabilities'];
        final double equity = data['equity'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assets, Liabilities & Equity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY:
                      [
                        totalAssets,
                        totalLiabilities,
                        equity,
                      ].reduce((a, b) => a > b ? a : b) *
                      1.2,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: totalAssets,
                          color: accentColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          width: 40,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: totalLiabilities,
                          color: secondaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          width: 40,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: equity,
                          color: tertiaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          width: 40,
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value % (meta.max / 5) < 0.1 * meta.max) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                '\$${(value / 1000).toInt()}K',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final titles = ['Assets', 'Liabilities', 'Equity'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              titles[value.toInt()],
                              style: TextStyle(color: textColor, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        );

      case 'cashFlow':
        // Cash flow components pie chart
        final double operatingCashFlow = data['operatingCashFlow'];
        final double investingCashFlow = data['investingCashFlow'].abs();
        final double financingCashFlow = data['financingCashFlow'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cash Flow Components',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: accentColor,
                      value: operatingCashFlow.abs(),
                      title: 'Operating',
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: secondaryColor,
                      value: investingCashFlow,
                      title: 'Investing',
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: tertiaryColor,
                      value: financingCashFlow.abs(),
                      title: 'Financing',
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.white,
                      ),
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        );

      default:
        return Center(
          child: Text(
            'Select a statement type',
            style: TextStyle(color: textColor),
          ),
        );
    }
  }

  // Enhanced content for large screens
  Widget _buildLargeScreenContent(String type, WidgetRef ref, bool isDarkMode) {
    final controller = ref.watch(financialStatementsControllerProvider);

    // Get data based on statement type
    Map<String, dynamic> data;
    Widget statementWidget;

    switch (type) {
      case 'profitAndLoss':
        data = controller.generateProfitAndLossStatement();
        statementWidget = EnhancedProfitAndLossStatementTable(
          data: data,
          isDarkMode: isDarkMode,
        );
        break;
      case 'balanceSheet':
        data = controller.generateBalanceSheet();
        statementWidget = EnhancedBalanceSheetTable(
          data: data,
          isDarkMode: isDarkMode,
        );
        break;
      case 'cashFlow':
        data = controller.generateCashFlowStatement();
        statementWidget = EnhancedCashFlowStatementTable(
          data: data,
          isDarkMode: isDarkMode,
        );
        break;
      default:
        return const Center(child: Text('Select a statement type'));
    }

    // Add header context for large screens
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statement period and description
        _buildStatementHeader(type, isDarkMode),
        const SizedBox(height: 32),
        // The statement table
        Expanded(child: statementWidget),
      ],
    );
  }

  // Statement header with period and contextual info
  Widget _buildStatementHeader(String type, bool isDarkMode) {
    final String title;
    final String description;
    final IconData icon;

    switch (type) {
      case 'profitAndLoss':
        title = 'Profit & Loss Statement';
        description =
            'Summary of revenues, costs, and expenses for the period ending March 15, 2025';
        icon = Icons.trending_up;
        break;
      case 'balanceSheet':
        title = 'Balance Sheet';
        description = 'Statement of financial position as of March 15, 2025';
        icon = Icons.account_balance;
        break;
      case 'cashFlow':
        title = 'Cash Flow Statement';
        description =
            'Analysis of cash movements for the period ending March 15, 2025';
        icon = Icons.attach_money;
        break;
      default:
        title = 'Financial Statement';
        description = 'Select a statement type to view';
        icon = Icons.description;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDarkMode ? const Color(0xFF353552) : const Color(0xFFEDF2F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 32,
            color:
                isDarkMode ? const Color(0xFF4ECCA3) : const Color(0xFF0072B5),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Original code for selecting statements
  Widget _buildSelectedStatement(String type, WidgetRef ref) {
    final controller = ref.watch(financialStatementsControllerProvider);

    switch (type) {
      case 'profitAndLoss':
        final data = controller.generateProfitAndLossStatement();
        return ProfitAndLossStatementTable(data: data);
      case 'balanceSheet':
        final data = controller.generateBalanceSheet();
        return BalanceSheetTable(data: data);
      case 'cashFlow':
        final data = controller.generateCashFlowStatement();
        return CashFlowStatementTable(data: data);
      default:
        return const Center(child: Text('Select a statement type'));
    }
  }
}

// Enhanced version of ProfitAndLossStatementTable
class EnhancedProfitAndLossStatementTable extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDarkMode;

  const EnhancedProfitAndLossStatementTable({
    Key? key,
    required this.data,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, double> incomeByCategory = data['incomeByCategory'];
    final Map<String, double> expensesByCategory = data['expensesByCategory'];
    final double totalIncome = data['totalIncome'];
    final double totalExpenses = data['totalExpenses'];
    final double netIncome = data['netIncome'];

    final backgroundColor = isDarkMode ? const Color(0xFF252538) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF2C2C44) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final positiveColor =
        isDarkMode ? const Color(0xFF4ECCA3) : Colors.green.shade700;
    final negativeColor =
        isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income section
            Row(
              children: [
                Icon(Icons.arrow_circle_up, color: positiveColor),
                const SizedBox(width: 8),
                Text(
                  'Revenue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF323250) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    isDarkMode ? const Color(0xFF3A3A60) : Colors.grey.shade100,
                  ),
                  dataRowColor: MaterialStateProperty.all(Colors.transparent),
                  columnSpacing: 60,
                  horizontalMargin: 24,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    ...incomeByCategory.entries.map(
                      (entry) => DataRow(
                        cells: [
                          DataCell(
                            Text(entry.key, style: TextStyle(color: textColor)),
                          ),
                          DataCell(
                            Text(
                              formatCurrency(entry.value),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataRow(
                      color: MaterialStateProperty.all(
                        isDarkMode
                            ? const Color(0xFF3A3A60)
                            : Colors.grey.shade100,
                      ),
                      cells: [
                        DataCell(
                          Text(
                            'Total Revenue',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            formatCurrency(totalIncome),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Expenses section
            Row(
              children: [
                Icon(Icons.arrow_circle_down, color: negativeColor),
                const SizedBox(width: 8),
                Text(
                  'Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF323250) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    isDarkMode ? const Color(0xFF3A3A60) : Colors.grey.shade100,
                  ),
                  dataRowColor: MaterialStateProperty.all(Colors.transparent),
                  columnSpacing: 60,
                  horizontalMargin: 24,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    ...expensesByCategory.entries.map(
                      (entry) => DataRow(
                        cells: [
                          DataCell(
                            Text(entry.key, style: TextStyle(color: textColor)),
                          ),
                          DataCell(
                            Text(
                              formatCurrency(entry.value),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataRow(
                      color: MaterialStateProperty.all(
                        isDarkMode
                            ? const Color(0xFF3A3A60)
                            : Colors.grey.shade100,
                      ),
                      cells: [
                        DataCell(
                          Text(
                            'Total Expenses',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            formatCurrency(totalExpenses),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Net Income
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? const Color(0xFF394060)
                        : const Color(0xFFF0F5FA),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Income',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        netIncome >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: netIncome >= 0 ? positiveColor : negativeColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatCurrency(netIncome),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: netIncome >= 0 ? positiveColor : negativeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced version of BalanceSheetTable
class EnhancedBalanceSheetTable extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDarkMode;

  const EnhancedBalanceSheetTable({
    Key? key,
    required this.data,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, double> assetsByCategory = data['assetsByCategory'];
    final Map<String, double> liabilitiesByCategory =
        data['liabilitiesByCategory'];
    final double totalAssets = data['totalAssets'];
    final double totalLiabilities = data['totalLiabilities'];
    final double equity = data['equity'];

    final backgroundColor = isDarkMode ? const Color(0xFF252538) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF2C2C44) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final assetColor =
        isDarkMode ? const Color(0xFF4ECCA3) : const Color(0xFF2E7D32);
    final liabilityColor =
        isDarkMode ? const Color(0xFFFF6B6B) : const Color(0xFFD32F2F);
    final equityColor =
        isDarkMode ? const Color(0xFF71C0F0) : const Color(0xFF1976D2);

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assets section
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: assetColor),
                const SizedBox(width: 8),
                Text(
                  'Assets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF323250) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    isDarkMode ? const Color(0xFF3A3A60) : Colors.grey.shade100,
                  ),
                  dataRowColor: MaterialStateProperty.all(Colors.transparent),
                  columnSpacing: 60,
                  horizontalMargin: 24,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    ...assetsByCategory.entries.map(
                      (entry) => DataRow(
                        cells: [
                          DataCell(
                            Text(entry.key, style: TextStyle(color: textColor)),
                          ),
                          DataCell(
                            Text(
                              formatCurrency(entry.value),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataRow(
                      color: MaterialStateProperty.all(
                        isDarkMode
                            ? const Color(0xFF3A3A60)
                            : Colors.grey.shade100,
                      ),
                      cells: [
                        DataCell(
                          Text(
                            'Total Assets',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            formatCurrency(totalAssets),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Liabilities section
            Row(
              children: [
                Icon(Icons.account_balance, color: liabilityColor),
                const SizedBox(width: 8),
                Text(
                  'Liabilities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF323250) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    isDarkMode ? const Color(0xFF3A3A60) : Colors.grey.shade100,
                  ),
                  dataRowColor: MaterialStateProperty.all(Colors.transparent),
                  columnSpacing: 60,
                  horizontalMargin: 24,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    ...liabilitiesByCategory.entries.map(
                      (entry) => DataRow(
                        cells: [
                          DataCell(
                            Text(entry.key, style: TextStyle(color: textColor)),
                          ),
                          DataCell(
                            Text(
                              formatCurrency(entry.value),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataRow(
                      color: MaterialStateProperty.all(
                        isDarkMode
                            ? const Color(0xFF3A3A60)
                            : Colors.grey.shade100,
                      ),
                      cells: [
                        DataCell(
                          Text(
                            'Total Liabilities',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            formatCurrency(totalLiabilities),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Equity section
            Row(
              children: [
                Icon(Icons.equalizer, color: equityColor),
                const SizedBox(width: 8),
                Text(
                  'Equity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color:
                    isDarkMode ? const Color(0xFF323250) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    isDarkMode ? const Color(0xFF3A3A60) : Colors.grey.shade100,
                  ),
                  dataRowColor: MaterialStateProperty.all(Colors.transparent),
                  columnSpacing: 60,
                  horizontalMargin: 24,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            'Owner\'s Equity',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        DataCell(
                          Text(
                            formatCurrency(equity),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    DataRow(
                      color: MaterialStateProperty.all(
                        isDarkMode
                            ? const Color(0xFF3A3A60)
                            : Colors.grey.shade100,
                      ),
                      cells: [
                        DataCell(
                          Text(
                            'Total Equity',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            formatCurrency(equity),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Total Liabilities and Equity
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? const Color(0xFF394060)
                        : const Color(0xFFF0F5FA),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Liabilities and Equity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    formatCurrency(totalLiabilities + equity),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced version of CashFlowStatementTable
class EnhancedCashFlowStatementTable extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDarkMode;

  const EnhancedCashFlowStatementTable({
    Key? key,
    required this.data,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double operatingCashFlow = data['operatingCashFlow'];
    final double investingCashFlow = data['investingCashFlow'];
    final double financingCashFlow = data['financingCashFlow'];
    final double netCashFlow = data['netCashFlow'];
    final double beginningCashBalance = data['beginningCashBalance'];
    final double endingCashBalance = data['endingCashBalance'];

    final backgroundColor = isDarkMode ? const Color(0xFF252538) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF2C2C44) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final positiveColor =
        isDarkMode ? const Color(0xFF4ECCA3) : Colors.green.shade700;
    final negativeColor =
        isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;
    final operatingColor =
        isDarkMode ? const Color(0xFF4ECCA3) : const Color(0xFF2E7D32);
    final investingColor =
        isDarkMode ? const Color(0xFFFF6B6B) : const Color(0xFFD32F2F);
    final financingColor =
        isDarkMode ? const Color(0xFF71C0F0) : const Color(0xFF1976D2);

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operating Activities section
            Row(
              children: [
                Icon(Icons.business_center, color: operatingColor),
                const SizedBox(width: 8),
                Text(
                  'Cash Flow from Operating Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildCashFlowSection(
              'Net Cash from Operations',
              operatingCashFlow,
              isDarkMode,
              textColor,
            ),

            const SizedBox(height: 32),

            // Investing Activities section
            Row(
              children: [
                Icon(Icons.trending_up, color: investingColor),
                const SizedBox(width: 8),
                Text(
                  'Cash Flow from Investing Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildCashFlowSection(
              'Purchase of Equipment',
              investingCashFlow,
              isDarkMode,
              textColor,
            ),

            const SizedBox(height: 32),

            // Financing Activities section
            Row(
              children: [
                Icon(Icons.account_balance, color: financingColor),
                const SizedBox(width: 8),
                Text(
                  'Cash Flow from Financing Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildCashFlowSection(
              'Net Proceeds from Loans',
              financingCashFlow,
              isDarkMode,
              textColor,
            ),

            const SizedBox(height: 32),

            // Cash Flow Summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? const Color(0xFF394060)
                        : const Color(0xFFF0F5FA),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net Cash Flow',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            netCashFlow >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color:
                                netCashFlow >= 0
                                    ? positiveColor
                                    : negativeColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatCurrency(netCashFlow),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  netCashFlow >= 0
                                      ? positiveColor
                                      : negativeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Beginning Cash Balance',
                        style: TextStyle(color: textColor),
                      ),
                      Text(
                        formatCurrency(beginningCashBalance),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ending Cash Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        formatCurrency(endingCashBalance),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlowSection(
    String title,
    double value,
    bool isDarkMode,
    Color textColor,
  ) {
    final Color positiveColor =
        isDarkMode ? const Color(0xFF4ECCA3) : Colors.green.shade700;
    final Color negativeColor =
        isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF323250) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          ),
          Text(
            formatCurrency(value),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: value >= 0 ? positiveColor : negativeColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Add this function to pubspec.yaml dependencies:
// fl_chart: ^0.60.0

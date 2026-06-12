import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../accounting_core/models/journal_entry.dart';
import '../accounting_core/models/ledger_posting.dart';
import '../helper/format_currency.dart';
import '../models/financial_period_close.dart';
import '../models/financial_report_evidence_close_task.dart';
import '../models/financial_report_exception_resolution.dart';
import '../models/financial_report_review_exception.dart';
import '../models/financial_report_tax_profile.dart';
import '../states/accounting_core_provider.dart';
import '../states/fin_statement/financial_close_checklist_provider.dart';
import '../states/fin_statement/financial_period_close_audit_provider.dart';
import '../states/fin_statement/financial_period_close_provider.dart';
import '../states/fin_statement/financial_report_evidence_task_resolution_provider.dart';
import '../states/fin_statement/financial_report_exception_resolution_provider.dart';
import '../states/fin_statement/financial_report_package_fingerprint_provider.dart';
import '../states/fin_statement/financial_report_package_integrity_provider.dart';
import '../states/fin_statement/financial_report_pack_provider.dart';
import '../states/fin_statement/financial_report_standard_transition_provider.dart';
import '../states/fin_statement/financial_provider.dart';
import '../states/fin_statement/period_closing_entry_provider.dart';
import '../widgets/balance_sheet_table.dart';
import '../widgets/cashflow_table.dart';
import '../widgets/financial_report_evidence_task_resolution_dialog.dart';
import '../widgets/financial_report_export_dialog.dart';
import '../widgets/financial_report_pack_view.dart';
import '../widgets/financial_report_exception_resolution_dialog.dart';
import '../widgets/profit_loss_table.dart';

class FinancialStatementsScreen extends ConsumerWidget {
  const FinancialStatementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedStatementTypeProvider);
    final controller = ref.watch(financialStatementsControllerProvider);
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
          IconButton(
            tooltip: 'Export statement',
            icon: Icon(Icons.download_rounded, color: accentColor),
            onPressed: () => _handleExportAction(context, selectedType),
          ),
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
                    'reportPack',
                    'Report Pack',
                    accentColor,
                    isDarkMode,
                  ),
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
      body: Column(
        children: [
          _buildStatementControls(
            context,
            ref,
            controller,
            isDarkMode,
            accentColor,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1200) {
                  // Extra large screen - side-by-side layout with summary
                  return _buildExtraLargeScreenLayout(
                    context,
                    selectedType,
                    ref,
                    isDarkMode,
                  );
                } else if (constraints.maxWidth > 800) {
                  // Large screen layout with enhanced padding and decorations
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildLargeScreenContent(
                      context,
                      selectedType,
                      ref,
                      isDarkMode,
                    ),
                  );
                } else {
                  // Medium to small screen layout - simplified version
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSelectedStatement(
                        context,
                        selectedType,
                        ref,
                        isDarkMode,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
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

  Widget _buildStatementControls(
    BuildContext context,
    WidgetRef ref,
    FinancialStatementsController controller,
    bool isDarkMode,
    Color accentColor,
  ) {
    final period = ref.watch(selectedFinancialPeriodProvider);
    final taxProfile = ref.watch(selectedFinancialReportTaxProfileProvider);
    final borderColor =
        isDarkMode
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.grey.shade200;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _periodChoice(
            ref,
            controller,
            period,
            FinancialPeriodPreset.all,
            'All',
          ),
          _periodChoice(
            ref,
            controller,
            period,
            FinancialPeriodPreset.dataMonth,
            'Data Month',
          ),
          _periodChoice(
            ref,
            controller,
            period,
            FinancialPeriodPreset.dataQuarter,
            'Quarter',
          ),
          _periodChoice(
            ref,
            controller,
            period,
            FinancialPeriodPreset.dataYear,
            'Year',
          ),
          ActionChip(
            avatar: Icon(
              Icons.date_range_rounded,
              size: 18,
              color: accentColor,
            ),
            label: Text(
              period.preset == FinancialPeriodPreset.custom
                  ? period.label
                  : 'Custom Range',
            ),
            onPressed: () => _pickCustomPeriod(context, ref, controller),
            backgroundColor:
                period.preset == FinancialPeriodPreset.custom
                    ? accentColor.withValues(alpha: 0.14)
                    : null,
          ),
          Chip(
            avatar: Icon(Icons.event_available_rounded, color: accentColor),
            label: Text(controller.periodLabel),
            side: BorderSide(color: accentColor.withValues(alpha: 0.25)),
            backgroundColor: accentColor.withValues(alpha: 0.08),
          ),
          _taxProfileMenu(ref, taxProfile, accentColor, isDarkMode),
        ],
      ),
    );
  }

  Widget _taxProfileMenu(
    WidgetRef ref,
    FinancialReportTaxProfile selectedProfile,
    Color accentColor,
    bool isDarkMode,
  ) {
    final foreground = isDarkMode ? Colors.white : Colors.black87;

    return PopupMenuButton<FinancialReportTaxProfile>(
      tooltip: 'Tax benchmark',
      initialValue: selectedProfile,
      onSelected: (profile) {
        ref.read(selectedFinancialReportTaxProfileProvider.notifier).state =
            profile;
      },
      itemBuilder:
          (context) =>
              FinancialReportTaxProfiles.values.map((profile) {
                return PopupMenuItem<FinancialReportTaxProfile>(
                  value: profile,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      profile.id == selectedProfile.id
                          ? Icons.check_circle_rounded
                          : Icons.percent_rounded,
                      color:
                          profile.id == selectedProfile.id ? accentColor : null,
                    ),
                    title: Text(profile.label, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${profile.rateLabel} - ${profile.taxReference}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
      child: Chip(
        avatar: Icon(Icons.percent_rounded, color: accentColor, size: 18),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            selectedProfile.shortLabel,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: foreground),
          ),
        ),
        side: BorderSide(color: accentColor.withValues(alpha: 0.25)),
        backgroundColor: accentColor.withValues(alpha: 0.08),
      ),
    );
  }

  Widget _periodChoice(
    WidgetRef ref,
    FinancialStatementsController controller,
    FinancialStatementPeriod period,
    FinancialPeriodPreset preset,
    String label,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: period.preset == preset,
      onSelected: (_) {
        ref.read(selectedFinancialPeriodProvider.notifier).state = controller
            .periodForPreset(preset);
      },
    );
  }

  Future<void> _pickCustomPeriod(
    BuildContext context,
    WidgetRef ref,
    FinancialStatementsController controller,
  ) async {
    final current = ref.read(selectedFinancialPeriodProvider);
    final start = current.startDate ?? controller.earliestEntryDate;
    final end = current.endDate ?? controller.latestEntryDate;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(controller.earliestEntryDate.year - 5),
      lastDate: DateTime(controller.latestEntryDate.year + 5, 12, 31),
      initialDateRange: DateTimeRange(start: start, end: end),
    );

    if (picked == null) {
      return;
    }

    ref
        .read(selectedFinancialPeriodProvider.notifier)
        .state = FinancialStatementPeriod(
      preset: FinancialPeriodPreset.custom,
      startDate: picked.start,
      endDate: picked.end,
    );
  }

  // Extra large screen layout with side panel for summary
  Widget _buildExtraLargeScreenLayout(
    BuildContext context,
    String type,
    WidgetRef ref,
    bool isDarkMode,
  ) {
    final controller = ref.watch(financialStatementsControllerProvider);
    final Color bgColor = isDarkMode ? const Color(0xFF252538) : Colors.white;
    final Color cardColor =
        isDarkMode ? const Color(0xFF2C2C44) : Colors.grey.shade50;

    if (type == 'reportPack') {
      return Container(
        padding: const EdgeInsets.all(32.0),
        color: bgColor,
        child: _buildLargeScreenContent(context, type, ref, isDarkMode),
      );
    }

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
            child: _buildLargeScreenContent(context, type, ref, isDarkMode),
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

                _buildReviewNotes(
                  controller.generateReviewNotes(type),
                  isDarkMode,
                ),

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
        final double profitMargin = data['profitMargin'] ?? 0.0;

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
              _formatPercent(profitMargin),
              netIncome >= 0 ? positiveColor : negativeColor,
              isDarkMode,
            ),
          ],
        );

      case 'balanceSheet':
        final double totalAssets = data['totalAssets'];
        final double totalLiabilities = data['totalLiabilities'];
        final double equity = data['equity'];
        final double debtToAssetRatio = data['debtToAssetRatio'] ?? 0.0;

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
              debtToAssetRatio.toStringAsFixed(2),
              textColor,
              isDarkMode,
            ),
          ],
        );

      case 'cashFlow':
        final double netCashFlow = data['netCashFlow'];
        final double beginningCashBalance = data['beginningCashBalance'];
        final double endingCashBalance = data['endingCashBalance'];
        final double changeRate =
            beginningCashBalance == 0 ? 0 : netCashFlow / beginningCashBalance;

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
              _formatPercent(changeRate),
              netCashFlow >= 0 ? positiveColor : negativeColor,
              isDarkMode,
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReviewNotes(List<String> notes, bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final noteColor =
        isDarkMode ? const Color(0xFF4ECCA3) : const Color(0xFF0072B5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        ...notes.map(
          (note) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_rounded, size: 18, color: noteColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(
                      height: 1.35,
                      color:
                          isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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

        if (totalIncome == 0 && totalExpenses == 0) {
          return _buildNoChartData(textColor);
        }

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
        final maxValue = [
          totalAssets,
          totalLiabilities,
          equity,
        ].reduce((a, b) => a > b ? a : b);

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
                  maxY: maxValue <= 0 ? 1 : maxValue * 1.2,
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
                          if (value.toInt() < 0 ||
                              value.toInt() >= titles.length) {
                            return const SizedBox.shrink();
                          }
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

        if (operatingCashFlow == 0 &&
            investingCashFlow == 0 &&
            financingCashFlow == 0) {
          return _buildNoChartData(textColor);
        }

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

  Widget _buildNoChartData(Color textColor) {
    return Center(
      child: Text(
        'No chart data for this period',
        style: TextStyle(color: textColor),
      ),
    );
  }

  // Enhanced content for large screens
  Widget _buildLargeScreenContent(
    BuildContext context,
    String type,
    WidgetRef ref,
    bool isDarkMode,
  ) {
    final controller = ref.watch(financialStatementsControllerProvider);

    if (type == 'reportPack') {
      final pack = ref.watch(financialReportPackProvider);
      final closeChecklist = ref.watch(financialCloseChecklistProvider);
      final closeRecord = ref.watch(currentFinancialPeriodCloseRecordProvider);
      final closeAuditTrail = ref.watch(
        currentFinancialPeriodCloseAuditProvider,
      );
      final packageIntegrity = ref.watch(
        currentFinancialReportPackageIntegrityProvider,
      );
      final standardTransitionSummary = ref.watch(
        currentFinancialReportStandardTransitionProvider,
      );
      final exceptionResolutionLockedReason = _exceptionResolutionLockedReason(
        closeRecord,
      );
      final evidenceTaskResolutionLockedReason =
          _evidenceTaskResolutionLockedReason(closeRecord);
      final exceptionResolutions = ref.watch(
        currentFinancialReportExceptionResolutionsProvider,
      );
      final evidenceTaskResolutions = ref.watch(
        currentFinancialReportEvidenceTaskResolutionsProvider,
      );
      final evidenceTaskAuditEvents = ref.watch(
        currentFinancialReportEvidenceTaskAuditProvider,
      );
      final postedAdjustmentJournals = _postedAdjustmentJournalsForPeriod(ref);
      final closingEntryPreview = ref.watch(
        currentPeriodClosingEntryPreviewProvider,
      );
      final closingEntryPosted = ref.watch(
        currentPeriodClosingEntryPostedProvider,
      );
      return FinancialReportPackView(
        pack: pack,
        closeChecklist: closeChecklist,
        closeRecord: closeRecord,
        packageIntegrity: packageIntegrity,
        standardTransitionSummary: standardTransitionSummary,
        exceptionResolutions: exceptionResolutions,
        evidenceTaskResolutions: evidenceTaskResolutions,
        evidenceTaskAuditEvents: evidenceTaskAuditEvents,
        postedAdjustmentJournals: postedAdjustmentJournals,
        exceptionResolutionLockedReason: exceptionResolutionLockedReason,
        evidenceTaskResolutionLockedReason: evidenceTaskResolutionLockedReason,
        closingEntryPreview: closingEntryPreview,
        closingEntryPosted: closingEntryPosted,
        closeAuditTrail: closeAuditTrail,
        onResolveException:
            exceptionResolutionLockedReason == null
                ? (exception, status) =>
                    _resolveReportException(context, ref, exception, status)
                : null,
        onResolveEvidenceTask:
            evidenceTaskResolutionLockedReason == null
                ? (task, status) =>
                    _resolveEvidenceTask(context, ref, task, status)
                : null,
        onClosePeriod: () => _closeCurrentPeriod(context, ref),
        onReopenPeriod: () => _reopenCurrentPeriod(context, ref),
        onPostClosingEntry: () => _postCurrentPeriodClosingEntry(context, ref),
        isDarkMode: isDarkMode,
      );
    }

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
        _buildStatementHeader(type, isDarkMode, controller.periodLabel),
        const SizedBox(height: 16),
        _buildInlineReviewNotes(
          controller.generateReviewNotes(type),
          isDarkMode,
        ),
        const SizedBox(height: 32),
        // The statement table
        Expanded(child: statementWidget),
      ],
    );
  }

  // Statement header with period and contextual info
  Widget _buildStatementHeader(
    String type,
    bool isDarkMode,
    String periodLabel,
  ) {
    final String title;
    final String description;
    final IconData icon;

    switch (type) {
      case 'profitAndLoss':
        title = 'Profit & Loss Statement';
        description =
            'Summary of revenues, costs, and expenses for $periodLabel';
        icon = Icons.trending_up;
        break;
      case 'balanceSheet':
        title = 'Balance Sheet';
        description = 'Statement of financial position for $periodLabel';
        icon = Icons.account_balance;
        break;
      case 'cashFlow':
        title = 'Cash Flow Statement';
        description = 'Analysis of cash movements for $periodLabel';
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

  Widget _buildInlineReviewNotes(List<String> notes, bool isDarkMode) {
    final noteColor =
        isDarkMode ? const Color(0xFF4ECCA3) : const Color(0xFF0072B5);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          notes.map((note) {
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Chip(
                avatar: Icon(
                  Icons.insights_rounded,
                  size: 18,
                  color: noteColor,
                ),
                label: Text(note, overflow: TextOverflow.ellipsis),
                side: BorderSide(color: noteColor.withValues(alpha: 0.24)),
                backgroundColor: noteColor.withValues(alpha: 0.08),
              ),
            );
          }).toList(),
    );
  }

  String _formatPercent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  void _showExportSnackBar(BuildContext context, String statementType) {
    final label = switch (statementType) {
      'reportPack' => 'Financial Report Pack',
      'profitAndLoss' => 'Profit & Loss',
      'balanceSheet' => 'Balance Sheet',
      'cashFlow' => 'Cash Flow',
      _ => 'Financial Statement',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label export is queued for the selected period.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleExportAction(BuildContext context, String statementType) {
    if (statementType == 'reportPack') {
      showDialog(
        context: context,
        builder: (context) => const FinancialReportExportDialog(),
      );
      return;
    }

    _showExportSnackBar(context, statementType);
  }

  Future<void> _resolveReportException(
    BuildContext context,
    WidgetRef ref,
    FinancialReportReviewException exception,
    FinancialReportExceptionResolutionStatus status,
  ) async {
    final lockedReason = _exceptionResolutionLockedReason(
      ref.read(currentFinancialPeriodCloseRecordProvider),
    );
    if (lockedReason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lockedReason),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final periodKey = ref.read(
      currentFinancialReportExceptionResolutionPeriodKeyProvider,
    );
    final existing = _existingExceptionResolution(
      ref.read(currentFinancialReportExceptionResolutionsProvider),
      exception.id,
    );
    final resolution = await showFinancialReportExceptionResolutionDialog(
      context,
      exception: exception,
      initialStatus: status,
      existingResolution: existing,
      adjustmentPostings: _postedAdjustmentJournalsForPeriod(ref),
    );

    if (resolution == null || !context.mounted) {
      return;
    }

    ref
        .read(financialReportExceptionResolutionProvider.notifier)
        .upsertResolution(periodKey: periodKey, resolution: resolution);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${resolution.status.label} evidence saved.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _resolveEvidenceTask(
    BuildContext context,
    WidgetRef ref,
    FinancialReportEvidenceCloseTask task,
    FinancialReportEvidenceCloseTaskResolutionStatus status,
  ) async {
    final lockedReason = _evidenceTaskResolutionLockedReason(
      ref.read(currentFinancialPeriodCloseRecordProvider),
    );
    if (lockedReason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lockedReason),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final periodKey = ref.read(
      currentFinancialReportEvidenceTaskResolutionPeriodKeyProvider,
    );
    final period = ref.read(selectedFinancialPeriodProvider);
    final existing = _existingEvidenceTaskResolution(
      ref.read(currentFinancialReportEvidenceTaskResolutionsProvider),
      task.id,
    );
    final resolution = await showFinancialReportEvidenceTaskResolutionDialog(
      context,
      task: task,
      initialStatus: status,
      existingResolution: existing,
    );

    if (resolution == null || !context.mounted) {
      return;
    }

    ref
        .read(financialReportEvidenceTaskResolutionProvider.notifier)
        .recordResolution(
          periodKey: periodKey,
          periodLabel: period.label,
          task: task,
          resolution: resolution,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${resolution.status.label} evidence saved.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  FinancialReportExceptionResolution? _existingExceptionResolution(
    List<FinancialReportExceptionResolution> resolutions,
    String exceptionId,
  ) {
    for (final resolution in resolutions) {
      if (resolution.exceptionId == exceptionId) {
        return resolution;
      }
    }
    return null;
  }

  FinancialReportEvidenceCloseTaskResolution? _existingEvidenceTaskResolution(
    List<FinancialReportEvidenceCloseTaskResolution> resolutions,
    String taskId,
  ) {
    for (final resolution in resolutions) {
      if (resolution.taskId == taskId) {
        return resolution;
      }
    }
    return null;
  }

  List<LedgerPosting> _postedAdjustmentJournalsForPeriod(WidgetRef ref) {
    final period = ref.read(selectedFinancialPeriodProvider);
    return ref
        .read(postedLedgerProvider)
        .where(
          (posting) =>
              posting.source == JournalSource.manualAdjustment &&
              period.contains(posting.entryDate),
        )
        .toList();
  }

  String? _exceptionResolutionLockedReason(
    FinancialPeriodCloseRecord? closeRecord,
  ) {
    if (closeRecord?.isClosed ?? false) {
      return 'Period closed - reopen to change exception evidence.';
    }
    return null;
  }

  String? _evidenceTaskResolutionLockedReason(
    FinancialPeriodCloseRecord? closeRecord,
  ) {
    if (closeRecord?.isClosed ?? false) {
      return 'Period closed - reopen to change evidence tasks.';
    }
    return null;
  }

  void _closeCurrentPeriod(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    final checklist = ref.read(financialCloseChecklistProvider);
    final period = ref.read(selectedFinancialPeriodProvider);
    final fingerprint = ref.read(
      currentFinancialReportPackageFingerprintProvider,
    );
    final closingEntryPosting = ref.read(
      currentPeriodClosingEntryPostingProvider,
    );

    try {
      final record = ref
          .read(financialPeriodCloseRecordsProvider.notifier)
          .closeCurrentPeriod(
            checklist: checklist,
            period: period,
            reportPackageHash: fingerprint.hash,
            reportPackageHashAlgorithm: fingerprint.algorithm,
            closingEntryPostingId: closingEntryPosting?.id,
            closingEntryReference: closingEntryPosting?.reference,
            closingEntryPostedAt: closingEntryPosting?.postedAt,
          );
      ref.read(financialPeriodCloseAuditProvider.notifier).recordClosed(record);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${record.periodLabel} is now closed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Close failed: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _reopenCurrentPeriod(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reopen Closed Period'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Example: add late vendor invoice',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Reopen'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (reason == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final period = ref.read(selectedFinancialPeriodProvider);
    try {
      final record = ref
          .read(financialPeriodCloseRecordsProvider.notifier)
          .reopenCurrentPeriod(period: period, reason: reason);
      ref
          .read(financialPeriodCloseAuditProvider.notifier)
          .recordReopened(record);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${record.periodLabel} was reopened.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Reopen failed: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _postCurrentPeriodClosingEntry(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final posting = ref
          .read(periodClosingEntryPostingServiceProvider)
          .post(
            preview: ref.read(currentPeriodClosingEntryPreviewProvider),
            chartOfAccounts: ref.read(accountingChartProvider),
            existingPostings: ref.read(postedLedgerProvider),
            closeRecords: ref.read(financialPeriodCloseRecordsProvider).values,
          );
      ref.read(postedLedgerProvider.notifier).addPosting(posting);
      messenger.showSnackBar(
        SnackBar(
          content: Text('${posting.reference} closing entry posted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Posting failed: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Original code for selecting statements
  Widget _buildSelectedStatement(
    BuildContext context,
    String type,
    WidgetRef ref,
    bool isDarkMode,
  ) {
    final controller = ref.watch(financialStatementsControllerProvider);

    switch (type) {
      case 'reportPack':
        final pack = ref.watch(financialReportPackProvider);
        final closeChecklist = ref.watch(financialCloseChecklistProvider);
        final closeRecord = ref.watch(
          currentFinancialPeriodCloseRecordProvider,
        );
        final closeAuditTrail = ref.watch(
          currentFinancialPeriodCloseAuditProvider,
        );
        final packageIntegrity = ref.watch(
          currentFinancialReportPackageIntegrityProvider,
        );
        final standardTransitionSummary = ref.watch(
          currentFinancialReportStandardTransitionProvider,
        );
        final exceptionResolutionLockedReason =
            _exceptionResolutionLockedReason(closeRecord);
        final evidenceTaskResolutionLockedReason =
            _evidenceTaskResolutionLockedReason(closeRecord);
        final exceptionResolutions = ref.watch(
          currentFinancialReportExceptionResolutionsProvider,
        );
        final evidenceTaskResolutions = ref.watch(
          currentFinancialReportEvidenceTaskResolutionsProvider,
        );
        final evidenceTaskAuditEvents = ref.watch(
          currentFinancialReportEvidenceTaskAuditProvider,
        );
        final postedAdjustmentJournals = _postedAdjustmentJournalsForPeriod(
          ref,
        );
        final closingEntryPreview = ref.watch(
          currentPeriodClosingEntryPreviewProvider,
        );
        final closingEntryPosted = ref.watch(
          currentPeriodClosingEntryPostedProvider,
        );
        return FinancialReportPackView(
          pack: pack,
          closeChecklist: closeChecklist,
          closeRecord: closeRecord,
          packageIntegrity: packageIntegrity,
          standardTransitionSummary: standardTransitionSummary,
          exceptionResolutions: exceptionResolutions,
          evidenceTaskResolutions: evidenceTaskResolutions,
          evidenceTaskAuditEvents: evidenceTaskAuditEvents,
          postedAdjustmentJournals: postedAdjustmentJournals,
          exceptionResolutionLockedReason: exceptionResolutionLockedReason,
          evidenceTaskResolutionLockedReason:
              evidenceTaskResolutionLockedReason,
          closingEntryPreview: closingEntryPreview,
          closingEntryPosted: closingEntryPosted,
          closeAuditTrail: closeAuditTrail,
          onResolveException:
              exceptionResolutionLockedReason == null
                  ? (exception, status) =>
                      _resolveReportException(context, ref, exception, status)
                  : null,
          onResolveEvidenceTask:
              evidenceTaskResolutionLockedReason == null
                  ? (task, status) =>
                      _resolveEvidenceTask(context, ref, task, status)
                  : null,
          onClosePeriod: () => _closeCurrentPeriod(context, ref),
          onReopenPeriod: () => _reopenCurrentPeriod(context, ref),
          onPostClosingEntry:
              () => _postCurrentPeriodClosingEntry(context, ref),
          isDarkMode: isDarkMode,
          scrollable: false,
        );
      case 'profitAndLoss':
        final data = controller.generateProfitAndLossStatement();
        return EnhancedProfitAndLossStatementTable(
          data: data,
          isDarkMode: isDarkMode,
        );
      case 'balanceSheet':
        final data = controller.generateBalanceSheet();
        return EnhancedBalanceSheetTable(data: data, isDarkMode: isDarkMode);
      case 'cashFlow':
        final data = controller.generateCashFlowStatement();
        return EnhancedCashFlowStatementTable(
          data: data,
          isDarkMode: isDarkMode,
        );
      default:
        return const Center(child: Text('Select a statement type'));
    }
  }
}

class FinancialStatementTypeScreen extends ConsumerStatefulWidget {
  final String statementType;

  const FinancialStatementTypeScreen({required this.statementType, super.key});

  @override
  ConsumerState<FinancialStatementTypeScreen> createState() =>
      _FinancialStatementTypeScreenState();
}

class _FinancialStatementTypeScreenState
    extends ConsumerState<FinancialStatementTypeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncStatementType());
  }

  @override
  void didUpdateWidget(covariant FinancialStatementTypeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statementType != widget.statementType) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncStatementType());
    }
  }

  void _syncStatementType() {
    if (!mounted) {
      return;
    }
    final current = ref.read(selectedStatementTypeProvider);
    if (current != widget.statementType) {
      ref.read(selectedStatementTypeProvider.notifier).state =
          widget.statementType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const FinancialStatementsScreen();
  }
}

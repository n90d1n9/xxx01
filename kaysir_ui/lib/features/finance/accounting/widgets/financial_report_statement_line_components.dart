import 'package:flutter/material.dart';

import '../helper/format_currency.dart';
import '../models/financial_report_pack.dart';
import 'financial_report_reference_pill.dart';
import 'financial_report_row_surface_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportStatementColumnHeader extends StatelessWidget {
  const FinancialReportStatementColumnHeader({
    required this.isDarkMode,
    required this.comparativeLabel,
    super.key,
  });

  final bool isDarkMode;
  final String comparativeLabel;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final labelStyle = TextStyle(
      color: mutedColor,
      fontSize: 12,
      fontWeight: FontWeight.w800,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          Expanded(child: Text('Line item', style: labelStyle)),
          SizedBox(
            width: 150,
            child: Text(
              'Current',
              textAlign: TextAlign.right,
              style: labelStyle,
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              comparativeLabel,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              'Variance',
              textAlign: TextAlign.right,
              style: labelStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialReportStatementLineRow extends StatelessWidget {
  const FinancialReportStatementLineRow({
    required this.line,
    required this.isDarkMode,
    required this.showComparative,
    required this.useComparativeColumns,
    this.comparativeLabel = 'Comparative',
    super.key,
  });

  final FinancialReportLine line;
  final bool isDarkMode;
  final bool showComparative;
  final bool useComparativeColumns;
  final String comparativeLabel;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final isHeading = line.type == FinancialReportLineType.section;
    final isTotal =
        line.type == FinancialReportLineType.total ||
        line.type == FinancialReportLineType.subtotal;
    final amount = line.amount;
    final amountColor = _amountColor(amount, textColor, mutedColor);

    return FinancialReportRowSurface(
      isDarkMode: isDarkMode,
      padding: EdgeInsets.fromLTRB(12 + (line.indentLevel * 16), 9, 12, 9),
      backgroundColor:
          isHeading
              ? (isDarkMode ? Colors.white10 : const Color(0xFFF1F5F9))
              : null,
      child:
          useComparativeColumns
              ? _buildWideRow(
                textColor,
                mutedColor,
                amountColor,
                isHeading,
                isTotal,
              )
              : _buildCompactRow(textColor, mutedColor, isHeading, isTotal),
    );
  }

  Widget _buildWideRow(
    Color textColor,
    Color mutedColor,
    Color amountColor,
    bool isHeading,
    bool isTotal,
  ) {
    return Row(
      children: [
        Expanded(child: _lineLabel(textColor, mutedColor, isHeading, isTotal)),
        if (line.hasAmount) ...[
          FinancialReportStatementAmountCell(
            amount: line.amount ?? 0,
            color: amountColor,
            isTotal: isTotal,
          ),
          FinancialReportStatementAmountCell(
            amount: line.comparativeAmount ?? 0,
            color: _amountColor(line.comparativeAmount, textColor, mutedColor),
            isTotal: isTotal,
          ),
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerRight,
              child: FinancialReportStatementVarianceText(
                variance: line.variance ?? 0,
                isDarkMode: isDarkMode,
                compact: true,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactRow(
    Color textColor,
    Color mutedColor,
    bool isHeading,
    bool isTotal,
  ) {
    final amount = line.amount;
    final showStackedComparison = showComparative && line.hasAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _lineLabel(textColor, mutedColor, isHeading, isTotal),
            ),
            if (amount != null && !showStackedComparison)
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatCurrency(amount),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _amountColor(amount, textColor, mutedColor),
                      fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (showStackedComparison) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FinancialReportStatementAmountPill(
                label: 'Current',
                amount: amount ?? 0,
                isDarkMode: isDarkMode,
              ),
              FinancialReportStatementAmountPill(
                label: comparativeLabel,
                amount: line.comparativeAmount ?? 0,
                isDarkMode: isDarkMode,
              ),
              FinancialReportStatementAmountPill(
                label: 'Variance',
                amount: line.variance ?? 0,
                isDarkMode: isDarkMode,
                isVariance: true,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _lineLabel(
    Color textColor,
    Color mutedColor,
    bool isHeading,
    bool isTotal,
  ) {
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          line.label,
          style: TextStyle(
            color: isHeading ? textColor : mutedColor,
            fontWeight: isHeading || isTotal ? FontWeight.w800 : null,
          ),
        ),
        if (line.noteReference != null)
          FinancialReportReferencePill(
            reference: 'Note ${line.noteReference}',
            isDarkMode: isDarkMode,
          ),
      ],
    );
  }

  Color _amountColor(double? value, Color textColor, Color mutedColor) {
    if (value == null) {
      return mutedColor;
    }
    if (value >= 0) {
      return textColor;
    }
    return isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;
  }
}

class FinancialReportStatementAmountCell extends StatelessWidget {
  const FinancialReportStatementAmountCell({
    required this.amount,
    required this.color,
    required this.isTotal,
    super.key,
  });

  final double amount;
  final Color color;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            formatCurrency(amount),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class FinancialReportStatementAmountPill extends StatelessWidget {
  const FinancialReportStatementAmountPill({
    required this.label,
    required this.amount,
    required this.isDarkMode,
    this.isVariance = false,
    super.key,
  });

  final String label;
  final double amount;
  final bool isDarkMode;
  final bool isVariance;

  @override
  Widget build(BuildContext context) {
    final color =
        isVariance
            ? financialReportStatementVarianceColor(amount, isDarkMode)
            : isDarkMode
            ? Colors.grey.shade300
            : Colors.blueGrey.shade700;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: FinancialReportTintedSurface(
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        fillAlpha: 0.08,
        borderAlpha: 0.22,
        borderRadius: 999,
        child: Text(
          '$label ${formatCurrency(amount)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class FinancialReportStatementVarianceText extends StatelessWidget {
  const FinancialReportStatementVarianceText({
    required this.variance,
    required this.isDarkMode,
    this.compact = false,
    super.key,
  });

  final double variance;
  final bool isDarkMode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = financialReportStatementVarianceColor(variance, isDarkMode);
    final prefix = variance > 0 ? '+' : '';

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(
        '${compact ? '' : 'Variance '}$prefix${formatCurrency(variance)}',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: color,
          fontSize: compact ? 12 : 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color financialReportStatementVarianceColor(double value, bool isDarkMode) {
  if (value > 0) {
    return isDarkMode ? const Color(0xFF4ECCA3) : Colors.green.shade700;
  }
  if (value < 0) {
    return isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;
  }
  return isDarkMode ? Colors.grey.shade400 : Colors.blueGrey.shade600;
}

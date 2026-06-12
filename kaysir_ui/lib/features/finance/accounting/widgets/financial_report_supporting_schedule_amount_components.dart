import 'package:flutter/material.dart';

import '../helper/format_currency.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportScheduleAmountCell extends StatelessWidget {
  const FinancialReportScheduleAmountCell({
    required this.amount,
    required this.isDarkMode,
    this.width = 142,
    this.isVariance = false,
    this.isTotal = false,
    super.key,
  });

  final double amount;
  final bool isDarkMode;
  final double width;
  final bool isVariance;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final color = financialReportScheduleAmountColor(
      amount,
      isDarkMode,
      isVariance,
    );

    return SizedBox(
      width: width,
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
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class FinancialReportScheduleAmountPill extends StatelessWidget {
  const FinancialReportScheduleAmountPill({
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
    final color = financialReportScheduleAmountColor(
      amount,
      isDarkMode,
      isVariance,
    );

    return FinancialReportTintedSurface(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      fillAlpha: 0.08,
      borderAlpha: 0.22,
      borderRadius: 999,
      child: Text(
        '$label ${formatCurrency(amount)}',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color financialReportScheduleAmountColor(
  double amount,
  bool isDarkMode,
  bool isVariance,
) {
  if (isVariance) {
    if (amount > 0) {
      return isDarkMode ? const Color(0xFF4ECCA3) : Colors.green.shade700;
    }
    if (amount < 0) {
      return isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;
    }
  }

  if (amount < 0) {
    return isDarkMode ? const Color(0xFFFF6B6B) : Colors.red.shade700;
  }
  return isDarkMode ? Colors.grey.shade200 : Colors.blueGrey.shade800;
}

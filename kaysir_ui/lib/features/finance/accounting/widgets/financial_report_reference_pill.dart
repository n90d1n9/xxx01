import 'package:flutter/material.dart';

import 'financial_report_tinted_surface_components.dart';

class FinancialReportReferencePill extends StatelessWidget {
  const FinancialReportReferencePill({
    required this.reference,
    required this.isDarkMode,
    super.key,
  });

  final String reference;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? const Color(0xFF71C0F0) : Colors.blue.shade700;

    return FinancialReportTintedSurface(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      fillAlpha: 0.1,
      borderAlpha: 0.25,
      borderRadius: 999,
      child: Text(
        reference,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

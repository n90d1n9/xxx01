import 'package:flutter/material.dart';

import 'financial_report_tinted_surface_components.dart';

class FinancialCloseStatusPill extends StatelessWidget {
  const FinancialCloseStatusPill({
    required this.label,
    required this.color,
    required this.isDarkMode,
    super.key,
  });

  final String label;
  final Color color;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportTintedSurface(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      fillAlpha: isDarkMode ? 0.14 : 0.1,
      borderAlpha: 0.25,
      borderRadius: 999,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

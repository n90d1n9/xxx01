import 'package:flutter/material.dart';

import '../models/financial_report_review_exception.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportExceptionRegisterHeader extends StatelessWidget {
  const FinancialReportExceptionRegisterHeader({
    required this.periodLabel,
    required this.exceptionCount,
    required this.blockerCount,
    required this.isDarkMode,
    super.key,
  });

  final String periodLabel;
  final int exceptionCount;
  final int blockerCount;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final accent =
        blockerCount == 0
            ? isDarkMode
                ? const Color(0xFF4ECCA3)
                : Colors.teal.shade700
            : Colors.red.shade700;

    return FinancialReportPanelHeader(
      title: 'Report Exception Register',
      subtitle:
          'Material variances and unresolved report checks for $periodLabel.',
      icon: Icons.assignment_late_rounded,
      accentColor: accent,
      isDarkMode: isDarkMode,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FinancialReportExceptionPill(
            label: exceptionCount == 0 ? 'Clear' : '$exceptionCount open',
            color: accent,
            isDarkMode: isDarkMode,
          ),
          if (exceptionCount > 0)
            FinancialReportExceptionPill(
              label: '$blockerCount blocker(s)',
              color: blockerCount == 0 ? Colors.blueGrey : accent,
              isDarkMode: isDarkMode,
            ),
        ],
      ),
    );
  }
}

class FinancialReportExceptionEmptyState extends StatelessWidget {
  const FinancialReportExceptionEmptyState({
    required this.isDarkMode,
    super.key,
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;

    return FinancialReportPanelEmptyState(
      title: 'No unresolved report exceptions',
      message: 'Compliance checks do not currently require exception review.',
      icon: Icons.task_alt_rounded,
      accentColor: color,
      isDarkMode: isDarkMode,
    );
  }
}

class FinancialReportExceptionSeverityPill extends StatelessWidget {
  const FinancialReportExceptionSeverityPill({
    required this.severity,
    required this.color,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportReviewExceptionSeverity severity;
  final Color color;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportExceptionPill(
      label: severity.label,
      color: color,
      isDarkMode: isDarkMode,
    );
  }
}

class FinancialReportExceptionPill extends StatelessWidget {
  const FinancialReportExceptionPill({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      fillAlpha: isDarkMode ? 0.18 : 0.12,
      borderAlpha: isDarkMode ? 0.24 : 0.16,
      borderRadius: 999,
      child: Text(
        label,
        style: TextStyle(
          color: isDarkMode ? Colors.white : color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class FinancialReportExceptionEvidencePill extends StatelessWidget {
  const FinancialReportExceptionEvidencePill({
    required this.icon,
    required this.label,
    required this.isDarkMode,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? Colors.grey.shade300 : Colors.blueGrey.shade700;

    return FinancialReportTintedSurface(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      backgroundColor: isDarkMode ? Colors.white10 : Colors.blueGrey.shade50,
      borderAlpha: isDarkMode ? 0.18 : 0.16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color financialReportExceptionSeverityColor(
  FinancialReportReviewExceptionSeverity severity,
  bool isDarkMode,
) {
  switch (severity) {
    case FinancialReportReviewExceptionSeverity.material:
      return Colors.red.shade700;
    case FinancialReportReviewExceptionSeverity.blocking:
      return Colors.orange.shade800;
    case FinancialReportReviewExceptionSeverity.review:
      return isDarkMode ? const Color(0xFF7AA2F7) : Colors.blue.shade700;
  }
}

import 'package:flutter/material.dart';

import 'financial_report_panel_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportComplianceHeader extends StatelessWidget {
  const FinancialReportComplianceHeader({
    required this.isDarkMode,
    this.title = 'SAK / IFRS Readiness',
    this.subtitle =
        'Tracks presentation coverage and remaining data gaps for Indonesian reporting.',
    super.key,
  });

  final bool isDarkMode;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return FinancialReportPanelHeader(
      title: title,
      subtitle: subtitle,
      icon: Icons.fact_check_rounded,
      accentColor: isDarkMode ? const Color(0xFF71C0F0) : Colors.blue.shade700,
      isDarkMode: isDarkMode,
    );
  }
}

class FinancialReportComplianceReadinessBadge extends StatelessWidget {
  const FinancialReportComplianceReadinessBadge({
    required this.percent,
    required this.helperText,
    required this.color,
    required this.isDarkMode,
    super.key,
  });

  final int percent;
  final String helperText;
  final Color color;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportTintedSurface(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      fillAlpha: isDarkMode ? 0.16 : 0.1,
      borderAlpha: 0.28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$percent% ready',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            helperText,
            style: TextStyle(
              color:
                  isDarkMode ? Colors.grey.shade300 : Colors.blueGrey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialReportComplianceSummaryStats extends StatelessWidget {
  const FinancialReportComplianceSummaryStats({
    required this.readyCount,
    required this.openCount,
    required this.exceptionCount,
    required this.isDarkMode,
    super.key,
  });

  final int readyCount;
  final int openCount;
  final int exceptionCount;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FinancialReportComplianceStatPill(
          icon: Icons.verified_rounded,
          label: 'Ready',
          value: '$readyCount',
          color: isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal,
          isDarkMode: isDarkMode,
        ),
        FinancialReportComplianceStatPill(
          icon: Icons.pending_actions_rounded,
          label: 'Open',
          value: '$openCount',
          color: Colors.orange,
          isDarkMode: isDarkMode,
        ),
        FinancialReportComplianceStatPill(
          icon: Icons.warning_amber_rounded,
          label: 'Exceptions',
          value: '$exceptionCount',
          color: Colors.red,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }
}

class FinancialReportComplianceStatPill extends StatelessWidget {
  const FinancialReportComplianceStatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDarkMode,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportTintedSurface(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      fillAlpha: isDarkMode ? 0.14 : 0.08,
      borderAlpha: 0.18,
      borderRadius: 999,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isDarkMode ? Colors.grey.shade200 : Colors.blueGrey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialReportComplianceEmptyState extends StatelessWidget {
  const FinancialReportComplianceEmptyState({
    required this.isDarkMode,
    super.key,
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportPanelEmptyState(
      title: 'No readiness controls are attached to this report pack.',
      icon: Icons.rule_folder_rounded,
      isDarkMode: isDarkMode,
    );
  }
}

Color financialReportReadinessColor(double readiness, bool isDarkMode) {
  if (readiness >= 0.9) {
    return isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;
  }
  if (readiness >= 0.65) {
    return isDarkMode ? const Color(0xFF71C0F0) : Colors.blue.shade700;
  }
  return Colors.orange.shade700;
}

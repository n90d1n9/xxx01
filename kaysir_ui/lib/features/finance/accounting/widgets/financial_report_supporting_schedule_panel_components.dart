import 'package:flutter/material.dart';

import '../services/financial_report_schedule_evidence_health_service.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportSupportingSchedulesHeader extends StatelessWidget {
  const FinancialReportSupportingSchedulesHeader({
    required this.scheduleCount,
    required this.activeCount,
    required this.sourceLineCount,
    required this.isDarkMode,
    required this.evidenceHealth,
    super.key,
  });

  final int scheduleCount;
  final int activeCount;
  final int sourceLineCount;
  final bool isDarkMode;
  final FinancialReportScheduleEvidenceHealthSummary evidenceHealth;

  @override
  Widget build(BuildContext context) {
    return FinancialReportPanelHeader(
      title: 'Supporting Schedules',
      subtitle:
          'Traceable source lines for tax, cash, reconciliation, and OCI disclosures.',
      icon: Icons.account_tree_rounded,
      accentColor: isDarkMode ? const Color(0xFF71C0F0) : Colors.blue.shade700,
      isDarkMode: isDarkMode,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FinancialReportSchedulePanelPill(
            icon: Icons.library_books_rounded,
            label: 'Schedules',
            value: '$scheduleCount',
            color: isDarkMode ? const Color(0xFF71C0F0) : Colors.blue,
            isDarkMode: isDarkMode,
          ),
          FinancialReportSchedulePanelPill(
            icon: Icons.bolt_rounded,
            label: 'Active',
            value: '$activeCount',
            color: isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal,
            isDarkMode: isDarkMode,
          ),
          FinancialReportSchedulePanelPill(
            icon: Icons.format_list_numbered_rounded,
            label: 'Lines',
            value: '$sourceLineCount',
            color: Colors.orange,
            isDarkMode: isDarkMode,
          ),
          FinancialReportSchedulePanelPill(
            icon: financialReportEvidenceHealthIcon(evidenceHealth.level),
            label: 'Evidence',
            value: evidenceHealth.level.label,
            color: financialReportEvidenceHealthColor(
              evidenceHealth.level,
              isDarkMode,
            ),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}

class FinancialReportSupportingSchedulesTitle extends StatelessWidget {
  const FinancialReportSupportingSchedulesTitle({
    required this.isDarkMode,
    super.key,
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportPanelHeader(
      title: 'Supporting Schedules',
      subtitle:
          'Traceable source lines for tax, cash, reconciliation, and OCI disclosures.',
      icon: Icons.account_tree_rounded,
      accentColor: isDarkMode ? const Color(0xFF71C0F0) : Colors.blue.shade700,
      isDarkMode: isDarkMode,
    );
  }
}

class FinancialReportSchedulePanelPill extends StatelessWidget {
  const FinancialReportSchedulePanelPill({
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

IconData financialReportEvidenceHealthIcon(
  FinancialReportScheduleEvidenceHealthLevel level,
) {
  switch (level) {
    case FinancialReportScheduleEvidenceHealthLevel.ready:
      return Icons.verified_rounded;
    case FinancialReportScheduleEvidenceHealthLevel.monitor:
      return Icons.manage_search_rounded;
    case FinancialReportScheduleEvidenceHealthLevel.action:
      return Icons.report_problem_rounded;
  }
}

Color financialReportEvidenceHealthColor(
  FinancialReportScheduleEvidenceHealthLevel level,
  bool isDarkMode,
) {
  switch (level) {
    case FinancialReportScheduleEvidenceHealthLevel.ready:
      return isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal;
    case FinancialReportScheduleEvidenceHealthLevel.monitor:
      return isDarkMode ? const Color(0xFFFFD166) : Colors.amber.shade800;
    case FinancialReportScheduleEvidenceHealthLevel.action:
      return isDarkMode ? const Color(0xFFFF8A80) : Colors.red.shade700;
  }
}

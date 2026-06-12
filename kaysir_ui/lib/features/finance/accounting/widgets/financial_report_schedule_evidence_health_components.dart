import 'package:flutter/material.dart';

import '../services/financial_report_schedule_evidence_health_service.dart';
import 'financial_report_supporting_schedule_panel_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportScheduleEvidenceHealthBanner extends StatelessWidget {
  const FinancialReportScheduleEvidenceHealthBanner({
    required this.summary,
    required this.items,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportScheduleEvidenceHealthSummary summary;
  final List<FinancialReportScheduleEvidenceHealthItem> items;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final level = summary.level;
    final color = financialReportEvidenceHealthColor(level, isDarkMode);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;

    return FinancialReportTintedSurface(
      color: color,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      fillAlpha: isDarkMode ? 0.14 : 0.08,
      borderAlpha: 0.24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            financialReportEvidenceHealthIcon(level),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evidence follow-up',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.actionLabel,
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (summary.criticalSignalCount > 0)
                      FinancialReportEvidenceHealthChip(
                        label: '${summary.criticalSignalCount} critical',
                        color:
                            isDarkMode
                                ? const Color(0xFFFF8A80)
                                : Colors.red.shade700,
                        isDarkMode: isDarkMode,
                      ),
                    if (summary.watchSignalCount > 0)
                      FinancialReportEvidenceHealthChip(
                        label: '${summary.watchSignalCount} watch',
                        color:
                            isDarkMode
                                ? const Color(0xFFFFD166)
                                : Colors.amber.shade800,
                        isDarkMode: isDarkMode,
                      ),
                  ],
                ),
                if (items.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  FinancialReportEvidenceScheduleStatusList(
                    items: items,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialReportEvidenceScheduleStatusList extends StatelessWidget {
  const FinancialReportEvidenceScheduleStatusList({
    required this.items,
    required this.isDarkMode,
    super.key,
  });

  final List<FinancialReportScheduleEvidenceHealthItem> items;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: FinancialReportEvidenceScheduleStatusRow(
                    item: item,
                    isDarkMode: isDarkMode,
                  ),
                ),
              )
              .toList(),
    );
  }
}

class FinancialReportEvidenceScheduleStatusRow extends StatelessWidget {
  const FinancialReportEvidenceScheduleStatusRow({
    required this.item,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportScheduleEvidenceHealthItem item;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = financialReportEvidenceHealthColor(item.level, isDarkMode);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;

    return FinancialReportTintedSurface(
      color: color,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      backgroundColor: isDarkMode ? Colors.white10 : Colors.white,
      borderAlpha: 0.24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialReportEvidenceHealthChip(
            label: item.level.label,
            color: color,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.scheduleTitle,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.actionLabel,
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialReportEvidenceHealthChip extends StatelessWidget {
  const FinancialReportEvidenceHealthChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      fillAlpha: isDarkMode ? 0.16 : 0.1,
      borderAlpha: 0.24,
      borderRadius: 999,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

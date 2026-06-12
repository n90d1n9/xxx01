import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/ui/app_surface.dart';
import '../models/financial_report_pack.dart';

class FinancialReportPackSummaryHeader extends StatelessWidget {
  const FinancialReportPackSummaryHeader({
    required this.pack,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportPack pack;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final accent = financialReportPackReadinessAccent(isDarkMode);
    final readiness = (pack.readinessRatio * 100).round();

    return AppSurface(
      padding: const EdgeInsets.all(20),
      backgroundColor:
          isDarkMode ? const Color(0xFF2C2C44) : const Color(0xFFF8FAFC),
      borderColor: isDarkMode ? Colors.white12 : Colors.grey.shade200,
      child: Wrap(
        spacing: 20,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_rounded, color: accent),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        '${pack.entityName} Financial Report Pack',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${pack.frameworkName} - ${pack.jurisdiction} - ${pack.presentationCurrency}',
                  style: TextStyle(color: mutedColor, fontSize: 14),
                ),
                const SizedBox(height: 12),
                FinancialReportPackInfoChips(
                  pack: pack,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 220,
            child: FinancialReportPackReadinessMeter(
              readinessRatio: pack.readinessRatio,
              readinessPercent: readiness,
              accent: accent,
              textColor: textColor,
              mutedColor: mutedColor,
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialReportPackInfoChips extends StatelessWidget {
  const FinancialReportPackInfoChips({
    required this.pack,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportPack pack;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FinancialReportPackInfoChip(
          icon: Icons.calendar_month_rounded,
          label: pack.periodLabel,
          isDarkMode: isDarkMode,
        ),
        FinancialReportPackInfoChip(
          icon: Icons.account_balance_rounded,
          label: 'As of ${pack.asOfLabel}',
          isDarkMode: isDarkMode,
        ),
        if (pack.hasComparativePeriod)
          FinancialReportPackInfoChip(
            icon: Icons.compare_arrows_rounded,
            label: 'Compare ${pack.comparativePeriodLabel}',
            isDarkMode: isDarkMode,
          ),
        FinancialReportPackInfoChip(
          icon: Icons.schedule_rounded,
          label:
              'Generated ${DateFormat('MMM d, yyyy HH:mm').format(pack.generatedAt)}',
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }
}

class FinancialReportPackReadinessMeter extends StatelessWidget {
  const FinancialReportPackReadinessMeter({
    required this.readinessRatio,
    required this.readinessPercent,
    required this.accent,
    required this.textColor,
    required this.mutedColor,
    required this.isDarkMode,
    super.key,
  });

  final double readinessRatio;
  final int readinessPercent;
  final Color accent;
  final Color textColor;
  final Color mutedColor;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Readiness',
          style: TextStyle(color: mutedColor, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: readinessRatio,
          minHeight: 10,
          borderRadius: BorderRadius.circular(999),
          color: accent,
          backgroundColor: isDarkMode ? Colors.white12 : Colors.grey.shade200,
        ),
        const SizedBox(height: 8),
        Text(
          '$readinessPercent% report-pack checks ready',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class FinancialReportPackInfoChip extends StatelessWidget {
  const FinancialReportPackInfoChip({
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
    final color = isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey;

    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, overflow: TextOverflow.ellipsis),
      side: BorderSide(color: color.withValues(alpha: 0.22)),
      backgroundColor: color.withValues(alpha: 0.08),
    );
  }
}

Color financialReportPackReadinessAccent(bool isDarkMode) {
  return isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;
}

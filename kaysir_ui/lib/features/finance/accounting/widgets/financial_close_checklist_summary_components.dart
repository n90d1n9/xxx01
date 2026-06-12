import 'package:flutter/material.dart';

import '../../../../widgets/ui/app_icon_badge.dart';
import '../../../../widgets/ui/app_text_cluster.dart';
import '../models/financial_close_checklist.dart';
import 'financial_close_status_pill.dart';

class FinancialCloseChecklistSummary extends StatelessWidget {
  const FinancialCloseChecklistSummary({
    required this.checklist,
    required this.isClosed,
    required this.isDarkMode,
    super.key,
  });

  final FinancialCloseChecklist checklist;
  final bool isClosed;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final accent = financialCloseReadinessAccent(
      isClosed: isClosed,
      hasBlockers: checklist.hasBlockers,
      isDarkMode: isDarkMode,
    );
    final readinessPercent = (checklist.readinessRatio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 620;

            return Flex(
              direction: isCompact ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment:
                  isCompact
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
              children: [
                if (isCompact)
                  FinancialCloseReadinessTitle(
                    accent: accent,
                    periodLabel: checklist.periodLabel,
                    isDarkMode: isDarkMode,
                  )
                else
                  Expanded(
                    child: FinancialCloseReadinessTitle(
                      accent: accent,
                      periodLabel: checklist.periodLabel,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                SizedBox(width: isCompact ? 0 : 16, height: isCompact ? 12 : 0),
                FinancialCloseStatusPill(
                  label: financialCloseSummaryStatusLabel(checklist, isClosed),
                  color: accent,
                  isDarkMode: isDarkMode,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: checklist.readinessRatio,
                minHeight: 10,
                borderRadius: BorderRadius.circular(999),
                color: accent,
                backgroundColor:
                    isDarkMode ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$readinessPercent%',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FinancialCloseChecklistCountPills(
          readyCount: checklist.readyCount,
          reviewCount: checklist.reviewCount,
          blockedCount: checklist.blockedCount,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }
}

class FinancialCloseReadinessTitle extends StatelessWidget {
  const FinancialCloseReadinessTitle({
    required this.accent,
    required this.periodLabel,
    required this.isDarkMode,
    super.key,
  });

  final Color accent;
  final String periodLabel;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: Icons.fact_check_rounded,
          size: 38,
          iconSize: 20,
          backgroundColor: accent.withValues(alpha: isDarkMode ? 0.16 : 0.1),
          foregroundColor: accent,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppTextCluster(
            title: 'Period Close Readiness',
            subtitle:
                'Operational checklist for $periodLabel. Resolve blockers before locking or sharing final reports.',
            titleStyle: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            subtitleStyle: TextStyle(color: mutedColor),
            titleGap: 4,
            subtitleMaxLines: 3,
          ),
        ),
      ],
    );
  }
}

class FinancialCloseChecklistCountPills extends StatelessWidget {
  const FinancialCloseChecklistCountPills({
    required this.readyCount,
    required this.reviewCount,
    required this.blockedCount,
    required this.isDarkMode,
    super.key,
  });

  final int readyCount;
  final int reviewCount;
  final int blockedCount;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FinancialCloseChecklistCountPill(
          label: 'Ready',
          count: readyCount,
          color: isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700,
          isDarkMode: isDarkMode,
        ),
        FinancialCloseChecklistCountPill(
          label: 'Review',
          count: reviewCount,
          color: isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey,
          isDarkMode: isDarkMode,
        ),
        FinancialCloseChecklistCountPill(
          label: 'Blocked',
          count: blockedCount,
          color: Colors.orange.shade700,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }
}

class FinancialCloseChecklistCountPill extends StatelessWidget {
  const FinancialCloseChecklistCountPill({
    required this.label,
    required this.count,
    required this.color,
    required this.isDarkMode,
    super.key,
  });

  final String label;
  final int count;
  final Color color;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialCloseStatusPill(
      label: '$label $count',
      color: color,
      isDarkMode: isDarkMode,
    );
  }
}

Color financialCloseReadinessAccent({
  required bool isClosed,
  required bool hasBlockers,
  required bool isDarkMode,
}) {
  if (isClosed) {
    return isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;
  }
  if (hasBlockers) {
    return Colors.orange.shade700;
  }
  return isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;
}

String financialCloseSummaryStatusLabel(
  FinancialCloseChecklist checklist,
  bool isClosed,
) {
  if (isClosed) {
    return 'Period closed';
  }
  if (checklist.hasBlockers) {
    return '${checklist.blockedCount} blocker(s)';
  }
  return 'Ready to close';
}

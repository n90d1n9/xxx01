import 'package:flutter/material.dart';

import '../../../../widgets/ui/app_status_pill.dart';
import '../../../../widgets/ui/app_text_cluster.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_release_distribution.dart';
import '../models/financial_report_release_signoff.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportExportReadinessPanel extends StatelessWidget {
  const FinancialReportExportReadinessPanel({
    required this.pack,
    this.signOffItems = const [],
    this.distributionItems = const [],
    super.key,
  });

  final FinancialReportPack pack;
  final List<FinancialReportReleaseSignOffItem> signOffItems;
  final List<FinancialReportReleaseDistributionItem> distributionItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final readiness = pack.readinessRatio.clamp(0.0, 1.0).toDouble();
    final accent = financialReportExportReadinessColor(readiness, colorScheme);

    return FinancialReportPanelSurface(
      isDarkMode: theme.brightness == Brightness.dark,
      padding: const EdgeInsets.all(14),
      backgroundColor: colorScheme.surfaceContainerLow,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextCluster(
                  title: 'Export Readiness',
                  subtitle: financialReportExportReadinessMessage(readiness),
                  titleStyle: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                  subtitleMaxLines: 2,
                ),
              ),
              const SizedBox(width: 10),
              AppStatusPill(
                label: financialReportExportReadinessLabel(readiness),
                color: accent,
                icon: financialReportExportReadinessIcon(readiness),
                maxWidth: 180,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: readiness,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in financialReportExportCoverageItems(
                pack,
                signOffItems: signOffItems,
                distributionItems: distributionItems,
              ))
                FinancialReportExportCoverageChip(item: item),
            ],
          ),
        ],
      ),
    );
  }
}

class FinancialReportExportCoverageChip extends StatelessWidget {
  const FinancialReportExportCoverageChip({required this.item, super.key});

  final FinancialReportExportCoverageItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = item.isHealthy ? colorScheme.primary : colorScheme.tertiary;

    return FinancialReportTintedSurface(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      fillAlpha: 0.08,
      borderAlpha: 0.22,
      borderRadius: 999,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            item.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialReportExportCoverageItem {
  const FinancialReportExportCoverageItem({
    required this.label,
    required this.icon,
    required this.isHealthy,
  });

  final String label;
  final IconData icon;
  final bool isHealthy;
}

List<FinancialReportExportCoverageItem> financialReportExportCoverageItems(
  FinancialReportPack pack, {
  List<FinancialReportReleaseSignOffItem> signOffItems = const [],
  List<FinancialReportReleaseDistributionItem> distributionItems = const [],
}) {
  final readyChecks =
      pack.complianceItems.where((item) => item.isSatisfied).length;
  final signedCount = signOffItems.where((item) => item.isSigned).length;
  final completedDistributionCount =
      distributionItems.where((item) => item.isComplete).length;
  return [
    FinancialReportExportCoverageItem(
      label: '${pack.statements.length} statement(s)',
      icon: Icons.article_outlined,
      isHealthy: pack.statements.isNotEmpty,
    ),
    FinancialReportExportCoverageItem(
      label: '${pack.supportingSchedules.length} schedule(s)',
      icon: Icons.account_tree_outlined,
      isHealthy: pack.supportingSchedules.isNotEmpty,
    ),
    FinancialReportExportCoverageItem(
      label: '${pack.notes.length} note(s)',
      icon: Icons.sticky_note_2_outlined,
      isHealthy: pack.notes.isNotEmpty,
    ),
    FinancialReportExportCoverageItem(
      label: '$readyChecks/${pack.complianceItems.length} checks',
      icon: Icons.verified_outlined,
      isHealthy:
          pack.complianceItems.isNotEmpty &&
          readyChecks == pack.complianceItems.length,
    ),
    if (signOffItems.isNotEmpty)
      FinancialReportExportCoverageItem(
        label: '$signedCount/${signOffItems.length} sign-off(s)',
        icon: Icons.verified_user_outlined,
        isHealthy: signOffItems.every((item) => !item.blocksRelease),
      ),
    if (distributionItems.isNotEmpty)
      FinancialReportExportCoverageItem(
        label:
            '$completedDistributionCount/${distributionItems.length} distribution(s)',
        icon: Icons.send_outlined,
        isHealthy: distributionItems.every((item) => item.isComplete),
      ),
  ];
}

String financialReportExportReadinessLabel(double readiness) {
  if (readiness >= 0.9) {
    return 'Ready to share';
  }
  if (readiness >= 0.65) {
    return 'Review recommended';
  }
  return 'Needs review';
}

String financialReportExportReadinessMessage(double readiness) {
  if (readiness >= 0.9) {
    return 'The pack has enough coverage for a board-ready handoff.';
  }
  if (readiness >= 0.65) {
    return 'Export is available, but open checks should be reviewed first.';
  }
  return 'Export is available for working review, not final distribution.';
}

IconData financialReportExportReadinessIcon(double readiness) {
  if (readiness >= 0.9) {
    return Icons.verified_rounded;
  }
  if (readiness >= 0.65) {
    return Icons.manage_search_rounded;
  }
  return Icons.report_problem_rounded;
}

Color financialReportExportReadinessColor(
  double readiness,
  ColorScheme colorScheme,
) {
  if (readiness >= 0.9) {
    return colorScheme.primary;
  }
  if (readiness >= 0.65) {
    return colorScheme.tertiary;
  }
  return colorScheme.error;
}

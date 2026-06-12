import 'package:flutter/material.dart';

import '../../../../widgets/ui/app_icon_badge.dart';
import '../../../../widgets/ui/app_info_row.dart';
import '../../../../widgets/ui/app_text_cluster.dart';
import '../models/financial_report_pack.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportExportHeader extends StatelessWidget {
  const FinancialReportExportHeader({
    super.key,
    this.title = 'Export Report Pack',
    this.subtitle =
        'Share board-ready statements or workbook data from the prepared pack.',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: Icons.ios_share_rounded,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppTextCluster(
            title: title,
            subtitle: subtitle,
            titleStyle: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            subtitleMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

class FinancialReportExportContextPanel extends StatelessWidget {
  const FinancialReportExportContextPanel({required this.pack, super.key});

  final FinancialReportPack pack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FinancialReportPanelSurface(
      isDarkMode: theme.brightness == Brightness.dark,
      padding: const EdgeInsets.all(14),
      backgroundColor: colorScheme.surfaceContainerLow,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInfoRow(
            title: pack.entityName,
            subtitle: '${pack.periodLabel} - ${pack.presentationCurrency}',
            icon: Icons.domain_rounded,
            iconStyle: AppInfoRowIconStyle.badge,
            titleMaxLines: 2,
            subtitleMaxLines: 2,
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FinancialReportExportMetricBadge(
                label: 'Statements',
                value: pack.statements.length.toString(),
                icon: Icons.article_outlined,
              ),
              FinancialReportExportMetricBadge(
                label: 'Schedules',
                value: pack.supportingSchedules.length.toString(),
                icon: Icons.account_tree_outlined,
              ),
              FinancialReportExportMetricBadge(
                label: 'Notes',
                value: pack.notes.length.toString(),
                icon: Icons.sticky_note_2_outlined,
              ),
              FinancialReportExportMetricBadge(
                label: 'Readiness',
                value: '${(pack.readinessRatio * 100).round()}%',
                icon: Icons.verified_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FinancialReportExportMetricBadge extends StatelessWidget {
  const FinancialReportExportMetricBadge({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FinancialReportTintedSurface(
      color: colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      backgroundColor: colorScheme.surfaceContainerHigh,
      borderAlpha: 0.18,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 7),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

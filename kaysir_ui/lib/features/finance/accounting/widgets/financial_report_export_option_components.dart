import 'package:flutter/material.dart';

import '../../../../widgets/ui/app_icon_badge.dart';
import '../../../../widgets/ui/app_surface.dart';
import '../../../../widgets/ui/app_text_cluster.dart';
import '../models/financial_report_export.dart';

class FinancialReportExportOptionList extends StatelessWidget {
  const FinancialReportExportOptionList({
    required this.exportingFormat,
    required this.isBusy,
    required this.onExport,
    super.key,
  });

  final FinancialReportExportFormat? exportingFormat;
  final bool isBusy;
  final ValueChanged<FinancialReportExportFormat> onExport;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FinancialReportExportOptionTile(
          format: FinancialReportExportFormat.pdf,
          isLoading: exportingFormat == FinancialReportExportFormat.pdf,
          isDisabled: isBusy,
          onTap: () => onExport(FinancialReportExportFormat.pdf),
        ),
        const SizedBox(height: 10),
        FinancialReportExportOptionTile(
          format: FinancialReportExportFormat.csv,
          isLoading: exportingFormat == FinancialReportExportFormat.csv,
          isDisabled: isBusy,
          onTap: () => onExport(FinancialReportExportFormat.csv),
        ),
      ],
    );
  }
}

class FinancialReportExportOptionTile extends StatelessWidget {
  const FinancialReportExportOptionTile({
    required this.format,
    required this.isLoading,
    required this.isDisabled,
    required this.onTap,
    super.key,
  });

  final FinancialReportExportFormat format;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = financialReportExportFormatAccentColor(format, colorScheme);
    final effectiveAccent =
        isDisabled && !isLoading ? colorScheme.onSurfaceVariant : accent;

    return AppSurface(
      padding: EdgeInsets.zero,
      backgroundColor:
          isLoading
              ? accent.withValues(alpha: 0.08)
              : colorScheme.surfaceContainerLowest,
      borderColor:
          isLoading
              ? accent.withValues(alpha: 0.38)
              : colorScheme.outlineVariant,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isDisabled ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AppIconBadge(
                  icon: financialReportExportFormatIcon(format),
                  size: 42,
                  backgroundColor: effectiveAccent.withValues(alpha: 0.12),
                  foregroundColor: effectiveAccent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextCluster(
                    title: financialReportExportFormatTitle(format),
                    subtitle: financialReportExportFormatSubtitle(format),
                    titleStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                    subtitleStyle: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    subtitleMaxLines: 2,
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child:
                      isLoading
                          ? SizedBox(
                            key: const ValueKey('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: accent,
                            ),
                          )
                          : Icon(
                            Icons.chevron_right_rounded,
                            key: const ValueKey('ready'),
                            color: effectiveAccent,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String financialReportExportFormatTitle(FinancialReportExportFormat format) {
  switch (format) {
    case FinancialReportExportFormat.pdf:
      return 'PDF Report Pack';
    case FinancialReportExportFormat.csv:
      return 'CSV Workbook Data';
  }
}

String financialReportExportFormatSubtitle(FinancialReportExportFormat format) {
  switch (format) {
    case FinancialReportExportFormat.pdf:
      return 'Cover, metrics, readiness checks, statements, and notes.';
    case FinancialReportExportFormat.csv:
      return 'Statement lines, comparatives, variances, notes, and checks.';
  }
}

IconData financialReportExportFormatIcon(FinancialReportExportFormat format) {
  switch (format) {
    case FinancialReportExportFormat.pdf:
      return Icons.picture_as_pdf_rounded;
    case FinancialReportExportFormat.csv:
      return Icons.table_chart_rounded;
  }
}

Color financialReportExportFormatAccentColor(
  FinancialReportExportFormat format,
  ColorScheme colorScheme,
) {
  switch (format) {
    case FinancialReportExportFormat.pdf:
      return colorScheme.error;
    case FinancialReportExportFormat.csv:
      return colorScheme.tertiary;
  }
}

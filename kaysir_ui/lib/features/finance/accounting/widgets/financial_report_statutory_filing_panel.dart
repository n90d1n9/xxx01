import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_statutory_filing.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportStatutoryFilingPanel extends StatelessWidget {
  const FinancialReportStatutoryFilingPanel({required this.summary, super.key});

  final FinancialReportStatutoryFilingSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent =
        summary.overdueCount > 0
            ? colorScheme.error
            : summary.dueSoonCount > 0
            ? colorScheme.tertiary
            : Colors.teal.shade700;

    return FinancialReportReleaseSignOffSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final title = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FinancialReportReleaseSignOffIcon(
                    icon: Icons.account_balance_rounded,
                    color: accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statutory Filing Tracker',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary.nextAction,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final badge = FinancialReportReleaseSignOffBadge(
                label:
                    '${summary.completeCount}/${summary.items.length} complete',
                color: accent,
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), badge],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  badge,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FinancialReportReleaseSignOffBadge(
                label: '${summary.dueSoonCount} due soon',
                color:
                    summary.dueSoonCount == 0
                        ? colorScheme.secondary
                        : colorScheme.tertiary,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.overdueCount} overdue',
                color:
                    summary.overdueCount == 0
                        ? colorScheme.secondary
                        : colorScheme.error,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.blockedCount} blocked',
                color:
                    summary.blockedCount == 0
                        ? colorScheme.secondary
                        : colorScheme.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: summary.completionRatio.clamp(0, 1).toDouble(),
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
          const SizedBox(height: 12),
          FinancialReportResponsiveWrapGrid<FinancialReportStatutoryFilingItem>(
            items: summary.items,
            breakpoints: const [
              FinancialReportResponsiveGridBreakpoint(
                minWidth: 680,
                columns: 2,
              ),
            ],
            itemBuilder:
                (_, item) => FinancialReportStatutoryFilingTile(item: item),
          ),
        ],
      ),
    );
  }
}

class FinancialReportStatutoryFilingTile extends StatelessWidget {
  const FinancialReportStatutoryFilingTile({required this.item, super.key});

  final FinancialReportStatutoryFilingItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _statusColor(item.status, colorScheme);

    return FinancialReportTintedSurface(
      color: color,
      minHeight: 136,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_kindIcon(item.kind), color: color, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FinancialReportReleaseSignOffBadge(
                label: item.status.label,
                color: color,
              ),
              FinancialReportReleaseSignOffBadge(
                label: 'Due ${_date(item.dueDate)}',
                color: colorScheme.primary,
              ),
              if (item.evidenceReference.trim().isNotEmpty)
                FinancialReportReleaseSignOffBadge(
                  label: item.evidenceReference,
                  color: colorScheme.secondary,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.owner} / ${item.reference}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(
  FinancialReportStatutoryFilingStatus status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case FinancialReportStatutoryFilingStatus.complete:
      return Colors.teal.shade700;
    case FinancialReportStatutoryFilingStatus.dueSoon:
      return colorScheme.tertiary;
    case FinancialReportStatutoryFilingStatus.pending:
      return colorScheme.primary;
    case FinancialReportStatutoryFilingStatus.overdue:
    case FinancialReportStatutoryFilingStatus.blocked:
      return colorScheme.error;
  }
}

IconData _kindIcon(FinancialReportStatutoryFilingKind kind) {
  switch (kind) {
    case FinancialReportStatutoryFilingKind.managementRelease:
      return Icons.approval_rounded;
    case FinancialReportStatutoryFilingKind.boardDistribution:
      return Icons.groups_rounded;
    case FinancialReportStatutoryFilingKind.auditorHandoff:
      return Icons.assignment_turned_in_rounded;
    case FinancialReportStatutoryFilingKind.annualCorporateTaxSupport:
      return Icons.receipt_long_rounded;
    case FinancialReportStatutoryFilingKind.statutoryArchive:
      return Icons.folder_copy_rounded;
  }
}

String _date(DateTime value) {
  return DateFormat('MMM d, yyyy').format(value);
}

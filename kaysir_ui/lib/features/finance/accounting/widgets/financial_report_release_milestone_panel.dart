import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_release_milestone.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportReleaseMilestonePanel extends StatelessWidget {
  const FinancialReportReleaseMilestonePanel({
    required this.summary,
    super.key,
  });

  final FinancialReportReleaseMilestoneSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent =
        summary.blockedCount > 0 || summary.overdueCount > 0
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
              final compact = constraints.maxWidth < 740;
              final title = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FinancialReportReleaseSignOffIcon(
                    icon: Icons.event_note_rounded,
                    color: accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Release Milestone Calendar',
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
                    '${summary.completeCount}/${summary.totalCount} milestones complete',
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
              FinancialReportReleaseSignOffBadge(
                label: '${summary.upcomingCount} upcoming',
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: summary.completionRatio.clamp(0, 1),
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 12),
          FinancialReportResponsiveWrapGrid<
            FinancialReportReleaseMilestoneItem
          >(
            items: summary.items,
            breakpoints: const [
              FinancialReportResponsiveGridBreakpoint(
                minWidth: 760,
                columns: 2,
              ),
            ],
            itemBuilder:
                (_, item) => FinancialReportReleaseMilestoneTile(item: item),
          ),
        ],
      ),
    );
  }
}

class FinancialReportReleaseMilestoneTile extends StatelessWidget {
  const FinancialReportReleaseMilestoneTile({required this.item, super.key});

  final FinancialReportReleaseMilestoneItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _statusColor(item.status, colorScheme);

    return FinancialReportTintedSurface(
      color: color,
      minHeight: 144,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MilestoneDateBadge(date: item.dueDate, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_areaIcon(item.area), color: color, size: 18),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.25,
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
                      label: item.area.label,
                      color: colorScheme.primary,
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
          ),
        ],
      ),
    );
  }
}

class _MilestoneDateBadge extends StatelessWidget {
  const _MilestoneDateBadge({required this.date, required this.color});

  final DateTime date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = DateFormat('MMM').format(date).toUpperCase();
    final day = DateFormat('d').format(date);
    return FinancialReportTintedSurface(
      color: color,
      width: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      fillAlpha: 0.11,
      borderAlpha: 0.26,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            month,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            day,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(
  FinancialReportReleaseMilestoneStatus status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case FinancialReportReleaseMilestoneStatus.complete:
      return Colors.teal.shade700;
    case FinancialReportReleaseMilestoneStatus.upcoming:
      return colorScheme.primary;
    case FinancialReportReleaseMilestoneStatus.dueSoon:
      return colorScheme.tertiary;
    case FinancialReportReleaseMilestoneStatus.overdue:
    case FinancialReportReleaseMilestoneStatus.blocked:
      return colorScheme.error;
  }
}

IconData _areaIcon(FinancialReportReleaseMilestoneArea area) {
  switch (area) {
    case FinancialReportReleaseMilestoneArea.packageIntegrity:
      return Icons.fingerprint_rounded;
    case FinancialReportReleaseMilestoneArea.signOff:
      return Icons.draw_rounded;
    case FinancialReportReleaseMilestoneArea.distribution:
      return Icons.send_rounded;
    case FinancialReportReleaseMilestoneArea.archive:
      return Icons.inventory_2_rounded;
    case FinancialReportReleaseMilestoneArea.retention:
      return Icons.manage_history_rounded;
    case FinancialReportReleaseMilestoneArea.statutoryFiling:
      return Icons.account_balance_rounded;
  }
}

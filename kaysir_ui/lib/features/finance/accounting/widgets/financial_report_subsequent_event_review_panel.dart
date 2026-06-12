import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_subsequent_event_review.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportSubsequentEventReviewPanel extends StatelessWidget {
  const FinancialReportSubsequentEventReviewPanel({
    required this.summary,
    super.key,
  });

  final FinancialReportSubsequentEventReviewSummary summary;

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
              final compact = constraints.maxWidth < 760;
              final title = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FinancialReportReleaseSignOffIcon(
                    icon: Icons.manage_search_rounded,
                    color: accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subsequent Events Review',
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
                    '${summary.completeCount}/${summary.totalCount} checks complete',
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
                label: summary.standardReference,
                color: colorScheme.primary,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.reviewWindowDays}d review window',
                color: colorScheme.secondary,
              ),
              FinancialReportReleaseSignOffBadge(
                label:
                    '${_date(summary.periodEnd)} - ${_date(summary.authorizationTargetDate)}',
                color: colorScheme.secondary,
              ),
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
            FinancialReportSubsequentEventReviewItem
          >(
            items: summary.items,
            breakpoints: const [
              FinancialReportResponsiveGridBreakpoint(
                minWidth: 760,
                columns: 2,
              ),
            ],
            itemBuilder:
                (_, item) =>
                    FinancialReportSubsequentEventReviewTile(item: item),
          ),
        ],
      ),
    );
  }
}

class FinancialReportSubsequentEventReviewTile extends StatelessWidget {
  const FinancialReportSubsequentEventReviewTile({
    required this.item,
    super.key,
  });

  final FinancialReportSubsequentEventReviewItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _statusColor(item.status, colorScheme);

    return FinancialReportTintedSurface(
      color: color,
      minHeight: 142,
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
  FinancialReportSubsequentEventReviewStatus status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case FinancialReportSubsequentEventReviewStatus.complete:
      return Colors.teal.shade700;
    case FinancialReportSubsequentEventReviewStatus.open:
      return colorScheme.primary;
    case FinancialReportSubsequentEventReviewStatus.dueSoon:
      return colorScheme.tertiary;
    case FinancialReportSubsequentEventReviewStatus.overdue:
    case FinancialReportSubsequentEventReviewStatus.blocked:
      return colorScheme.error;
  }
}

IconData _kindIcon(FinancialReportSubsequentEventReviewKind kind) {
  switch (kind) {
    case FinancialReportSubsequentEventReviewKind.packageLock:
      return Icons.lock_rounded;
    case FinancialReportSubsequentEventReviewKind.managementInquiry:
      return Icons.groups_rounded;
    case FinancialReportSubsequentEventReviewKind.adjustingEventAssessment:
      return Icons.rule_rounded;
    case FinancialReportSubsequentEventReviewKind.disclosureUpdate:
      return Icons.sticky_note_2_rounded;
    case FinancialReportSubsequentEventReviewKind.authorizationForIssue:
      return Icons.verified_rounded;
    case FinancialReportSubsequentEventReviewKind.releaseChangeFreeze:
      return Icons.ac_unit_rounded;
  }
}

String _date(DateTime value) {
  return DateFormat('MMM d, yyyy').format(value);
}

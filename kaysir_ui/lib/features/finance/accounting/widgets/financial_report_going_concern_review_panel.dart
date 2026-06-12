import 'package:flutter/material.dart';

import '../models/financial_report_going_concern_review.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportGoingConcernReviewPanel extends StatelessWidget {
  const FinancialReportGoingConcernReviewPanel({
    required this.summary,
    super.key,
  });

  final FinancialReportGoingConcernReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent =
        summary.materialUncertaintyCount > 0 || summary.attentionCount > 0
            ? colorScheme.error
            : summary.incompleteCount > 0 || summary.watchCount > 0
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
                    icon: Icons.health_and_safety_rounded,
                    color: accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Going Concern Review',
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
                label: summary.conclusion,
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
                label: '${summary.materialUncertaintyCount} uncertainty',
                color:
                    summary.materialUncertaintyCount == 0
                        ? colorScheme.secondary
                        : colorScheme.error,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.attentionCount} attention',
                color:
                    summary.attentionCount == 0
                        ? colorScheme.secondary
                        : colorScheme.error,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.watchCount} watch',
                color:
                    summary.watchCount == 0
                        ? colorScheme.secondary
                        : colorScheme.tertiary,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.incompleteCount} incomplete',
                color:
                    summary.incompleteCount == 0
                        ? colorScheme.secondary
                        : colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: summary.readinessRatio.clamp(0, 1),
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 12),
          FinancialReportResponsiveWrapGrid<
            FinancialReportGoingConcernReviewItem
          >(
            items: summary.items,
            breakpoints: const [
              FinancialReportResponsiveGridBreakpoint(
                minWidth: 760,
                columns: 2,
              ),
            ],
            itemBuilder:
                (_, item) => FinancialReportGoingConcernReviewTile(item: item),
          ),
        ],
      ),
    );
  }
}

class FinancialReportGoingConcernReviewTile extends StatelessWidget {
  const FinancialReportGoingConcernReviewTile({required this.item, super.key});

  final FinancialReportGoingConcernReviewItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _statusColor(item.status, colorScheme);

    return FinancialReportTintedSurface(
      color: color,
      minHeight: 138,
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
                label: item.metric,
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
  FinancialReportGoingConcernReviewStatus status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case FinancialReportGoingConcernReviewStatus.satisfactory:
      return Colors.teal.shade700;
    case FinancialReportGoingConcernReviewStatus.watch:
    case FinancialReportGoingConcernReviewStatus.incomplete:
      return colorScheme.tertiary;
    case FinancialReportGoingConcernReviewStatus.attention:
    case FinancialReportGoingConcernReviewStatus.materialUncertainty:
      return colorScheme.error;
  }
}

IconData _kindIcon(FinancialReportGoingConcernReviewKind kind) {
  switch (kind) {
    case FinancialReportGoingConcernReviewKind.liquidityBuffer:
      return Icons.water_drop_rounded;
    case FinancialReportGoingConcernReviewKind.operatingPerformance:
      return Icons.trending_up_rounded;
    case FinancialReportGoingConcernReviewKind.netAssetPosition:
      return Icons.account_balance_wallet_rounded;
    case FinancialReportGoingConcernReviewKind.operatingCashFlow:
      return Icons.payments_rounded;
    case FinancialReportGoingConcernReviewKind.liabilitiesPressure:
      return Icons.scale_rounded;
    case FinancialReportGoingConcernReviewKind.managementAssessment:
      return Icons.verified_user_rounded;
  }
}

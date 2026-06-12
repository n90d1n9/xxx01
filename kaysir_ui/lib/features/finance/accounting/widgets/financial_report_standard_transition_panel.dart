import 'package:flutter/material.dart';

import '../models/financial_report_standard_transition.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportStandardTransitionPanel extends StatelessWidget {
  const FinancialReportStandardTransitionPanel({
    required this.summary,
    super.key,
  });

  final FinancialReportStandardTransitionSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = _summaryColor(summary, colorScheme);

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
                    icon: Icons.rule_folder_rounded,
                    color: accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PSAK 118 Transition Readiness',
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
                label: summary.headline,
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
                label: summary.nextStandardReference,
                color: colorScheme.primary,
              ),
              FinancialReportReleaseSignOffBadge(
                label: 'Effective ${_date(summary.effectiveDate)}',
                color: colorScheme.secondary,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.readyCount} ready',
                color: Colors.teal.shade700,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.monitorCount} monitor',
                color:
                    summary.monitorCount == 0
                        ? colorScheme.secondary
                        : colorScheme.tertiary,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.actionRequiredCount} action',
                color:
                    summary.actionRequiredCount == 0
                        ? colorScheme.secondary
                        : colorScheme.error,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.overdueCount} overdue',
                color:
                    summary.overdueCount == 0
                        ? colorScheme.secondary
                        : colorScheme.error,
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
            FinancialReportStandardTransitionItem
          >(
            items: summary.items,
            breakpoints: const [
              FinancialReportResponsiveGridBreakpoint(
                minWidth: 760,
                columns: 2,
              ),
            ],
            itemBuilder:
                (_, item) => FinancialReportStandardTransitionTile(item: item),
          ),
        ],
      ),
    );
  }
}

class FinancialReportStandardTransitionTile extends StatelessWidget {
  const FinancialReportStandardTransitionTile({required this.item, super.key});

  final FinancialReportStandardTransitionItem item;

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
                label: item.metric,
                color: colorScheme.primary,
              ),
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

Color _summaryColor(
  FinancialReportStandardTransitionSummary summary,
  ColorScheme colorScheme,
) {
  if (summary.overdueCount > 0 || summary.actionRequiredCount > 0) {
    return colorScheme.error;
  }
  if (summary.monitorCount > 0) {
    return colorScheme.tertiary;
  }
  return Colors.teal.shade700;
}

Color _statusColor(
  FinancialReportStandardTransitionStatus status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case FinancialReportStandardTransitionStatus.ready:
      return Colors.teal.shade700;
    case FinancialReportStandardTransitionStatus.monitor:
      return colorScheme.tertiary;
    case FinancialReportStandardTransitionStatus.actionRequired:
    case FinancialReportStandardTransitionStatus.overdue:
      return colorScheme.error;
    case FinancialReportStandardTransitionStatus.notApplicable:
      return colorScheme.secondary;
  }
}

IconData _kindIcon(FinancialReportStandardTransitionKind kind) {
  switch (kind) {
    case FinancialReportStandardTransitionKind.effectiveStandard:
      return Icons.event_available_rounded;
    case FinancialReportStandardTransitionKind.profitLossSubtotals:
      return Icons.functions_rounded;
    case FinancialReportStandardTransitionKind.incomeExpenseClassification:
      return Icons.account_tree_rounded;
    case FinancialReportStandardTransitionKind.managementPerformanceMeasures:
      return Icons.insights_rounded;
    case FinancialReportStandardTransitionKind.comparativeTransition:
      return Icons.compare_arrows_rounded;
    case FinancialReportStandardTransitionKind.cashFlowPresentation:
      return Icons.payments_rounded;
    case FinancialReportStandardTransitionKind.disclosureUpdate:
      return Icons.notes_rounded;
  }
}

String _date(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_gap_focus_service.dart';
import '../services/project_domain_gap_summary_service.dart';
import '../services/project_table_custom_column_service.dart';
import 'project_domain_gap_lens_bar.dart';

class ProjectTableCustomColumnBrief extends StatelessWidget {
  const ProjectTableCustomColumnBrief({
    required this.columns,
    this.domainGapFocus = ProjectDomainGapFocus.all,
    this.onDomainGapFocusChanged,
    super.key,
  });

  final List<ProjectTableCustomColumn> columns;
  final ProjectDomainGapFocus domainGapFocus;
  final ValueChanged<ProjectDomainGapFocus>? onDomainGapFocusChanged;

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final summary = buildProjectDomainGapSummary(columns: columns);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BriefHeading(summary: summary),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusPill(
                  label: summary.coverageLabel,
                  icon: Icons.fact_check_outlined,
                  color:
                      summary.isComplete
                          ? Colors.green.shade700
                          : colorScheme.primary,
                  tooltip:
                      '${summary.coveragePercent}% of selected domain fields are filled.',
                  maxWidth: 150,
                ),
                if (summary.missingFieldCount > 0)
                  AppStatusPill(
                    label: 'Any gaps: ${summary.missingFieldCount}',
                    icon: ProjectDomainGapFocus.missingAny.icon,
                    color: colorScheme.secondary,
                    maxWidth: 160,
                  ),
                if (summary.missingRequiredCount > 0)
                  AppStatusPill(
                    label: 'Required gaps: ${summary.missingRequiredCount}',
                    icon: Icons.priority_high_rounded,
                    color: colorScheme.error,
                    maxWidth: 180,
                  ),
                if (summary.missingRecommendedCount > 0)
                  AppStatusPill(
                    label:
                        'Recommended gaps: ${summary.missingRecommendedCount}',
                    icon: Icons.fact_check_outlined,
                    color: colorScheme.primary,
                    maxWidth: 220,
                  ),
                if (summary.missingRiskSignalCount > 0)
                  AppStatusPill(
                    label: 'Risk gaps: ${summary.missingRiskSignalCount}',
                    icon: Icons.sensors_outlined,
                    color: colorScheme.tertiary,
                    maxWidth: 160,
                  ),
                AppStatusPill(
                  label: '${columns.length} fields',
                  icon: Icons.view_column_outlined,
                  color: colorScheme.secondary,
                  maxWidth: 132,
                ),
              ],
            ),
            if (onDomainGapFocusChanged != null && summary.hasGaps) ...[
              const SizedBox(height: 10),
              ProjectDomainGapLensBar(
                summary: summary,
                value: domainGapFocus,
                onChanged: onDomainGapFocusChanged!,
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final column in columns)
                  AppStatusPill(
                    label: '${column.label}: ${column.gapSummaryLabel}',
                    icon: _columnIcon(column),
                    color: _columnColor(column, colorScheme),
                    tooltip: column.summaryLabel,
                    maxWidth: 240,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BriefHeading extends StatelessWidget {
  const _BriefHeading({required this.summary});

  final ProjectDomainGapSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.extension_outlined,
              color: colorScheme.tertiary,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Domain Gap Workbench',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                '${summary.coveragePercent}% complete across ${summary.columnCount} adaptive fields',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Color _columnColor(ProjectTableCustomColumn column, ColorScheme colorScheme) {
  if (column.missingRequiredProjectCount > 0) return colorScheme.error;
  if (column.missingRiskSignalProjectCount > 0) return colorScheme.tertiary;
  if (column.missingRecommendedProjectCount > 0) return colorScheme.primary;
  return Colors.green.shade700;
}

IconData _columnIcon(ProjectTableCustomColumn column) {
  if (column.missingRequiredProjectCount > 0) {
    return Icons.priority_high_rounded;
  }
  if (column.missingRiskSignalProjectCount > 0) return Icons.sensors_outlined;
  if (column.missingRecommendedProjectCount > 0) {
    return Icons.fact_check_outlined;
  }
  return Icons.check_circle_outline;
}

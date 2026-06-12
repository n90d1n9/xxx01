import 'package:flutter/material.dart';

import '../logic/survey_response_section_flow.dart';
import 'survey_response_section_metric_pill.dart';
import 'survey_response_section_status_chip.dart';

/// Shows the selected response section title, readiness, and progress metrics.
class SurveyResponseSectionHeader extends StatelessWidget {
  final SurveyResponseSectionPage page;
  final SurveyResponseSectionPageStatus? status;

  const SurveyResponseSectionHeader({
    super.key,
    required this.page,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveStatus =
        status ?? SurveyResponseSectionPageStatus(page: page, issues: const []);
    final progressColor = _progressColor(colorScheme, effectiveStatus);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    page.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SurveyResponseSectionStatusChip(status: effectiveStatus),
              ],
            ),
            if (page.description.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                page.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: page.completionRate,
                minHeight: 8,
                color: progressColor,
                backgroundColor: colorScheme.surface,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SurveyResponseSectionMetricPill(
                  label: effectiveStatus.answerProgressLabel,
                  icon: Icons.checklist_outlined,
                  color: colorScheme.primary,
                ),
                if (effectiveStatus.requiredIssueCount > 0)
                  SurveyResponseSectionMetricPill(
                    label: _plural(
                      effectiveStatus.requiredIssueCount,
                      'required missing',
                      'required missing',
                    ),
                    icon: Icons.star_rounded,
                    color: colorScheme.error,
                  ),
                if (effectiveStatus.invalidIssueCount > 0)
                  SurveyResponseSectionMetricPill(
                    label: _plural(
                      effectiveStatus.invalidIssueCount,
                      'invalid answer',
                    ),
                    icon: Icons.error_outline,
                    color: colorScheme.error,
                  ),
                if (!effectiveStatus.hasIssues && effectiveStatus.isComplete)
                  SurveyResponseSectionMetricPill(
                    label: 'Required complete',
                    icon: Icons.verified_outlined,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _progressColor(
    ColorScheme colorScheme,
    SurveyResponseSectionPageStatus status,
  ) {
    if (status.hasIssues) {
      return colorScheme.error;
    }

    if (status.isComplete) {
      return colorScheme.primary;
    }

    return colorScheme.secondary;
  }

  String _plural(int count, String singular, [String? plural]) {
    return count == 1 ? '1 $singular' : '$count ${plural ?? '${singular}s'}';
  }
}

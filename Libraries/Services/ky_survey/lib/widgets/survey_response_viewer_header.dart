import 'package:flutter/material.dart';

import '../logic/survey_response_session_summary.dart';
import '../models/survey.dart';

/// Presents response identity, answer progress, and session status.
class SurveyResponseViewerHeader extends StatelessWidget {
  final Survey survey;
  final SurveyResponseSessionSummary summary;

  const SurveyResponseViewerHeader({
    super.key,
    required this.survey,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _statusColor(colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        survey.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (survey.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          survey.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusPill(
                  label: summary.primaryStatusLabel,
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: summary.completionRate.clamp(0, 1).toDouble(),
                backgroundColor: colorScheme.surface,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeaderMetric(
                  icon: Icons.checklist_rtl_outlined,
                  label:
                      '${summary.answeredQuestionCount} of ${summary.visibleQuestionCount} answered',
                ),
                _HeaderMetric(
                  icon: Icons.percent_outlined,
                  label: '${summary.completionPercent}% complete',
                ),
                _HeaderMetric(
                  icon: Icons.assignment_turned_in_outlined,
                  label: summary.requiredProgressLabel,
                ),
                _HeaderMetric(
                  icon: Icons.schedule_outlined,
                  label: summary.secondaryStatusLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(ColorScheme colorScheme) {
    if (summary.issues.isNotEmpty) {
      return colorScheme.error;
    }

    if (summary.canSubmit) {
      return colorScheme.tertiary;
    }

    return colorScheme.primary;
  }
}

/// Shows a compact response status label in the viewer header.
class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Displays one concise response progress attribute.
class _HeaderMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderMetric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

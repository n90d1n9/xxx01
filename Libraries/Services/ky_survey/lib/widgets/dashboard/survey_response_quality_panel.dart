import 'package:flutter/material.dart';

import '../../analytics/survey_response_quality_insights.dart';
import '../../models/survey_response_quality.dart';
import 'survey_dashboard_shared.dart';
import 'survey_metric_card.dart';

class SurveyResponseQualityPanel extends StatelessWidget {
  final SurveyResponseQualityInsights insights;

  const SurveyResponseQualityPanel({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    final queue = insights.reviewQueue(limit: 6);

    return SurveySectionStack(
      children: [
        SurveyMetricGrid(
          cards: [
            SurveyMetricCard(
              icon: Icons.verified_outlined,
              label: 'Clean submitted',
              value: insights.cleanSubmittedResponseCount().toString(),
              detail: '${insights.submittedResponseCount} submitted total',
            ),
            SurveyMetricCard(
              icon: Icons.flag_outlined,
              label: 'Flagged',
              value: insights.flaggedResponseCount().toString(),
              detail: '${insights.signalCount()} quality signals',
            ),
            SurveyMetricCard(
              icon: Icons.priority_high_outlined,
              label: 'Critical',
              value: insights.criticalSignalCount().toString(),
              detail: '${insights.warningSignalCount()} warnings',
            ),
          ],
        ),
        const SurveySectionHeader(title: 'Review Queue'),
        if (queue.isEmpty)
          const SurveyEmptyState(
            icon: Icons.fact_check_outlined,
            title: 'No response quality flags',
            subtitle: 'Submitted responses are ready for analysis.',
          )
        else
          ...queue.map((signal) => _QualitySignalTile(signal: signal)),
      ],
    );
  }
}

class _QualitySignalTile extends StatelessWidget {
  final SurveyResponseQualitySignal signal;

  const _QualitySignalTile({required this.signal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _severityColor(colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_severityIcon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signal.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _detailText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _SeverityBadge(signal: signal, color: color),
          ],
        ),
      ),
    );
  }

  String get _detailText {
    final question = signal.question?.text.trim();
    final questionText = question == null || question.isEmpty
        ? null
        : ' • $question';
    return '${signal.survey.title} • ${signal.response.respondentName}${questionText ?? ''}';
  }

  IconData get _severityIcon {
    switch (signal.severity) {
      case SurveyResponseQualitySeverity.info:
        return Icons.info_outline;
      case SurveyResponseQualitySeverity.warning:
        return Icons.warning_amber_outlined;
      case SurveyResponseQualitySeverity.critical:
        return Icons.error_outline;
    }
  }

  Color _severityColor(ColorScheme colorScheme) {
    switch (signal.severity) {
      case SurveyResponseQualitySeverity.info:
        return colorScheme.primary;
      case SurveyResponseQualitySeverity.warning:
        return colorScheme.tertiary;
      case SurveyResponseQualitySeverity.critical:
        return colorScheme.error;
    }
  }
}

class _SeverityBadge extends StatelessWidget {
  final SurveyResponseQualitySignal signal;
  final Color color;

  const _SeverityBadge({required this.signal, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          signal.severity.name.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

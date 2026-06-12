import 'package:flutter/material.dart';

import '../../models/survey.dart';
import '../../models/survey_status.dart';
import '../../validation/survey_readiness_validator.dart';
import 'survey_status_chip.dart';

typedef SurveyStatusChanged = void Function(Survey survey, SurveyStatus status);

class SurveyLifecyclePanel extends StatelessWidget {
  final List<Survey> surveys;
  final SurveyStatusChanged onStatusChanged;

  const SurveyLifecyclePanel({
    super.key,
    required this.surveys,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) {
      return const _LifecycleEmptyState();
    }

    return Column(
      children: surveys.map((survey) {
        final readiness = SurveyReadinessValidator.validate(survey);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _LifecycleTile(
            survey: survey,
            readiness: readiness,
            onStatusChanged: onStatusChanged,
          ),
        );
      }).toList(),
    );
  }
}

class _LifecycleTile extends StatelessWidget {
  final Survey survey;
  final SurveyReadinessResult readiness;
  final SurveyStatusChanged onStatusChanged;

  const _LifecycleTile({
    required this.survey,
    required this.readiness,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nextStatuses = SurveyReadinessValidator.nextStatuses(survey);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    survey.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SurveyStatusChip(status: survey.status),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _ReadinessChip(readiness: readiness),
                Text(
                  '${survey.questions.length} questions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${survey.responseCount} / ${survey.targetResponses} responses',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (readiness.issues.isNotEmpty) ...[
              const SizedBox(height: 12),
              _IssuePreview(readiness: readiness),
            ],
            if (nextStatuses.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: nextStatuses.map((status) {
                  return OutlinedButton.icon(
                    icon: Icon(_statusIcon(status), size: 18),
                    label: Text(status.label),
                    onPressed: () => onStatusChanged(survey, status),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(SurveyStatus status) {
    switch (status) {
      case SurveyStatus.draft:
        return Icons.edit_note_outlined;
      case SurveyStatus.review:
        return Icons.rate_review_outlined;
      case SurveyStatus.published:
        return Icons.publish_outlined;
      case SurveyStatus.collecting:
        return Icons.play_circle_outline;
      case SurveyStatus.analyzing:
        return Icons.query_stats_outlined;
      case SurveyStatus.closed:
        return Icons.lock_outline;
      case SurveyStatus.archived:
        return Icons.archive_outlined;
    }
  }
}

class _ReadinessChip extends StatelessWidget {
  final SurveyReadinessResult readiness;

  const _ReadinessChip({required this.readiness});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = readiness.hasBlockers
        ? colorScheme.error
        : readiness.hasWarnings
        ? colorScheme.tertiary
        : colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          readiness.summary,
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

class _IssuePreview extends StatelessWidget {
  final SurveyReadinessResult readiness;

  const _IssuePreview({required this.readiness});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final issue = readiness.issues.first;

    return Row(
      children: [
        Icon(
          issue.severity == SurveyReadinessSeverity.blocker
              ? Icons.error_outline
              : Icons.info_outline,
          size: 18,
          color: issue.severity == SurveyReadinessSeverity.blocker
              ? colorScheme.error
              : colorScheme.tertiary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            issue.message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _LifecycleEmptyState extends StatelessWidget {
  const _LifecycleEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(Icons.route_outlined, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Lifecycle queue is empty.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

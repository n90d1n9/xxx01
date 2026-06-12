import 'package:flutter/material.dart';

import '../../analytics/survey_insights.dart';
import '../../analytics/survey_response_insights.dart';
import '../../analytics/survey_response_quality_insights.dart';
import '../../analytics/survey_response_review_insights.dart';
import '../../models/question.dart';
import '../../models/survey.dart';
import 'survey_dashboard_shared.dart';
import 'survey_metric_card.dart';
import 'survey_progress_list.dart';
import 'survey_response_quality_panel.dart';
import 'survey_response_review_panel.dart';

/// Renders analytics, response quality signals, and review workflow insights.
class SurveyAnalyticsSection extends StatelessWidget {
  final SurveyInsights insights;
  final SurveyResponseInsights responseInsights;
  final SurveyResponseQualityInsights responseQualityInsights;
  final SurveyResponseReviewInsights responseReviewInsights;
  final SurveyResponseReviewStatusChanged? onResponseReviewStatusChanged;
  final List<Survey> surveys;

  const SurveyAnalyticsSection({
    super.key,
    required this.insights,
    required this.responseInsights,
    required this.responseQualityInsights,
    required this.responseReviewInsights,
    this.onResponseReviewStatusChanged,
    required this.surveys,
  });

  @override
  Widget build(BuildContext context) {
    return SurveySectionStack(
      children: [
        SurveyMetricGrid(
          cards: [
            SurveyMetricCard(
              icon: Icons.mark_email_read_outlined,
              label: 'Submitted',
              value: responseInsights.submittedResponseCount.toString(),
              detail: '${responseInsights.draftResponseCount} drafts',
            ),
            SurveyMetricCard(
              icon: Icons.query_stats_outlined,
              label: 'Avg completion',
              value: '${(responseInsights.averageCompletion * 100).round()}%',
              detail: 'Submitted responses',
            ),
            SurveyMetricCard(
              icon: Icons.flag_outlined,
              label: 'Quality flags',
              value: responseQualityInsights.flaggedResponseCount().toString(),
              detail:
                  '${responseQualityInsights.criticalSignalCount()} critical',
            ),
          ],
        ),
        const SurveySectionHeader(title: 'Question Mix'),
        _QuestionMix(insights: insights),
        const SurveySectionHeader(title: 'Response Signals'),
        _QuestionSignals(breakdowns: responseInsights.notableBreakdowns()),
        const SurveySectionHeader(title: 'Response Quality'),
        SurveyResponseQualityPanel(insights: responseQualityInsights),
        const SurveySectionHeader(title: 'Review Workflow'),
        SurveyResponseReviewPanel(
          insights: responseReviewInsights,
          onStatusChanged: onResponseReviewStatusChanged,
        ),
        const SurveySectionHeader(title: 'Top Response Sources'),
        SurveyProgressList(surveys: insights.topSurveysByResponses()),
      ],
    );
  }
}

class _QuestionSignals extends StatelessWidget {
  final List<QuestionResponseBreakdown> breakdowns;

  const _QuestionSignals({required this.breakdowns});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (breakdowns.isEmpty) {
      return const SurveyEmptyState(
        icon: Icons.insights_outlined,
        title: 'No submitted response signals',
        subtitle: 'Submitted participant responses will appear here.',
      );
    }

    return Column(
      children: breakdowns.map((breakdown) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.troubleshoot_outlined, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          breakdown.question.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${breakdown.answeredCount} answers • ${breakdown.missingRequiredCount} missing required',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    breakdown.primaryInsight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuestionMix extends StatelessWidget {
  final SurveyInsights insights;

  const _QuestionMix({required this.insights});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = insights.totalQuestions;

    return Column(
      children: insights.questionTypeCounts.entries.map((entry) {
        final count = entry.value;
        if (count == 0) {
          return const SizedBox.shrink();
        }

        final progress = total == 0 ? 0.0 : count / total;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 144,
                child: Text(
                  _questionTypeLabel(entry.key),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                count.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _questionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice:
        return 'Single choice';
      case QuestionType.multipleChoice:
        return 'Multiple choice';
      case QuestionType.singleLineText:
        return 'Short answer';
      case QuestionType.multiLineText:
        return 'Long answer';
      case QuestionType.number:
        return 'Number';
      case QuestionType.date:
        return 'Date';
      case QuestionType.rating:
        return 'Rating';
    }
  }
}

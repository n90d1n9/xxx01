import 'package:flutter/material.dart';

import '../../analytics/survey_evidence_sync_insights.dart';
import '../../analytics/survey_evidence_upload_queue_insights.dart';
import '../../analytics/survey_insights.dart';
import '../../analytics/survey_operations_center_insights.dart';
import '../../analytics/survey_response_sync_readiness.dart';
import '../../models/survey.dart';
import '../../models/survey_status.dart';
import 'survey_dashboard_shared.dart';
import 'survey_evidence_upload_plan_panel.dart';
import 'survey_metric_card.dart';
import 'survey_operations_center_panel.dart';
import 'survey_progress_list.dart';
import 'survey_status_chip.dart';

/// Renders high-level survey metrics and role-aware operations shortcuts.
class SurveyOverviewSection extends StatelessWidget {
  final SurveyInsights insights;
  final SurveyResponseSyncReadinessInsights responseSyncReadiness;
  final SurveyEvidenceSyncInsights evidenceSyncInsights;
  final List<Survey> surveys;
  final ValueChanged<Survey>? onOpenSurvey;
  final ValueChanged<SurveyResponseSyncReadiness>? onOpenResponse;
  final SurveyEvidenceUploadQueueInsights? evidenceUploadQueueInsights;
  final SurveyEvidenceUploadPlanAction? onRunEvidenceUploadPlan;
  final String runEvidenceUploadPlanLabel;
  final Set<String> activeEvidenceUploadKeys;
  final VoidCallback? onRunDueEvidenceUploads;
  final VoidCallback? onMaintainEvidenceUploadQueue;
  final VoidCallback? onRequeueFailedEvidenceUploads;

  const SurveyOverviewSection({
    super.key,
    required this.insights,
    required this.responseSyncReadiness,
    required this.evidenceSyncInsights,
    required this.surveys,
    this.onOpenSurvey,
    this.onOpenResponse,
    this.evidenceUploadQueueInsights,
    this.onRunEvidenceUploadPlan,
    this.runEvidenceUploadPlanLabel = 'Upload ready',
    this.activeEvidenceUploadKeys = const {},
    this.onRunDueEvidenceUploads,
    this.onMaintainEvidenceUploadQueue,
    this.onRequeueFailedEvidenceUploads,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final operationsInsights = SurveyOperationsCenterInsights.evaluate(
      responseReadiness: responseSyncReadiness,
      evidenceSyncInsights: evidenceSyncInsights,
      uploadQueueInsights: evidenceUploadQueueInsights,
    );

    return SurveySectionStack(
      children: [
        SurveyMetricGrid(
          cards: [
            SurveyMetricCard(
              icon: Icons.ballot_outlined,
              label: 'Total surveys',
              value: insights.totalSurveys.toString(),
              detail: '${insights.liveSurveys} live',
              accentColor: colorScheme.primary,
            ),
            SurveyMetricCard(
              icon: Icons.checklist_rtl_outlined,
              label: 'Questions',
              value: insights.totalQuestions.toString(),
              detail: '${insights.requiredQuestions} required',
              accentColor: colorScheme.secondary,
            ),
            SurveyMetricCard(
              icon: Icons.groups_2_outlined,
              label: 'Responses',
              value: insights.totalResponses.toString(),
              detail: '${(insights.responseProgress * 100).round()}% target',
              accentColor: colorScheme.tertiary,
            ),
            SurveyMetricCard(
              icon: Icons.assignment_turned_in_outlined,
              label: 'Completed',
              value: insights.completedSurveys.toString(),
              detail: '${insights.draftSurveys} drafts',
              accentColor: colorScheme.error,
            ),
          ],
        ),
        SurveyOperationsCenterPanel(
          insights: operationsInsights,
          visibleActionLimit: 3,
          onOpenResponse: onOpenResponse,
          onRunEvidenceUploadPlan: onRunEvidenceUploadPlan,
          runEvidenceUploadPlanLabel: runEvidenceUploadPlanLabel,
          activeEvidenceUploadKeys: activeEvidenceUploadKeys,
          onRunDueEvidenceUploads: onRunDueEvidenceUploads,
          onMaintainEvidenceUploadQueue: onMaintainEvidenceUploadQueue,
          onRequeueFailedEvidenceUploads: onRequeueFailedEvidenceUploads,
        ),
        SurveySectionHeader(
          title: 'Lifecycle Pipeline',
          trailing:
              '${insights.averageQuestionsPerSurvey.toStringAsFixed(1)} avg questions',
        ),
        _StatusPipeline(insights: insights),
        const SurveySectionHeader(title: 'Collection Progress'),
        SurveyProgressList(
          surveys: insights.topSurveysByResponses(limit: 5),
          onSurveySelected: onOpenSurvey,
        ),
        _AttentionList(items: insights.attentionItems()),
      ],
    );
  }
}

class _StatusPipeline extends StatelessWidget {
  final SurveyInsights insights;

  const _StatusPipeline({required this.insights});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: SurveyStatus.values.map((status) {
        final count = insights.statusCounts[status] ?? 0;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SurveyStatusChip(status: status),
                const SizedBox(width: 10),
                Text(
                  count.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AttentionList extends StatelessWidget {
  final List<SurveyAttentionItem> items;

  const _AttentionList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SurveySectionStack(
      children: [
        const SurveySectionHeader(title: 'Attention'),
        ...items.take(3).map((item) => _AttentionTile(item: item)),
      ],
    );
  }
}

class _AttentionTile extends StatelessWidget {
  final SurveyAttentionItem item;

  const _AttentionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = item.severity == SurveyAttentionSeverity.high
        ? colorScheme.error
        : colorScheme.tertiary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.priority_high_outlined, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${item.survey.title}: ${item.reason}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
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

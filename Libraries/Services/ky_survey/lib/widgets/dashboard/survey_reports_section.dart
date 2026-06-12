import 'package:flutter/material.dart';

import '../../analytics/survey_evidence_sync_insights.dart';
import '../../analytics/survey_evidence_upload_queue_insights.dart';
import '../../analytics/survey_evidence_upload_planner.dart';
import '../../analytics/survey_insights.dart';
import '../../analytics/survey_operations_center_insights.dart';
import '../../analytics/survey_response_insights.dart';
import '../../analytics/survey_response_sync_readiness.dart';
import '../../models/survey.dart';
import 'survey_dashboard_shared.dart';
import 'survey_evidence_upload_queue_panel_slot.dart';
import 'survey_evidence_sync_panel.dart';
import 'survey_evidence_upload_plan_panel.dart';
import 'survey_evidence_upload_queue_status_panel.dart';
import 'survey_metric_card.dart';
import 'survey_operations_center_panel.dart';
import 'survey_requested_section_focus.dart';
import 'survey_status_chip.dart';

/// Renders report readiness, export context, and evidence sync work queues.
class SurveyReportsSection extends StatefulWidget {
  final SurveyInsights insights;
  final SurveyResponseInsights responseInsights;
  final SurveyResponseSyncReadinessInsights responseSyncReadiness;
  final SurveyEvidenceSyncInsights evidenceSyncInsights;
  final List<Survey> surveys;
  final ValueChanged<SurveyResponseSyncReadiness>? onOpenResponse;
  final SurveyEvidenceUploadPlanAction? onRunEvidenceUploadPlan;
  final String runEvidenceUploadPlanLabel;
  final SurveyEvidenceUploadTaskAction? onQueueEvidenceUpload;
  final SurveyEvidenceUploadTaskAction? onRetryEvidenceUpload;
  final SurveyEvidenceUploadTaskAction? onFixEvidenceUpload;
  final SurveyEvidenceUploadTaskAction? onMonitorEvidenceUpload;
  final Set<String> activeEvidenceUploadKeys;
  final SurveyEvidenceUploadQueuePanelBuilder? evidenceUploadQueuePanelBuilder;
  final SurveyEvidenceUploadQueueInsights? evidenceUploadQueueInsights;
  final VoidCallback? onRunDueEvidenceUploads;
  final VoidCallback? onMaintainEvidenceUploadQueue;
  final VoidCallback? onRequeueFailedEvidenceUploads;
  final int evidenceSyncFocusRequestId;

  const SurveyReportsSection({
    super.key,
    required this.insights,
    required this.responseInsights,
    required this.responseSyncReadiness,
    required this.evidenceSyncInsights,
    required this.surveys,
    this.onOpenResponse,
    this.onRunEvidenceUploadPlan,
    this.runEvidenceUploadPlanLabel = 'Upload ready',
    this.onQueueEvidenceUpload,
    this.onRetryEvidenceUpload,
    this.onFixEvidenceUpload,
    this.onMonitorEvidenceUpload,
    this.activeEvidenceUploadKeys = const {},
    this.evidenceUploadQueuePanelBuilder,
    this.evidenceUploadQueueInsights,
    this.onRunDueEvidenceUploads,
    this.onMaintainEvidenceUploadQueue,
    this.onRequeueFailedEvidenceUploads,
    this.evidenceSyncFocusRequestId = 0,
  });

  @override
  State<SurveyReportsSection> createState() => _SurveyReportsSectionState();
}

class _SurveyReportsSectionState extends State<SurveyReportsSection> {
  @override
  Widget build(BuildContext context) {
    final uploadPlan = SurveyEvidenceUploadPlanner(
      insights: widget.evidenceSyncInsights,
    ).createPlan(limit: 6);
    final uploadQueuePanel = widget.evidenceUploadQueuePanelBuilder?.call(
      context,
      uploadPlan,
    );
    final operationsInsights = SurveyOperationsCenterInsights.evaluate(
      responseReadiness: widget.responseSyncReadiness,
      evidenceSyncInsights: widget.evidenceSyncInsights,
      uploadPlan: uploadPlan,
      uploadQueueInsights: widget.evidenceUploadQueueInsights,
    );

    return SurveySectionStack(
      children: [
        SurveyOperationsCenterPanel(
          insights: operationsInsights,
          onOpenResponse: widget.onOpenResponse,
          onRunEvidenceUploadPlan: widget.onRunEvidenceUploadPlan,
          runEvidenceUploadPlanLabel: widget.runEvidenceUploadPlanLabel,
          activeEvidenceUploadKeys: widget.activeEvidenceUploadKeys,
          onRunDueEvidenceUploads: widget.onRunDueEvidenceUploads,
          onMaintainEvidenceUploadQueue: widget.onMaintainEvidenceUploadQueue,
          onRequeueFailedEvidenceUploads: widget.onRequeueFailedEvidenceUploads,
        ),
        SurveyMetricGrid(
          cards: [
            SurveyMetricCard(
              icon: Icons.summarize_outlined,
              label: 'Report-ready',
              value: widget.responseInsights.reportReadySurveyCount.toString(),
              detail:
                  '${widget.responseInsights.submittedResponseCount} submitted responses',
            ),
            SurveyMetricCard(
              icon: Icons.archive_outlined,
              label: 'Closed surveys',
              value: widget.insights.completedSurveys.toString(),
              detail: 'Ready for archive',
            ),
            SurveyMetricCard(
              icon: Icons.cloud_done_outlined,
              label: 'Evidence uploaded',
              value: _evidenceUploadValue,
              detail: widget.evidenceSyncInsights.statusLabel,
            ),
          ],
        ),
        const SurveySectionHeader(title: 'Report Packets'),
        if (widget.responseInsights.summaries.isEmpty)
          const SurveyEmptyState(
            icon: Icons.summarize_outlined,
            title: 'No report packets',
            subtitle: 'Create a survey to prepare report packets.',
          )
        else
          ...widget.responseInsights.summaries.map(
            (summary) => _ReportTile(summary: summary),
          ),
        SurveyRequestedSectionFocus(
          requestId: widget.evidenceSyncFocusRequestId,
          semanticsLabel: 'Focused evidence sync work area',
          child: SurveySectionStack(
            children: [
              if (uploadQueuePanel != null) ...[
                const SurveySectionHeader(title: 'Evidence Upload Queue'),
                uploadQueuePanel,
              ] else if (widget.evidenceUploadQueueInsights != null) ...[
                const SurveySectionHeader(title: 'Evidence Upload Queue'),
                SurveyEvidenceUploadQueueStatusPanel(
                  insights: widget.evidenceUploadQueueInsights!,
                  onRunDueUploads: widget.onRunDueEvidenceUploads,
                  onMaintainQueue: widget.onMaintainEvidenceUploadQueue,
                  onRequeueFailedUploads: widget.onRequeueFailedEvidenceUploads,
                ),
              ],
              const SurveySectionHeader(title: 'Evidence Upload Plan'),
              SurveyEvidenceUploadPlanPanel(
                plan: uploadPlan,
                onRunUploadPlan: widget.onRunEvidenceUploadPlan,
                runUploadPlanLabel: widget.runEvidenceUploadPlanLabel,
                onQueueUpload: widget.onQueueEvidenceUpload,
                onRetryUpload: widget.onRetryEvidenceUpload,
                onFixEvidence: widget.onFixEvidenceUpload,
                onMonitorUpload: widget.onMonitorEvidenceUpload,
                activeUploadKeys: widget.activeEvidenceUploadKeys,
              ),
              const SurveySectionHeader(title: 'Evidence Sync Queue'),
              SurveyEvidenceSyncPanel(insights: widget.evidenceSyncInsights),
            ],
          ),
        ),
      ],
    );
  }

  String get _evidenceUploadValue {
    if (widget.evidenceSyncInsights.requiredUploadCount > 0) {
      return '${widget.evidenceSyncInsights.requiredUploadedCount}/${widget.evidenceSyncInsights.requiredUploadCount}';
    }

    if (widget.evidenceSyncInsights.totalAttachmentCount > 0) {
      return '${widget.evidenceSyncInsights.uploadedCount}/${widget.evidenceSyncInsights.totalAttachmentCount}';
    }

    return '0';
  }
}

class _ReportTile extends StatelessWidget {
  final SurveyResponseSummary summary;

  const _ReportTile({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final survey = summary.survey;
    final ready = summary.submittedResponses > 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              ready ? Icons.task_alt_outlined : Icons.hourglass_empty_outlined,
              color: ready ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    survey.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ready
                        ? '${summary.submittedResponses} submitted • ${summary.draftResponses} draft • ${(summary.averageCompletion * 100).round()}% complete'
                        : '${summary.draftResponses} drafts • awaiting submitted responses',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SurveyStatusChip(status: survey.status),
          ],
        ),
      ),
    );
  }
}

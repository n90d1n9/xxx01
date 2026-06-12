import 'package:flutter/material.dart';

import '../../analytics/survey_operations_center_insights.dart';
import '../../analytics/survey_response_sync_readiness.dart';
import '../../logic/survey_evidence_upload_plan_activity.dart';
import '../survey_feedback_tone.dart';
import 'survey_evidence_upload_plan_panel.dart';
import 'survey_read_only_pill.dart';

part 'survey_operations_center_panel_actions.dart';
part 'survey_operations_center_panel_header.dart';
part 'survey_operations_center_panel_metrics.dart';

/// Renders a reusable command surface for survey operations follow-up.
class SurveyOperationsCenterPanel extends StatelessWidget {
  final SurveyOperationsCenterInsights insights;
  final ValueChanged<SurveyResponseSyncReadiness>? onOpenResponse;
  final SurveyEvidenceUploadPlanAction? onRunEvidenceUploadPlan;
  final VoidCallback? onRunDueEvidenceUploads;
  final VoidCallback? onMaintainEvidenceUploadQueue;
  final VoidCallback? onRequeueFailedEvidenceUploads;
  final String runEvidenceUploadPlanLabel;
  final Set<String> activeEvidenceUploadKeys;
  final int visibleActionLimit;

  const SurveyOperationsCenterPanel({
    super.key,
    required this.insights,
    this.onOpenResponse,
    this.onRunEvidenceUploadPlan,
    this.onRunDueEvidenceUploads,
    this.onMaintainEvidenceUploadQueue,
    this.onRequeueFailedEvidenceUploads,
    this.runEvidenceUploadPlanLabel = 'Upload ready',
    this.activeEvidenceUploadKeys = const {},
    this.visibleActionLimit = 4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final toneStyle = SurveyFeedbackToneStyle.resolve(
      colorScheme,
      _feedbackTone,
    );
    final primaryAction = insights.primaryAction;
    final actions = insights.actions.take(visibleActionLimit).toList();
    final uploadActivity = _uploadActivity;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: toneStyle.color.withValues(alpha: 0.36)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 14,
              children: [
                _OperationsHeader(
                  icon: toneStyle.icon,
                  color: toneStyle.color,
                  status: insights.statusLabel,
                  detail: insights.detailLabel,
                ),
                _PrimaryOperationButton(
                  action: primaryAction,
                  labelOverride: _labelOverrideFor(
                    primaryAction,
                    uploadActivity,
                  ),
                  showDisabledCommand: _showDisabledCommandFor(
                    primaryAction,
                    uploadActivity,
                  ),
                  onPressed: _callbackFor(primaryAction),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _OperationsMetricStrip(insights: insights),
            const SizedBox(height: 16),
            Divider(color: colorScheme.outlineVariant, height: 1),
            const SizedBox(height: 12),
            Text(
              'Next operations',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < actions.length; index++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: index == actions.length - 1 ? 0 : 8,
                ),
                child: _OperationActionRow(
                  action: actions[index],
                  labelOverride: _labelOverrideFor(
                    actions[index],
                    uploadActivity,
                  ),
                  showDisabledCommand: _showDisabledCommandFor(
                    actions[index],
                    uploadActivity,
                  ),
                  onPressed: _callbackFor(actions[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  SurveyFeedbackTone get _feedbackTone {
    switch (insights.health) {
      case SurveyOperationsCenterHealth.attention:
        return SurveyFeedbackTone.error;
      case SurveyOperationsCenterHealth.ready:
        return SurveyFeedbackTone.success;
      case SurveyOperationsCenterHealth.monitoring:
        return SurveyFeedbackTone.warning;
      case SurveyOperationsCenterHealth.steady:
        return SurveyFeedbackTone.info;
    }
  }

  SurveyEvidenceUploadPlanActivity get _uploadActivity {
    return SurveyEvidenceUploadPlanActivity(
      plan: insights.uploadPlan,
      activeUploadKeys: activeEvidenceUploadKeys,
    );
  }

  String? _labelOverrideFor(
    SurveyOperationsCenterAction action,
    SurveyEvidenceUploadPlanActivity uploadActivity,
  ) {
    if (action.kind != SurveyOperationsCenterActionKind.runUploadPlan) {
      return null;
    }

    return uploadActivity.allUploadableTasksActive
        ? 'Uploading...'
        : runEvidenceUploadPlanLabel;
  }

  bool _showDisabledCommandFor(
    SurveyOperationsCenterAction action,
    SurveyEvidenceUploadPlanActivity uploadActivity,
  ) {
    return action.kind == SurveyOperationsCenterActionKind.runUploadPlan &&
        uploadActivity.allUploadableTasksActive;
  }

  VoidCallback? _callbackFor(SurveyOperationsCenterAction action) {
    switch (action.kind) {
      case SurveyOperationsCenterActionKind.openFieldworkQueue:
        final response = insights.nextResponseAction;
        return response == null || onOpenResponse == null
            ? null
            : () => onOpenResponse!(response);
      case SurveyOperationsCenterActionKind.runDueUploads:
        return onRunDueEvidenceUploads;
      case SurveyOperationsCenterActionKind.runUploadPlan:
        return onRunEvidenceUploadPlan == null ||
                _uploadActivity.allUploadableTasksActive
            ? null
            : () => onRunEvidenceUploadPlan!(insights.uploadPlan);
      case SurveyOperationsCenterActionKind.requeueFailedUploads:
        return onRequeueFailedEvidenceUploads;
      case SurveyOperationsCenterActionKind.maintainUploadQueue:
      case SurveyOperationsCenterActionKind.monitorUploadQueue:
        return onMaintainEvidenceUploadQueue;
      case SurveyOperationsCenterActionKind.reviewReports:
        return null;
    }
  }
}

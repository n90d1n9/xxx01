import 'package:flutter/material.dart';

import '../../analytics/survey_evidence_sync_insights.dart';
import '../../analytics/survey_evidence_upload_queue_insights.dart';
import '../../analytics/survey_fieldwork_insights.dart';
import '../../analytics/survey_insights.dart';
import '../../analytics/survey_response_insights.dart';
import '../../analytics/survey_response_quality_insights.dart';
import '../../analytics/survey_response_review_insights.dart';
import '../../analytics/survey_response_sync_readiness.dart';
import '../../logic/survey_evidence_sync_activity_summary.dart';
import '../../models/survey.dart';
import '../../models/survey_role.dart';
import 'survey_dashboard_header.dart';
import 'survey_evidence_upload_plan_panel.dart';
import 'survey_evidence_upload_queue_panel_slot.dart';
import 'survey_fieldwork_board.dart';
import 'survey_lifecycle_panel.dart';
import 'survey_response_review_panel.dart';
import 'survey_workspace_sections.dart';

/// Renders the scrollable dashboard body for the selected survey workspace.
class SurveyDashboardContent extends StatelessWidget {
  final SurveyRole role;
  final SurveyWorkspaceSection selectedSection;
  final SurveyInsights insights;
  final SurveyFieldworkInsights fieldworkInsights;
  final SurveyResponseInsights responseInsights;
  final SurveyEvidenceSyncInsights evidenceSyncInsights;
  final SurveyResponseQualityInsights responseQualityInsights;
  final SurveyResponseReviewInsights responseReviewInsights;
  final SurveyResponseSyncReadinessInsights responseSyncReadiness;
  final List<Survey> surveys;
  final bool isWide;
  final ValueChanged<SurveyRole> onRoleChanged;
  final List<SurveyRole> availableRoles;
  final ValueChanged<Survey> onEditSurvey;
  final ValueChanged<Survey> onOpenSurvey;
  final ValueChanged<SurveyResponseSyncReadiness> onOpenResponse;
  final SurveyAssignmentStatusChanged onAssignmentStatusChanged;
  final SurveyResponseReviewStatusChanged onResponseReviewStatusChanged;
  final SurveyStatusChanged onStatusChanged;
  final SurveyEvidenceUploadPlanAction onRunEvidenceUploadPlan;
  final String runEvidenceUploadPlanLabel;
  final SurveyEvidenceUploadTaskAction onQueueEvidenceUpload;
  final SurveyEvidenceUploadTaskAction onRetryEvidenceUpload;
  final SurveyEvidenceUploadTaskAction onFixEvidenceUpload;
  final SurveyEvidenceUploadTaskAction onMonitorEvidenceUpload;
  final Set<String> activeEvidenceUploadKeys;
  final SurveyEvidenceUploadQueuePanelBuilder? evidenceUploadQueuePanelBuilder;
  final SurveyEvidenceUploadQueueInsights? evidenceUploadQueueInsights;
  final VoidCallback? onRunDueEvidenceUploads;
  final VoidCallback? onMaintainEvidenceUploadQueue;
  final VoidCallback? onRequeueFailedEvidenceUploads;
  final VoidCallback? onOpenEvidenceSyncActivity;
  final int evidenceSyncFocusRequestId;

  const SurveyDashboardContent({
    super.key,
    required this.role,
    required this.selectedSection,
    required this.insights,
    required this.fieldworkInsights,
    required this.responseInsights,
    required this.evidenceSyncInsights,
    required this.responseQualityInsights,
    required this.responseReviewInsights,
    required this.responseSyncReadiness,
    required this.surveys,
    required this.isWide,
    required this.onRoleChanged,
    this.availableRoles = SurveyRole.values,
    required this.onEditSurvey,
    required this.onOpenSurvey,
    required this.onOpenResponse,
    required this.onAssignmentStatusChanged,
    required this.onResponseReviewStatusChanged,
    required this.onStatusChanged,
    required this.onRunEvidenceUploadPlan,
    required this.runEvidenceUploadPlanLabel,
    required this.onQueueEvidenceUpload,
    required this.onRetryEvidenceUpload,
    required this.onFixEvidenceUpload,
    required this.onMonitorEvidenceUpload,
    this.activeEvidenceUploadKeys = const {},
    this.evidenceUploadQueuePanelBuilder,
    this.evidenceUploadQueueInsights,
    this.onRunDueEvidenceUploads,
    this.onMaintainEvidenceUploadQueue,
    this.onRequeueFailedEvidenceUploads,
    this.onOpenEvidenceSyncActivity,
    this.evidenceSyncFocusRequestId = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final syncActivitySummary = SurveyEvidenceSyncActivitySummary.evaluate(
      evidenceSyncInsights: evidenceSyncInsights,
      evidenceUploadQueueInsights: evidenceUploadQueueInsights,
      activeEvidenceUploadKeys: activeEvidenceUploadKeys,
    );

    return ColoredBox(
      color: colorScheme.surfaceContainerLowest,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SurveyDashboardHeader(
                  role: role,
                  selectedSection: selectedSection,
                  isWide: isWide,
                  syncActivitySummary: syncActivitySummary,
                  onRoleChanged: onRoleChanged,
                  availableRoles: availableRoles,
                  onOpenEvidenceSyncActivity: onOpenEvidenceSyncActivity,
                ),
                const SizedBox(height: 28),
                SurveyWorkspaceSectionView(
                  role: role,
                  section: selectedSection,
                  insights: insights,
                  fieldworkInsights: fieldworkInsights,
                  responseInsights: responseInsights,
                  evidenceSyncInsights: evidenceSyncInsights,
                  responseQualityInsights: responseQualityInsights,
                  responseReviewInsights: responseReviewInsights,
                  responseSyncReadiness: responseSyncReadiness,
                  surveys: surveys,
                  onEditSurvey: onEditSurvey,
                  onOpenSurvey: onOpenSurvey,
                  onOpenResponse: onOpenResponse,
                  onAssignmentStatusChanged: onAssignmentStatusChanged,
                  onResponseReviewStatusChanged: onResponseReviewStatusChanged,
                  onStatusChanged: onStatusChanged,
                  onRunEvidenceUploadPlan: onRunEvidenceUploadPlan,
                  runEvidenceUploadPlanLabel: runEvidenceUploadPlanLabel,
                  onQueueEvidenceUpload: onQueueEvidenceUpload,
                  onRetryEvidenceUpload: onRetryEvidenceUpload,
                  onFixEvidenceUpload: onFixEvidenceUpload,
                  onMonitorEvidenceUpload: onMonitorEvidenceUpload,
                  activeEvidenceUploadKeys: activeEvidenceUploadKeys,
                  evidenceUploadQueuePanelBuilder:
                      evidenceUploadQueuePanelBuilder,
                  evidenceUploadQueueInsights: evidenceUploadQueueInsights,
                  onRunDueEvidenceUploads: onRunDueEvidenceUploads,
                  onMaintainEvidenceUploadQueue: onMaintainEvidenceUploadQueue,
                  onRequeueFailedEvidenceUploads:
                      onRequeueFailedEvidenceUploads,
                  evidenceSyncFocusRequestId: evidenceSyncFocusRequestId,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

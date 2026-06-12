import 'package:flutter/material.dart';

import '../../analytics/survey_evidence_sync_insights.dart';
import '../../analytics/survey_evidence_upload_queue_insights.dart';
import '../../analytics/survey_fieldwork_insights.dart';
import '../../analytics/survey_insights.dart';
import '../../analytics/survey_response_insights.dart';
import '../../analytics/survey_response_quality_insights.dart';
import '../../analytics/survey_response_review_insights.dart';
import '../../analytics/survey_response_sync_readiness.dart';
import '../../logic/survey_role_capabilities.dart';
import '../../models/survey.dart';
import '../../models/survey_role.dart';
import 'survey_lifecycle_panel.dart';
import 'survey_analytics_section.dart';
import 'survey_builder_section.dart';
import 'survey_fieldwork_board.dart';
import 'survey_overview_section.dart';
import 'survey_people_sections.dart';
import 'survey_evidence_upload_plan_panel.dart';
import 'survey_evidence_upload_queue_panel_slot.dart';
import 'survey_reports_section.dart';
import 'survey_response_review_panel.dart';

/// Routes each workspace section to its role-aware dashboard module.
class SurveyWorkspaceSectionView extends StatelessWidget {
  final SurveyRole role;
  final SurveyWorkspaceSection section;
  final SurveyInsights insights;
  final SurveyFieldworkInsights fieldworkInsights;
  final SurveyResponseInsights responseInsights;
  final SurveyEvidenceSyncInsights evidenceSyncInsights;
  final SurveyResponseQualityInsights responseQualityInsights;
  final SurveyResponseReviewInsights responseReviewInsights;
  final SurveyResponseSyncReadinessInsights responseSyncReadiness;
  final List<Survey> surveys;
  final ValueChanged<Survey> onEditSurvey;
  final ValueChanged<Survey> onOpenSurvey;
  final ValueChanged<SurveyResponseSyncReadiness>? onOpenResponse;
  final SurveyAssignmentStatusChanged onAssignmentStatusChanged;
  final SurveyResponseReviewStatusChanged onResponseReviewStatusChanged;
  final SurveyStatusChanged onStatusChanged;
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

  const SurveyWorkspaceSectionView({
    super.key,
    this.role = SurveyRole.admin,
    required this.section,
    required this.insights,
    required this.fieldworkInsights,
    required this.responseInsights,
    required this.evidenceSyncInsights,
    required this.responseQualityInsights,
    required this.responseReviewInsights,
    required this.responseSyncReadiness,
    required this.surveys,
    required this.onEditSurvey,
    required this.onOpenSurvey,
    this.onOpenResponse,
    required this.onAssignmentStatusChanged,
    required this.onResponseReviewStatusChanged,
    required this.onStatusChanged,
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
  Widget build(BuildContext context) {
    final capabilities = SurveyRoleCapabilities.forRole(role);
    final canReviewResponses = capabilities.can(
      SurveyWorkspaceAction.reviewResponses,
    );
    final canOpenIntake = capabilities.can(SurveyWorkspaceAction.openIntake);
    final canSyncEvidence = capabilities.can(
      SurveyWorkspaceAction.syncEvidence,
    );

    switch (section) {
      case SurveyWorkspaceSection.overview:
        return SurveyOverviewSection(
          insights: insights,
          responseSyncReadiness: responseSyncReadiness,
          evidenceSyncInsights: evidenceSyncInsights,
          surveys: surveys,
          onOpenSurvey: canOpenIntake ? onOpenSurvey : null,
          onOpenResponse: canOpenIntake ? onOpenResponse : null,
          evidenceUploadQueueInsights: evidenceUploadQueueInsights,
          onRunEvidenceUploadPlan: canSyncEvidence
              ? onRunEvidenceUploadPlan
              : null,
          runEvidenceUploadPlanLabel: runEvidenceUploadPlanLabel,
          activeEvidenceUploadKeys: activeEvidenceUploadKeys,
          onRunDueEvidenceUploads: canSyncEvidence
              ? onRunDueEvidenceUploads
              : null,
          onMaintainEvidenceUploadQueue: canSyncEvidence
              ? onMaintainEvidenceUploadQueue
              : null,
          onRequeueFailedEvidenceUploads: canSyncEvidence
              ? onRequeueFailedEvidenceUploads
              : null,
        );
      case SurveyWorkspaceSection.builder:
        return SurveyBuilderSection(
          surveys: surveys,
          onEditSurvey: onEditSurvey,
          onStatusChanged: onStatusChanged,
        );
      case SurveyWorkspaceSection.fieldwork:
        return SurveyFieldworkSection(
          fieldworkInsights: fieldworkInsights,
          responseSyncReadiness: responseSyncReadiness,
          onOpenSurvey: canOpenIntake ? onOpenSurvey : null,
          onOpenResponse: canOpenIntake ? onOpenResponse : null,
          onAssignmentStatusChanged:
              capabilities.can(SurveyWorkspaceAction.manageAssignments)
              ? onAssignmentStatusChanged
              : null,
        );
      case SurveyWorkspaceSection.participants:
        return SurveyParticipantSection(
          surveys: surveys,
          onOpenSurvey: canOpenIntake ? onOpenSurvey : null,
        );
      case SurveyWorkspaceSection.analytics:
        return SurveyAnalyticsSection(
          insights: insights,
          responseInsights: responseInsights,
          responseQualityInsights: responseQualityInsights,
          responseReviewInsights: responseReviewInsights,
          onResponseReviewStatusChanged: canReviewResponses
              ? onResponseReviewStatusChanged
              : null,
          surveys: surveys,
        );
      case SurveyWorkspaceSection.reports:
        return SurveyReportsSection(
          insights: insights,
          responseInsights: responseInsights,
          responseSyncReadiness: responseSyncReadiness,
          evidenceSyncInsights: evidenceSyncInsights,
          surveys: surveys,
          onOpenResponse: canOpenIntake ? onOpenResponse : null,
          onRunEvidenceUploadPlan: canSyncEvidence
              ? onRunEvidenceUploadPlan
              : null,
          runEvidenceUploadPlanLabel: runEvidenceUploadPlanLabel,
          onQueueEvidenceUpload: canSyncEvidence ? onQueueEvidenceUpload : null,
          onRetryEvidenceUpload: canSyncEvidence ? onRetryEvidenceUpload : null,
          onFixEvidenceUpload: canSyncEvidence ? onFixEvidenceUpload : null,
          onMonitorEvidenceUpload: canSyncEvidence
              ? onMonitorEvidenceUpload
              : null,
          activeEvidenceUploadKeys: activeEvidenceUploadKeys,
          evidenceUploadQueuePanelBuilder: evidenceUploadQueuePanelBuilder,
          evidenceUploadQueueInsights: evidenceUploadQueueInsights,
          onRunDueEvidenceUploads: canSyncEvidence
              ? onRunDueEvidenceUploads
              : null,
          onMaintainEvidenceUploadQueue: canSyncEvidence
              ? onMaintainEvidenceUploadQueue
              : null,
          onRequeueFailedEvidenceUploads: canSyncEvidence
              ? onRequeueFailedEvidenceUploads
              : null,
          evidenceSyncFocusRequestId: evidenceSyncFocusRequestId,
        );
    }
  }
}

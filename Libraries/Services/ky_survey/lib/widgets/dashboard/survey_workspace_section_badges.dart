import '../../analytics/survey_evidence_sync_insights.dart';
import '../../analytics/survey_evidence_upload_queue_insights.dart';
import '../../analytics/survey_operations_center_insights.dart';
import '../../analytics/survey_response_review_insights.dart';
import '../../analytics/survey_response_sync_readiness.dart';
import '../../logic/survey_evidence_upload_plan_activity.dart';
import '../../models/survey_role.dart';
import 'survey_workspace_navigation.dart';

/// Builds role module badges from operations, review, and upload activity signals.
class SurveyWorkspaceSectionBadgeBuilder {
  final SurveyResponseSyncReadinessInsights responseSyncReadiness;
  final SurveyEvidenceSyncInsights evidenceSyncInsights;
  final SurveyResponseReviewInsights responseReviewInsights;
  final SurveyEvidenceUploadQueueInsights? evidenceUploadQueueInsights;
  final Set<String> activeEvidenceUploadKeys;

  const SurveyWorkspaceSectionBadgeBuilder({
    required this.responseSyncReadiness,
    required this.evidenceSyncInsights,
    required this.responseReviewInsights,
    this.evidenceUploadQueueInsights,
    this.activeEvidenceUploadKeys = const {},
  });

  Map<SurveyWorkspaceSection, SurveyWorkspaceSectionBadge> build() {
    final operationsInsights = SurveyOperationsCenterInsights.evaluate(
      responseReadiness: responseSyncReadiness,
      evidenceSyncInsights: evidenceSyncInsights,
      uploadQueueInsights: evidenceUploadQueueInsights,
    );
    final uploadActivity = SurveyEvidenceUploadPlanActivity(
      plan: operationsInsights.uploadPlan,
      activeUploadKeys: activeEvidenceUploadKeys,
    );
    final badges = <SurveyWorkspaceSection, SurveyWorkspaceSectionBadge>{};

    final overviewBadge = _badgeForOperations(
      operationsInsights,
      uploadActivity: uploadActivity,
    );
    if (overviewBadge != null) {
      badges[SurveyWorkspaceSection.overview] = overviewBadge;
    }

    final fieldworkBadge = _badgeForFieldwork(responseSyncReadiness);
    if (fieldworkBadge != null) {
      badges[SurveyWorkspaceSection.fieldwork] = fieldworkBadge;
    }

    final analyticsBadge = _badgeForReview(responseReviewInsights);
    if (analyticsBadge != null) {
      badges[SurveyWorkspaceSection.analytics] = analyticsBadge;
    }

    final reportsBadge = _badgeForReports(
      evidenceSyncInsights: evidenceSyncInsights,
      operationsInsights: operationsInsights,
      uploadActivity: uploadActivity,
    );
    if (reportsBadge != null) {
      badges[SurveyWorkspaceSection.reports] = reportsBadge;
    }

    return badges;
  }

  SurveyWorkspaceSectionBadge? _badgeForOperations(
    SurveyOperationsCenterInsights insights, {
    required SurveyEvidenceUploadPlanActivity uploadActivity,
  }) {
    if (insights.attentionCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(insights.attentionCount),
        tone: SurveyWorkspaceSectionBadgeTone.error,
        tooltip: insights.detailLabel,
      );
    }

    final readyWorkCount =
        insights.readyResponseCount +
        uploadActivity.readyUploadableCount +
        insights.dueQueueUploadCount;
    if (readyWorkCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(readyWorkCount),
        tone: SurveyWorkspaceSectionBadgeTone.success,
        tooltip: _plural(
          readyWorkCount,
          'item is ready for action',
          'items are ready for action',
        ),
      );
    }

    final activeUploadCount =
        uploadActivity.activeUploadableCount + insights.activeQueueUploadCount;
    if (activeUploadCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(activeUploadCount),
        tone: SurveyWorkspaceSectionBadgeTone.warning,
        tooltip: _plural(
          activeUploadCount,
          'evidence upload is running',
          'evidence uploads are running',
        ),
      );
    }

    if (insights.waitingSyncCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(insights.waitingSyncCount),
        tone: SurveyWorkspaceSectionBadgeTone.warning,
        tooltip: insights.detailLabel,
      );
    }

    return null;
  }

  SurveyWorkspaceSectionBadge? _badgeForFieldwork(
    SurveyResponseSyncReadinessInsights insights,
  ) {
    final blockerCount =
        insights.answerIssueCount +
        insights.evidenceIssueCount +
        insights.uploadFailedCount;
    if (blockerCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(blockerCount),
        tone: SurveyWorkspaceSectionBadgeTone.error,
        tooltip: insights.summaryLabel,
      );
    }

    if (insights.readyToSubmitCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(insights.readyToSubmitCount),
        tone: SurveyWorkspaceSectionBadgeTone.success,
        tooltip: insights.summaryLabel,
      );
    }

    if (insights.uploadPendingCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(insights.uploadPendingCount),
        tone: SurveyWorkspaceSectionBadgeTone.warning,
        tooltip: insights.summaryLabel,
      );
    }

    return null;
  }

  SurveyWorkspaceSectionBadge? _badgeForReview(
    SurveyResponseReviewInsights insights,
  ) {
    if (insights.needsFollowUpCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(insights.needsFollowUpCount),
        tone: SurveyWorkspaceSectionBadgeTone.error,
        tooltip: 'Responses need follow-up review',
      );
    }

    if (insights.pendingReviewCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(insights.pendingReviewCount),
        tone: SurveyWorkspaceSectionBadgeTone.warning,
        tooltip: 'Responses are pending review',
      );
    }

    return null;
  }

  SurveyWorkspaceSectionBadge? _badgeForReports({
    required SurveyEvidenceSyncInsights evidenceSyncInsights,
    required SurveyOperationsCenterInsights operationsInsights,
    required SurveyEvidenceUploadPlanActivity uploadActivity,
  }) {
    final uploadAttentionCount =
        evidenceSyncInsights.blockedCount +
        evidenceSyncInsights.failedCount +
        operationsInsights.queueAttentionCount;
    if (uploadAttentionCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(uploadAttentionCount),
        tone: SurveyWorkspaceSectionBadgeTone.error,
        tooltip: evidenceSyncInsights.statusLabel,
      );
    }

    final activeUploadCount =
        uploadActivity.activeUploadableCount +
        operationsInsights.activeQueueUploadCount;
    if (activeUploadCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(activeUploadCount),
        tone: SurveyWorkspaceSectionBadgeTone.warning,
        tooltip: _plural(
          activeUploadCount,
          'evidence upload is running',
          'evidence uploads are running',
        ),
      );
    }

    final readyUploadCount =
        uploadActivity.readyUploadableCount +
        operationsInsights.dueQueueUploadCount;
    if (readyUploadCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(readyUploadCount),
        tone: SurveyWorkspaceSectionBadgeTone.success,
        tooltip: 'Evidence uploads are ready',
      );
    }

    if (evidenceSyncInsights.pendingUploadCount > 0) {
      return SurveyWorkspaceSectionBadge(
        label: _badgeCount(evidenceSyncInsights.pendingUploadCount),
        tone: SurveyWorkspaceSectionBadgeTone.warning,
        tooltip: evidenceSyncInsights.statusLabel,
      );
    }

    return null;
  }

  String _badgeCount(int count) {
    return count > 99 ? '99+' : count.toString();
  }

  String _plural(int count, String singular, String plural) {
    return count == 1 ? '1 $singular' : '$count $plural';
  }
}

import '../analytics/survey_evidence_sync_insights.dart';
import '../analytics/survey_response_sync_readiness.dart';

/// Identifies the response viewer workflow that should receive initial focus.
enum SurveyResponseViewerFocus {
  standard,
  answerIssue,
  evidenceIssue,
  uploadIssue,
  submitReview,
  readOnly,
}

/// Maps response readiness into reusable response viewer copy and actions.
class SurveyResponseViewerIntent {
  final SurveyResponseViewerFocus focus;
  final String title;
  final String detail;
  final String? actionLabel;
  final String? focusQuestionId;

  const SurveyResponseViewerIntent({
    required this.focus,
    required this.title,
    required this.detail,
    this.actionLabel,
    this.focusQuestionId,
  });

  factory SurveyResponseViewerIntent.fromReadiness(
    SurveyResponseSyncReadiness readiness,
  ) {
    final status = readiness.status;
    final uploadItem = readiness.firstUploadIssueItem;
    if (status == SurveyResponseSyncReadinessStatus.uploadFailed &&
        uploadItem != null) {
      return SurveyResponseViewerIntent(
        focus: SurveyResponseViewerFocus.uploadIssue,
        title: 'Retry failed upload',
        detail: _uploadDetail(uploadItem),
        actionLabel: 'Review failure',
        focusQuestionId:
            uploadItem.evidence.questionId ??
            uploadItem.requirement?.questionId,
      );
    }

    if (status == SurveyResponseSyncReadinessStatus.uploadPending &&
        uploadItem != null) {
      return SurveyResponseViewerIntent(
        focus: SurveyResponseViewerFocus.uploadIssue,
        title: 'Upload pending',
        detail: _uploadDetail(uploadItem, fallback: uploadItem.stateLabel),
        actionLabel: 'View upload',
        focusQuestionId:
            uploadItem.evidence.questionId ??
            uploadItem.requirement?.questionId,
      );
    }

    return SurveyResponseViewerIntent.fromStatus(
      status: status,
      detail: readiness.detailLabel,
    );
  }

  factory SurveyResponseViewerIntent.fromStatus({
    required SurveyResponseSyncReadinessStatus status,
    required String detail,
  }) {
    switch (status) {
      case SurveyResponseSyncReadinessStatus.needsAnswers:
        return SurveyResponseViewerIntent(
          focus: SurveyResponseViewerFocus.answerIssue,
          title: 'Resume answers',
          detail: detail,
        );
      case SurveyResponseSyncReadinessStatus.needsEvidence:
        return SurveyResponseViewerIntent(
          focus: SurveyResponseViewerFocus.evidenceIssue,
          title: 'Fix evidence',
          detail: detail,
        );
      case SurveyResponseSyncReadinessStatus.uploadPending:
        return SurveyResponseViewerIntent(
          focus: SurveyResponseViewerFocus.uploadIssue,
          title: 'Upload pending',
          detail: detail,
        );
      case SurveyResponseSyncReadinessStatus.uploadFailed:
        return SurveyResponseViewerIntent(
          focus: SurveyResponseViewerFocus.uploadIssue,
          title: 'Review failed upload',
          detail: detail,
        );
      case SurveyResponseSyncReadinessStatus.readyToSubmit:
        return SurveyResponseViewerIntent(
          focus: SurveyResponseViewerFocus.submitReview,
          title: 'Ready to submit',
          detail: detail,
        );
      case SurveyResponseSyncReadinessStatus.submitted:
      case SurveyResponseSyncReadinessStatus.discarded:
        return SurveyResponseViewerIntent(
          focus: SurveyResponseViewerFocus.readOnly,
          title: status == SurveyResponseSyncReadinessStatus.submitted
              ? 'Submitted response'
              : 'Discarded response',
          detail: detail,
        );
      case SurveyResponseSyncReadinessStatus.missingSurvey:
        return SurveyResponseViewerIntent(
          focus: SurveyResponseViewerFocus.readOnly,
          title: 'Survey unavailable',
          detail: detail,
        );
    }
  }

  bool get shouldFocusFirstAnswerIssue {
    return focus == SurveyResponseViewerFocus.answerIssue;
  }

  bool get shouldHighlightEvidence {
    return focus == SurveyResponseViewerFocus.evidenceIssue ||
        focus == SurveyResponseViewerFocus.uploadIssue;
  }

  bool get shouldOpenEvidenceCapture {
    return focus == SurveyResponseViewerFocus.evidenceIssue;
  }

  bool get shouldReviewUpload {
    return focus == SurveyResponseViewerFocus.uploadIssue;
  }

  bool get shouldPromptSubmit {
    return focus == SurveyResponseViewerFocus.submitReview;
  }

  String? get primaryActionLabel {
    switch (focus) {
      case SurveyResponseViewerFocus.answerIssue:
        return 'Review issue';
      case SurveyResponseViewerFocus.evidenceIssue:
        return 'Open evidence';
      case SurveyResponseViewerFocus.uploadIssue:
        return actionLabel ?? 'Review upload';
      case SurveyResponseViewerFocus.submitReview:
        return 'Submit now';
      case SurveyResponseViewerFocus.standard:
      case SurveyResponseViewerFocus.readOnly:
        return null;
    }
  }

  static String _uploadDetail(SurveyEvidenceSyncItem item, {String? fallback}) {
    final uploadError = item.attachment.uploadError;
    if (uploadError != null && uploadError.trim().isNotEmpty) {
      return '${item.title}: $uploadError';
    }

    return '${item.title}: ${fallback ?? item.detail}';
  }
}

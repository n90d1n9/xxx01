import '../logic/survey_response_evidence_summary.dart';
import '../logic/survey_response_session_summary.dart';
import '../logic/survey_response_survey_resolver.dart';
import '../models/survey.dart';
import '../models/survey_response.dart';
import '../validation/survey_evidence_requirement_validator.dart';
import 'survey_evidence_sync_insights.dart';

enum SurveyResponseSyncReadinessStatus {
  readyToSubmit,
  needsAnswers,
  needsEvidence,
  uploadPending,
  uploadFailed,
  submitted,
  discarded,
  missingSurvey,
}

/// Builds fieldwork readiness summaries for draft responses and evidence sync.
class SurveyResponseSyncReadinessInsights {
  final List<Survey> surveys;
  final List<SurveyResponse> responses;
  final DateTime now;

  const SurveyResponseSyncReadinessInsights({
    required this.surveys,
    required this.responses,
    required this.now,
  });

  factory SurveyResponseSyncReadinessInsights.evaluate({
    required List<Survey> surveys,
    required List<SurveyResponse> responses,
    DateTime? now,
  }) {
    return SurveyResponseSyncReadinessInsights(
      surveys: surveys,
      responses: responses,
      now: now ?? DateTime.now(),
    );
  }

  List<SurveyResponseSyncReadiness> get items {
    final resolver = SurveyResponseSurveyResolver(surveys: surveys);
    final syncItems = SurveyEvidenceSyncInsights(
      surveys: surveys,
      responses: responses,
    ).items;

    return responses.map((response) {
      final survey = resolver.surveyForResponse(response);
      final responseSyncItems = syncItems
          .where((item) => item.response.id == response.id)
          .toList();

      return SurveyResponseSyncReadiness(
        survey: survey,
        response: response,
        now: now,
        responseSummary: survey == null
            ? null
            : SurveyResponseSessionSummary.evaluate(
                survey: survey,
                response: response,
                now: now,
              ),
        evidenceSummary: survey == null
            ? null
            : SurveyResponseEvidenceSummary.evaluate(
                survey: survey,
                response: response,
              ),
        evidenceSyncItems: responseSyncItems,
      );
    }).toList();
  }

  int get draftCount {
    return items
        .where((item) => item.response.status == SurveyResponseStatus.draft)
        .length;
  }

  int get submittedCount {
    return items
        .where(
          (item) => item.status == SurveyResponseSyncReadinessStatus.submitted,
        )
        .length;
  }

  int get readyToSubmitCount {
    return items.where((item) => item.canSubmit).length;
  }

  int get answerIssueCount {
    return items
        .where(
          (item) =>
              item.status == SurveyResponseSyncReadinessStatus.needsAnswers,
        )
        .length;
  }

  int get evidenceIssueCount {
    return items
        .where(
          (item) =>
              item.status == SurveyResponseSyncReadinessStatus.needsEvidence,
        )
        .length;
  }

  int get uploadPendingCount {
    return items
        .where(
          (item) =>
              item.status == SurveyResponseSyncReadinessStatus.uploadPending,
        )
        .length;
  }

  int get uploadFailedCount {
    return items
        .where(
          (item) =>
              item.status == SurveyResponseSyncReadinessStatus.uploadFailed,
        )
        .length;
  }

  int get actionRequiredCount {
    return items.where((item) => item.requiresAction).length;
  }

  bool get hasActionRequired => actionRequiredCount > 0;

  bool get hasPendingSync => uploadPendingCount > 0;

  List<SurveyResponseSyncReadiness> actionQueue({int limit = 6}) {
    final queue = items
        .where((item) => item.requiresAction || item.isWaitingForSync)
        .toList();
    queue.sort((left, right) {
      final priority = left.priority.compareTo(right.priority);
      if (priority != 0) {
        return priority;
      }

      return right.lastActivityAt.compareTo(left.lastActivityAt);
    });
    return queue.take(limit).toList();
  }

  String get summaryLabel {
    if (responses.isEmpty) {
      return 'No response drafts';
    }

    if (actionRequiredCount > 0) {
      return actionRequiredCount == 1
          ? '1 response needs attention'
          : '$actionRequiredCount responses need attention';
    }

    if (uploadPendingCount > 0) {
      return uploadPendingCount == 1
          ? '1 response waiting for upload'
          : '$uploadPendingCount responses waiting for upload';
    }

    if (readyToSubmitCount > 0) {
      return readyToSubmitCount == 1
          ? '1 response ready to submit'
          : '$readyToSubmitCount responses ready to submit';
    }

    if (submittedCount == responses.length) {
      return 'All responses submitted';
    }

    return 'Responses up to date';
  }
}

/// Describes the next action required before a response can be submitted.
class SurveyResponseSyncReadiness {
  final Survey? survey;
  final SurveyResponse response;
  final DateTime now;
  final SurveyResponseSessionSummary? responseSummary;
  final SurveyResponseEvidenceSummary? evidenceSummary;
  final List<SurveyEvidenceSyncItem> evidenceSyncItems;

  const SurveyResponseSyncReadiness({
    required this.survey,
    required this.response,
    required this.now,
    required this.responseSummary,
    required this.evidenceSummary,
    required this.evidenceSyncItems,
  });

  SurveyResponseSyncReadinessStatus get status {
    final survey = this.survey;
    if (survey == null) {
      return SurveyResponseSyncReadinessStatus.missingSurvey;
    }

    switch (response.status) {
      case SurveyResponseStatus.submitted:
        return SurveyResponseSyncReadinessStatus.submitted;
      case SurveyResponseStatus.discarded:
        return SurveyResponseSyncReadinessStatus.discarded;
      case SurveyResponseStatus.draft:
        break;
    }

    final responseSummary = this.responseSummary;
    if (responseSummary == null ||
        responseSummary.visibleQuestionCount == 0 ||
        !responseSummary.isValid) {
      return SurveyResponseSyncReadinessStatus.needsAnswers;
    }

    if (failedUploadCount > 0) {
      return SurveyResponseSyncReadinessStatus.uploadFailed;
    }

    if (_hasEvidenceCaptureIssue) {
      return SurveyResponseSyncReadinessStatus.needsEvidence;
    }

    if (pendingUploadCount > 0) {
      return SurveyResponseSyncReadinessStatus.uploadPending;
    }

    final evidenceSummary = this.evidenceSummary;
    if (evidenceSummary != null && !evidenceSummary.isComplete) {
      return SurveyResponseSyncReadinessStatus.needsEvidence;
    }

    return SurveyResponseSyncReadinessStatus.readyToSubmit;
  }

  bool get canSubmit {
    return status == SurveyResponseSyncReadinessStatus.readyToSubmit;
  }

  bool get requiresAction {
    return status == SurveyResponseSyncReadinessStatus.missingSurvey ||
        status == SurveyResponseSyncReadinessStatus.needsAnswers ||
        status == SurveyResponseSyncReadinessStatus.needsEvidence ||
        status == SurveyResponseSyncReadinessStatus.uploadFailed ||
        status == SurveyResponseSyncReadinessStatus.readyToSubmit;
  }

  bool get isWaitingForSync {
    return status == SurveyResponseSyncReadinessStatus.uploadPending;
  }

  /// Returns the most urgent evidence item that needs upload review.
  SurveyEvidenceSyncItem? get firstUploadIssueItem {
    final queue =
        evidenceSyncItems
            .where((item) => item.requiresAction || item.isPendingUpload)
            .toList()
          ..sort((left, right) {
            final priority = left.priority.compareTo(right.priority);
            if (priority != 0) {
              return priority;
            }

            return right.evidence.capturedAt.compareTo(
              left.evidence.capturedAt,
            );
          });

    return queue.isEmpty ? null : queue.first;
  }

  int get pendingUploadCount {
    return evidenceSyncItems.where((item) => item.isPendingUpload).length;
  }

  int get failedUploadCount {
    return evidenceSyncItems
        .where((item) => item.state == SurveyEvidenceSyncState.failed)
        .length;
  }

  int get blockedEvidenceCount {
    return evidenceSyncItems
        .where((item) => item.state == SurveyEvidenceSyncState.blocked)
        .length;
  }

  int get priority {
    switch (status) {
      case SurveyResponseSyncReadinessStatus.missingSurvey:
        return 0;
      case SurveyResponseSyncReadinessStatus.needsAnswers:
        return 1;
      case SurveyResponseSyncReadinessStatus.needsEvidence:
        return 2;
      case SurveyResponseSyncReadinessStatus.uploadFailed:
        return 3;
      case SurveyResponseSyncReadinessStatus.readyToSubmit:
        return 4;
      case SurveyResponseSyncReadinessStatus.uploadPending:
        return 5;
      case SurveyResponseSyncReadinessStatus.submitted:
        return 6;
      case SurveyResponseSyncReadinessStatus.discarded:
        return 7;
    }
  }

  DateTime get lastActivityAt {
    final submittedAt = response.submittedAt;
    final answeredAt = responseSummary?.lastAnsweredAt;
    var latest = submittedAt ?? answeredAt ?? response.startedAt;

    for (final item in response.evidence) {
      final capturedAt = item.capturedAt;
      if (capturedAt.isAfter(latest)) {
        latest = capturedAt;
      }
    }

    return latest;
  }

  String get statusLabel {
    switch (status) {
      case SurveyResponseSyncReadinessStatus.readyToSubmit:
        return 'Ready to submit';
      case SurveyResponseSyncReadinessStatus.needsAnswers:
        return responseSummary?.primaryStatusLabel ?? 'Answer review needed';
      case SurveyResponseSyncReadinessStatus.needsEvidence:
        return evidenceSummary?.primaryStatusLabel ?? 'Evidence needed';
      case SurveyResponseSyncReadinessStatus.uploadPending:
        return _plural(pendingUploadCount, 'upload pending', 'uploads pending');
      case SurveyResponseSyncReadinessStatus.uploadFailed:
        return _plural(failedUploadCount, 'upload failed', 'uploads failed');
      case SurveyResponseSyncReadinessStatus.submitted:
        return 'Submitted';
      case SurveyResponseSyncReadinessStatus.discarded:
        return 'Discarded';
      case SurveyResponseSyncReadinessStatus.missingSurvey:
        return 'Survey unavailable';
    }
  }

  String get detailLabel {
    if (survey == null) {
      return 'Response cannot be matched to a survey definition.';
    }

    final responseIssue = responseSummary?.firstIssueMessage;
    if (status == SurveyResponseSyncReadinessStatus.needsAnswers &&
        responseIssue != null) {
      return responseIssue;
    }

    final evidenceIssue = evidenceSummary?.firstIssueMessage;
    if (status == SurveyResponseSyncReadinessStatus.needsEvidence &&
        evidenceIssue != null) {
      return evidenceIssue;
    }

    final syncIssue = _firstSyncActionItem;
    if (syncIssue != null &&
        (status == SurveyResponseSyncReadinessStatus.uploadFailed ||
            status == SurveyResponseSyncReadinessStatus.uploadPending)) {
      return syncIssue.detail;
    }

    return responseSummary?.secondaryStatusLabel ??
        '${response.respondentName} response';
  }

  bool get _hasEvidenceCaptureIssue {
    final evidenceSummary = this.evidenceSummary;
    if (evidenceSummary == null) {
      return false;
    }

    if (blockedEvidenceCount > 0) {
      return true;
    }

    if (evidenceSummary.validation.missingRequirementCount > 0) {
      return true;
    }

    if (evidenceSummary.validation.evidenceValidation.hasBlockers) {
      return true;
    }

    return evidenceSummary.validation.issues.any(
      (issue) =>
          issue.type !=
          SurveyEvidenceRequirementIssueType.attachmentNotUploaded,
    );
  }

  SurveyEvidenceSyncItem? get _firstSyncActionItem {
    for (final item in evidenceSyncItems) {
      if (item.requiresAction || item.isPendingUpload) {
        return item;
      }
    }

    return null;
  }

  static String _plural(int count, String singular, [String? plural]) {
    return count == 1 ? '1 $singular' : '$count ${plural ?? '${singular}s'}';
  }
}

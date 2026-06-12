import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../data/sample_responses.dart';
import '../logic/survey_response_answer_sanitizer.dart';
import '../logic/survey_response_draft_selector.dart';
import '../models/question.dart';
import '../models/survey_attachment.dart';
import '../models/survey_evidence.dart';
import '../models/survey_response.dart';
import '../models/survey_response_review.dart';

final surveyResponseProvider =
    StateNotifierProvider<SurveyResponseNotifier, List<SurveyResponse>>((ref) {
      return SurveyResponseNotifier();
    });

class SurveyResponseNotifier extends StateNotifier<List<SurveyResponse>> {
  SurveyResponseNotifier() : super(sampleResponses);

  SurveyResponse createOrResumeDraft({
    required String surveyId,
    String respondentId = 'anonymous',
    String respondentName = 'Participant',
    String? collectorId,
    String? collectorName,
    String? surveyVersionId,
    Map<String, dynamic> metadata = const {},
  }) {
    final draft = SurveyResponseDraftSelector.activeDraftFor(
      responses: state,
      surveyId: surveyId,
      respondentId: respondentId,
      collectorId: collectorId,
      surveyVersionId: surveyVersionId,
    );
    if (draft != null) {
      return draft;
    }

    return createDraft(
      surveyId: surveyId,
      respondentId: respondentId,
      respondentName: respondentName,
      collectorId: collectorId,
      collectorName: collectorName,
      surveyVersionId: surveyVersionId,
      metadata: metadata,
    );
  }

  SurveyResponse createDraft({
    required String surveyId,
    String respondentId = 'anonymous',
    String respondentName = 'Participant',
    String? collectorId,
    String? collectorName,
    String? surveyVersionId,
    Map<String, dynamic> metadata = const {},
  }) {
    const uuid = Uuid();
    final response = SurveyResponse(
      id: uuid.v4(),
      surveyId: surveyId,
      surveyVersionId: surveyVersionId,
      respondentId: respondentId,
      respondentName: respondentName,
      collectorId: collectorId,
      collectorName: collectorName,
      startedAt: DateTime.now(),
      metadata: metadata,
    );

    state = [...state, response];
    return response;
  }

  SurveyResponse? responseById(String responseId) {
    for (final response in state) {
      if (response.id == responseId) {
        return response;
      }
    }

    return null;
  }

  List<SurveyResponse> responsesForSurvey(String surveyId) {
    return state.where((response) => response.surveyId == surveyId).toList();
  }

  void updateAnswer({
    required String responseId,
    required String questionId,
    required dynamic value,
    List<Question>? questions,
  }) {
    state = state.map((response) {
      if (response.id != responseId) {
        return response;
      }

      final updated = response.upsertAnswer(
        questionId: questionId,
        value: value,
      );
      if (questions == null) {
        return updated;
      }

      return SurveyResponseAnswerSanitizer.pruneHiddenAnswers(
        questions: questions,
        response: updated,
      );
    }).toList();
  }

  void submitResponse(String responseId, {String? surveyVersionId}) {
    state = state.map((response) {
      if (response.id != responseId) {
        return response;
      }

      return response.submit(surveyVersionId: surveyVersionId);
    }).toList();
  }

  void upsertEvidence({
    required String responseId,
    required SurveyEvidence evidence,
  }) {
    state = state.map((response) {
      if (response.id != responseId) {
        return response;
      }

      return response.upsertEvidence(evidence);
    }).toList();
  }

  void removeEvidence({
    required String responseId,
    required String evidenceId,
  }) {
    state = state.map((response) {
      if (response.id != responseId) {
        return response;
      }

      return response.removeEvidence(evidenceId);
    }).toList();
  }

  void queueEvidenceUpload({
    required String responseId,
    required String evidenceId,
    DateTime? queuedAt,
  }) {
    updateEvidenceAttachmentUploadStatus(
      responseId: responseId,
      evidenceId: evidenceId,
      uploadStatus: SurveyAttachmentUploadStatus.queued,
      metadata: {'queuedAt': (queuedAt ?? DateTime.now()).toIso8601String()},
    );
  }

  void markEvidenceUploading({
    required String responseId,
    required String evidenceId,
    DateTime? uploadingAt,
  }) {
    updateEvidenceAttachmentUploadStatus(
      responseId: responseId,
      evidenceId: evidenceId,
      uploadStatus: SurveyAttachmentUploadStatus.uploading,
      metadata: {
        'uploadingAt': (uploadingAt ?? DateTime.now()).toIso8601String(),
      },
    );
  }

  void markEvidenceUploaded({
    required String responseId,
    required String evidenceId,
    required String remoteUrl,
    DateTime? uploadedAt,
  }) {
    updateEvidenceAttachmentUploadStatus(
      responseId: responseId,
      evidenceId: evidenceId,
      uploadStatus: SurveyAttachmentUploadStatus.uploaded,
      remoteUrl: remoteUrl,
      metadata: {
        'uploadedAt': (uploadedAt ?? DateTime.now()).toIso8601String(),
      },
    );
  }

  void markEvidenceUploadFailed({
    required String responseId,
    required String evidenceId,
    required String uploadError,
    DateTime? failedAt,
  }) {
    updateEvidenceAttachmentUploadStatus(
      responseId: responseId,
      evidenceId: evidenceId,
      uploadStatus: SurveyAttachmentUploadStatus.failed,
      uploadError: uploadError,
      metadata: {'failedAt': (failedAt ?? DateTime.now()).toIso8601String()},
    );
  }

  void updateEvidenceAttachmentUploadStatus({
    required String responseId,
    required String evidenceId,
    required SurveyAttachmentUploadStatus uploadStatus,
    String? remoteUrl,
    String? uploadError,
    Map<String, dynamic> metadata = const {},
  }) {
    state = state.map((response) {
      if (response.id != responseId) {
        return response;
      }

      return _updateEvidenceAttachment(
        response: response,
        evidenceId: evidenceId,
        update: (attachment) {
          return attachment.withUploadState(
            uploadStatus: uploadStatus,
            remoteUrl: remoteUrl,
            uploadError: uploadError,
            metadata: metadata,
          );
        },
      );
    }).toList();
  }

  void updateReviewStatus({
    required String responseId,
    required SurveyResponseReviewStatus status,
    String reviewerId = 'reviewer',
    String reviewerName = 'Reviewer',
    String? note,
  }) {
    state = state.map((response) {
      if (response.id != responseId) {
        return response;
      }

      return response.review(
        status: status,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        note: note,
      );
    }).toList();
  }

  void discardResponse(String responseId) {
    state = state.map((response) {
      if (response.id != responseId) {
        return response;
      }

      return response.copyWith(status: SurveyResponseStatus.discarded);
    }).toList();
  }

  SurveyResponse _updateEvidenceAttachment({
    required SurveyResponse response,
    required String evidenceId,
    required SurveyAttachment Function(SurveyAttachment attachment) update,
  }) {
    for (final evidence in response.evidence) {
      if (evidence.id != evidenceId) {
        continue;
      }

      final attachment = evidence.attachment;
      if (attachment == null) {
        return response;
      }

      return response.upsertEvidence(
        evidence.copyWith(attachment: update(attachment)),
      );
    }

    return response;
  }
}

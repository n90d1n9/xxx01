import 'package:ky_survey/analytics/survey_response_sync_readiness.dart';
import 'package:ky_survey/logic/survey_response_view_intent.dart';
import 'package:ky_survey/models/answer.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyResponseViewerIntent', () {
    test('maps readiness states to focused response viewer intents', () {
      expect(
        SurveyResponseViewerIntent.fromStatus(
          status: SurveyResponseSyncReadinessStatus.needsAnswers,
          detail: 'Missing required answer',
        ).focus,
        SurveyResponseViewerFocus.answerIssue,
      );
      expect(
        SurveyResponseViewerIntent.fromStatus(
          status: SurveyResponseSyncReadinessStatus.needsAnswers,
          detail: 'Missing required answer',
        ).primaryActionLabel,
        'Review issue',
      );
      expect(
        SurveyResponseViewerIntent.fromStatus(
          status: SurveyResponseSyncReadinessStatus.needsEvidence,
          detail: 'Photo required',
        ).shouldHighlightEvidence,
        isTrue,
      );
      expect(
        SurveyResponseViewerIntent.fromStatus(
          status: SurveyResponseSyncReadinessStatus.needsEvidence,
          detail: 'Photo required',
        ).shouldOpenEvidenceCapture,
        isTrue,
      );
      expect(
        SurveyResponseViewerIntent.fromStatus(
          status: SurveyResponseSyncReadinessStatus.readyToSubmit,
          detail: 'Ready',
        ).shouldPromptSubmit,
        isTrue,
      );
      expect(
        SurveyResponseViewerIntent.fromStatus(
          status: SurveyResponseSyncReadinessStatus.submitted,
          detail: 'Locked',
        ).focus,
        SurveyResponseViewerFocus.readOnly,
      );
    });

    test('uses fieldwork-friendly labels for response actions', () {
      final failedUpload = SurveyResponseViewerIntent.fromStatus(
        status: SurveyResponseSyncReadinessStatus.uploadFailed,
        detail: 'Network timeout',
      );

      expect(failedUpload.title, 'Review failed upload');
      expect(failedUpload.detail, 'Network timeout');
      expect(failedUpload.focus, SurveyResponseViewerFocus.uploadIssue);
      expect(failedUpload.primaryActionLabel, 'Review upload');
      expect(failedUpload.shouldReviewUpload, isTrue);
      expect(failedUpload.shouldOpenEvidenceCapture, isFalse);
    });

    test('uses upload sync context when created from readiness', () {
      final survey = _survey();
      final readiness = SurveyResponseSyncReadinessInsights.evaluate(
        surveys: [survey],
        responses: [
          _response(
            answer: 'Display is clean',
            uploadStatus: SurveyAttachmentUploadStatus.failed,
          ),
        ],
        now: _now,
      ).items.single;

      final intent = SurveyResponseViewerIntent.fromReadiness(readiness);

      expect(intent.title, 'Retry failed upload');
      expect(intent.detail, contains('Display image'));
      expect(intent.detail, contains('network unavailable'));
      expect(intent.primaryActionLabel, 'Review failure');
      expect(intent.focusQuestionId, 'display-photo');
    });
  });
}

final _now = DateTime(2026, 1, 1, 12);

Survey _survey() {
  return Survey(
    id: 'retail-audit',
    title: 'Retail Audit',
    description: 'Field audit',
    createdAt: DateTime(2026),
    questions: [
      Question(
        id: 'display-photo',
        text: 'Take a display photo',
        type: QuestionType.singleLineText,
        required: true,
      ),
    ],
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'display-image',
        kind: SurveyEvidenceKind.image,
        scope: SurveyEvidenceScope.question,
        questionId: 'display-photo',
        label: 'Display image',
        requireUploaded: true,
      ),
    ],
  );
}

SurveyResponse _response({
  required String answer,
  required SurveyAttachmentUploadStatus uploadStatus,
}) {
  return SurveyResponse(
    id: 'response-1',
    surveyId: 'retail-audit',
    respondentId: 'participant-1',
    respondentName: 'Participant',
    startedAt: _now.subtract(const Duration(minutes: 12)),
    answers: [
      ResponseAnswer(
        questionId: 'display-photo',
        value: answer,
        answeredAt: _now.subtract(const Duration(minutes: 4)),
      ),
    ],
    evidence: [
      SurveyEvidence.attachment(
        id: 'display-evidence',
        attachment: SurveyAttachment(
          id: 'display-attachment',
          type: SurveyAttachmentType.image,
          fileName: 'display.jpg',
          capturedAt: _now.subtract(const Duration(minutes: 2)),
          localPath: '/local/display.jpg',
          uploadStatus: uploadStatus,
          uploadError: uploadStatus == SurveyAttachmentUploadStatus.failed
              ? 'network unavailable'
              : null,
        ),
        scope: SurveyEvidenceScope.question,
        questionId: 'display-photo',
        metadata: const {'requirementId': 'display-image'},
      ),
    ],
  );
}

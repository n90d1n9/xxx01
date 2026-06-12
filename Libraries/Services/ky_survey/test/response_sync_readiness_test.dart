import 'package:ky_survey/analytics/survey_response_sync_readiness.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/models/answer.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyResponseSyncReadinessInsights', () {
    test('classifies fieldwork response readiness states', () {
      final survey = _survey();
      final ready = _response(
        id: 'ready',
        answer: 'Shelf looks clean',
        evidenceStatus: SurveyAttachmentUploadStatus.uploaded,
      );
      final needsAnswers = _response(
        id: 'needs-answers',
        evidenceStatus: SurveyAttachmentUploadStatus.uploaded,
      );
      final needsEvidence = _response(
        id: 'needs-evidence',
        answer: 'No photo yet',
      );
      final uploadPending = _response(
        id: 'upload-pending',
        answer: 'Photo captured',
        evidenceStatus: SurveyAttachmentUploadStatus.local,
      );
      final uploadFailed = _response(
        id: 'upload-failed',
        answer: 'Retry photo',
        evidenceStatus: SurveyAttachmentUploadStatus.failed,
      );
      final submitted = _response(
        id: 'submitted',
        answer: 'Already sent',
        evidenceStatus: SurveyAttachmentUploadStatus.uploaded,
        status: SurveyResponseStatus.submitted,
      );
      final missingSurvey = _response(
        id: 'missing-survey',
        surveyId: 'missing',
        answer: 'Cannot match definition',
      );

      final insights = SurveyResponseSyncReadinessInsights.evaluate(
        surveys: [survey],
        responses: [
          ready,
          needsAnswers,
          needsEvidence,
          uploadPending,
          uploadFailed,
          submitted,
          missingSurvey,
        ],
        now: _now,
      );
      final byId = {
        for (final item in insights.items) item.response.id: item.status,
      };

      expect(
        byId,
        containsPair('ready', SurveyResponseSyncReadinessStatus.readyToSubmit),
      );
      expect(
        byId,
        containsPair(
          'needs-answers',
          SurveyResponseSyncReadinessStatus.needsAnswers,
        ),
      );
      expect(
        byId,
        containsPair(
          'needs-evidence',
          SurveyResponseSyncReadinessStatus.needsEvidence,
        ),
      );
      expect(
        byId,
        containsPair(
          'upload-pending',
          SurveyResponseSyncReadinessStatus.uploadPending,
        ),
      );
      expect(
        byId,
        containsPair(
          'upload-failed',
          SurveyResponseSyncReadinessStatus.uploadFailed,
        ),
      );
      expect(
        byId,
        containsPair('submitted', SurveyResponseSyncReadinessStatus.submitted),
      );
      expect(
        byId,
        containsPair(
          'missing-survey',
          SurveyResponseSyncReadinessStatus.missingSurvey,
        ),
      );
      expect(insights.draftCount, 6);
      expect(insights.readyToSubmitCount, 1);
      expect(insights.answerIssueCount, 1);
      expect(insights.evidenceIssueCount, 1);
      expect(insights.uploadPendingCount, 1);
      expect(insights.uploadFailedCount, 1);
      expect(insights.submittedCount, 1);
      expect(insights.actionRequiredCount, 5);
      expect(insights.summaryLabel, '5 responses need attention');
      expect(
        insights.items
            .firstWhere((item) => item.response.id == 'upload-failed')
            .firstUploadIssueItem
            ?.state,
        SurveyEvidenceSyncState.failed,
      );
    });

    test('prioritizes actionable responses before pending sync', () {
      final survey = _survey();
      final insights = SurveyResponseSyncReadinessInsights.evaluate(
        surveys: [survey],
        responses: [
          _response(
            id: 'waiting-upload',
            answer: 'Captured',
            evidenceStatus: SurveyAttachmentUploadStatus.queued,
          ),
          _response(id: 'missing-answer'),
          _response(
            id: 'ready',
            answer: 'Done',
            evidenceStatus: SurveyAttachmentUploadStatus.uploaded,
          ),
        ],
        now: _now,
      );

      expect(insights.actionQueue().map((item) => item.response.id), [
        'missing-answer',
        'ready',
        'waiting-upload',
      ]);
      expect(insights.actionQueue().last.isWaitingForSync, isTrue);
    });

    test('uses useful status and detail labels for field operators', () {
      final survey = _survey();
      final insights = SurveyResponseSyncReadinessInsights.evaluate(
        surveys: [survey],
        responses: [
          _response(
            id: 'upload-pending',
            answer: 'Captured',
            evidenceStatus: SurveyAttachmentUploadStatus.local,
          ),
          _response(id: 'missing-evidence', answer: 'Needs capture'),
        ],
        now: _now,
      );
      final pending = insights.items.firstWhere(
        (item) => item.response.id == 'upload-pending',
      );
      final missingEvidence = insights.items.firstWhere(
        (item) => item.response.id == 'missing-evidence',
      );

      expect(pending.statusLabel, '1 upload pending');
      expect(pending.detailLabel, contains('Retail Audit'));
      expect(missingEvidence.statusLabel, '1 evidence missing');
      expect(missingEvidence.detailLabel, contains('Display image requires'));
    });
  });
}

final _now = DateTime(2026, 11, 1, 10);

Survey _survey() {
  return Survey(
    id: 'retail-audit',
    title: 'Retail Audit',
    description: 'Field audit',
    createdAt: DateTime(2026),
    questions: [
      Question(
        id: 'q1',
        text: 'What did you observe?',
        type: QuestionType.singleLineText,
        required: true,
      ),
    ],
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'display-image',
        kind: SurveyEvidenceKind.image,
        label: 'Display image',
        requireUploaded: true,
      ),
    ],
  );
}

SurveyResponse _response({
  required String id,
  String surveyId = 'retail-audit',
  String? answer,
  SurveyAttachmentUploadStatus? evidenceStatus,
  SurveyResponseStatus status = SurveyResponseStatus.draft,
}) {
  return SurveyResponse(
    id: id,
    surveyId: surveyId,
    respondentId: 'participant-$id',
    respondentName: 'Participant $id',
    startedAt: _now.subtract(const Duration(minutes: 12)),
    submittedAt: status == SurveyResponseStatus.submitted ? _now : null,
    status: status,
    answers: answer == null
        ? const []
        : [
            ResponseAnswer(
              questionId: 'q1',
              value: answer,
              answeredAt: _now.subtract(const Duration(minutes: 4)),
            ),
          ],
    evidence: evidenceStatus == null
        ? const []
        : [_imageEvidence(id: id, status: evidenceStatus)],
  );
}

SurveyEvidence _imageEvidence({
  required String id,
  required SurveyAttachmentUploadStatus status,
}) {
  return SurveyEvidence.attachment(
    id: 'evidence-$id',
    attachment: SurveyAttachment(
      id: 'attachment-$id',
      type: SurveyAttachmentType.image,
      fileName: '$id.jpg',
      capturedAt: _now.subtract(const Duration(minutes: 2)),
      localPath: '/local/$id.jpg',
      remoteUrl: status == SurveyAttachmentUploadStatus.uploaded
          ? 'https://cdn.example/$id.jpg'
          : null,
      uploadStatus: status,
      uploadError: status == SurveyAttachmentUploadStatus.failed
          ? 'network unavailable'
          : null,
    ),
    metadata: const {'requirementId': 'display-image'},
  );
}

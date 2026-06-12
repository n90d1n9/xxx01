import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceSyncInsights', () {
    test('classifies uploaded, pending, failed, and blocked evidence', () {
      final survey = _surveyWithUploadRules();
      final response = _responseFor(survey).copyWith(
        evidence: [
          _attachmentEvidence(
            id: 'uploaded-image',
            kind: SurveyEvidenceKind.image,
            requirementId: 'image-q1',
            uploadStatus: SurveyAttachmentUploadStatus.uploaded,
            localPath: '/local/display.jpg',
            remoteUrl: 'https://cdn.example/display.jpg',
            questionId: 'q1',
          ),
          _attachmentEvidence(
            id: 'local-audio',
            kind: SurveyEvidenceKind.audio,
            requirementId: 'audio',
            uploadStatus: SurveyAttachmentUploadStatus.local,
            localPath: '/local/interview.m4a',
          ),
          _attachmentEvidence(
            id: 'failed-file',
            kind: SurveyEvidenceKind.file,
            requirementId: 'optional-file',
            uploadStatus: SurveyAttachmentUploadStatus.failed,
            localPath: '/local/consent.pdf',
          ),
          _attachmentEvidence(
            id: 'blocked-image',
            kind: SurveyEvidenceKind.image,
            requirementId: 'image-q1',
            uploadStatus: SurveyAttachmentUploadStatus.local,
            questionId: 'q1',
          ),
        ],
      );

      final insights = SurveyEvidenceSyncInsights(
        surveys: [survey],
        responses: [response],
      );
      final queue = insights.itemsNeedingAttention();

      expect(insights.totalAttachmentCount, 4);
      expect(insights.requiredUploadCount, 3);
      expect(insights.requiredUploadedCount, 1);
      expect(insights.uploadedCount, 1);
      expect(insights.pendingUploadCount, 1);
      expect(insights.failedCount, 1);
      expect(insights.blockedCount, 1);
      expect(insights.localOnlyCount, 0);
      expect(insights.actionRequiredCount, 3);
      expect(insights.requiredUploadCompletionRate, closeTo(1 / 3, 0.001));
      expect(insights.statusLabel, '1 blocked');
      expect(queue.map((item) => item.state), [
        SurveyEvidenceSyncState.blocked,
        SurveyEvidenceSyncState.failed,
        SurveyEvidenceSyncState.readyToUpload,
      ]);
      expect(queue.first.detail, contains('local path or remote URL'));
    });

    test('uses metadata requirement id before generic kind matching', () {
      final survey = _surveyWithUploadRules().copyWith(
        evidenceRequirements: const [
          SurveyEvidenceRequirement(
            id: 'optional-image',
            kind: SurveyEvidenceKind.image,
            scope: SurveyEvidenceScope.question,
            questionId: 'q1',
            label: 'Optional image',
            required: false,
          ),
          SurveyEvidenceRequirement(
            id: 'required-image',
            kind: SurveyEvidenceKind.image,
            scope: SurveyEvidenceScope.question,
            questionId: 'q1',
            label: 'Required image',
            requireUploaded: true,
          ),
        ],
      );
      final response = _responseFor(survey).copyWith(
        evidence: [
          _attachmentEvidence(
            id: 'image',
            kind: SurveyEvidenceKind.image,
            requirementId: 'required-image',
            uploadStatus: SurveyAttachmentUploadStatus.local,
            localPath: '/local/image.jpg',
            questionId: 'q1',
          ),
        ],
      );

      final insights = SurveyEvidenceSyncInsights(
        surveys: [survey],
        responses: [response],
      );
      final item = insights.items.single;

      expect(item.requirement?.id, 'required-image');
      expect(item.requiresUpload, isTrue);
      expect(item.state, SurveyEvidenceSyncState.readyToUpload);
    });

    test('reports no attachments as an empty sync queue', () {
      final survey = _surveyWithUploadRules();
      final insights = SurveyEvidenceSyncInsights(
        surveys: [survey],
        responses: [_responseFor(survey)],
      );

      expect(insights.hasAttachments, isFalse);
      expect(insights.statusLabel, 'No evidence attachments');
      expect(insights.itemsNeedingAttention(), isEmpty);
      expect(insights.surveySummaries.single.attachmentCount, 0);
    });
  });
}

Survey _surveyWithUploadRules() {
  return Survey(
    id: 'retail-audit',
    title: 'Retail Audit',
    description: 'Evidence sync audit',
    createdAt: DateTime(2026),
    questions: [
      Question(
        id: 'q1',
        text: 'Take a display photo',
        type: QuestionType.singleLineText,
        required: false,
      ),
    ],
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'image-q1',
        kind: SurveyEvidenceKind.image,
        scope: SurveyEvidenceScope.question,
        questionId: 'q1',
        label: 'Display image',
        requireUploaded: true,
      ),
      SurveyEvidenceRequirement(
        id: 'audio',
        kind: SurveyEvidenceKind.audio,
        label: 'Interview audio',
        requireUploaded: true,
      ),
      SurveyEvidenceRequirement(
        id: 'optional-file',
        kind: SurveyEvidenceKind.file,
        label: 'Consent file',
        required: false,
      ),
    ],
  );
}

SurveyResponse _responseFor(Survey survey) {
  return SurveyResponse(
    id: 'response-1',
    surveyId: survey.id,
    respondentId: 'participant-1',
    respondentName: 'Participant',
    startedAt: DateTime(2026),
  );
}

SurveyEvidence _attachmentEvidence({
  required String id,
  required SurveyEvidenceKind kind,
  required String requirementId,
  required SurveyAttachmentUploadStatus uploadStatus,
  String? localPath,
  String? remoteUrl,
  String? questionId,
}) {
  return SurveyEvidence.attachment(
    id: id,
    attachment: SurveyAttachment(
      id: id,
      type: _attachmentTypeFor(kind),
      fileName: '$id.dat',
      capturedAt: DateTime(2026),
      localPath: localPath,
      remoteUrl: remoteUrl,
      uploadStatus: uploadStatus,
    ),
    scope: questionId == null
        ? SurveyEvidenceScope.response
        : SurveyEvidenceScope.question,
    questionId: questionId,
    metadata: {'requirementId': requirementId},
  );
}

SurveyAttachmentType _attachmentTypeFor(SurveyEvidenceKind kind) {
  switch (kind) {
    case SurveyEvidenceKind.image:
      return SurveyAttachmentType.image;
    case SurveyEvidenceKind.audio:
      return SurveyAttachmentType.audio;
    case SurveyEvidenceKind.file:
      return SurveyAttachmentType.file;
    case SurveyEvidenceKind.location:
      throw ArgumentError('Location evidence does not have an attachment type');
  }
}

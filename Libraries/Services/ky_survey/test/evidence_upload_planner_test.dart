import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceUploadPlanner', () {
    test('prioritizes blocked, failed, ready, and active upload tasks', () {
      final survey = _surveyWithUploadRules();
      final response = _responseFor(survey).copyWith(
        evidence: [
          _attachmentEvidence(
            id: 'uploaded',
            kind: SurveyEvidenceKind.image,
            requirementId: 'image-q1',
            uploadStatus: SurveyAttachmentUploadStatus.uploaded,
            localPath: '/local/uploaded.jpg',
            questionId: 'q1',
          ),
          _attachmentEvidence(
            id: 'queued',
            kind: SurveyEvidenceKind.audio,
            requirementId: 'audio',
            uploadStatus: SurveyAttachmentUploadStatus.queued,
            localPath: '/local/queued.m4a',
          ),
          _attachmentEvidence(
            id: 'ready',
            kind: SurveyEvidenceKind.audio,
            requirementId: 'audio',
            uploadStatus: SurveyAttachmentUploadStatus.local,
            localPath: '/local/ready.m4a',
          ),
          _attachmentEvidence(
            id: 'failed',
            kind: SurveyEvidenceKind.audio,
            requirementId: 'audio',
            uploadStatus: SurveyAttachmentUploadStatus.failed,
            localPath: '/local/failed.m4a',
            uploadError: 'timeout',
          ),
          _attachmentEvidence(
            id: 'blocked',
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

      final plan = SurveyEvidenceUploadPlanner(insights: insights).createPlan();

      expect(plan.hasWork, isTrue);
      expect(plan.tasks.map((task) => task.evidenceId), [
        'blocked',
        'failed',
        'ready',
        'queued',
      ]);
      expect(plan.tasks.map((task) => task.action), [
        SurveyEvidenceUploadAction.fixEvidence,
        SurveyEvidenceUploadAction.retryUpload,
        SurveyEvidenceUploadAction.queueUpload,
        SurveyEvidenceUploadAction.monitorUpload,
      ]);
      expect(plan.uploadableTasks.map((task) => task.evidenceId), [
        'failed',
        'ready',
      ]);
      expect(plan.nextUploadTask?.evidenceId, 'failed');
      expect(plan.blockedTasks.single.actionLabel, 'Fix evidence');
      expect(plan.retryableTasks.single.detail, 'timeout');
      expect(plan.monitoringTasks.single.actionLabel, 'Monitor upload');
    });

    test('respects task limits after priority sorting', () {
      final survey = _surveyWithUploadRules();
      final response = _responseFor(survey).copyWith(
        evidence: [
          _attachmentEvidence(
            id: 'ready-1',
            kind: SurveyEvidenceKind.audio,
            requirementId: 'audio',
            uploadStatus: SurveyAttachmentUploadStatus.local,
            localPath: '/local/ready-1.m4a',
            capturedAt: DateTime(2026, 1, 1),
          ),
          _attachmentEvidence(
            id: 'failed',
            kind: SurveyEvidenceKind.audio,
            requirementId: 'audio',
            uploadStatus: SurveyAttachmentUploadStatus.failed,
            localPath: '/local/failed.m4a',
          ),
          _attachmentEvidence(
            id: 'ready-2',
            kind: SurveyEvidenceKind.audio,
            requirementId: 'audio',
            uploadStatus: SurveyAttachmentUploadStatus.local,
            localPath: '/local/ready-2.m4a',
            capturedAt: DateTime(2026, 1, 2),
          ),
        ],
      );
      final insights = SurveyEvidenceSyncInsights(
        surveys: [survey],
        responses: [response],
      );

      final plan = SurveyEvidenceUploadPlanner(
        insights: insights,
      ).createPlan(limit: 2);

      expect(plan.tasks.map((task) => task.evidenceId), ['failed', 'ready-2']);
    });
  });
}

Survey _surveyWithUploadRules() {
  return Survey(
    id: 'retail-audit',
    title: 'Retail Audit',
    description: 'Evidence upload audit',
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
  String? questionId,
  String? uploadError,
  DateTime? capturedAt,
}) {
  return SurveyEvidence.attachment(
    id: id,
    attachment: SurveyAttachment(
      id: id,
      type: _attachmentTypeFor(kind),
      fileName: '$id.dat',
      capturedAt: capturedAt ?? DateTime(2026),
      localPath: localPath,
      uploadStatus: uploadStatus,
      uploadError: uploadError,
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

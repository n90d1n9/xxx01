import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_execution_feedback.dart';
import 'package:ky_survey/logic/survey_evidence_upload_service.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';

void main() {
  group('SurveyEvidenceUploadExecutionFeedback', () {
    test('uses success copy for completed uploads', () {
      final task = _uploadTask();
      final feedback = SurveyEvidenceUploadExecutionFeedback.fromExecution(
        SurveyEvidenceUploadExecution.uploaded(
          task: task,
          queuedAt: _now,
          uploadingAt: _now,
          completedAt: _now,
          remoteUrl: 'https://cdn.example/display.jpg',
        ),
      );

      expect(feedback.tone, SurveyEvidenceUploadExecutionFeedbackTone.success);
      expect(feedback.title, 'Upload completed');
      expect(feedback.message, 'Display image uploaded');
    });

    test('uses error copy for failed uploads', () {
      final task = _uploadTask();
      final feedback = SurveyEvidenceUploadExecutionFeedback.fromExecution(
        SurveyEvidenceUploadExecution.failed(
          task: task,
          queuedAt: _now,
          uploadingAt: _now,
          completedAt: _now,
          message: 'network timeout',
        ),
      );

      expect(feedback.tone, SurveyEvidenceUploadExecutionFeedbackTone.error);
      expect(feedback.title, 'Upload failed');
      expect(feedback.message, 'Display image: network timeout');
    });

    test('uses warning copy for skipped uploads', () {
      final task = _uploadTask();
      final feedback = SurveyEvidenceUploadExecutionFeedback.fromExecution(
        SurveyEvidenceUploadExecution.skipped(
          task: task,
          completedAt: _now,
          message: 'Task action cannot start upload.',
        ),
      );

      expect(feedback.tone, SurveyEvidenceUploadExecutionFeedbackTone.warning);
      expect(feedback.title, 'Upload skipped');
      expect(
        feedback.message,
        'Display image: Task action cannot start upload.',
      );
    });

    test('uses info copy when no task is available', () {
      final feedback = SurveyEvidenceUploadExecutionFeedback.fromExecution(
        SurveyEvidenceUploadExecution.noTask(completedAt: _now),
      );

      expect(feedback.tone, SurveyEvidenceUploadExecutionFeedbackTone.info);
      expect(feedback.title, 'No upload task');
      expect(feedback.message, 'No uploadable evidence task is available.');
    });
  });
}

final _now = DateTime(2026, 1, 2, 9, 30);

SurveyEvidenceUploadTask _uploadTask() {
  final survey = Survey(
    id: 'survey-1',
    title: 'Store Audit',
    description: 'Audit display setup',
    createdAt: _now,
    questions: [
      Question(
        id: 'display-photo',
        text: 'Display photo',
        type: QuestionType.singleLineText,
        required: false,
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
  final response = SurveyResponse(
    id: 'response-1',
    surveyId: survey.id,
    respondentId: 'respondent-1',
    respondentName: 'Participant',
    startedAt: _now,
  );
  final attachment = SurveyAttachment(
    id: 'attachment-1',
    type: SurveyAttachmentType.image,
    fileName: 'display.jpg',
    capturedAt: _now,
    uploadStatus: SurveyAttachmentUploadStatus.failed,
  );
  final evidence = SurveyEvidence.attachment(
    id: 'evidence-1',
    attachment: attachment,
    scope: SurveyEvidenceScope.question,
    questionId: 'display-photo',
    metadata: const {'requirementId': 'display-image'},
  );

  return SurveyEvidenceUploadTask(
    item: SurveyEvidenceSyncItem(
      survey: survey,
      response: response,
      evidence: evidence,
      attachment: attachment,
      requirement: survey.evidenceRequirements.single,
      issues: const [],
    ),
    action: SurveyEvidenceUploadAction.retryUpload,
  );
}

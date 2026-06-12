import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_activity_tracker.dart';
import 'package:ky_survey/logic/survey_evidence_upload_plan_activity.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';

void main() {
  group('SurveyEvidenceUploadPlanActivity', () {
    test('splits uploadable tasks into ready and active work', () {
      final activeTask = _uploadTask(evidenceId: 'photo-active');
      final readyTask = _uploadTask(evidenceId: 'photo-ready');
      final blockedTask = _uploadTask(
        evidenceId: 'photo-blocked',
        action: SurveyEvidenceUploadAction.fixEvidence,
      );

      final activity = SurveyEvidenceUploadPlanActivity(
        plan: SurveyEvidenceUploadPlan(
          tasks: [activeTask, readyTask, blockedTask],
        ),
        activeUploadKeys: {
          SurveyEvidenceUploadActivityTracker.keyFor(activeTask),
        },
      );

      expect(activity.uploadableTasks, [activeTask, readyTask]);
      expect(activity.activeUploadableTasks, [activeTask]);
      expect(activity.readyUploadableTasks, [readyTask]);
      expect(activity.activeUploadableCount, 1);
      expect(activity.readyUploadableCount, 1);
      expect(activity.allUploadableTasksActive, isFalse);
    });

    test('reports all uploadable tasks active when no ready work remains', () {
      final task = _uploadTask(evidenceId: 'photo-active');

      final activity = SurveyEvidenceUploadPlanActivity(
        plan: SurveyEvidenceUploadPlan(tasks: [task]),
        activeUploadKeys: {SurveyEvidenceUploadActivityTracker.keyFor(task)},
      );

      expect(activity.hasUploadableTasks, isTrue);
      expect(activity.hasReadyUploadableTasks, isFalse);
      expect(activity.allUploadableTasksActive, isTrue);
    });
  });
}

SurveyEvidenceUploadTask _uploadTask({
  required String evidenceId,
  SurveyEvidenceUploadAction action = SurveyEvidenceUploadAction.queueUpload,
}) {
  final survey = Survey(
    id: 'survey-1',
    title: 'Field Audit',
    description: 'Upload plan activity test',
    createdAt: DateTime(2026),
    questions: const [],
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'upload-required',
        kind: SurveyEvidenceKind.image,
        label: 'Upload evidence',
        requireUploaded: true,
      ),
    ],
  );
  final response = SurveyResponse(
    id: 'response-1',
    surveyId: survey.id,
    respondentId: 'participant-1',
    respondentName: 'Participant',
    startedAt: DateTime(2026),
  );
  final attachment = SurveyAttachment(
    id: evidenceId,
    type: SurveyAttachmentType.image,
    fileName: '$evidenceId.dat',
    capturedAt: DateTime(2026),
    localPath: '/local/$evidenceId.dat',
  );
  final evidence = SurveyEvidence.attachment(
    id: evidenceId,
    attachment: attachment,
    metadata: const {'requirementId': 'upload-required'},
  );
  final item = SurveyEvidenceSyncItem(
    survey: survey,
    response: response,
    evidence: evidence,
    attachment: attachment,
    requirement: survey.evidenceRequirements.single,
    issues: const [],
  );

  return SurveyEvidenceUploadTask(item: item, action: action);
}

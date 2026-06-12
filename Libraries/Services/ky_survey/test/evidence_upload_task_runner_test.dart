import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_activity_tracker.dart';
import 'package:ky_survey/logic/survey_evidence_upload_service.dart';
import 'package:ky_survey/logic/survey_evidence_upload_task_runner.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';

void main() {
  group('SurveyEvidenceUploadTaskRunner', () {
    test('does not run an already active task', () async {
      final task = _uploadTask(evidenceId: 'photo-1');
      final tracker = SurveyEvidenceUploadActivityTracker(
        activeKeys: {SurveyEvidenceUploadActivityTracker.keyFor(task)},
      );
      var uploadCount = 0;
      final runner = SurveyEvidenceUploadTaskRunner(
        service: SurveyEvidenceUploadService(
          uploader: _FakeUploader((request) async {
            uploadCount += 1;
            return const SurveyEvidenceUploadResult.uploaded(
              remoteUrl: 'https://cdn.example/photo-1.dat',
            );
          }),
        ),
        activityTracker: tracker,
      );

      final result = await runner.uploadTask(task);

      expect(result.alreadyActive, isTrue);
      expect(uploadCount, 0);
      expect(tracker.isActive(task), isTrue);
    });

    test('tracks a task while it uploads and releases it afterward', () async {
      final task = _uploadTask(evidenceId: 'photo-2');
      final tracker = SurveyEvidenceUploadActivityTracker();
      final activityChanges = <Set<String>>[];
      final runner = SurveyEvidenceUploadTaskRunner(
        service: SurveyEvidenceUploadService(
          uploader: _FakeUploader((request) async {
            expect(tracker.isActive(task), isTrue);
            return const SurveyEvidenceUploadResult.uploaded(
              remoteUrl: 'https://cdn.example/photo-2.dat',
            );
          }),
        ),
        activityTracker: tracker,
        onActivityChanged: () => activityChanges.add(tracker.activeKeys),
      );

      final result = await runner.uploadTask(task);

      expect(result.completed, isTrue);
      expect(
        result.execution!.status,
        SurveyEvidenceUploadExecutionStatus.uploaded,
      );
      expect(activityChanges, [
        {'response-1:photo-2'},
        <String>{},
      ]);
      expect(tracker.activeKeys, isEmpty);
    });

    test('runs only inactive uploadable tasks from a plan', () async {
      final activeTask = _uploadTask(evidenceId: 'photo-active');
      final inactiveTask = _uploadTask(evidenceId: 'photo-ready');
      final blockedTask = _uploadTask(
        evidenceId: 'photo-blocked',
        action: SurveyEvidenceUploadAction.fixEvidence,
      );
      final tracker = SurveyEvidenceUploadActivityTracker(
        activeKeys: {SurveyEvidenceUploadActivityTracker.keyFor(activeTask)},
      );
      final uploadedEvidenceIds = <String>[];
      final runner = SurveyEvidenceUploadTaskRunner(
        service: SurveyEvidenceUploadService(
          uploader: _FakeUploader((request) async {
            uploadedEvidenceIds.add(request.task.evidenceId);
            expect(tracker.isActive(request.task), isTrue);
            return SurveyEvidenceUploadResult.uploaded(
              remoteUrl: 'https://cdn.example/${request.task.evidenceId}.dat',
            );
          }),
        ),
        activityTracker: tracker,
      );

      final result = await runner.uploadPlan(
        SurveyEvidenceUploadPlan(
          tasks: [activeTask, inactiveTask, blockedTask],
        ),
      );

      expect(result.hasUploadableTasks, isTrue);
      expect(result.tasks, [inactiveTask]);
      expect(uploadedEvidenceIds, ['photo-ready']);
      expect(tracker.activeKeys, {'response-1:photo-active'});
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
    description: 'Upload runner test',
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

class _FakeUploader implements SurveyEvidenceUploader {
  final Future<SurveyEvidenceUploadResult> Function(
    SurveyEvidenceUploadRequest request,
  )
  handler;

  const _FakeUploader(this.handler);

  @override
  Future<SurveyEvidenceUploadResult> upload(
    SurveyEvidenceUploadRequest request,
  ) {
    return handler(request);
  }
}

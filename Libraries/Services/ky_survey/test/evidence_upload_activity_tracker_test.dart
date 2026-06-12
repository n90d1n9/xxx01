import 'package:flutter_test/flutter_test.dart';
import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_activity_tracker.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';

void main() {
  group('SurveyEvidenceUploadActivityTracker', () {
    test('tracks and releases individual evidence upload tasks', () {
      final tracker = SurveyEvidenceUploadActivityTracker();
      final task = _uploadTask(responseId: 'response-1', evidenceId: 'photo-1');

      expect(
        SurveyEvidenceUploadActivityTracker.keyFor(task),
        'response-1:photo-1',
      );
      expect(tracker.isActive(task), isFalse);

      tracker.track(task);

      expect(tracker.isActive(task), isTrue);
      expect(tracker.activeKeys, {'response-1:photo-1'});

      tracker.release(task);

      expect(tracker.isActive(task), isFalse);
      expect(tracker.activeKeys, isEmpty);
    });

    test('filters inactive tasks and releases tracked plan keys', () {
      final first = _uploadTask(
        responseId: 'response-1',
        evidenceId: 'photo-1',
      );
      final second = _uploadTask(
        responseId: 'response-1',
        evidenceId: 'photo-2',
      );
      final tracker = SurveyEvidenceUploadActivityTracker(
        activeKeys: {SurveyEvidenceUploadActivityTracker.keyFor(first)},
      );

      expect(tracker.inactiveTasks([first, second]), [second]);

      final planKeys = tracker.keysFor([first, second]);
      tracker.trackKeys(planKeys);

      expect(tracker.activeKeys, {'response-1:photo-1', 'response-1:photo-2'});

      tracker.releaseKeys(planKeys);

      expect(tracker.activeKeys, isEmpty);
    });
  });
}

SurveyEvidenceUploadTask _uploadTask({
  required String responseId,
  required String evidenceId,
}) {
  final survey = Survey(
    id: 'survey-1',
    title: 'Field Audit',
    description: 'Upload activity test',
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
    id: responseId,
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

  return SurveyEvidenceUploadTask(
    item: item,
    action: SurveyEvidenceUploadAction.queueUpload,
  );
}

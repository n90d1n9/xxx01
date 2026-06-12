import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_queue_insights.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_action_feedback.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_actions.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_coordinator.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_maintenance.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_processor.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceUploadQueueActionFeedback', () {
    test('uses success feedback when evidence is queued', () {
      final entry = _entry('photo');
      final queue = SurveyEvidenceUploadQueue(entries: [entry]);
      final result = _actionResult(
        action: SurveyEvidenceUploadQueueAction.enqueuePlan,
        message: '1 queued',
        enqueueResult: SurveyEvidenceUploadQueueEnqueueResult(
          initialQueue: const SurveyEvidenceUploadQueue(),
          queue: queue,
          enqueuedEntries: [entry],
          queuedAt: _now,
        ),
      );

      final feedback = SurveyEvidenceUploadQueueActionFeedback.fromResult(
        result,
      );

      expect(
        feedback.tone,
        SurveyEvidenceUploadQueueActionFeedbackTone.success,
      );
      expect(feedback.title, 'Evidence queued');
      expect(feedback.message, '1 queued');
    });

    test('uses warning feedback when uploads are scheduled for retry', () {
      final original = _entry('audio');
      final retry = original.copyWith(
        attemptCount: 1,
        nextAttemptAt: _now.add(const Duration(minutes: 5)),
        lastError: 'timeout',
        updatedAt: _now,
      );
      final queue = SurveyEvidenceUploadQueue(entries: [retry]);
      final result = _actionResult(
        action: SurveyEvidenceUploadQueueAction.runDueUploads,
        message: '1 retry scheduled',
        processResult: SurveyEvidenceUploadQueueProcessResult(
          queue: queue,
          items: [
            SurveyEvidenceUploadQueueProcessItem(
              originalEntry: original,
              updatedEntry: retry,
              message: 'timeout',
            ),
          ],
          dueEntryCount: 1,
        ),
      );

      final feedback = SurveyEvidenceUploadQueueActionFeedback.fromResult(
        result,
      );

      expect(
        feedback.tone,
        SurveyEvidenceUploadQueueActionFeedbackTone.warning,
      );
      expect(feedback.title, 'Uploads need follow-up');
      expect(feedback.message, '1 retry scheduled');
    });

    test('uses error feedback when due uploads end in terminal failure', () {
      final original = _entry('location');
      final failed = original.copyWith(
        status: SurveyEvidenceUploadQueueStatus.failed,
        attemptCount: 1,
        clearNextAttemptAt: true,
        lastError: 'network unavailable',
        updatedAt: _now,
      );
      final queue = SurveyEvidenceUploadQueue(entries: [failed]);
      final result = _actionResult(
        action: SurveyEvidenceUploadQueueAction.runDueUploads,
        message: '1 failed',
        processResult: SurveyEvidenceUploadQueueProcessResult(
          queue: queue,
          items: [
            SurveyEvidenceUploadQueueProcessItem(
              originalEntry: original,
              updatedEntry: failed,
              message: 'network unavailable',
            ),
          ],
          dueEntryCount: 1,
        ),
      );

      final feedback = SurveyEvidenceUploadQueueActionFeedback.fromResult(
        result,
      );

      expect(feedback.tone, SurveyEvidenceUploadQueueActionFeedbackTone.error);
      expect(feedback.title, 'Uploads failed');
      expect(feedback.message, '1 failed');
    });

    test('distinguishes clean maintenance from recovered queue work', () {
      final recovered = _entry('photo').copyWith(
        status: SurveyEvidenceUploadQueueStatus.pending,
        updatedAt: _now,
      );
      final queue = SurveyEvidenceUploadQueue(entries: [recovered]);

      final cleanFeedback = SurveyEvidenceUploadQueueActionFeedback.fromResult(
        _actionResult(
          action: SurveyEvidenceUploadQueueAction.maintainQueue,
          message: 'Queue maintenance made no changes',
          maintenanceResult: SurveyEvidenceUploadQueueMaintenanceResult(
            initialQueue: queue,
            queue: queue,
            maintainedAt: _now,
          ),
        ),
      );
      final recoveredFeedback =
          SurveyEvidenceUploadQueueActionFeedback.fromResult(
            _actionResult(
              action: SurveyEvidenceUploadQueueAction.maintainQueue,
              message: '1 recovered',
              maintenanceResult: SurveyEvidenceUploadQueueMaintenanceResult(
                initialQueue: const SurveyEvidenceUploadQueue(),
                queue: queue,
                recoveredEntries: [recovered],
                maintainedAt: _now,
              ),
            ),
          );

      expect(
        cleanFeedback.tone,
        SurveyEvidenceUploadQueueActionFeedbackTone.info,
      );
      expect(cleanFeedback.title, 'Queue already clean');
      expect(
        recoveredFeedback.tone,
        SurveyEvidenceUploadQueueActionFeedbackTone.warning,
      );
      expect(recoveredFeedback.title, 'Queue has recovered work');
    });

    test('builds concise error feedback for failed actions', () {
      final feedback = SurveyEvidenceUploadQueueActionFeedback.fromError(
        action: SurveyEvidenceUploadQueueAction.syncPlan,
        error: StateError('storage unavailable'),
      );

      expect(feedback.tone, SurveyEvidenceUploadQueueActionFeedbackTone.error);
      expect(feedback.title, 'Sync queue failed');
      expect(feedback.message, contains('storage unavailable'));
    });
  });
}

final _now = DateTime(2026, 10, 1, 9);

SurveyEvidenceUploadQueueActionResult _actionResult({
  required SurveyEvidenceUploadQueueAction action,
  required String message,
  SurveyEvidenceUploadQueueEnqueueResult? enqueueResult,
  SurveyEvidenceUploadQueueProcessResult? processResult,
  SurveyEvidenceUploadQueueMaintenanceResult? maintenanceResult,
  SurveyEvidenceUploadQueueSyncResult? syncResult,
}) {
  final queue =
      enqueueResult?.queue ??
      processResult?.queue ??
      maintenanceResult?.queue ??
      syncResult?.finalQueue ??
      const SurveyEvidenceUploadQueue();

  return SurveyEvidenceUploadQueueActionResult(
    action: action,
    queue: queue,
    insights: SurveyEvidenceUploadQueueInsights(queue: queue, now: _now),
    generatedAt: _now,
    message: message,
    enqueueResult: enqueueResult,
    processResult: processResult,
    maintenanceResult: maintenanceResult,
    syncResult: syncResult,
  );
}

SurveyEvidenceUploadQueueEntry _entry(String id) {
  return SurveyEvidenceUploadQueueEntry.fromTask(
    _uploadTask(id),
    queuedAt: _now.subtract(const Duration(minutes: 1)),
  );
}

SurveyEvidenceUploadTask _uploadTask(String id) {
  return SurveyEvidenceUploadTask(
    item: _syncItem(id),
    action: SurveyEvidenceUploadAction.queueUpload,
  );
}

SurveyEvidenceSyncItem _syncItem(String id) {
  final survey = Survey(
    id: 'survey-1',
    title: 'Feedback survey',
    description: 'Queue feedback test',
    createdAt: DateTime(2026),
    questions: const [],
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'upload-required',
        kind: SurveyEvidenceKind.image,
        label: 'Evidence upload',
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
    id: id,
    type: SurveyAttachmentType.image,
    fileName: '$id.jpg',
    capturedAt: DateTime(2026),
    localPath: '/local/$id.jpg',
  );
  final evidence = SurveyEvidence.attachment(
    id: id,
    attachment: attachment,
    metadata: const {'requirementId': 'upload-required'},
  );

  return SurveyEvidenceSyncItem(
    survey: survey,
    response: response,
    evidence: evidence,
    attachment: attachment,
    requirement: survey.evidenceRequirements.single,
    issues: const [],
  );
}

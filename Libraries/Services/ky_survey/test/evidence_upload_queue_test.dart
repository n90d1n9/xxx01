import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue.dart';
import 'package:ky_survey/logic/survey_evidence_upload_retry_policy.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceUploadQueuePlanner', () {
    test('enqueues uploadable tasks and deduplicates active entries', () {
      final queuedAt = DateTime(2026, 3, 1, 8);
      final plan = SurveyEvidenceUploadPlan(
        tasks: [
          _uploadTask(
            id: 'failed',
            action: SurveyEvidenceUploadAction.retryUpload,
          ),
          _uploadTask(id: 'ready'),
          _uploadTask(
            id: 'blocked',
            action: SurveyEvidenceUploadAction.fixEvidence,
          ),
        ],
      );

      final firstQueue = SurveyEvidenceUploadQueuePlanner(
        queue: const SurveyEvidenceUploadQueue(),
        plan: plan,
        queuedAt: queuedAt,
      ).enqueueUploadableTasks(metadata: const {'source': 'reports'});
      final secondQueue = SurveyEvidenceUploadQueuePlanner(
        queue: firstQueue,
        plan: plan,
        queuedAt: queuedAt.add(const Duration(minutes: 5)),
      ).enqueueUploadableTasks();

      expect(firstQueue.entries.map((entry) => entry.evidenceId), [
        'failed',
        'ready',
      ]);
      expect(firstQueue.pendingCount, 2);
      expect(firstQueue.entries.first.metadata['source'], 'reports');
      expect(secondQueue.entries, hasLength(2));
    });

    test('orders due entries by upload priority then created time', () {
      final now = DateTime(2026, 3, 2, 8);
      final queue = SurveyEvidenceUploadQueue(
        entries: [
          _queueEntry(
            id: 'ready-new',
            action: SurveyEvidenceUploadAction.queueUpload,
            createdAt: now.add(const Duration(minutes: 2)),
            nextAttemptAt: now,
          ),
          _queueEntry(
            id: 'retry-old',
            action: SurveyEvidenceUploadAction.retryUpload,
            createdAt: now,
          ),
          _queueEntry(
            id: 'ready-later',
            action: SurveyEvidenceUploadAction.queueUpload,
            createdAt: now.add(const Duration(minutes: 1)),
            nextAttemptAt: now.add(const Duration(hours: 1)),
          ),
        ],
      );

      final dueEntries = queue.dueEntries(now: now);

      expect(dueEntries.map((entry) => entry.evidenceId), [
        'retry-old',
        'ready-new',
      ]);
    });

    test('schedules retries and eventually marks failures terminal', () {
      final failedAt = DateTime(2026, 3, 3, 8);
      final policy = SurveyEvidenceUploadRetryPolicy.fixed(
        maxAttempts: 2,
        delay: const Duration(minutes: 15),
      );
      final entry = _queueEntry(id: 'retry-me');

      final retry = entry.markFailed(
        error: 'network unavailable',
        failedAt: failedAt,
        retryPolicy: policy,
      );
      final terminalFailure = retry.markFailed(
        error: 'still offline',
        failedAt: failedAt.add(const Duration(minutes: 20)),
        retryPolicy: policy,
      );

      expect(retry.status, SurveyEvidenceUploadQueueStatus.pending);
      expect(retry.attemptCount, 1);
      expect(retry.nextAttemptAt, failedAt.add(const Duration(minutes: 15)));
      expect(retry.lastError, 'network unavailable');
      expect(terminalFailure.status, SurveyEvidenceUploadQueueStatus.failed);
      expect(terminalFailure.attemptCount, 2);
      expect(terminalFailure.nextAttemptAt, isNull);
      expect(terminalFailure.lastError, 'still offline');
    });

    test('serializes queue entries for host app persistence', () {
      final queue = SurveyEvidenceUploadQueue(
        entries: [
          _queueEntry(id: 'persisted').markUploading(DateTime(2026, 3, 4, 9)),
        ],
      );

      final restored = SurveyEvidenceUploadQueue.fromJson(queue.toJson());

      expect(restored.entries, hasLength(1));
      expect(restored.entries.single.id, 'response-1:persisted');
      expect(
        restored.entries.single.status,
        SurveyEvidenceUploadQueueStatus.uploading,
      );
      expect(
        restored.entries.single.metadata['evidenceTitle'],
        'Upload evidence',
      );
    });
  });
}

SurveyEvidenceUploadTask _uploadTask({
  required String id,
  SurveyEvidenceUploadAction action = SurveyEvidenceUploadAction.queueUpload,
}) {
  final item = _syncItem(id: id);
  return SurveyEvidenceUploadTask(item: item, action: action);
}

SurveyEvidenceUploadQueueEntry _queueEntry({
  required String id,
  SurveyEvidenceUploadAction action = SurveyEvidenceUploadAction.queueUpload,
  DateTime? createdAt,
  DateTime? nextAttemptAt,
}) {
  final task = _uploadTask(id: id, action: action);
  return SurveyEvidenceUploadQueueEntry.fromTask(
    task,
    queuedAt: createdAt ?? DateTime(2026, 3),
    nextAttemptAt: nextAttemptAt ?? createdAt ?? DateTime(2026, 3),
  );
}

SurveyEvidenceSyncItem _syncItem({required String id}) {
  final survey = Survey(
    id: 'survey-1',
    title: 'Offline Audit',
    description: 'Queue test',
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

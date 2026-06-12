import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_queue_insights.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceUploadQueueInsights', () {
    test('reports due uploads as ready work', () {
      final now = DateTime(2026, 6, 1, 8);
      final queue = SurveyEvidenceUploadQueue(
        entries: [
          _queueEntry(
            id: 'retry',
            action: SurveyEvidenceUploadAction.retryUpload,
            createdAt: now.subtract(const Duration(minutes: 20)),
            nextAttemptAt: now,
          ),
          _queueEntry(
            id: 'ready',
            createdAt: now.subtract(const Duration(minutes: 10)),
            nextAttemptAt: now.subtract(const Duration(minutes: 1)),
          ),
        ],
      );

      final insights = SurveyEvidenceUploadQueueInsights(
        queue: queue,
        now: now,
      );

      expect(insights.health, SurveyEvidenceUploadQueueHealth.ready);
      expect(insights.healthLabel, 'Ready to upload');
      expect(insights.nextActionLabel, 'Run due uploads');
      expect(insights.dueCount, 2);
      expect(insights.oldestDueAt, now.subtract(const Duration(minutes: 20)));
      expect(insights.summaryLabel, '2 due');
    });

    test('identifies scheduled retries and next wake time', () {
      final now = DateTime(2026, 6, 2, 8);
      final queue = SurveyEvidenceUploadQueue(
        entries: [
          _queueEntry(
            id: 'later',
            createdAt: now.subtract(const Duration(hours: 2)),
            nextAttemptAt: now.add(const Duration(minutes: 30)),
          ),
          _queueEntry(
            id: 'soon',
            action: SurveyEvidenceUploadAction.retryUpload,
            createdAt: now.subtract(const Duration(hours: 1)),
            nextAttemptAt: now.add(const Duration(minutes: 5)),
          ),
        ],
      );

      final insights = SurveyEvidenceUploadQueueInsights(
        queue: queue,
        now: now,
      );

      expect(insights.health, SurveyEvidenceUploadQueueHealth.waiting);
      expect(insights.waitingCount, 2);
      expect(insights.nextWakeAt, now.add(const Duration(minutes: 5)));
      expect(insights.waitUntilNextWake, const Duration(minutes: 5));
      expect(insights.oldestPendingAt, now.subtract(const Duration(hours: 2)));
      expect(insights.summaryLabel, '2 waiting');
    });

    test('prioritizes failed and stale uploads as attention items', () {
      final now = DateTime(2026, 6, 3, 8);
      final failed =
          _queueEntry(
            id: 'failed',
            createdAt: now.subtract(const Duration(hours: 3)),
          ).copyWith(
            status: SurveyEvidenceUploadQueueStatus.failed,
            updatedAt: now.subtract(const Duration(hours: 2)),
            lastError: 'quota exceeded',
            clearNextAttemptAt: true,
          );
      final staleUploading =
          _queueEntry(
            id: 'stale',
            createdAt: now.subtract(const Duration(hours: 1)),
          ).copyWith(
            status: SurveyEvidenceUploadQueueStatus.uploading,
            updatedAt: now.subtract(const Duration(minutes: 45)),
          );
      final activeUploading =
          _queueEntry(
            id: 'active',
            createdAt: now.subtract(const Duration(minutes: 5)),
          ).copyWith(
            status: SurveyEvidenceUploadQueueStatus.uploading,
            updatedAt: now.subtract(const Duration(minutes: 5)),
          );

      final insights = SurveyEvidenceUploadQueueInsights(
        queue: SurveyEvidenceUploadQueue(
          entries: [failed, staleUploading, activeUploading],
        ),
        now: now,
      );

      expect(insights.health, SurveyEvidenceUploadQueueHealth.needsAttention);
      expect(insights.needsAttention, isTrue);
      expect(insights.failedCount, 1);
      expect(insights.uploadingCount, 2);
      expect(insights.staleUploadingCount, 1);
      expect(insights.nextActionLabel, 'Review failed uploads');
      expect(insights.summaryLabel, '2 uploading, 1 failed, 1 stale');
    });

    test('reports terminal queues as complete', () {
      final now = DateTime(2026, 6, 4, 8);
      final uploaded =
          _queueEntry(
            id: 'uploaded',
            createdAt: now.subtract(const Duration(hours: 2)),
          ).markUploaded(
            remoteUrl: 'https://cdn.example/uploaded.jpg',
            uploadedAt: now.subtract(const Duration(hours: 1)),
          );
      final skipped = _queueEntry(
        id: 'skipped',
        createdAt: now.subtract(const Duration(hours: 1)),
      ).markSkipped(reason: 'Requirement removed', skippedAt: now);

      final insights = SurveyEvidenceUploadQueueInsights(
        queue: SurveyEvidenceUploadQueue(entries: [uploaded, skipped]),
        now: now,
      );

      expect(insights.health, SurveyEvidenceUploadQueueHealth.complete);
      expect(insights.isComplete, isTrue);
      expect(insights.terminalCount, 2);
      expect(insights.hasWork, isFalse);
      expect(insights.summaryLabel, '2 complete');
    });
  });
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
    queuedAt: createdAt ?? DateTime(2026, 6),
    nextAttemptAt: nextAttemptAt ?? createdAt ?? DateTime(2026, 6),
  );
}

SurveyEvidenceUploadTask _uploadTask({
  required String id,
  SurveyEvidenceUploadAction action = SurveyEvidenceUploadAction.queueUpload,
}) {
  return SurveyEvidenceUploadTask(
    item: _syncItem(id: id),
    action: action,
  );
}

SurveyEvidenceSyncItem _syncItem({required String id}) {
  final survey = Survey(
    id: 'survey-1',
    title: 'Queue Insights',
    description: 'Queue insights test',
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

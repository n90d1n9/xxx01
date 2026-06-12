import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_queue_insights.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_actions.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_coordinator.dart';
import 'package:ky_survey/logic/survey_evidence_upload_retry_policy.dart';
import 'package:ky_survey/logic/survey_evidence_upload_service.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceUploadQueueActionController', () {
    test('loads queue state with fresh insights', () async {
      final now = DateTime(2026, 9, 1, 8);
      final store = SurveyEvidenceUploadMemoryQueueStore(
        initialQueue: SurveyEvidenceUploadQueue(
          entries: [_queueEntry(id: 'due', createdAt: now)],
        ),
      );
      final controller = _controller(store: store, controllerClock: () => now);

      final state = await controller.loadState();

      expect(state.generatedAt, now);
      expect(state.queue.pendingCount, 1);
      expect(state.insights.health, SurveyEvidenceUploadQueueHealth.ready);
      expect(state.insights.dueCount, 1);
    });

    test('enqueues a plan and returns refreshed queue insights', () async {
      final now = DateTime(2026, 9, 2, 8);
      final store = SurveyEvidenceUploadMemoryQueueStore();
      final controller = _controller(
        store: store,
        coordinatorClock: () => now,
        controllerClock: () => now.add(const Duration(minutes: 1)),
      );

      final result = await controller.enqueuePlan(
        SurveyEvidenceUploadPlan(tasks: [_uploadTask(id: 'ready')]),
      );

      expect(result.action, SurveyEvidenceUploadQueueAction.enqueuePlan);
      expect(result.changed, isTrue);
      expect(result.enqueueResult?.enqueuedCount, 1);
      expect(result.message, '1 queued');
      expect(result.insights.dueCount, 1);
      expect(store.queue.pendingCount, 1);
    });

    test('can be created from a store, uploader, and retry policy', () async {
      final now = DateTime(2026, 9, 2, 10);
      final store = SurveyEvidenceUploadMemoryQueueStore();
      final task = _uploadTask(id: 'factory');
      final controller = SurveyEvidenceUploadQueueActionController.fromStore(
        store: store,
        uploader: _FakeUploader((request) async {
          return const SurveyEvidenceUploadResult.failed(message: 'offline');
        }),
        clock: _clock([
          now,
          now.add(const Duration(seconds: 1)),
          now.add(const Duration(seconds: 2)),
          now.add(const Duration(seconds: 3)),
          now.add(const Duration(seconds: 4)),
          now.add(const Duration(seconds: 5)),
        ]),
        queueRetryPolicy: SurveyEvidenceUploadRetryPolicy.fixed(
          maxAttempts: 2,
          delay: const Duration(minutes: 10),
        ),
      );

      final result = await controller.syncPlan(
        SurveyEvidenceUploadPlan(tasks: [task]),
      );

      final entry = store.queue.entryById('response-1:factory')!;
      expect(result.action, SurveyEvidenceUploadQueueAction.syncPlan);
      expect(result.syncResult?.enqueuedCount, 1);
      expect(result.syncResult?.retryScheduledCount, 1);
      expect(result.message, '1 queued, 1 retry scheduled');
      expect(result.generatedAt, now.add(const Duration(seconds: 5)));
      expect(entry.status, SurveyEvidenceUploadQueueStatus.pending);
      expect(entry.attemptCount, 1);
      expect(
        entry.nextAttemptAt,
        now.add(const Duration(seconds: 4, minutes: 10)),
      );
    });

    test('maintains stale uploads and reports ready follow-up work', () async {
      final now = DateTime(2026, 9, 3, 8);
      final staleUploading =
          _queueEntry(
            id: 'stale',
            createdAt: now.subtract(const Duration(hours: 1)),
          ).copyWith(
            status: SurveyEvidenceUploadQueueStatus.uploading,
            updatedAt: now.subtract(const Duration(minutes: 45)),
          );
      final store = SurveyEvidenceUploadMemoryQueueStore(
        initialQueue: SurveyEvidenceUploadQueue(entries: [staleUploading]),
      );
      final controller = _controller(
        store: store,
        coordinatorClock: () => now,
        controllerClock: () => now,
      );

      final result = await controller.maintainQueue();

      expect(result.action, SurveyEvidenceUploadQueueAction.maintainQueue);
      expect(result.changed, isTrue);
      expect(result.maintenanceResult?.recoveredCount, 1);
      expect(result.message, '1 recovered');
      expect(result.insights.dueCount, 1);
      expect(
        store.queue.entryById('response-1:stale')?.status,
        SurveyEvidenceUploadQueueStatus.pending,
      );
    });

    test('requeues failed uploads for dashboard retry actions', () async {
      final now = DateTime(2026, 9, 4, 8);
      final failed =
          _queueEntry(
            id: 'failed',
            createdAt: now.subtract(const Duration(hours: 2)),
          ).copyWith(
            status: SurveyEvidenceUploadQueueStatus.failed,
            attemptCount: 3,
            updatedAt: now.subtract(const Duration(hours: 1)),
            lastError: 'timeout',
            clearNextAttemptAt: true,
          );
      final store = SurveyEvidenceUploadMemoryQueueStore(
        initialQueue: SurveyEvidenceUploadQueue(entries: [failed]),
      );
      final controller = _controller(
        store: store,
        coordinatorClock: () => now,
        controllerClock: () => now,
      );

      final result = await controller.requeueFailedUploads(
        resetAttemptCount: true,
      );

      final entry = store.queue.entryById('response-1:failed')!;
      expect(
        result.action,
        SurveyEvidenceUploadQueueAction.requeueFailedUploads,
      );
      expect(result.maintenanceResult?.requeuedCount, 1);
      expect(result.changed, isTrue);
      expect(result.message, '1 requeued');
      expect(result.insights.health, SurveyEvidenceUploadQueueHealth.ready);
      expect(entry.status, SurveyEvidenceUploadQueueStatus.pending);
      expect(entry.attemptCount, 0);
    });

    test('runs due uploads and returns post-upload queue insights', () async {
      final now = DateTime(2026, 9, 5, 8);
      final task = _uploadTask(id: 'photo');
      final store = SurveyEvidenceUploadMemoryQueueStore(
        initialQueue: SurveyEvidenceUploadQueue(
          entries: [
            SurveyEvidenceUploadQueueEntry.fromTask(task, queuedAt: now),
          ],
        ),
      );
      final attemptedIds = <String>[];
      final controller = _controller(
        store: store,
        uploader: _FakeUploader((request) async {
          attemptedIds.add('${request.task.evidenceId}:${request.attempt}');
          return const SurveyEvidenceUploadResult.uploaded(
            remoteUrl: 'https://cdn.example/photo.jpg',
          );
        }),
        serviceClock: _clock([
          DateTime(2026, 9, 5, 8, 0, 1),
          DateTime(2026, 9, 5, 8, 0, 2),
          DateTime(2026, 9, 5, 8, 0, 3),
        ]),
        coordinatorClock: () => now,
        controllerClock: () => now.add(const Duration(minutes: 1)),
      );

      final result = await controller.runDueUploads(
        SurveyEvidenceUploadPlan(tasks: [task]),
      );

      expect(attemptedIds, ['photo:1']);
      expect(result.action, SurveyEvidenceUploadQueueAction.runDueUploads);
      expect(result.processResult?.uploadedCount, 1);
      expect(result.message, '1 uploaded');
      expect(result.insights.health, SurveyEvidenceUploadQueueHealth.complete);
      expect(
        result.queue.entryById('response-1:photo')?.remoteUrl,
        'https://cdn.example/photo.jpg',
      );
    });

    test('syncs a plan through enqueue and process checkpoints', () async {
      final now = DateTime(2026, 9, 6, 8);
      final store = SurveyEvidenceUploadMemoryQueueStore();
      final controller = _controller(
        store: store,
        uploader: _FakeUploader((request) async {
          return SurveyEvidenceUploadResult.uploaded(
            remoteUrl: 'https://cdn.example/${request.task.evidenceId}.jpg',
          );
        }),
        serviceClock: _clock([
          DateTime(2026, 9, 6, 8, 0, 1),
          DateTime(2026, 9, 6, 8, 0, 2),
          DateTime(2026, 9, 6, 8, 0, 3),
        ]),
        coordinatorClock: _clock([now, now.add(const Duration(seconds: 1))]),
        controllerClock: () => now.add(const Duration(minutes: 1)),
      );

      final result = await controller.syncPlan(
        SurveyEvidenceUploadPlan(tasks: [_uploadTask(id: 'synced')]),
      );

      expect(result.action, SurveyEvidenceUploadQueueAction.syncPlan);
      expect(result.syncResult?.enqueuedCount, 1);
      expect(result.syncResult?.uploadedCount, 1);
      expect(result.changed, isTrue);
      expect(result.insights.health, SurveyEvidenceUploadQueueHealth.complete);
      expect(store.queue.uploadedCount, 1);
    });
  });
}

SurveyEvidenceUploadQueueActionController _controller({
  required SurveyEvidenceUploadMemoryQueueStore store,
  SurveyEvidenceUploader? uploader,
  SurveyEvidenceUploadClock? serviceClock,
  SurveyEvidenceUploadClock? coordinatorClock,
  SurveyEvidenceUploadClock? controllerClock,
}) {
  DateTime fallbackClock() => DateTime(2026, 9);
  final service = SurveyEvidenceUploadService(
    uploader:
        uploader ??
        _FakeUploader((request) async {
          fail('Uploader should not be called by this action.');
        }),
    clock: serviceClock ?? fallbackClock,
  );
  final coordinator = SurveyEvidenceUploadQueueCoordinator(
    store: store,
    service: service,
    clock: coordinatorClock ?? fallbackClock,
  );

  return SurveyEvidenceUploadQueueActionController(
    coordinator: coordinator,
    clock: controllerClock ?? fallbackClock,
  );
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
    queuedAt: createdAt ?? DateTime(2026, 9),
    nextAttemptAt: nextAttemptAt ?? createdAt ?? DateTime(2026, 9),
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
    title: 'Queue Actions',
    description: 'Queue actions test',
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

SurveyEvidenceUploadClock _clock(List<DateTime> timestamps) {
  final queue = [...timestamps];
  return () {
    if (queue.isEmpty) {
      return timestamps.last;
    }

    return queue.removeAt(0);
  };
}

class _FakeUploader implements SurveyEvidenceUploader {
  final Future<SurveyEvidenceUploadResult> Function(
    SurveyEvidenceUploadRequest request,
  )
  uploadHandler;

  const _FakeUploader(this.uploadHandler);

  @override
  Future<SurveyEvidenceUploadResult> upload(
    SurveyEvidenceUploadRequest request,
  ) {
    return uploadHandler(request);
  }
}

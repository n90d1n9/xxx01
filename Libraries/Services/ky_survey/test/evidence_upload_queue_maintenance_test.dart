import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_coordinator.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_maintenance.dart';
import 'package:ky_survey/logic/survey_evidence_upload_service.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceUploadQueueMaintenance', () {
    test('recovers stale uploading entries for another attempt', () {
      final now = DateTime(2026, 7, 1, 8);
      final stale =
          _queueEntry(
            id: 'stale',
            createdAt: now.subtract(const Duration(hours: 1)),
          ).copyWith(
            status: SurveyEvidenceUploadQueueStatus.uploading,
            attemptCount: 2,
            updatedAt: now.subtract(const Duration(minutes: 31)),
          );
      final active =
          _queueEntry(
            id: 'active',
            createdAt: now.subtract(const Duration(minutes: 5)),
          ).copyWith(
            status: SurveyEvidenceUploadQueueStatus.uploading,
            updatedAt: now.subtract(const Duration(minutes: 5)),
          );

      final result = SurveyEvidenceUploadQueueMaintenance(
        queue: SurveyEvidenceUploadQueue(entries: [stale, active]),
        now: now,
      ).recoverStaleUploads(reason: 'Recovered after app restart');

      final recovered = result.queue.entryById('response-1:stale')!;
      final stillActive = result.queue.entryById('response-1:active')!;
      expect(result.recoveredCount, 1);
      expect(result.changed, isTrue);
      expect(result.summaryLabel, '1 recovered');
      expect(recovered.status, SurveyEvidenceUploadQueueStatus.pending);
      expect(recovered.attemptCount, 2);
      expect(recovered.nextAttemptAt, now);
      expect(recovered.updatedAt, now);
      expect(recovered.lastError, 'Recovered after app restart');
      expect(stillActive.status, SurveyEvidenceUploadQueueStatus.uploading);
    });

    test('prunes old uploaded and skipped entries while keeping failures', () {
      final now = DateTime(2026, 7, 2, 8);
      final oldUploaded = _queueEntry(id: 'old-uploaded').markUploaded(
        remoteUrl: 'https://cdn.example/old.jpg',
        uploadedAt: now.subtract(const Duration(days: 8)),
      );
      final oldSkipped = _queueEntry(id: 'old-skipped').markSkipped(
        reason: 'Requirement removed',
        skippedAt: now.subtract(const Duration(days: 9)),
      );
      final oldFailed = _queueEntry(id: 'old-failed').copyWith(
        status: SurveyEvidenceUploadQueueStatus.failed,
        updatedAt: now.subtract(const Duration(days: 10)),
        lastError: 'Still needs review',
        clearNextAttemptAt: true,
      );
      final recentUploaded = _queueEntry(id: 'recent-uploaded').markUploaded(
        remoteUrl: 'https://cdn.example/recent.jpg',
        uploadedAt: now.subtract(const Duration(days: 2)),
      );
      final pending = _queueEntry(
        id: 'pending',
        createdAt: now.subtract(const Duration(days: 30)),
      );

      final result = SurveyEvidenceUploadQueueMaintenance(
        queue: SurveyEvidenceUploadQueue(
          entries: [
            oldUploaded,
            oldSkipped,
            oldFailed,
            recentUploaded,
            pending,
          ],
        ),
        now: now,
      ).pruneTerminalEntries(olderThan: const Duration(days: 7));

      expect(result.prunedEntries.map((entry) => entry.evidenceId), [
        'old-uploaded',
        'old-skipped',
      ]);
      expect(result.prunedCount, 2);
      expect(result.summaryLabel, '2 pruned');
      expect(result.queue.entryById('response-1:old-failed'), isNotNull);
      expect(result.queue.entryById('response-1:recent-uploaded'), isNotNull);
      expect(result.queue.entryById('response-1:pending'), isNotNull);
    });

    test('runs recovery before terminal pruning', () {
      final now = DateTime(2026, 7, 3, 8);
      final stale =
          _queueEntry(
            id: 'stale',
            createdAt: now.subtract(const Duration(hours: 2)),
          ).copyWith(
            status: SurveyEvidenceUploadQueueStatus.uploading,
            updatedAt: now.subtract(const Duration(hours: 1)),
          );
      final oldUploaded = _queueEntry(id: 'old-uploaded').markUploaded(
        remoteUrl: 'https://cdn.example/old.jpg',
        uploadedAt: now.subtract(const Duration(days: 14)),
      );

      final result = SurveyEvidenceUploadQueueMaintenance(
        queue: SurveyEvidenceUploadQueue(entries: [stale, oldUploaded]),
        now: now,
      ).run(terminalRetention: const Duration(days: 7));

      expect(result.recoveredCount, 1);
      expect(result.prunedCount, 1);
      expect(result.summaryLabel, '1 recovered, 1 pruned');
      expect(
        result.queue.entryById('response-1:stale')?.status,
        SurveyEvidenceUploadQueueStatus.pending,
      );
      expect(result.queue.entryById('response-1:old-uploaded'), isNull);
    });

    test('requeues selected failed entries for manual retry', () {
      final now = DateTime(2026, 7, 4, 8);
      final failedOne = _failedEntry(
        id: 'failed-one',
        attemptCount: 3,
        updatedAt: now.subtract(const Duration(hours: 2)),
      );
      final failedTwo = _failedEntry(
        id: 'failed-two',
        attemptCount: 2,
        updatedAt: now.subtract(const Duration(hours: 1)),
      );
      final pending = _queueEntry(id: 'pending');

      final result =
          SurveyEvidenceUploadQueueMaintenance(
            queue: SurveyEvidenceUploadQueue(
              entries: [failedOne, failedTwo, pending],
            ),
            now: now,
          ).requeueFailedEntries(
            queueIds: const {'response-1:failed-two'},
            reason: 'Admin retry requested',
          );

      final unchanged = result.queue.entryById('response-1:failed-one')!;
      final requeued = result.queue.entryById('response-1:failed-two')!;
      expect(result.requeuedCount, 1);
      expect(result.summaryLabel, '1 requeued');
      expect(unchanged.status, SurveyEvidenceUploadQueueStatus.failed);
      expect(requeued.status, SurveyEvidenceUploadQueueStatus.pending);
      expect(requeued.action, SurveyEvidenceUploadAction.retryUpload);
      expect(requeued.priority, 1);
      expect(requeued.attemptCount, 2);
      expect(requeued.nextAttemptAt, now);
      expect(requeued.lastError, 'Admin retry requested');
      expect(
        result.queue.entryById('response-1:pending')?.status,
        SurveyEvidenceUploadQueueStatus.pending,
      );
    });

    test('can reset attempt counts when failed uploads are requeued', () {
      final now = DateTime(2026, 7, 5, 8);
      final failed = _failedEntry(
        id: 'failed-reset',
        attemptCount: 4,
        updatedAt: now.subtract(const Duration(hours: 1)),
      );

      final result = SurveyEvidenceUploadQueueMaintenance(
        queue: SurveyEvidenceUploadQueue(entries: [failed]),
        now: now,
      ).requeueFailedEntries(resetAttemptCount: true, limit: 1);

      final requeued = result.queue.entryById('response-1:failed-reset')!;
      expect(result.requeuedCount, 1);
      expect(requeued.status, SurveyEvidenceUploadQueueStatus.pending);
      expect(requeued.attemptCount, 0);
      expect(requeued.nextAttemptAt, now);
    });

    test(
      'coordinator saves maintenance changes through the queue store',
      () async {
        final now = DateTime(2026, 7, 4, 8);
        final store = _RecordingQueueStore(
          initialQueue: SurveyEvidenceUploadQueue(
            entries: [
              _queueEntry(
                id: 'stale',
                createdAt: now.subtract(const Duration(hours: 1)),
              ).copyWith(
                status: SurveyEvidenceUploadQueueStatus.uploading,
                updatedAt: now.subtract(const Duration(minutes: 45)),
              ),
            ],
          ),
        );
        final coordinator = SurveyEvidenceUploadQueueCoordinator(
          store: store,
          service: SurveyEvidenceUploadService(
            uploader: _FakeUploader((request) async {
              fail('maintainQueue should not call the uploader.');
            }),
          ),
          clock: () => now,
        );

        final result = await coordinator.maintainQueue();

        expect(result.recoveredCount, 1);
        expect(store.saves, hasLength(1));
        expect(
          store.queue.entryById('response-1:stale')?.status,
          SurveyEvidenceUploadQueueStatus.pending,
        );
      },
    );

    test('coordinator saves failed requeues without running uploads', () async {
      final now = DateTime(2026, 7, 6, 8);
      final store = _RecordingQueueStore(
        initialQueue: SurveyEvidenceUploadQueue(
          entries: [
            _failedEntry(
              id: 'failed',
              attemptCount: 2,
              updatedAt: now.subtract(const Duration(hours: 1)),
            ),
          ],
        ),
      );
      final coordinator = SurveyEvidenceUploadQueueCoordinator(
        store: store,
        service: SurveyEvidenceUploadService(
          uploader: _FakeUploader((request) async {
            fail('requeueFailedUploads should not call the uploader.');
          }),
        ),
        clock: () => now,
      );

      final result = await coordinator.requeueFailedUploads(
        resetAttemptCount: true,
      );

      final requeued = store.queue.entryById('response-1:failed')!;
      expect(result.requeuedCount, 1);
      expect(store.saves, hasLength(1));
      expect(requeued.status, SurveyEvidenceUploadQueueStatus.pending);
      expect(requeued.attemptCount, 0);
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
    queuedAt: createdAt ?? DateTime(2026, 7),
    nextAttemptAt: nextAttemptAt ?? createdAt ?? DateTime(2026, 7),
  );
}

SurveyEvidenceUploadQueueEntry _failedEntry({
  required String id,
  required int attemptCount,
  required DateTime updatedAt,
}) {
  return _queueEntry(id: id, createdAt: updatedAt).copyWith(
    status: SurveyEvidenceUploadQueueStatus.failed,
    attemptCount: attemptCount,
    updatedAt: updatedAt,
    lastError: 'Upload failed',
    clearNextAttemptAt: true,
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
    title: 'Queue Maintenance',
    description: 'Queue maintenance test',
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

class _RecordingQueueStore implements SurveyEvidenceUploadQueueStore {
  SurveyEvidenceUploadQueue _queue;
  final List<SurveyEvidenceUploadQueue> saves = [];

  _RecordingQueueStore({
    SurveyEvidenceUploadQueue initialQueue = const SurveyEvidenceUploadQueue(),
  }) : _queue = initialQueue;

  SurveyEvidenceUploadQueue get queue => _queue;

  @override
  Future<SurveyEvidenceUploadQueue> load() async => _queue;

  @override
  Future<void> save(SurveyEvidenceUploadQueue queue) async {
    _queue = queue;
    saves.add(queue);
  }
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

import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue.dart';
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
  group('SurveyEvidenceUploadQueueCoordinator', () {
    test('enqueues uploadable plan tasks without running uploads', () async {
      final store = _RecordingQueueStore();
      final coordinator = SurveyEvidenceUploadQueueCoordinator(
        store: store,
        service: SurveyEvidenceUploadService(
          uploader: _FakeUploader((request) async {
            fail('enqueuePlan should not call the uploader.');
          }),
        ),
        clock: _clock([DateTime(2026, 5, 1, 8)]),
      );
      final plan = SurveyEvidenceUploadPlan(
        tasks: [
          _uploadTask(id: 'ready'),
          _uploadTask(
            id: 'blocked',
            action: SurveyEvidenceUploadAction.fixEvidence,
          ),
        ],
      );

      final result = await coordinator.enqueuePlan(
        plan,
        metadata: const {'source': 'background-sync'},
      );

      expect(result.enqueuedCount, 1);
      expect(result.summaryLabel, '1 queued');
      expect(store.saves, hasLength(1));
      expect(store.queue.pendingCount, 1);
      expect(
        store.queue.entryById('response-1:ready')?.metadata['source'],
        'background-sync',
      );
      expect(store.queue.entryById('response-1:blocked'), isNull);
    });

    test('syncs a plan by enqueueing tasks, processing due work, and saving '
        'checkpoints', () async {
      final store = _RecordingQueueStore();
      final attemptedIds = <String>[];
      final coordinator = SurveyEvidenceUploadQueueCoordinator(
        store: store,
        service: SurveyEvidenceUploadService(
          uploader: _FakeUploader((request) async {
            attemptedIds.add('${request.task.evidenceId}:${request.attempt}');
            if (request.task.evidenceId == 'fail') {
              return const SurveyEvidenceUploadResult.failed(
                message: 'network unavailable',
              );
            }

            return const SurveyEvidenceUploadResult.uploaded(
              remoteUrl: 'https://cdn.example/ok.jpg',
            );
          }),
          clock: _clock([
            DateTime(2026, 5, 2, 8, 0, 2),
            DateTime(2026, 5, 2, 8, 0, 3),
            DateTime(2026, 5, 2, 8, 0, 4),
            DateTime(2026, 5, 2, 8, 0, 5),
            DateTime(2026, 5, 2, 8, 0, 6),
            DateTime(2026, 5, 2, 8, 0, 7),
          ]),
        ),
        queueRetryPolicy: SurveyEvidenceUploadRetryPolicy.fixed(
          maxAttempts: 2,
          delay: const Duration(minutes: 15),
        ),
        clock: _clock([DateTime(2026, 5, 2, 8), DateTime(2026, 5, 2, 8, 0, 1)]),
      );
      final plan = SurveyEvidenceUploadPlan(
        tasks: [
          _uploadTask(id: 'ok'),
          _uploadTask(id: 'fail'),
        ],
      );

      final result = await coordinator.syncPlan(plan);

      final uploaded = result.finalQueue.entryById('response-1:ok')!;
      final retry = result.finalQueue.entryById('response-1:fail')!;
      expect(attemptedIds, ['ok:1', 'fail:1']);
      expect(store.saves, hasLength(2));
      expect(store.saves.first.pendingCount, 2);
      expect(uploaded.status, SurveyEvidenceUploadQueueStatus.uploaded);
      expect(uploaded.remoteUrl, 'https://cdn.example/ok.jpg');
      expect(retry.status, SurveyEvidenceUploadQueueStatus.pending);
      expect(retry.nextAttemptAt, DateTime(2026, 5, 2, 8, 15, 7));
      expect(result.enqueuedCount, 2);
      expect(result.uploadedCount, 1);
      expect(result.retryScheduledCount, 1);
      expect(result.summaryLabel, '2 queued, 1 uploaded, 1 retry scheduled');
    });

    test('processes a persisted due retry without re-enqueueing it', () async {
      final now = DateTime(2026, 5, 3, 8);
      final task = _uploadTask(id: 'retry');
      final entry = SurveyEvidenceUploadQueueEntry.fromTask(
        task,
        queuedAt: now.subtract(const Duration(hours: 1)),
        nextAttemptAt: now,
      ).copyWith(attemptCount: 1);
      final store = _RecordingQueueStore(
        initialQueue: SurveyEvidenceUploadQueue(entries: [entry]),
      );
      final attempts = <int>[];
      final coordinator = SurveyEvidenceUploadQueueCoordinator(
        store: store,
        service: SurveyEvidenceUploadService(
          uploader: _FakeUploader((request) async {
            attempts.add(request.attempt);
            return const SurveyEvidenceUploadResult.uploaded(
              remoteUrl: 'https://cdn.example/retry.jpg',
            );
          }),
          clock: _clock([
            DateTime(2026, 5, 3, 8, 0, 1),
            DateTime(2026, 5, 3, 8, 0, 2),
            DateTime(2026, 5, 3, 8, 0, 3),
          ]),
        ),
        clock: _clock([now]),
      );

      final result = await coordinator.processDue(
        SurveyEvidenceUploadPlan(tasks: [task]),
      );

      expect(attempts, [2]);
      expect(store.saves, hasLength(1));
      expect(result.uploadedCount, 1);
      expect(
        store.queue.entryById('response-1:retry')?.status,
        SurveyEvidenceUploadQueueStatus.uploaded,
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

SurveyEvidenceSyncItem _syncItem({required String id}) {
  final survey = Survey(
    id: 'survey-1',
    title: 'Queue Coordinator',
    description: 'Queue coordinator test',
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

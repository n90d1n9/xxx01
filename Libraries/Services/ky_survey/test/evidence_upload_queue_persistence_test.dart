import 'dart:convert';

import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_coordinator.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_persistence.dart';
import 'package:ky_survey/logic/survey_evidence_upload_service.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceUploadQueueSnapshot', () {
    test('serializes versioned queue snapshots with metadata', () {
      final queue = SurveyEvidenceUploadQueue(
        entries: [_queueEntry(id: 'persisted')],
      );
      final snapshot = SurveyEvidenceUploadQueueSnapshot(
        queue: queue,
        savedAt: DateTime(2026, 8, 1, 8),
        metadata: const {'tenant': 'north'},
      );

      final restored = SurveyEvidenceUploadQueueSnapshot.fromJson(
        snapshot.toJson(),
      );

      expect(snapshot.toJson()['schemaVersion'], 1);
      expect(restored.isCurrentSchema, isTrue);
      expect(restored.savedAt, DateTime(2026, 8, 1, 8));
      expect(restored.metadata['tenant'], 'north');
      expect(restored.queue.entries.single.id, 'response-1:persisted');
    });

    test('decodes legacy raw queue JSON payloads', () {
      final queue = SurveyEvidenceUploadQueue(
        entries: [_queueEntry(id: 'legacy')],
      );

      final snapshot = SurveyEvidenceUploadQueueSnapshot.fromJson(
        queue.toJson(),
      );

      expect(snapshot.schemaVersion, 0);
      expect(snapshot.isCurrentSchema, isFalse);
      expect(snapshot.queue.entries.single.evidenceId, 'legacy');
    });

    test('codec round-trips snapshots as JSON strings', () {
      const codec = SurveyEvidenceUploadQueueSnapshotCodec();
      final snapshot = SurveyEvidenceUploadQueueSnapshot(
        queue: SurveyEvidenceUploadQueue(
          entries: [_queueEntry(id: 'stringified')],
        ),
        savedAt: DateTime(2026, 8, 2, 9),
      );

      final encoded = codec.encodeString(snapshot);
      final decoded = codec.decodeString(encoded);

      expect(jsonDecode(encoded), isA<Map>());
      expect(decoded.savedAt, DateTime(2026, 8, 2, 9));
      expect(decoded.queue.entries.single.evidenceId, 'stringified');
    });
  });

  group('SurveyEvidenceUploadJsonQueueStore', () {
    test('loads fallback queue when no snapshot exists', () async {
      final fallback = SurveyEvidenceUploadQueue(
        entries: [_queueEntry(id: 'fallback')],
      );
      final storage = SurveyEvidenceUploadMemoryJsonStorage();
      final store = SurveyEvidenceUploadJsonQueueStore(
        readJson: storage.read,
        writeJson: storage.write,
        fallbackQueue: fallback,
      );

      final queue = await store.load();

      expect(queue.entries.single.evidenceId, 'fallback');
    });

    test(
      'saves versioned snapshots and reloads them through storage',
      () async {
        final storage = SurveyEvidenceUploadMemoryJsonStorage();
        final store = SurveyEvidenceUploadJsonQueueStore(
          readJson: storage.read,
          writeJson: storage.write,
          clock: () => DateTime(2026, 8, 3, 10),
          metadata: const {'source': 'coordinator'},
        );
        final queue = SurveyEvidenceUploadQueue(
          entries: [_queueEntry(id: 'saved')],
        );

        await store.save(queue);
        final restored = await store.load();
        final snapshotJson = jsonDecode(storage.json!) as Map<String, dynamic>;

        expect(snapshotJson['schemaVersion'], 1);
        expect(snapshotJson['savedAt'], '2026-08-03T10:00:00.000');
        expect(snapshotJson['metadata']['source'], 'coordinator');
        expect(restored.entries.single.evidenceId, 'saved');
      },
    );

    test('can reset to fallback on decode errors', () async {
      final errors = <Object>[];
      final storage = SurveyEvidenceUploadMemoryJsonStorage(
        initialJson: '{broken',
      );
      final store = SurveyEvidenceUploadJsonQueueStore(
        readJson: storage.read,
        writeJson: storage.write,
        fallbackQueue: SurveyEvidenceUploadQueue(
          entries: [_queueEntry(id: 'safe')],
        ),
        resetOnDecodeError: true,
        onDecodeError: (error, stackTrace) => errors.add(error),
      );

      final queue = await store.load();

      expect(queue.entries.single.evidenceId, 'safe');
      expect(errors, hasLength(1));
    });

    test('persists coordinator queue checkpoints as snapshots', () async {
      final storage = SurveyEvidenceUploadMemoryJsonStorage();
      final store = SurveyEvidenceUploadJsonQueueStore(
        readJson: storage.read,
        writeJson: storage.write,
        clock: () => DateTime(2026, 8, 4, 11),
      );
      final coordinator = SurveyEvidenceUploadQueueCoordinator(
        store: store,
        service: SurveyEvidenceUploadService(
          uploader: _FakeUploader((request) async {
            fail('enqueuePlan should not upload evidence.');
          }),
        ),
        clock: () => DateTime(2026, 8, 4, 8),
      );

      await coordinator.enqueuePlan(
        SurveyEvidenceUploadPlan(tasks: [_uploadTask(id: 'queued')]),
      );

      final snapshot = const SurveyEvidenceUploadQueueSnapshotCodec()
          .decodeString(storage.json!);
      expect(snapshot.savedAt, DateTime(2026, 8, 4, 11));
      expect(snapshot.queue.pendingCount, 1);
      expect(snapshot.queue.entries.single.evidenceId, 'queued');
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
    queuedAt: createdAt ?? DateTime(2026, 8),
    nextAttemptAt: nextAttemptAt ?? createdAt ?? DateTime(2026, 8),
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
    title: 'Queue Persistence',
    description: 'Queue persistence test',
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

import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_retry_policy.dart';
import 'package:ky_survey/logic/survey_evidence_upload_service.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceUploadService', () {
    test(
      'uploads a task and emits queue, uploading, and uploaded events',
      () async {
        final task = _uploadTask(id: 'photo');
        final events = <String>[];
        final uploader = _FakeUploader((request) async {
          expect(request.task, task);
          expect(request.attempt, 2);
          expect(request.metadata['source'], 'dashboard');
          expect(request.survey.id, 'survey-1');
          expect(request.response.id, 'response-1');
          expect(request.evidence.id, 'photo');
          expect(request.attachment.localPath, '/local/photo.dat');
          expect(request.requirement?.id, 'upload-required');

          return const SurveyEvidenceUploadResult.uploaded(
            remoteUrl: 'https://cdn.example/photo.dat',
            metadata: {'storage': 'mock'},
          );
        });
        final service = SurveyEvidenceUploadService(
          uploader: uploader,
          clock: _clock([
            DateTime(2026, 1, 1, 10),
            DateTime(2026, 1, 1, 10, 0, 1),
            DateTime(2026, 1, 1, 10, 0, 2),
          ]),
        );

        final execution = await service.uploadTask(
          task,
          attempt: 2,
          metadata: const {'source': 'dashboard'},
          observer: SurveyEvidenceUploadCallbacks(
            queued: (task, at) => events.add('queued:${task.evidenceId}:$at'),
            uploading: (task, at) =>
                events.add('uploading:${task.evidenceId}:$at'),
            uploaded: (task, result, at) => events.add(
              'uploaded:${task.evidenceId}:${result.remoteUrl}:$at',
            ),
          ),
        );

        expect(execution.status, SurveyEvidenceUploadExecutionStatus.uploaded);
        expect(execution.didUpload, isTrue);
        expect(execution.remoteUrl, 'https://cdn.example/photo.dat');
        expect(execution.metadata['storage'], 'mock');
        expect(events, [
          'queued:photo:2026-01-01 10:00:00.000',
          'uploading:photo:2026-01-01 10:00:01.000',
          'uploaded:photo:https://cdn.example/photo.dat:2026-01-01 10:00:02.000',
        ]);
        expect(uploader.callCount, 1);
      },
    );

    test('skips tasks that cannot start upload', () async {
      final task = _uploadTask(
        id: 'blocked',
        action: SurveyEvidenceUploadAction.fixEvidence,
      );
      final events = <String>[];
      final service = SurveyEvidenceUploadService(
        uploader: _FakeUploader((request) async {
          fail('Uploader should not be called for non-uploadable tasks.');
        }),
        clock: _clock([DateTime(2026, 1, 2)]),
      );

      final execution = await service.uploadTask(
        task,
        observer: SurveyEvidenceUploadCallbacks(
          skipped: (task, reason, at) =>
              events.add('${task.evidenceId}:$reason:$at'),
        ),
      );

      expect(execution.status, SurveyEvidenceUploadExecutionStatus.skipped);
      expect(execution.message, contains('cannot start upload'));
      expect(events.single, contains('blocked:Task action Fix evidence'));
    });

    test('returns noTask when a plan has no uploadable work', () async {
      final service = SurveyEvidenceUploadService(
        uploader: _FakeUploader((request) async {
          fail('Uploader should not be called for an empty plan.');
        }),
        clock: _clock([DateTime(2026, 1, 3)]),
      );

      final execution = await service.uploadNext(
        const SurveyEvidenceUploadPlan(tasks: []),
      );

      expect(execution.status, SurveyEvidenceUploadExecutionStatus.noTask);
      expect(execution.task, isNull);
      expect(execution.completedAt, DateTime(2026, 1, 3));
    });

    test('uploads uploadable plan tasks and summarizes the batch', () async {
      final uploadedIds = <String>[];
      final service = SurveyEvidenceUploadService(
        uploader: _FakeUploader((request) async {
          uploadedIds.add(request.task.evidenceId);
          return SurveyEvidenceUploadResult.uploaded(
            remoteUrl: 'https://cdn.example/${request.task.evidenceId}.dat',
          );
        }),
        clock: _clock([
          DateTime(2026, 1, 6, 8),
          DateTime(2026, 1, 6, 8, 0, 1),
          DateTime(2026, 1, 6, 8, 0, 2),
          DateTime(2026, 1, 6, 8, 0, 3),
          DateTime(2026, 1, 6, 8, 0, 4),
          DateTime(2026, 1, 6, 8, 0, 5),
          DateTime(2026, 1, 6, 8, 0, 6),
          DateTime(2026, 1, 6, 8, 0, 7),
        ]),
      );
      final plan = SurveyEvidenceUploadPlan(
        tasks: [
          _uploadTask(id: 'first'),
          _uploadTask(
            id: 'blocked',
            action: SurveyEvidenceUploadAction.fixEvidence,
          ),
          _uploadTask(id: 'second'),
        ],
      );

      final batch = await service.uploadPlan(plan);

      expect(uploadedIds, ['first', 'second']);
      expect(batch.requestedTaskCount, 2);
      expect(batch.attemptedCount, 2);
      expect(batch.uploadedCount, 2);
      expect(batch.failedCount, 0);
      expect(batch.summaryLabel, '2 uploaded');
      expect(batch.isComplete, isTrue);
    });

    test('can stop plan execution after the first failed upload', () async {
      final attemptedIds = <String>[];
      final service = SurveyEvidenceUploadService(
        uploader: _FakeUploader((request) async {
          attemptedIds.add(request.task.evidenceId);
          return const SurveyEvidenceUploadResult.failed(message: 'timeout');
        }),
        clock: _clock([
          DateTime(2026, 1, 7, 8),
          DateTime(2026, 1, 7, 8, 0, 1),
          DateTime(2026, 1, 7, 8, 0, 2),
          DateTime(2026, 1, 7, 8, 0, 3),
          DateTime(2026, 1, 7, 8, 0, 4),
        ]),
      );
      final plan = SurveyEvidenceUploadPlan(
        tasks: [
          _uploadTask(id: 'failed'),
          _uploadTask(id: 'not-started'),
        ],
      );

      final batch = await service.uploadPlan(plan, stopOnFailure: true);

      expect(attemptedIds, ['failed']);
      expect(batch.requestedTaskCount, 2);
      expect(batch.attemptedCount, 1);
      expect(batch.failedCount, 1);
      expect(batch.uploadedCount, 0);
      expect(batch.hasFailures, isTrue);
      expect(batch.isComplete, isFalse);
      expect(batch.summaryLabel, '0 uploaded, 1 failed');
    });

    test('converts uploader errors into failed executions', () async {
      final task = _uploadTask(id: 'audio');
      final events = <String>[];
      final service = SurveyEvidenceUploadService(
        uploader: _FakeUploader((request) async {
          throw StateError('network unavailable');
        }),
        clock: _clock([
          DateTime(2026, 1, 4, 9),
          DateTime(2026, 1, 4, 9, 0, 1),
          DateTime(2026, 1, 4, 9, 0, 2),
        ]),
      );

      final execution = await service.uploadNext(
        SurveyEvidenceUploadPlan(tasks: [task]),
        observer: SurveyEvidenceUploadCallbacks(
          failed: (task, result, at) =>
              events.add('${task.evidenceId}:${result.message}:$at'),
        ),
      );

      expect(execution.status, SurveyEvidenceUploadExecutionStatus.failed);
      expect(execution.failed, isTrue);
      expect(execution.message, contains('network unavailable'));
      expect(execution.metadata['errorType'], 'StateError');
      expect(events.single, contains('audio:Bad state: network unavailable'));
    });

    test('retries failed uploads before returning the final execution', () async {
      final task = _uploadTask(id: 'retry-photo');
      final attempts = <int>[];
      final waits = <Duration>[];
      final events = <String>[];
      final service = SurveyEvidenceUploadService(
        uploader: _FakeUploader((request) async {
          attempts.add(request.attempt);
          if (request.attempt == 1) {
            return const SurveyEvidenceUploadResult.failed(
              message: 'temporary outage',
            );
          }

          return const SurveyEvidenceUploadResult.uploaded(
            remoteUrl: 'https://cdn.example/retry-photo.dat',
          );
        }),
        retryPolicy: SurveyEvidenceUploadRetryPolicy.fixed(
          maxAttempts: 2,
          delay: const Duration(milliseconds: 25),
        ),
        retryWait: (delay) {
          waits.add(delay);
          return Future.value();
        },
        clock: _clock([
          DateTime(2026, 1, 8, 9),
          DateTime(2026, 1, 8, 9, 0, 1),
          DateTime(2026, 1, 8, 9, 0, 2),
          DateTime(2026, 1, 8, 9, 0, 3),
          DateTime(2026, 1, 8, 9, 0, 4),
          DateTime(2026, 1, 8, 9, 0, 5),
        ]),
      );

      final execution = await service.uploadTask(
        task,
        observer: SurveyEvidenceUploadCallbacks(
          retrying: (task, result, nextAttempt, retryDelay, retryingAt) {
            events.add(
              '${task.evidenceId}:${result.message}:$nextAttempt:$retryDelay:$retryingAt',
            );
          },
        ),
      );

      expect(execution.status, SurveyEvidenceUploadExecutionStatus.uploaded);
      expect(execution.remoteUrl, 'https://cdn.example/retry-photo.dat');
      expect(attempts, [1, 2]);
      expect(waits, [const Duration(milliseconds: 25)]);
      expect(events, [
        'retry-photo:temporary outage:2:0:00:00.025000:2026-01-08 09:00:02.000',
      ]);
    });

    test('treats uploaded results without a remote URL as failed', () async {
      final task = _uploadTask(id: 'missing-url');
      final events = <String>[];
      final service = SurveyEvidenceUploadService(
        uploader: _FakeUploader((request) async {
          return const SurveyEvidenceUploadResult.uploaded(remoteUrl: ' ');
        }),
        clock: _clock([
          DateTime(2026, 1, 5, 9),
          DateTime(2026, 1, 5, 9, 0, 1),
          DateTime(2026, 1, 5, 9, 0, 2),
        ]),
      );

      final execution = await service.uploadTask(
        task,
        observer: SurveyEvidenceUploadCallbacks(
          failed: (task, result, at) =>
              events.add('${task.evidenceId}:${result.message}:$at'),
        ),
      );

      expect(execution.status, SurveyEvidenceUploadExecutionStatus.failed);
      expect(execution.message, 'Upload completed without a remote URL.');
      expect(
        events.single,
        'missing-url:Upload completed without a remote URL.:2026-01-05 09:00:02.000',
      );
    });
  });
}

SurveyEvidenceUploadTask _uploadTask({
  required String id,
  SurveyEvidenceUploadAction action = SurveyEvidenceUploadAction.queueUpload,
}) {
  final survey = Survey(
    id: 'survey-1',
    title: 'Field Audit',
    description: 'Upload test',
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
    fileName: '$id.dat',
    capturedAt: DateTime(2026),
    localPath: '/local/$id.dat',
  );
  final evidence = SurveyEvidence.attachment(
    id: id,
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
  handler;
  int callCount = 0;

  _FakeUploader(this.handler);

  @override
  Future<SurveyEvidenceUploadResult> upload(
    SurveyEvidenceUploadRequest request,
  ) {
    callCount += 1;
    return handler(request);
  }
}

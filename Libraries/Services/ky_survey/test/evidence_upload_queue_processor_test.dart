import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue.dart';
import 'package:ky_survey/logic/survey_evidence_upload_queue_processor.dart';
import 'package:ky_survey/logic/survey_evidence_upload_retry_policy.dart';
import 'package:ky_survey/logic/survey_evidence_upload_service.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceUploadQueueProcessor', () {
    test(
      'processes due entries and schedules failed uploads for retry',
      () async {
        final now = DateTime(2026, 4, 1, 8);
        final plan = SurveyEvidenceUploadPlan(
          tasks: [
            _uploadTask(id: 'ok'),
            _uploadTask(id: 'fail'),
          ],
        );
        final queue = SurveyEvidenceUploadQueuePlanner(
          queue: const SurveyEvidenceUploadQueue(),
          plan: plan,
          queuedAt: now,
        ).enqueueUploadableTasks();
        final attemptedIds = <String>[];
        final processor = SurveyEvidenceUploadQueueProcessor(
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
              DateTime(2026, 4, 1, 8, 0, 1),
              DateTime(2026, 4, 1, 8, 0, 2),
              DateTime(2026, 4, 1, 8, 0, 3),
              DateTime(2026, 4, 1, 8, 0, 4),
              DateTime(2026, 4, 1, 8, 0, 5),
              DateTime(2026, 4, 1, 8, 0, 6),
            ]),
          ),
          queueRetryPolicy: SurveyEvidenceUploadRetryPolicy.fixed(
            maxAttempts: 2,
            delay: const Duration(minutes: 10),
          ),
        );

        final result = await processor.processDueEntries(
          queue: queue,
          plan: plan,
          now: now,
        );

        final uploaded = result.queue.entryById('response-1:ok')!;
        final retry = result.queue.entryById('response-1:fail')!;
        expect(attemptedIds, ['ok:1', 'fail:1']);
        expect(uploaded.status, SurveyEvidenceUploadQueueStatus.uploaded);
        expect(uploaded.remoteUrl, 'https://cdn.example/ok.jpg');
        expect(retry.status, SurveyEvidenceUploadQueueStatus.pending);
        expect(retry.attemptCount, 1);
        expect(retry.nextAttemptAt, DateTime(2026, 4, 1, 8, 10, 6));
        expect(retry.lastError, 'network unavailable');
        expect(result.uploadedCount, 1);
        expect(result.retryScheduledCount, 1);
        expect(result.summaryLabel, '1 uploaded, 1 retry scheduled');
      },
    );

    test('skips stale queue entries when no uploadable task remains', () async {
      final now = DateTime(2026, 4, 2, 8);
      final staleTask = _uploadTask(id: 'stale');
      final queue = SurveyEvidenceUploadQueue(
        entries: [
          SurveyEvidenceUploadQueueEntry.fromTask(staleTask, queuedAt: now),
        ],
      );
      final processor = SurveyEvidenceUploadQueueProcessor(
        service: SurveyEvidenceUploadService(
          uploader: _FakeUploader((request) async {
            fail('Uploader should not be called for stale queue entries.');
          }),
        ),
      );

      final result = await processor.processDueEntries(
        queue: queue,
        plan: const SurveyEvidenceUploadPlan(tasks: []),
        now: now,
      );

      final skipped = result.queue.entryById('response-1:stale')!;
      expect(skipped.status, SurveyEvidenceUploadQueueStatus.skipped);
      expect(skipped.lastError, 'Upload task is no longer available.');
      expect(result.skippedCount, 1);
      expect(result.summaryLabel, '1 skipped');
    });

    test(
      'continues persisted attempt counts when processing retries',
      () async {
        final now = DateTime(2026, 4, 3, 8);
        final task = _uploadTask(id: 'retry');
        final entry = SurveyEvidenceUploadQueueEntry.fromTask(
          task,
          queuedAt: now.subtract(const Duration(hours: 1)),
          nextAttemptAt: now,
        ).copyWith(attemptCount: 2);
        final attempts = <int>[];
        final processor = SurveyEvidenceUploadQueueProcessor(
          service: SurveyEvidenceUploadService(
            uploader: _FakeUploader((request) async {
              attempts.add(request.attempt);
              return const SurveyEvidenceUploadResult.uploaded(
                remoteUrl: 'https://cdn.example/retry.jpg',
              );
            }),
            clock: _clock([
              DateTime(2026, 4, 3, 8, 0, 1),
              DateTime(2026, 4, 3, 8, 0, 2),
              DateTime(2026, 4, 3, 8, 0, 3),
            ]),
          ),
        );

        final result = await processor.processDueEntries(
          queue: SurveyEvidenceUploadQueue(entries: [entry]),
          plan: SurveyEvidenceUploadPlan(tasks: [task]),
          now: now,
        );

        expect(attempts, [3]);
        expect(
          result.queue.entryById('response-1:retry')?.status,
          SurveyEvidenceUploadQueueStatus.uploaded,
        );
      },
    );
  });
}

SurveyEvidenceUploadTask _uploadTask({required String id}) {
  final item = _syncItem(id: id);
  return SurveyEvidenceUploadTask(
    item: item,
    action: SurveyEvidenceUploadAction.queueUpload,
  );
}

SurveyEvidenceSyncItem _syncItem({required String id}) {
  final survey = Survey(
    id: 'survey-1',
    title: 'Queue Processor',
    description: 'Queue processor test',
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
  handler;

  const _FakeUploader(this.handler);

  @override
  Future<SurveyEvidenceUploadResult> upload(
    SurveyEvidenceUploadRequest request,
  ) {
    return handler(request);
  }
}

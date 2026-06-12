import 'package:ky_survey/analytics/survey_evidence_sync_insights.dart';
import 'package:ky_survey/analytics/survey_evidence_upload_planner.dart';
import 'package:ky_survey/logic/survey_evidence_upload_service.dart';
import 'package:ky_survey/logic/survey_evidence_upload_state_bridge.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceUploadStateObserver', () {
    test('mirrors successful service lifecycle events to state sink', () async {
      final sink = _RecordingUploadStateSink();
      final task = _uploadTask(id: 'image-1');
      final service = SurveyEvidenceUploadService(
        uploader: _FakeUploader((request) async {
          return const SurveyEvidenceUploadResult.uploaded(
            remoteUrl: 'https://cdn.example/image-1.jpg',
          );
        }),
        clock: _clock([
          DateTime(2026, 2, 1, 8),
          DateTime(2026, 2, 1, 8, 0, 1),
          DateTime(2026, 2, 1, 8, 0, 2),
        ]),
      );

      final execution = await service.uploadTask(
        task,
        observer: SurveyEvidenceUploadStateObserver(sink: sink),
      );

      expect(execution.didUpload, isTrue);
      expect(sink.events, [
        'queued:response-1:image-1:2026-02-01 08:00:00.000',
        'uploading:response-1:image-1:2026-02-01 08:00:01.000',
        'uploaded:response-1:image-1:https://cdn.example/image-1.jpg:2026-02-01 08:00:02.000',
      ]);
    });

    test('mirrors failed service results to state sink', () async {
      final sink = _RecordingUploadStateSink();
      final task = _uploadTask(id: 'audio-1');
      final service = SurveyEvidenceUploadService(
        uploader: _FakeUploader((request) async {
          return const SurveyEvidenceUploadResult.failed(message: 'timeout');
        }),
        clock: _clock([
          DateTime(2026, 2, 2, 9),
          DateTime(2026, 2, 2, 9, 0, 1),
          DateTime(2026, 2, 2, 9, 0, 2),
        ]),
      );

      final execution = await service.uploadTask(
        task,
        observer: SurveyEvidenceUploadStateObserver(sink: sink),
      );

      expect(execution.failed, isTrue);
      expect(sink.events, [
        'queued:response-1:audio-1:2026-02-02 09:00:00.000',
        'uploading:response-1:audio-1:2026-02-02 09:00:01.000',
        'failed:response-1:audio-1:timeout:2026-02-02 09:00:02.000',
      ]);
    });

    test('marks empty uploaded URLs as failed state updates', () {
      final sink = _RecordingUploadStateSink();
      final task = _uploadTask(id: 'broken-url');
      final observer = SurveyEvidenceUploadStateObserver(sink: sink);

      observer.onUploaded(
        task,
        const SurveyEvidenceUploadResult.uploaded(remoteUrl: ' '),
        DateTime(2026, 2, 3),
      );

      expect(sink.events.single, contains('failed:response-1:broken-url'));
      expect(
        sink.events.single,
        contains('Upload completed without a remote URL.'),
      );
    });
  });
}

SurveyEvidenceUploadTask _uploadTask({required String id}) {
  final survey = Survey(
    id: 'survey-1',
    title: 'Field Evidence',
    description: 'Upload bridge test',
    createdAt: DateTime(2026),
    questions: const [],
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'upload-required',
        kind: SurveyEvidenceKind.image,
        label: 'Evidence attachment',
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

SurveyEvidenceUploadClock _clock(List<DateTime> timestamps) {
  final queue = [...timestamps];
  return () {
    if (queue.isEmpty) {
      return timestamps.last;
    }
    return queue.removeAt(0);
  };
}

class _RecordingUploadStateSink implements SurveyEvidenceUploadStateSink {
  final List<String> events = [];

  @override
  void queueEvidenceUpload({
    required String responseId,
    required String evidenceId,
    DateTime? queuedAt,
  }) {
    events.add('queued:$responseId:$evidenceId:$queuedAt');
  }

  @override
  void markEvidenceUploading({
    required String responseId,
    required String evidenceId,
    DateTime? uploadingAt,
  }) {
    events.add('uploading:$responseId:$evidenceId:$uploadingAt');
  }

  @override
  void markEvidenceUploaded({
    required String responseId,
    required String evidenceId,
    required String remoteUrl,
    DateTime? uploadedAt,
  }) {
    events.add('uploaded:$responseId:$evidenceId:$remoteUrl:$uploadedAt');
  }

  @override
  void markEvidenceUploadFailed({
    required String responseId,
    required String evidenceId,
    required String uploadError,
    DateTime? failedAt,
  }) {
    events.add('failed:$responseId:$evidenceId:$uploadError:$failedAt');
  }
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

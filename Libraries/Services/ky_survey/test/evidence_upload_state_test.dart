import 'package:ky_survey/models/survey_attachment.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyAttachment upload state', () {
    test('updates upload state while preserving attachment identity', () {
      final attachment = SurveyAttachment(
        id: 'attachment-1',
        type: SurveyAttachmentType.image,
        fileName: 'display.jpg',
        localPath: '/local/display.jpg',
        capturedAt: DateTime(2026),
        uploadStatus: SurveyAttachmentUploadStatus.failed,
        uploadError: 'timeout',
        metadata: const {'requirementId': 'image-q1'},
      );

      final queued = attachment.withUploadState(
        uploadStatus: SurveyAttachmentUploadStatus.queued,
        metadata: {'queuedAt': DateTime(2026, 1, 2).toIso8601String()},
      );
      final uploaded = queued.withUploadState(
        uploadStatus: SurveyAttachmentUploadStatus.uploaded,
        remoteUrl: 'https://cdn.example/display.jpg',
        metadata: {'uploadedAt': DateTime(2026, 1, 3).toIso8601String()},
      );

      expect(queued.id, attachment.id);
      expect(queued.localPath, attachment.localPath);
      expect(queued.uploadStatus, SurveyAttachmentUploadStatus.queued);
      expect(queued.uploadError, isNull);
      expect(queued.metadata['requirementId'], 'image-q1');
      expect(
        queued.metadata['queuedAt'],
        DateTime(2026, 1, 2).toIso8601String(),
      );
      expect(uploaded.uploadStatus, SurveyAttachmentUploadStatus.uploaded);
      expect(uploaded.remoteUrl, 'https://cdn.example/display.jpg');
      expect(uploaded.uploadError, isNull);
      expect(
        uploaded.metadata['queuedAt'],
        DateTime(2026, 1, 2).toIso8601String(),
      );
      expect(
        uploaded.metadata['uploadedAt'],
        DateTime(2026, 1, 3).toIso8601String(),
      );
    });

    test('keeps failure details when marking upload failed', () {
      final attachment = SurveyAttachment(
        id: 'attachment-1',
        type: SurveyAttachmentType.audio,
        fileName: 'interview.m4a',
        localPath: '/local/interview.m4a',
        capturedAt: DateTime(2026),
      );

      final failed = attachment.withUploadState(
        uploadStatus: SurveyAttachmentUploadStatus.failed,
        uploadError: 'network unavailable',
        metadata: {'failedAt': DateTime(2026, 1, 4).toIso8601String()},
      );

      expect(failed.uploadStatus, SurveyAttachmentUploadStatus.failed);
      expect(failed.uploadError, 'network unavailable');
      expect(
        failed.metadata['failedAt'],
        DateTime(2026, 1, 4).toIso8601String(),
      );
    });
  });
}

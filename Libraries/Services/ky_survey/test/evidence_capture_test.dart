import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_location.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/validation/survey_evidence_validator.dart';
import 'package:test/test.dart';

void main() {
  group('Survey evidence capture', () {
    test('serializes location, image, and audio evidence on responses', () {
      final location = SurveyLocation(
        latitude: -6.2,
        longitude: 106.816666,
        accuracyMeters: 12.5,
        altitudeMeters: 24,
        capturedAt: DateTime(2026, 1, 1, 10),
        provider: 'gps',
      );
      final image = SurveyAttachment(
        id: 'img-1',
        type: SurveyAttachmentType.image,
        fileName: 'shelf.jpg',
        localPath: '/local/shelf.jpg',
        thumbnailPath: '/local/shelf-thumb.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 320000,
        capturedAt: DateTime(2026, 1, 1, 10, 1),
      );
      final audio = SurveyAttachment(
        id: 'aud-1',
        type: SurveyAttachmentType.audio,
        fileName: 'interview.m4a',
        localPath: '/local/interview.m4a',
        mimeType: 'audio/mp4',
        durationMilliseconds: 42000,
        capturedAt: DateTime(2026, 1, 1, 10, 2),
      );
      final response = SurveyResponse(
        id: 'r1',
        surveyId: 's1',
        respondentId: 'u1',
        respondentName: 'Participant',
        startedAt: DateTime(2026, 1, 1, 10),
        evidence: [
          SurveyEvidence.location(id: 'loc-1', location: location),
          SurveyEvidence.attachment(
            id: 'img-evidence',
            attachment: image,
            scope: SurveyEvidenceScope.question,
            questionId: 'q1',
          ),
          SurveyEvidence.attachment(id: 'audio-evidence', attachment: audio),
        ],
      );

      final restored = SurveyResponse.fromJson(response.toJson());

      expect(restored.evidence, hasLength(3));
      expect(
        restored.evidenceByKind(SurveyEvidenceKind.location),
        hasLength(1),
      );
      expect(restored.evidenceByKind(SurveyEvidenceKind.audio), hasLength(1));
      expect(
        restored.evidenceForQuestion('q1').single.kind,
        SurveyEvidenceKind.image,
      );
      expect(restored.responseEvidence.map((item) => item.id), [
        'loc-1',
        'audio-evidence',
      ]);
      expect(
        restored
            .evidenceByKind(SurveyEvidenceKind.audio)
            .single
            .attachment
            ?.duration,
        const Duration(seconds: 42),
      );
    });

    test('upserts and removes evidence by stable evidence id', () {
      final image = SurveyAttachment(
        id: 'img-1',
        type: SurveyAttachmentType.image,
        fileName: 'front.jpg',
        localPath: '/local/front.jpg',
        capturedAt: DateTime(2026),
      );
      final firstEvidence = SurveyEvidence.attachment(
        id: 'e1',
        attachment: image,
        note: 'Before retake',
      );
      final updatedEvidence = firstEvidence.copyWith(note: 'After retake');
      final response = SurveyResponse(
        id: 'r1',
        surveyId: 's1',
        respondentId: 'u1',
        respondentName: 'Participant',
        startedAt: DateTime(2026),
      );

      final updated = response
          .upsertEvidence(firstEvidence)
          .upsertEvidence(updatedEvidence);
      final removed = updated.removeEvidence('e1');

      expect(updated.evidence, hasLength(1));
      expect(updated.evidence.single.note, 'After retake');
      expect(removed.evidence, isEmpty);
    });

    test('validates broken evidence before sync or submit', () {
      final invalidLocation = SurveyEvidence.location(
        id: 'bad-location',
        location: SurveyLocation(
          latitude: 120,
          longitude: 200,
          accuracyMeters: -1,
          capturedAt: DateTime(2026),
        ),
      );
      final missingStorage = SurveyEvidence.attachment(
        id: 'missing-storage',
        attachment: SurveyAttachment(
          id: 'img-2',
          type: SurveyAttachmentType.image,
          fileName: 'empty.jpg',
          capturedAt: DateTime(2026),
        ),
      );
      final missingQuestion = SurveyEvidence.attachment(
        id: 'missing-question',
        attachment: SurveyAttachment(
          id: 'file-1',
          type: SurveyAttachmentType.file,
          fileName: 'consent.pdf',
          localPath: '/local/consent.pdf',
          capturedAt: DateTime(2026),
        ),
        scope: SurveyEvidenceScope.question,
      );
      final mismatch = SurveyEvidence(
        id: 'mismatch',
        kind: SurveyEvidenceKind.audio,
        capturedAt: DateTime(2026),
        attachment: SurveyAttachment(
          id: 'img-3',
          type: SurveyAttachmentType.image,
          fileName: 'wrong.jpg',
          localPath: '/local/wrong.jpg',
          capturedAt: DateTime(2026),
        ),
      );

      final result = SurveyEvidenceValidator.validate([
        invalidLocation,
        missingStorage,
        missingQuestion,
        mismatch,
      ]);
      final issueTypes = result.issues.map((issue) => issue.type).toSet();

      expect(result.isValid, isFalse);
      expect(result.hasBlockers, isTrue);
      expect(
        issueTypes,
        contains(SurveyEvidenceValidationIssueType.invalidCoordinates),
      );
      expect(
        issueTypes,
        contains(SurveyEvidenceValidationIssueType.invalidAccuracy),
      );
      expect(
        issueTypes,
        contains(SurveyEvidenceValidationIssueType.missingStorageReference),
      );
      expect(
        issueTypes,
        contains(SurveyEvidenceValidationIssueType.missingQuestionId),
      );
      expect(
        issueTypes,
        contains(SurveyEvidenceValidationIssueType.attachmentTypeMismatch),
      );
    });

    test('accepts complete GPS, image, and audio evidence', () {
      final result = SurveyEvidenceValidator.validate([
        SurveyEvidence.location(
          id: 'loc',
          location: SurveyLocation(
            latitude: -6.2,
            longitude: 106.8,
            capturedAt: DateTime(2026),
          ),
        ),
        SurveyEvidence.attachment(
          id: 'img',
          attachment: SurveyAttachment(
            id: 'img',
            type: SurveyAttachmentType.image,
            fileName: 'display.jpg',
            localPath: '/local/display.jpg',
            capturedAt: DateTime(2026),
          ),
        ),
        SurveyEvidence.attachment(
          id: 'audio',
          attachment: SurveyAttachment(
            id: 'audio',
            type: SurveyAttachmentType.audio,
            fileName: 'interview.m4a',
            remoteUrl: 'https://cdn.example/interview.m4a',
            durationMilliseconds: 1000,
            capturedAt: DateTime(2026),
          ),
        ),
      ]);

      expect(result.isValid, isTrue);
      expect(result.issues, isEmpty);
    });
  });
}

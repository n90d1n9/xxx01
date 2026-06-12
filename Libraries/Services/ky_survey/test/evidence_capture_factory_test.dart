import 'package:ky_survey/logic/survey_evidence_capture_factory.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/validation/survey_evidence_validator.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceCaptureFactory', () {
    test('creates question-scoped location evidence from a requirement', () {
      const requirement = SurveyEvidenceRequirement(
        id: 'gps-q1',
        kind: SurveyEvidenceKind.location,
        scope: SurveyEvidenceScope.question,
        questionId: 'q1',
        label: 'Question GPS',
      );

      final evidence = SurveyEvidenceCaptureFactory.createLocationEvidence(
        requirement: requirement,
        evidenceId: 'location-1',
        latitude: -6.2,
        longitude: 106.8,
        accuracyMeters: 12,
        capturedAt: DateTime(2026),
        collectorId: 'collector-1',
        collectorName: 'Surveyor',
        note: 'Captured at outlet',
      );
      final validation = SurveyEvidenceValidator.validate([evidence]);

      expect(evidence.id, 'location-1');
      expect(evidence.kind, SurveyEvidenceKind.location);
      expect(evidence.scope, SurveyEvidenceScope.question);
      expect(evidence.questionId, 'q1');
      expect(evidence.location?.accuracyMeters, 12);
      expect(evidence.metadata['requirementId'], 'gps-q1');
      expect(evidence.collectorName, 'Surveyor');
      expect(evidence.note, 'Captured at outlet');
      expect(validation.isValid, isTrue);
    });

    test('creates typed attachment evidence with upload state metadata', () {
      const requirement = SurveyEvidenceRequirement(
        id: 'audio-response',
        kind: SurveyEvidenceKind.audio,
        label: 'Interview audio',
        requireUploaded: true,
      );

      final evidence = SurveyEvidenceCaptureFactory.createAttachmentEvidence(
        requirement: requirement,
        evidenceId: 'audio-1',
        fileName: 'interview.m4a',
        localPath: '/local/interview.m4a',
        mimeType: 'audio/mp4',
        durationMilliseconds: 45000,
        uploadStatus: SurveyAttachmentUploadStatus.uploaded,
        capturedAt: DateTime(2026),
      );
      final validation = SurveyEvidenceValidator.validate([evidence]);

      expect(evidence.kind, SurveyEvidenceKind.audio);
      expect(evidence.scope, SurveyEvidenceScope.response);
      expect(evidence.questionId, isNull);
      expect(evidence.attachment?.type, SurveyAttachmentType.audio);
      expect(evidence.attachment?.isUploaded, isTrue);
      expect(evidence.attachment?.durationMilliseconds, 45000);
      expect(evidence.attachment?.metadata['requirementId'], 'audio-response');
      expect(validation.isValid, isTrue);
    });

    test('rejects capture kind mismatches', () {
      const locationRequirement = SurveyEvidenceRequirement(
        id: 'gps',
        kind: SurveyEvidenceKind.location,
      );
      const imageRequirement = SurveyEvidenceRequirement(
        id: 'image',
        kind: SurveyEvidenceKind.image,
      );

      expect(
        () => SurveyEvidenceCaptureFactory.createAttachmentEvidence(
          requirement: locationRequirement,
          fileName: 'gps.txt',
          localPath: '/local/gps.txt',
        ),
        throwsArgumentError,
      );
      expect(
        () => SurveyEvidenceCaptureFactory.createLocationEvidence(
          requirement: imageRequirement,
          latitude: -6.2,
          longitude: 106.8,
        ),
        throwsArgumentError,
      );
    });
  });
}

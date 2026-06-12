import 'package:ky_survey/logic/survey_evidence_capture_adapter.dart';
import 'package:ky_survey/logic/survey_evidence_capture_factory.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/validation/survey_evidence_validator.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyEvidenceCaptureRegistry', () {
    test('selects a matching adapter and returns captured evidence', () async {
      const requirement = SurveyEvidenceRequirement(
        id: 'gps',
        kind: SurveyEvidenceKind.location,
      );
      final adapter = SurveyEvidenceKindCaptureAdapter(
        id: 'test-gps',
        label: 'Test GPS',
        kind: SurveyEvidenceKind.location,
        onCapture: (request) async {
          return SurveyEvidenceCaptureFactory.createLocationEvidence(
            requirement: request.requirement,
            evidenceId: 'gps-capture',
            latitude: -6.2,
            longitude: 106.8,
            collectorId: request.collectorId,
            collectorName: request.collectorName,
            metadata: request.evidenceMetadata,
          );
        },
      );
      const imageAdapter = SurveyEvidenceKindCaptureAdapter(
        id: 'image',
        label: 'Image',
        kind: SurveyEvidenceKind.image,
        onCapture: _noCapture,
      );
      final registry = SurveyEvidenceCaptureRegistry(
        adapters: [imageAdapter, adapter],
      );

      final evidence = await registry.capture(
        const SurveyEvidenceCaptureRequest(
          requirement: requirement,
          collectorId: 'collector-1',
          collectorName: 'Surveyor',
          captureSource: 'device_adapter:test-gps',
        ),
      );
      final validation = SurveyEvidenceValidator.validate([evidence!]);

      expect(registry.adapterFor(requirement), adapter);
      expect(evidence.id, 'gps-capture');
      expect(evidence.collectorId, 'collector-1');
      expect(evidence.metadata['captureSource'], 'device_adapter:test-gps');
      expect(evidence.metadata['requirementId'], 'gps');
      expect(validation.isValid, isTrue);
    });

    test('returns null when no adapter supports the requirement', () async {
      const requirement = SurveyEvidenceRequirement(
        id: 'audio',
        kind: SurveyEvidenceKind.audio,
      );
      const registry = SurveyEvidenceCaptureRegistry(
        adapters: [
          SurveyEvidenceKindCaptureAdapter(
            id: 'gps',
            label: 'GPS',
            kind: SurveyEvidenceKind.location,
            onCapture: _noCapture,
          ),
        ],
      );

      final evidence = await registry.capture(
        const SurveyEvidenceCaptureRequest(requirement: requirement),
      );

      expect(registry.adapterFor(requirement), isNull);
      expect(evidence, isNull);
    });

    test('request copyWith preserves existing context by default', () {
      const requirement = SurveyEvidenceRequirement(
        id: 'image',
        kind: SurveyEvidenceKind.image,
      );
      final request = SurveyEvidenceCaptureRequest(
        requirement: requirement,
        collectorId: 'collector-1',
        collectorName: 'Surveyor',
        metadata: const {'flow': 'interview'},
      );

      final copied = request.copyWith(captureSource: 'camera');

      expect(copied.requirement, requirement);
      expect(copied.collectorId, 'collector-1');
      expect(copied.collectorName, 'Surveyor');
      expect(copied.captureSource, 'camera');
      expect(copied.evidenceMetadata['flow'], 'interview');
      expect(copied.evidenceMetadata['captureSource'], 'camera');
    });
  });
}

Future<SurveyEvidence?> _noCapture(SurveyEvidenceCaptureRequest request) async {
  return null;
}

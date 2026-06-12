import 'package:ky_survey/logic/survey_response_evidence_summary.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_location.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:test/test.dart';

void main() {
  group('SurveyResponseEvidenceSummary', () {
    test('tracks missing and invalid required evidence', () {
      final survey = _surveyWithEvidenceRequirements();
      final response = _responseFor(survey)
          .upsertEvidence(_locationEvidence(80))
          .upsertEvidence(_audioEvidence(5000));

      final summary = SurveyResponseEvidenceSummary.evaluate(
        survey: survey,
        response: response,
      );
      final gps = _statusById(summary, 'gps');
      final audio = _statusById(summary, 'audio');
      final image = _statusById(summary, 'image-q1');

      expect(summary.hasRequirements, isTrue);
      expect(summary.isComplete, isFalse);
      expect(summary.canSubmit, isFalse);
      expect(summary.requiredCount, 3);
      expect(summary.requiredCompleteCount, 0);
      expect(summary.missingRequiredCount, 1);
      expect(summary.primaryStatusLabel, '1 evidence missing');
      expect(summary.firstIssueMessage, contains('accuracy'));
      expect(gps.statusLabel, 'Needs attention');
      expect(audio.statusLabel, 'Needs attention');
      expect(image.isMissingRequiredEvidence, isTrue);
      expect(image.captureProgressLabel, '0/1 captured');
      expect(image.scopeLabel, 'Question: Take a display photo');
    });

    test('marks response evidence complete when all requirements pass', () {
      final survey = _surveyWithEvidenceRequirements();
      final response = _responseFor(survey)
          .upsertEvidence(_locationEvidence(12))
          .upsertEvidence(_audioEvidence(45000))
          .upsertEvidence(_imageEvidence(sizeBytes: 250000));

      final summary = SurveyResponseEvidenceSummary.evaluate(
        survey: survey,
        response: response,
      );

      expect(summary.isComplete, isTrue);
      expect(summary.canSubmit, isTrue);
      expect(summary.requiredCompleteCount, 3);
      expect(summary.completionPercent, 100);
      expect(summary.primaryStatusLabel, 'Evidence ready');
      expect(summary.firstIssueMessage, isNull);
      expect(
        summary.requirementStatuses.every((status) => status.isComplete),
        isTrue,
      );
    });

    test('keeps optional missing evidence non-blocking', () {
      final survey = _surveyWithEvidenceRequirements().copyWith(
        evidenceRequirements: const [
          SurveyEvidenceRequirement(
            id: 'optional-file',
            kind: SurveyEvidenceKind.file,
            label: 'Supporting file',
            required: false,
          ),
        ],
      );
      final response = _responseFor(survey);

      final summary = SurveyResponseEvidenceSummary.evaluate(
        survey: survey,
        response: response,
      );
      final optionalFile = _statusById(summary, 'optional-file');

      expect(summary.isComplete, isTrue);
      expect(summary.canSubmit, isTrue);
      expect(summary.requiredCount, 0);
      expect(summary.primaryStatusLabel, 'Evidence ready');
      expect(optionalFile.isComplete, isTrue);
      expect(optionalFile.captureProgressLabel, 'Optional');
    });
  });
}

SurveyEvidenceRequirementStatus _statusById(
  SurveyResponseEvidenceSummary summary,
  String id,
) {
  return summary.requirementStatuses.firstWhere(
    (status) => status.requirement.id == id,
  );
}

Survey _surveyWithEvidenceRequirements() {
  return Survey(
    id: 'field-check',
    title: 'Field Check',
    description: 'Evidence readiness',
    createdAt: DateTime(2026),
    questions: [
      Question(
        id: 'q1',
        text: 'Take a display photo',
        type: QuestionType.singleLineText,
        required: true,
      ),
    ],
    evidenceRequirements: const [
      SurveyEvidenceRequirement(
        id: 'gps',
        kind: SurveyEvidenceKind.location,
        label: 'Outlet GPS',
        maxLocationAccuracyMeters: 25,
      ),
      SurveyEvidenceRequirement(
        id: 'audio',
        kind: SurveyEvidenceKind.audio,
        label: 'Interview audio',
        minAudioDurationMilliseconds: 30000,
      ),
      SurveyEvidenceRequirement(
        id: 'image-q1',
        kind: SurveyEvidenceKind.image,
        scope: SurveyEvidenceScope.question,
        questionId: 'q1',
        label: 'Display image',
        maxAttachmentSizeBytes: 1000000,
      ),
    ],
  );
}

SurveyResponse _responseFor(Survey survey) {
  return SurveyResponse(
    id: 'response-1',
    surveyId: survey.id,
    respondentId: 'participant-1',
    respondentName: 'Participant',
    startedAt: DateTime(2026),
  );
}

SurveyEvidence _locationEvidence(double accuracyMeters) {
  return SurveyEvidence.location(
    id: 'gps-capture',
    location: SurveyLocation(
      latitude: -6.2,
      longitude: 106.8,
      accuracyMeters: accuracyMeters,
      capturedAt: DateTime(2026),
    ),
  );
}

SurveyEvidence _audioEvidence(int durationMilliseconds) {
  return SurveyEvidence.attachment(
    id: 'audio-capture',
    attachment: SurveyAttachment(
      id: 'audio-capture',
      type: SurveyAttachmentType.audio,
      fileName: 'interview.m4a',
      localPath: '/local/interview.m4a',
      durationMilliseconds: durationMilliseconds,
      capturedAt: DateTime(2026),
    ),
  );
}

SurveyEvidence _imageEvidence({required int sizeBytes}) {
  return SurveyEvidence.attachment(
    id: 'image-capture',
    attachment: SurveyAttachment(
      id: 'image-capture',
      type: SurveyAttachmentType.image,
      fileName: 'display.jpg',
      localPath: '/local/display.jpg',
      sizeBytes: sizeBytes,
      capturedAt: DateTime(2026),
    ),
    scope: SurveyEvidenceScope.question,
    questionId: 'q1',
  );
}

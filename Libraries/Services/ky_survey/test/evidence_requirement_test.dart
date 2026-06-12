import 'package:ky_survey/logic/survey_version_audit.dart';
import 'package:ky_survey/logic/survey_versioning.dart';
import 'package:ky_survey/models/question.dart';
import 'package:ky_survey/models/survey.dart';
import 'package:ky_survey/models/survey_attachment.dart';
import 'package:ky_survey/models/survey_evidence.dart';
import 'package:ky_survey/models/survey_evidence_requirement.dart';
import 'package:ky_survey/models/survey_location.dart';
import 'package:ky_survey/models/survey_response.dart';
import 'package:ky_survey/validation/survey_evidence_requirement_validator.dart';
import 'package:ky_survey/validation/survey_readiness_validator.dart';
import 'package:test/test.dart';

void main() {
  group('Survey evidence requirements', () {
    test('validates required GPS, image, and interview audio evidence', () {
      final survey = _evidenceSurvey();
      final incompleteResponse = SurveyResponse(
        id: 'r1',
        surveyId: survey.id,
        respondentId: 'u1',
        respondentName: 'Participant',
        startedAt: DateTime(2026),
        evidence: [
          SurveyEvidence.location(
            id: 'loc',
            location: SurveyLocation(
              latitude: -6.2,
              longitude: 106.8,
              accuracyMeters: 80,
              capturedAt: DateTime(2026),
            ),
          ),
          SurveyEvidence.attachment(
            id: 'audio',
            attachment: SurveyAttachment(
              id: 'audio',
              type: SurveyAttachmentType.audio,
              fileName: 'interview.m4a',
              localPath: '/local/interview.m4a',
              durationMilliseconds: 5000,
              capturedAt: DateTime(2026),
            ),
          ),
        ],
      );
      final completeResponse = incompleteResponse
          .upsertEvidence(
            SurveyEvidence.location(
              id: 'loc',
              location: SurveyLocation(
                latitude: -6.2,
                longitude: 106.8,
                accuracyMeters: 10,
                capturedAt: DateTime(2026),
              ),
            ),
          )
          .upsertEvidence(
            SurveyEvidence.attachment(
              id: 'audio',
              attachment: SurveyAttachment(
                id: 'audio',
                type: SurveyAttachmentType.audio,
                fileName: 'interview.m4a',
                localPath: '/local/interview.m4a',
                durationMilliseconds: 45000,
                capturedAt: DateTime(2026),
              ),
            ),
          )
          .upsertEvidence(
            SurveyEvidence.attachment(
              id: 'image',
              attachment: SurveyAttachment(
                id: 'image',
                type: SurveyAttachmentType.image,
                fileName: 'display.jpg',
                localPath: '/local/display.jpg',
                sizeBytes: 250000,
                capturedAt: DateTime(2026),
              ),
              scope: SurveyEvidenceScope.question,
              questionId: 'q1',
            ),
          );

      final incomplete = SurveyEvidenceRequirementValidator.validate(
        survey: survey,
        response: incompleteResponse,
      );
      final complete = SurveyEvidenceRequirementValidator.validate(
        survey: survey,
        response: completeResponse,
      );
      final issueTypes = incomplete.issues.map((issue) => issue.type).toSet();

      expect(incomplete.isValid, isFalse);
      expect(incomplete.missingRequirementCount, 1);
      expect(
        issueTypes,
        contains(SurveyEvidenceRequirementIssueType.locationTooInaccurate),
      );
      expect(
        issueTypes,
        contains(SurveyEvidenceRequirementIssueType.audioTooShort),
      );
      expect(
        issueTypes,
        contains(SurveyEvidenceRequirementIssueType.missingRequiredEvidence),
      );
      expect(complete.isValid, isTrue);
      expect(complete.issues, isEmpty);
    });

    test('serializes evidence requirements and freezes them in versions', () {
      final survey = _evidenceSurvey();

      final restored = Survey.fromJson(survey.toJson());
      final published = SurveyVersioning.publishSnapshot(
        survey: survey,
        publishedAt: DateTime(2026),
      );
      final edited = published.copyWith(
        evidenceRequirements: [
          ...published.evidenceRequirements,
          const SurveyEvidenceRequirement(
            id: 'consent-file',
            kind: SurveyEvidenceKind.file,
            label: 'Signed consent',
          ),
        ],
      );
      final audit = SurveyVersionAudit.evaluate(edited);

      expect(restored.evidenceRequirements, hasLength(3));
      expect(restored.evidenceRequirements.first.maxLocationAccuracyMeters, 25);
      expect(published.activeVersion?.evidenceRequirements, hasLength(3));
      expect(
        audit.changes.map((change) => change.type),
        contains(SurveyVersionChangeType.evidenceRequirementAdded),
      );
    });

    test('readiness blocks invalid evidence requirement configuration', () {
      final survey = _evidenceSurvey().copyWith(
        evidenceRequirements: const [
          SurveyEvidenceRequirement(
            id: 'broken',
            kind: SurveyEvidenceKind.image,
            scope: SurveyEvidenceScope.question,
            questionId: 'missing',
            minCount: 0,
            maxAttachmentSizeBytes: -1,
          ),
        ],
      );

      final result = SurveyReadinessValidator.validate(survey);
      final messages = result.blockers.map((issue) => issue.message).join('\n');

      expect(result.hasBlockers, isTrue);
      expect(messages, contains('references a missing question'));
      expect(messages, contains('must require at least 1 capture'));
    });
  });
}

Survey _evidenceSurvey() {
  return Survey(
    id: 'evidence-survey',
    title: 'Evidence Survey',
    description: 'Field evidence requirements',
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

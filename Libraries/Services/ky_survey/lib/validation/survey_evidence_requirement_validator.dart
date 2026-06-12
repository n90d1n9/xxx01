import '../models/survey.dart';
import '../models/survey_evidence.dart';
import '../models/survey_evidence_requirement.dart';
import '../models/survey_response.dart';
import 'survey_evidence_validator.dart';

class SurveyEvidenceRequirementValidator {
  const SurveyEvidenceRequirementValidator._();

  static SurveyEvidenceRequirementValidationResult validate({
    required Survey survey,
    required SurveyResponse response,
  }) {
    final evidenceValidation = SurveyEvidenceValidator.validate(
      response.evidence,
    );
    final issues = <SurveyEvidenceRequirementIssue>[];

    for (final requirement in survey.evidenceRequirements) {
      issues.addAll(_validateRequirement(requirement, response));
    }

    return SurveyEvidenceRequirementValidationResult(
      survey: survey,
      response: response,
      evidenceValidation: evidenceValidation,
      issues: issues,
    );
  }

  static List<SurveyEvidence> matchingEvidenceFor({
    required SurveyEvidenceRequirement requirement,
    required SurveyResponse response,
  }) {
    return _matchingEvidence(requirement, response);
  }

  static List<SurveyEvidenceRequirementIssue> _validateRequirement(
    SurveyEvidenceRequirement requirement,
    SurveyResponse response,
  ) {
    final issues = <SurveyEvidenceRequirementIssue>[];
    final matches = _matchingEvidence(requirement, response);

    if (requirement.required && matches.length < requirement.minCount) {
      issues.add(
        SurveyEvidenceRequirementIssue(
          requirement: requirement,
          type: SurveyEvidenceRequirementIssueType.missingRequiredEvidence,
          message:
              '${requirement.labelOrFallback} requires ${requirement.minCount} capture(s)',
        ),
      );
    }

    for (final evidence in matches) {
      issues.addAll(_validateEvidenceAgainstRequirement(requirement, evidence));
    }

    return issues;
  }

  static List<SurveyEvidenceRequirementIssue>
  _validateEvidenceAgainstRequirement(
    SurveyEvidenceRequirement requirement,
    SurveyEvidence evidence,
  ) {
    final issues = <SurveyEvidenceRequirementIssue>[];
    final attachment = evidence.attachment;
    final location = evidence.location;

    final maxAttachmentSizeBytes = requirement.maxAttachmentSizeBytes;
    if (maxAttachmentSizeBytes != null &&
        attachment?.sizeBytes != null &&
        attachment!.sizeBytes! > maxAttachmentSizeBytes) {
      issues.add(
        SurveyEvidenceRequirementIssue(
          requirement: requirement,
          evidence: evidence,
          type: SurveyEvidenceRequirementIssueType.attachmentTooLarge,
          message: '${requirement.labelOrFallback} exceeds max file size',
        ),
      );
    }

    final minAudioDurationMilliseconds =
        requirement.minAudioDurationMilliseconds;
    if (requirement.kind == SurveyEvidenceKind.audio &&
        minAudioDurationMilliseconds != null &&
        (attachment?.durationMilliseconds == null ||
            attachment!.durationMilliseconds! < minAudioDurationMilliseconds)) {
      issues.add(
        SurveyEvidenceRequirementIssue(
          requirement: requirement,
          evidence: evidence,
          type: SurveyEvidenceRequirementIssueType.audioTooShort,
          message: '${requirement.labelOrFallback} is shorter than required',
        ),
      );
    }

    final maxLocationAccuracyMeters = requirement.maxLocationAccuracyMeters;
    if (requirement.kind == SurveyEvidenceKind.location &&
        maxLocationAccuracyMeters != null &&
        (location?.accuracyMeters == null ||
            location!.accuracyMeters! > maxLocationAccuracyMeters)) {
      issues.add(
        SurveyEvidenceRequirementIssue(
          requirement: requirement,
          evidence: evidence,
          type: SurveyEvidenceRequirementIssueType.locationTooInaccurate,
          message:
              '${requirement.labelOrFallback} accuracy is outside the required range',
        ),
      );
    }

    if (requirement.requireUploaded &&
        attachment != null &&
        !attachment.isUploaded) {
      issues.add(
        SurveyEvidenceRequirementIssue(
          requirement: requirement,
          evidence: evidence,
          type: SurveyEvidenceRequirementIssueType.attachmentNotUploaded,
          message: '${requirement.labelOrFallback} has not uploaded yet',
        ),
      );
    }

    return issues;
  }

  static List<SurveyEvidence> _matchingEvidence(
    SurveyEvidenceRequirement requirement,
    SurveyResponse response,
  ) {
    return response.evidence.where((evidence) {
      if (evidence.kind != requirement.kind) {
        return false;
      }

      if (evidence.scope != requirement.scope) {
        return false;
      }

      if (requirement.scope == SurveyEvidenceScope.question) {
        return evidence.questionId == requirement.questionId;
      }

      return true;
    }).toList();
  }
}

class SurveyEvidenceRequirementValidationResult {
  final Survey survey;
  final SurveyResponse response;
  final SurveyEvidenceValidationResult evidenceValidation;
  final List<SurveyEvidenceRequirementIssue> issues;

  const SurveyEvidenceRequirementValidationResult({
    required this.survey,
    required this.response,
    required this.evidenceValidation,
    required this.issues,
  });

  bool get isValid => !hasBlockers;

  bool get hasBlockers => evidenceValidation.hasBlockers || issues.isNotEmpty;

  int get missingRequirementCount => issues
      .where(
        (issue) =>
            issue.type ==
            SurveyEvidenceRequirementIssueType.missingRequiredEvidence,
      )
      .length;
}

class SurveyEvidenceRequirementIssue {
  final SurveyEvidenceRequirement requirement;
  final SurveyEvidence? evidence;
  final SurveyEvidenceRequirementIssueType type;
  final String message;

  const SurveyEvidenceRequirementIssue({
    required this.requirement,
    required this.type,
    required this.message,
    this.evidence,
  });
}

enum SurveyEvidenceRequirementIssueType {
  missingRequiredEvidence,
  attachmentTooLarge,
  audioTooShort,
  locationTooInaccurate,
  attachmentNotUploaded,
}

import '../models/survey.dart';
import '../models/survey_evidence.dart';
import '../models/survey_evidence_requirement.dart';
import '../models/survey_response.dart';
import '../validation/survey_evidence_requirement_validator.dart';
import '../validation/survey_evidence_validator.dart';

/// Summarizes response evidence readiness for checklists and submit gating.
class SurveyResponseEvidenceSummary {
  final Survey survey;
  final SurveyResponse response;
  final SurveyEvidenceRequirementValidationResult validation;
  final List<SurveyEvidenceRequirementStatus> requirementStatuses;

  const SurveyResponseEvidenceSummary({
    required this.survey,
    required this.response,
    required this.validation,
    required this.requirementStatuses,
  });

  factory SurveyResponseEvidenceSummary.evaluate({
    required Survey survey,
    required SurveyResponse response,
  }) {
    final validation = SurveyEvidenceRequirementValidator.validate(
      survey: survey,
      response: response,
    );

    return SurveyResponseEvidenceSummary(
      survey: survey,
      response: response,
      validation: validation,
      requirementStatuses: survey.evidenceRequirements.map((requirement) {
        final evidence = SurveyEvidenceRequirementValidator.matchingEvidenceFor(
          requirement: requirement,
          response: response,
        );
        final evidenceIds = evidence.map((item) => item.id).toSet();
        return SurveyEvidenceRequirementStatus(
          requirement: requirement,
          evidence: evidence,
          questionLabel: _questionLabel(survey, requirement.questionId),
          requirementIssues: validation.issues
              .where((issue) => issue.requirement.id == requirement.id)
              .toList(),
          evidenceIssues: validation.evidenceValidation.issues
              .where((issue) => evidenceIds.contains(issue.evidence.id))
              .toList(),
        );
      }).toList(),
    );
  }

  bool get hasRequirements => requirementStatuses.isNotEmpty;

  bool get isComplete => validation.isValid;

  bool get canSubmit => !responseIsSubmitted && isComplete;

  bool get hasBlockers => validation.hasBlockers;

  bool get responseIsSubmitted =>
      response.status == SurveyResponseStatus.submitted;

  int get requiredCount {
    return requirementStatuses
        .where((status) => status.requirement.required)
        .length;
  }

  int get completeCount {
    return requirementStatuses.where((status) => status.isComplete).length;
  }

  int get requiredCompleteCount {
    return requirementStatuses
        .where((status) => status.requirement.required && status.isComplete)
        .length;
  }

  int get missingRequiredCount => requirementStatuses
      .where((status) => status.isMissingRequiredEvidence)
      .length;

  int get issueCount =>
      validation.issues.length + validation.evidenceValidation.issues.length;

  double get completionRate {
    if (requiredCount == 0) {
      return hasBlockers ? 0 : 1;
    }

    return requiredCompleteCount / requiredCount;
  }

  int get completionPercent => (completionRate * 100).round();

  String get primaryStatusLabel {
    if (!hasRequirements) {
      return 'No evidence required';
    }

    if (responseIsSubmitted) {
      return 'Evidence submitted';
    }

    if (missingRequiredCount > 0) {
      return _plural(missingRequiredCount, 'evidence missing');
    }

    if (issueCount > 0) {
      return _plural(issueCount, 'evidence issue');
    }

    return 'Evidence ready';
  }

  String get progressLabel {
    if (requiredCount == 0) {
      return 'Optional evidence only';
    }

    return '$requiredCompleteCount of $requiredCount required complete';
  }

  String? get firstIssueMessage {
    final requirementIssue = validation.issues.firstOrNull;
    if (requirementIssue != null) {
      return requirementIssue.message;
    }

    return validation.evidenceValidation.issues.firstOrNull?.message;
  }

  SurveyEvidenceRequirementStatus? get firstIncompleteRequirement {
    for (final status in requirementStatuses) {
      if (!status.isComplete) {
        return status;
      }
    }

    return null;
  }

  static String? _questionLabel(Survey survey, String? questionId) {
    if (questionId == null) {
      return null;
    }

    for (final question in survey.questions) {
      if (question.id == questionId) {
        final text = question.text.trim();
        return text.isEmpty ? 'Untitled question' : text;
      }
    }

    return 'Missing question';
  }

  static String _plural(int count, String singular, [String? plural]) {
    return count == 1 ? '1 $singular' : '$count ${plural ?? '${singular}s'}';
  }
}

/// Describes one evidence requirement and the evidence captured for it.
class SurveyEvidenceRequirementStatus {
  final SurveyEvidenceRequirement requirement;
  final List<SurveyEvidence> evidence;
  final String? questionLabel;
  final List<SurveyEvidenceRequirementIssue> requirementIssues;
  final List<SurveyEvidenceValidationIssue> evidenceIssues;

  const SurveyEvidenceRequirementStatus({
    required this.requirement,
    required this.evidence,
    required this.requirementIssues,
    required this.evidenceIssues,
    this.questionLabel,
  });

  bool get hasIssues =>
      requirementIssues.isNotEmpty || evidenceIssues.isNotEmpty;

  bool get hasRequiredEvidence =>
      !requirement.required || evidence.length >= requirement.minCount;

  bool get isComplete => hasRequiredEvidence && !hasIssues;

  bool get isMissingRequiredEvidence {
    return requirementIssues.any(
      (issue) =>
          issue.type ==
          SurveyEvidenceRequirementIssueType.missingRequiredEvidence,
    );
  }

  String get statusLabel {
    if (isComplete) {
      return 'Complete';
    }

    if (isMissingRequiredEvidence) {
      return 'Missing';
    }

    return 'Needs attention';
  }

  String get scopeLabel {
    if (requirement.scope == SurveyEvidenceScope.question) {
      return questionLabel == null
          ? 'Question evidence'
          : 'Question: $questionLabel';
    }

    return 'Response evidence';
  }

  String get captureProgressLabel {
    if (!requirement.required && evidence.isEmpty) {
      return 'Optional';
    }

    return '${evidence.length}/${requirement.minCount} captured';
  }

  String? get firstIssueMessage {
    final requirementIssue = requirementIssues.firstOrNull;
    if (requirementIssue != null) {
      return requirementIssue.message;
    }

    return evidenceIssues.firstOrNull?.message;
  }
}

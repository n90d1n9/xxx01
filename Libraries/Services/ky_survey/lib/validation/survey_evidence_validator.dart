import '../models/survey_attachment.dart';
import '../models/survey_evidence.dart';

class SurveyEvidenceValidator {
  const SurveyEvidenceValidator._();

  static SurveyEvidenceValidationResult validate(
    List<SurveyEvidence> evidence,
  ) {
    final issues = <SurveyEvidenceValidationIssue>[];

    for (final item in evidence) {
      issues.addAll(_validateScope(item));
      issues.addAll(_validateLocation(item));
      issues.addAll(_validateAttachment(item));
    }

    return SurveyEvidenceValidationResult(evidence: evidence, issues: issues);
  }

  static List<SurveyEvidenceValidationIssue> _validateScope(
    SurveyEvidence item,
  ) {
    if (item.scope == SurveyEvidenceScope.question &&
        !_hasText(item.questionId)) {
      return [
        SurveyEvidenceValidationIssue(
          evidence: item,
          type: SurveyEvidenceValidationIssueType.missingQuestionId,
          severity: SurveyEvidenceValidationSeverity.blocker,
          message: 'Question evidence must reference a question',
        ),
      ];
    }

    return const [];
  }

  static List<SurveyEvidenceValidationIssue> _validateLocation(
    SurveyEvidence item,
  ) {
    final issues = <SurveyEvidenceValidationIssue>[];
    final location = item.location;

    if (item.kind == SurveyEvidenceKind.location && location == null) {
      return [
        SurveyEvidenceValidationIssue(
          evidence: item,
          type: SurveyEvidenceValidationIssueType.missingLocation,
          severity: SurveyEvidenceValidationSeverity.blocker,
          message: 'Location evidence is missing coordinates',
        ),
      ];
    }

    if (location == null) {
      return const [];
    }

    if (!_validLatitude(location.latitude) ||
        !_validLongitude(location.longitude)) {
      issues.add(
        SurveyEvidenceValidationIssue(
          evidence: item,
          type: SurveyEvidenceValidationIssueType.invalidCoordinates,
          severity: SurveyEvidenceValidationSeverity.blocker,
          message: 'Location coordinates are outside valid bounds',
        ),
      );
    }

    final accuracy = location.accuracyMeters;
    if (accuracy != null && accuracy < 0) {
      issues.add(
        SurveyEvidenceValidationIssue(
          evidence: item,
          type: SurveyEvidenceValidationIssueType.invalidAccuracy,
          severity: SurveyEvidenceValidationSeverity.warning,
          message: 'Location accuracy cannot be negative',
        ),
      );
    }

    return issues;
  }

  static List<SurveyEvidenceValidationIssue> _validateAttachment(
    SurveyEvidence item,
  ) {
    final issues = <SurveyEvidenceValidationIssue>[];
    final attachment = item.attachment;

    if (_requiresAttachment(item.kind) && attachment == null) {
      return [
        SurveyEvidenceValidationIssue(
          evidence: item,
          type: SurveyEvidenceValidationIssueType.missingAttachment,
          severity: SurveyEvidenceValidationSeverity.blocker,
          message: 'Media evidence is missing an attachment',
        ),
      ];
    }

    if (attachment == null) {
      return const [];
    }

    if (!_kindMatchesAttachment(item.kind, attachment.type)) {
      issues.add(
        SurveyEvidenceValidationIssue(
          evidence: item,
          type: SurveyEvidenceValidationIssueType.attachmentTypeMismatch,
          severity: SurveyEvidenceValidationSeverity.blocker,
          message: 'Evidence kind does not match the attachment type',
        ),
      );
    }

    if (!attachment.hasStorageReference) {
      issues.add(
        SurveyEvidenceValidationIssue(
          evidence: item,
          type: SurveyEvidenceValidationIssueType.missingStorageReference,
          severity: SurveyEvidenceValidationSeverity.blocker,
          message: 'Attachment needs a local path or remote URL',
        ),
      );
    }

    final sizeBytes = attachment.sizeBytes;
    if (sizeBytes != null && sizeBytes < 0) {
      issues.add(
        SurveyEvidenceValidationIssue(
          evidence: item,
          type: SurveyEvidenceValidationIssueType.invalidAttachmentSize,
          severity: SurveyEvidenceValidationSeverity.blocker,
          message: 'Attachment size cannot be negative',
        ),
      );
    }

    final durationMilliseconds = attachment.durationMilliseconds;
    if (durationMilliseconds != null && durationMilliseconds < 0) {
      issues.add(
        SurveyEvidenceValidationIssue(
          evidence: item,
          type: SurveyEvidenceValidationIssueType.invalidAudioDuration,
          severity: SurveyEvidenceValidationSeverity.blocker,
          message: 'Audio duration cannot be negative',
        ),
      );
    }

    return issues;
  }

  static bool _requiresAttachment(SurveyEvidenceKind kind) {
    switch (kind) {
      case SurveyEvidenceKind.image:
      case SurveyEvidenceKind.audio:
      case SurveyEvidenceKind.file:
        return true;
      case SurveyEvidenceKind.location:
        return false;
    }
  }

  static bool _kindMatchesAttachment(
    SurveyEvidenceKind kind,
    SurveyAttachmentType type,
  ) {
    switch (kind) {
      case SurveyEvidenceKind.image:
        return type == SurveyAttachmentType.image;
      case SurveyEvidenceKind.audio:
        return type == SurveyAttachmentType.audio;
      case SurveyEvidenceKind.file:
        return type == SurveyAttachmentType.file;
      case SurveyEvidenceKind.location:
        return true;
    }
  }

  static bool _validLatitude(double latitude) {
    return latitude >= -90 && latitude <= 90;
  }

  static bool _validLongitude(double longitude) {
    return longitude >= -180 && longitude <= 180;
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}

class SurveyEvidenceValidationResult {
  final List<SurveyEvidence> evidence;
  final List<SurveyEvidenceValidationIssue> issues;

  const SurveyEvidenceValidationResult({
    required this.evidence,
    required this.issues,
  });

  bool get isValid => issues.isEmpty;

  bool get hasBlockers => issues.any(
    (issue) => issue.severity == SurveyEvidenceValidationSeverity.blocker,
  );
}

class SurveyEvidenceValidationIssue {
  final SurveyEvidence evidence;
  final SurveyEvidenceValidationIssueType type;
  final SurveyEvidenceValidationSeverity severity;
  final String message;

  const SurveyEvidenceValidationIssue({
    required this.evidence,
    required this.type,
    required this.severity,
    required this.message,
  });
}

enum SurveyEvidenceValidationIssueType {
  missingQuestionId,
  missingLocation,
  invalidCoordinates,
  invalidAccuracy,
  missingAttachment,
  attachmentTypeMismatch,
  missingStorageReference,
  invalidAttachmentSize,
  invalidAudioDuration,
}

enum SurveyEvidenceValidationSeverity { warning, blocker }

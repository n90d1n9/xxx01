import '../logic/survey_response_survey_resolver.dart';
import '../models/survey.dart';
import '../models/survey_attachment.dart';
import '../models/survey_evidence.dart';
import '../models/survey_evidence_requirement.dart';
import '../models/survey_response.dart';
import '../validation/survey_evidence_validator.dart';

class SurveyEvidenceSyncInsights {
  final List<Survey> surveys;
  final List<SurveyResponse> responses;

  const SurveyEvidenceSyncInsights({
    required this.surveys,
    required this.responses,
  });

  SurveyResponseSurveyResolver get _surveyResolver {
    return SurveyResponseSurveyResolver(surveys: surveys);
  }

  List<SurveyEvidenceSyncItem> get items {
    final syncItems = <SurveyEvidenceSyncItem>[];

    for (final response in responses) {
      final survey = _surveyResolver.surveyForResponse(response);
      if (survey == null) {
        continue;
      }

      final validation = SurveyEvidenceValidator.validate(response.evidence);
      for (final evidence in response.evidence) {
        final attachment = evidence.attachment;
        if (attachment == null) {
          continue;
        }

        syncItems.add(
          SurveyEvidenceSyncItem(
            survey: survey,
            response: response,
            evidence: evidence,
            attachment: attachment,
            requirement: _requirementFor(survey: survey, evidence: evidence),
            issues: validation.issues
                .where((issue) => issue.evidence.id == evidence.id)
                .toList(),
          ),
        );
      }
    }

    return syncItems;
  }

  int get totalAttachmentCount => items.length;

  int get requiredUploadCount {
    return items.where((item) => item.requiresUpload).length;
  }

  int get requiredUploadedCount {
    return items
        .where(
          (item) =>
              item.requiresUpload &&
              item.state == SurveyEvidenceSyncState.uploaded,
        )
        .length;
  }

  int get uploadedCount {
    return items
        .where((item) => item.state == SurveyEvidenceSyncState.uploaded)
        .length;
  }

  int get pendingUploadCount {
    return items.where((item) => item.isPendingUpload).length;
  }

  int get failedCount {
    return items
        .where((item) => item.state == SurveyEvidenceSyncState.failed)
        .length;
  }

  int get blockedCount {
    return items
        .where((item) => item.state == SurveyEvidenceSyncState.blocked)
        .length;
  }

  int get localOnlyCount {
    return items
        .where((item) => item.state == SurveyEvidenceSyncState.localOnly)
        .length;
  }

  int get actionRequiredCount {
    return items.where((item) => item.requiresAction).length;
  }

  bool get hasAttachments => totalAttachmentCount > 0;

  bool get hasActionRequired => actionRequiredCount > 0;

  double get requiredUploadCompletionRate {
    if (requiredUploadCount == 0) {
      return 1;
    }

    return requiredUploadedCount / requiredUploadCount;
  }

  String get statusLabel {
    if (!hasAttachments) {
      return 'No evidence attachments';
    }

    if (blockedCount > 0) {
      return '$blockedCount blocked';
    }

    if (failedCount > 0) {
      return '$failedCount failed';
    }

    if (pendingUploadCount > 0) {
      return '$pendingUploadCount pending upload';
    }

    return 'Evidence synced';
  }

  List<SurveyEvidenceSyncItem> itemsNeedingAttention({int limit = 6}) {
    final queue = items
        .where((item) => item.requiresAction || item.isPendingUpload)
        .toList();
    queue.sort((left, right) {
      final priority = left.priority.compareTo(right.priority);
      if (priority != 0) {
        return priority;
      }

      return right.evidence.capturedAt.compareTo(left.evidence.capturedAt);
    });
    return queue.take(limit).toList();
  }

  List<SurveyEvidenceSyncSurveySummary> get surveySummaries {
    return surveys.map((survey) {
      final surveyItems = items
          .where((item) => item.response.surveyId == survey.id)
          .toList();
      return SurveyEvidenceSyncSurveySummary(
        survey: survey,
        items: surveyItems,
      );
    }).toList();
  }

  SurveyEvidenceRequirement? _requirementFor({
    required Survey survey,
    required SurveyEvidence evidence,
  }) {
    final requirementId = evidence.metadata['requirementId'];
    if (requirementId is String && requirementId.trim().isNotEmpty) {
      for (final requirement in survey.evidenceRequirements) {
        if (requirement.id == requirementId) {
          return requirement;
        }
      }
    }

    for (final requirement in survey.evidenceRequirements) {
      if (_matchesRequirement(requirement, evidence)) {
        return requirement;
      }
    }

    return null;
  }

  bool _matchesRequirement(
    SurveyEvidenceRequirement requirement,
    SurveyEvidence evidence,
  ) {
    if (requirement.kind != evidence.kind) {
      return false;
    }

    if (requirement.scope != evidence.scope) {
      return false;
    }

    if (requirement.scope == SurveyEvidenceScope.question) {
      return requirement.questionId == evidence.questionId;
    }

    return true;
  }
}

class SurveyEvidenceSyncItem {
  final Survey survey;
  final SurveyResponse response;
  final SurveyEvidence evidence;
  final SurveyAttachment attachment;
  final SurveyEvidenceRequirement? requirement;
  final List<SurveyEvidenceValidationIssue> issues;

  const SurveyEvidenceSyncItem({
    required this.survey,
    required this.response,
    required this.evidence,
    required this.attachment,
    required this.issues,
    this.requirement,
  });

  bool get requiresUpload => requirement?.requireUploaded ?? false;

  bool get hasBlockers => issues.any(
    (issue) => issue.severity == SurveyEvidenceValidationSeverity.blocker,
  );

  SurveyEvidenceSyncState get state {
    if (hasBlockers) {
      return SurveyEvidenceSyncState.blocked;
    }

    switch (attachment.uploadStatus) {
      case SurveyAttachmentUploadStatus.uploaded:
        return SurveyEvidenceSyncState.uploaded;
      case SurveyAttachmentUploadStatus.failed:
        return SurveyEvidenceSyncState.failed;
      case SurveyAttachmentUploadStatus.uploading:
        return SurveyEvidenceSyncState.uploading;
      case SurveyAttachmentUploadStatus.queued:
        return SurveyEvidenceSyncState.queued;
      case SurveyAttachmentUploadStatus.local:
        return requiresUpload
            ? SurveyEvidenceSyncState.readyToUpload
            : SurveyEvidenceSyncState.localOnly;
    }
  }

  bool get isPendingUpload {
    return state == SurveyEvidenceSyncState.readyToUpload ||
        state == SurveyEvidenceSyncState.queued ||
        state == SurveyEvidenceSyncState.uploading;
  }

  bool get requiresAction {
    return state == SurveyEvidenceSyncState.blocked ||
        state == SurveyEvidenceSyncState.failed ||
        state == SurveyEvidenceSyncState.readyToUpload;
  }

  int get priority {
    switch (state) {
      case SurveyEvidenceSyncState.blocked:
        return 0;
      case SurveyEvidenceSyncState.failed:
        return 1;
      case SurveyEvidenceSyncState.readyToUpload:
        return 2;
      case SurveyEvidenceSyncState.queued:
        return 3;
      case SurveyEvidenceSyncState.uploading:
        return 4;
      case SurveyEvidenceSyncState.localOnly:
        return 5;
      case SurveyEvidenceSyncState.uploaded:
        return 6;
    }
  }

  String get stateLabel {
    switch (state) {
      case SurveyEvidenceSyncState.uploaded:
        return 'Uploaded';
      case SurveyEvidenceSyncState.queued:
        return 'Queued';
      case SurveyEvidenceSyncState.uploading:
        return 'Uploading';
      case SurveyEvidenceSyncState.failed:
        return 'Failed';
      case SurveyEvidenceSyncState.readyToUpload:
        return 'Ready to upload';
      case SurveyEvidenceSyncState.localOnly:
        return 'Local only';
      case SurveyEvidenceSyncState.blocked:
        return 'Blocked';
    }
  }

  String get title {
    return requirement?.labelOrFallback ?? attachment.fileName;
  }

  String get detail {
    final issueMessage = issues.firstOrNull?.message;
    if (issueMessage != null) {
      return issueMessage;
    }

    return '${survey.title} • ${response.respondentName} • ${attachment.fileName}';
  }
}

class SurveyEvidenceSyncSurveySummary {
  final Survey survey;
  final List<SurveyEvidenceSyncItem> items;

  const SurveyEvidenceSyncSurveySummary({
    required this.survey,
    required this.items,
  });

  int get attachmentCount => items.length;

  int get requiredUploadCount {
    return items.where((item) => item.requiresUpload).length;
  }

  int get actionRequiredCount {
    return items.where((item) => item.requiresAction).length;
  }

  bool get hasActionRequired => actionRequiredCount > 0;
}

enum SurveyEvidenceSyncState {
  uploaded,
  queued,
  uploading,
  failed,
  readyToUpload,
  localOnly,
  blocked,
}

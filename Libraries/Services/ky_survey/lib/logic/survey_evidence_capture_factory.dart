import 'package:uuid/uuid.dart';

import '../models/survey_attachment.dart';
import '../models/survey_evidence.dart';
import '../models/survey_evidence_requirement.dart';
import '../models/survey_location.dart';

class SurveyEvidenceCaptureFactory {
  const SurveyEvidenceCaptureFactory._();

  static SurveyEvidence createLocationEvidence({
    required SurveyEvidenceRequirement requirement,
    required double latitude,
    required double longitude,
    String? evidenceId,
    double? accuracyMeters,
    double? altitudeMeters,
    DateTime? capturedAt,
    SurveyLocationSource source = SurveyLocationSource.device,
    bool isMocked = false,
    String? provider,
    String? collectorId,
    String? collectorName,
    String? note,
    Map<String, dynamic> metadata = const {},
  }) {
    if (requirement.kind != SurveyEvidenceKind.location) {
      throw ArgumentError.value(
        requirement.kind,
        'requirement.kind',
        'Location evidence requires a location requirement',
      );
    }

    final resolvedCapturedAt = capturedAt ?? DateTime.now();
    return SurveyEvidence.location(
      id: evidenceId ?? const Uuid().v4(),
      location: SurveyLocation(
        latitude: latitude,
        longitude: longitude,
        accuracyMeters: accuracyMeters,
        altitudeMeters: altitudeMeters,
        capturedAt: resolvedCapturedAt,
        source: source,
        isMocked: isMocked,
        provider: provider,
      ),
      scope: requirement.scope,
      questionId: _questionIdFor(requirement),
      collectorId: collectorId,
      collectorName: collectorName,
      note: note,
      metadata: _metadataFor(requirement, metadata),
    );
  }

  static SurveyEvidence createAttachmentEvidence({
    required SurveyEvidenceRequirement requirement,
    required String fileName,
    String? evidenceId,
    String? attachmentId,
    DateTime? capturedAt,
    String? localPath,
    String? remoteUrl,
    String? thumbnailPath,
    String? mimeType,
    int? sizeBytes,
    int? durationMilliseconds,
    SurveyAttachmentUploadStatus uploadStatus =
        SurveyAttachmentUploadStatus.local,
    String? uploadError,
    String? collectorId,
    String? collectorName,
    String? note,
    Map<String, dynamic> metadata = const {},
  }) {
    if (requirement.kind == SurveyEvidenceKind.location) {
      throw ArgumentError.value(
        requirement.kind,
        'requirement.kind',
        'Attachment evidence requires an image, audio, or file requirement',
      );
    }

    final resolvedEvidenceId = evidenceId ?? const Uuid().v4();
    final attachment = SurveyAttachment(
      id: attachmentId ?? resolvedEvidenceId,
      type: attachmentTypeForKind(requirement.kind),
      fileName: fileName,
      capturedAt: capturedAt ?? DateTime.now(),
      localPath: _emptyToNull(localPath),
      remoteUrl: _emptyToNull(remoteUrl),
      thumbnailPath: _emptyToNull(thumbnailPath),
      mimeType: _emptyToNull(mimeType),
      sizeBytes: sizeBytes,
      durationMilliseconds: durationMilliseconds,
      uploadStatus: uploadStatus,
      uploadError: _emptyToNull(uploadError),
      metadata: _metadataFor(requirement, metadata),
    );

    return SurveyEvidence.attachment(
      id: resolvedEvidenceId,
      attachment: attachment,
      scope: requirement.scope,
      questionId: _questionIdFor(requirement),
      collectorId: collectorId,
      collectorName: collectorName,
      note: note,
      metadata: _metadataFor(requirement, metadata),
    );
  }

  static SurveyAttachmentType attachmentTypeForKind(SurveyEvidenceKind kind) {
    switch (kind) {
      case SurveyEvidenceKind.image:
        return SurveyAttachmentType.image;
      case SurveyEvidenceKind.audio:
        return SurveyAttachmentType.audio;
      case SurveyEvidenceKind.file:
        return SurveyAttachmentType.file;
      case SurveyEvidenceKind.location:
        throw ArgumentError.value(
          kind,
          'kind',
          'Location evidence does not use an attachment type',
        );
    }
  }

  static String? _questionIdFor(SurveyEvidenceRequirement requirement) {
    if (requirement.scope == SurveyEvidenceScope.question) {
      return requirement.questionId;
    }

    return null;
  }

  static Map<String, dynamic> _metadataFor(
    SurveyEvidenceRequirement requirement,
    Map<String, dynamic> metadata,
  ) {
    return {
      ...metadata,
      'requirementId': requirement.id,
      'requirementKind': requirement.kind.name,
      'requirementScope': requirement.scope.name,
    };
  }

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

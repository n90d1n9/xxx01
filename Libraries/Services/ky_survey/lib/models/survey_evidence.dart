import 'survey_attachment.dart';
import 'survey_location.dart';

enum SurveyEvidenceKind { location, image, audio, file }

enum SurveyEvidenceScope { response, question }

SurveyEvidenceKind surveyEvidenceKindFromJson(Object? value) {
  if (value is SurveyEvidenceKind) {
    return value;
  }

  if (value is String) {
    for (final kind in SurveyEvidenceKind.values) {
      if (kind.name == value) {
        return kind;
      }
    }
  }

  return SurveyEvidenceKind.file;
}

SurveyEvidenceScope surveyEvidenceScopeFromJson(Object? value) {
  if (value is SurveyEvidenceScope) {
    return value;
  }

  if (value is String) {
    for (final scope in SurveyEvidenceScope.values) {
      if (scope.name == value) {
        return scope;
      }
    }
  }

  return SurveyEvidenceScope.response;
}

class SurveyEvidence {
  final String id;
  final SurveyEvidenceKind kind;
  final SurveyEvidenceScope scope;
  final String? questionId;
  final DateTime capturedAt;
  final SurveyLocation? location;
  final SurveyAttachment? attachment;
  final String? collectorId;
  final String? collectorName;
  final String? note;
  final Map<String, dynamic> metadata;

  const SurveyEvidence({
    required this.id,
    required this.kind,
    required this.capturedAt,
    this.scope = SurveyEvidenceScope.response,
    this.questionId,
    this.location,
    this.attachment,
    this.collectorId,
    this.collectorName,
    this.note,
    this.metadata = const {},
  });

  factory SurveyEvidence.location({
    required String id,
    required SurveyLocation location,
    SurveyEvidenceScope scope = SurveyEvidenceScope.response,
    String? questionId,
    String? collectorId,
    String? collectorName,
    String? note,
    Map<String, dynamic> metadata = const {},
  }) {
    return SurveyEvidence(
      id: id,
      kind: SurveyEvidenceKind.location,
      scope: scope,
      questionId: questionId,
      capturedAt: location.capturedAt,
      location: location,
      collectorId: collectorId,
      collectorName: collectorName,
      note: note,
      metadata: metadata,
    );
  }

  factory SurveyEvidence.attachment({
    required String id,
    required SurveyAttachment attachment,
    SurveyEvidenceScope scope = SurveyEvidenceScope.response,
    String? questionId,
    String? collectorId,
    String? collectorName,
    String? note,
    Map<String, dynamic> metadata = const {},
  }) {
    return SurveyEvidence(
      id: id,
      kind: _kindForAttachment(attachment),
      scope: scope,
      questionId: questionId,
      capturedAt: attachment.capturedAt,
      attachment: attachment,
      collectorId: collectorId,
      collectorName: collectorName,
      note: note,
      metadata: metadata,
    );
  }

  bool get isQuestionScoped =>
      scope == SurveyEvidenceScope.question && questionId != null;

  bool get isResponseScoped => scope == SurveyEvidenceScope.response;

  SurveyEvidence copyWith({
    String? id,
    SurveyEvidenceKind? kind,
    SurveyEvidenceScope? scope,
    String? questionId,
    DateTime? capturedAt,
    SurveyLocation? location,
    SurveyAttachment? attachment,
    String? collectorId,
    String? collectorName,
    String? note,
    Map<String, dynamic>? metadata,
  }) {
    return SurveyEvidence(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      scope: scope ?? this.scope,
      questionId: questionId ?? this.questionId,
      capturedAt: capturedAt ?? this.capturedAt,
      location: location ?? this.location,
      attachment: attachment ?? this.attachment,
      collectorId: collectorId ?? this.collectorId,
      collectorName: collectorName ?? this.collectorName,
      note: note ?? this.note,
      metadata: metadata ?? this.metadata,
    );
  }

  factory SurveyEvidence.fromJson(Map<String, dynamic> json) {
    return SurveyEvidence(
      id: json['id'] as String,
      kind: surveyEvidenceKindFromJson(json['kind']),
      scope: surveyEvidenceScopeFromJson(json['scope']),
      questionId: json['questionId'] as String?,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      location: json['location'] != null
          ? SurveyLocation.fromJson(
              Map<String, dynamic>.from(json['location'] as Map),
            )
          : null,
      attachment: json['attachment'] != null
          ? SurveyAttachment.fromJson(
              Map<String, dynamic>.from(json['attachment'] as Map),
            )
          : null,
      collectorId: json['collectorId'] as String?,
      collectorName: json['collectorName'] as String?,
      note: json['note'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'scope': scope.name,
      'questionId': questionId,
      'capturedAt': capturedAt.toIso8601String(),
      'location': location?.toJson(),
      'attachment': attachment?.toJson(),
      'collectorId': collectorId,
      'collectorName': collectorName,
      'note': note,
      'metadata': metadata,
    };
  }

  static SurveyEvidenceKind _kindForAttachment(SurveyAttachment attachment) {
    switch (attachment.type) {
      case SurveyAttachmentType.image:
        return SurveyEvidenceKind.image;
      case SurveyAttachmentType.audio:
        return SurveyEvidenceKind.audio;
      case SurveyAttachmentType.file:
        return SurveyEvidenceKind.file;
    }
  }
}

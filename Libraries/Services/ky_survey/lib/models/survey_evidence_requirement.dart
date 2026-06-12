import 'survey_evidence.dart';

class SurveyEvidenceRequirement {
  final String id;
  final SurveyEvidenceKind kind;
  final SurveyEvidenceScope scope;
  final String? questionId;
  final String label;
  final String instructions;
  final int minCount;
  final bool required;
  final bool requireUploaded;
  final int? maxAttachmentSizeBytes;
  final int? minAudioDurationMilliseconds;
  final double? maxLocationAccuracyMeters;

  const SurveyEvidenceRequirement({
    required this.id,
    required this.kind,
    this.scope = SurveyEvidenceScope.response,
    this.questionId,
    this.label = '',
    this.instructions = '',
    this.minCount = 1,
    this.required = true,
    this.requireUploaded = false,
    this.maxAttachmentSizeBytes,
    this.minAudioDurationMilliseconds,
    this.maxLocationAccuracyMeters,
  });

  bool get isQuestionScoped =>
      scope == SurveyEvidenceScope.question && questionId != null;

  String get labelOrFallback {
    final trimmed = label.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }

    switch (kind) {
      case SurveyEvidenceKind.location:
        return 'Location evidence';
      case SurveyEvidenceKind.image:
        return 'Image evidence';
      case SurveyEvidenceKind.audio:
        return 'Audio evidence';
      case SurveyEvidenceKind.file:
        return 'File evidence';
    }
  }

  SurveyEvidenceRequirement copyWith({
    String? id,
    SurveyEvidenceKind? kind,
    SurveyEvidenceScope? scope,
    String? questionId,
    String? label,
    String? instructions,
    int? minCount,
    bool? required,
    bool? requireUploaded,
    int? maxAttachmentSizeBytes,
    int? minAudioDurationMilliseconds,
    double? maxLocationAccuracyMeters,
  }) {
    return SurveyEvidenceRequirement(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      scope: scope ?? this.scope,
      questionId: questionId ?? this.questionId,
      label: label ?? this.label,
      instructions: instructions ?? this.instructions,
      minCount: minCount ?? this.minCount,
      required: required ?? this.required,
      requireUploaded: requireUploaded ?? this.requireUploaded,
      maxAttachmentSizeBytes:
          maxAttachmentSizeBytes ?? this.maxAttachmentSizeBytes,
      minAudioDurationMilliseconds:
          minAudioDurationMilliseconds ?? this.minAudioDurationMilliseconds,
      maxLocationAccuracyMeters:
          maxLocationAccuracyMeters ?? this.maxLocationAccuracyMeters,
    );
  }

  factory SurveyEvidenceRequirement.fromJson(Map<String, dynamic> json) {
    return SurveyEvidenceRequirement(
      id: json['id'] as String,
      kind: surveyEvidenceKindFromJson(json['kind']),
      scope: surveyEvidenceScopeFromJson(json['scope']),
      questionId: json['questionId'] as String?,
      label: json['label'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      minCount: json['minCount'] as int? ?? 1,
      required: json['required'] as bool? ?? true,
      requireUploaded: json['requireUploaded'] as bool? ?? false,
      maxAttachmentSizeBytes: json['maxAttachmentSizeBytes'] as int?,
      minAudioDurationMilliseconds:
          json['minAudioDurationMilliseconds'] as int?,
      maxLocationAccuracyMeters: (json['maxLocationAccuracyMeters'] as num?)
          ?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'scope': scope.name,
      'questionId': questionId,
      'label': label,
      'instructions': instructions,
      'minCount': minCount,
      'required': required,
      'requireUploaded': requireUploaded,
      'maxAttachmentSizeBytes': maxAttachmentSizeBytes,
      'minAudioDurationMilliseconds': minAudioDurationMilliseconds,
      'maxLocationAccuracyMeters': maxLocationAccuracyMeters,
    };
  }
}

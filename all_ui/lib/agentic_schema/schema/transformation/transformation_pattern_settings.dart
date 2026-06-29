import 'enrichment_source.dart';

class TransformationPatternSettings {
  final String? mappingType;
  final String? mappingScript;
  final Map<String, dynamic>? mappingRules;
  final EnrichmentSource? enrichmentSource;
  final String? validationSchema;
  final String? onValidationFailure;

  TransformationPatternSettings({
    this.mappingType,
    this.mappingScript,
    this.mappingRules,
    this.enrichmentSource,
    this.validationSchema,
    this.onValidationFailure,
  });

  factory TransformationPatternSettings.fromJson(Map<String, dynamic> json) {
    return TransformationPatternSettings(
      mappingType: json['mappingType'] as String?,
      mappingScript: json['mappingScript'] as String?,
      mappingRules: json['mappingRules'] != null
          ? Map<String, dynamic>.from(json['mappingRules'] as Map)
          : null,
      enrichmentSource: json['enrichmentSource'] != null
          ? EnrichmentSource.fromJson(
              json['enrichmentSource'] as Map<String, dynamic>,
            )
          : null,
      validationSchema: json['validationSchema'] as String?,
      onValidationFailure: json['onValidationFailure'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (mappingType != null) 'mappingType': mappingType,
      if (mappingScript != null) 'mappingScript': mappingScript,
      if (mappingRules != null) 'mappingRules': mappingRules,
      if (enrichmentSource != null)
        'enrichmentSource': enrichmentSource!.toJson(),
      if (validationSchema != null) 'validationSchema': validationSchema,
      if (onValidationFailure != null)
        'onValidationFailure': onValidationFailure,
    };
  }
}

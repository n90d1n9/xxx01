import 'transformation_pattern_settings.dart';

enum TransformationPattern {
  messageTranslator,
  contentEnricher,
  contentFilter,
  claimCheck,
  normalizer,
  canonicalDataModel,
  validator,
  sorter,
}

class TransformationPatternConfig {
  final TransformationPattern pattern;
  final TransformationPatternSettings? config;

  TransformationPatternConfig({required this.pattern, this.config});

  factory TransformationPatternConfig.fromJson(Map<String, dynamic> json) {
    return TransformationPatternConfig(
      pattern: _parseTransformationPattern(json['pattern']),
      config: json['config'] != null
          ? TransformationPatternSettings.fromJson(
              json['config'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pattern': pattern.name,
      if (config != null) 'config': config!.toJson(),
    };
  }

  static TransformationPattern _parseTransformationPattern(dynamic value) {
    if (value is TransformationPattern) return value;
    final stringValue = value.toString();
    return TransformationPattern.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => TransformationPattern.messageTranslator,
    );
  }
}

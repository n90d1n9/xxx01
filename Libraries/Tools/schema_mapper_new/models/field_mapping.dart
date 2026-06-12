import 'package:flutter/foundation.dart';

import 'schema_field.dart';

enum MappingStrategy { direct, transform, custom }

class FieldMapping {
  final SchemaField sourceField;
  final SchemaField targetField;
  final MappingStrategy strategy;
  final String? transformationScript;
  final Map<String, dynamic>? transformationConfig;

  FieldMapping({
    required this.sourceField,
    required this.targetField,
    required this.strategy,
    this.transformationScript,
    this.transformationConfig,
  });

  FieldMapping copyWith({
    SchemaField? sourceField,
    SchemaField? targetField,
    MappingStrategy? strategy,
    String? transformationScript,
    Map<String, dynamic>? transformationConfig,
  }) {
    return FieldMapping(
      sourceField: sourceField ?? this.sourceField,
      targetField: targetField ?? this.targetField,
      strategy: strategy ?? this.strategy,
      transformationScript: transformationScript ?? this.transformationScript,
      transformationConfig: transformationConfig ?? this.transformationConfig,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceField': sourceField.toJson(),
      'targetField': targetField.toJson(),
      'strategy': strategy.toString(),
      'transformationScript': transformationScript,
      'transformationConfig': transformationConfig,
    };
  }

  factory FieldMapping.fromJson(Map<String, dynamic> json) {
    return FieldMapping(
      sourceField: SchemaField.fromJson(
        json['sourceField'] as Map<String, dynamic>,
      ),
      targetField: SchemaField.fromJson(
        json['targetField'] as Map<String, dynamic>,
      ),
      strategy: MappingStrategy.values.firstWhere(
        (e) => e.toString() == json['strategy'],
      ),
      transformationScript: json['transformationScript'] as String?,
      transformationConfig:
          json['transformationConfig'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'FieldMapping(sourceField: $sourceField, targetField: $targetField, strategy: $strategy, transformationScript: $transformationScript, transformationConfig: $transformationConfig)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FieldMapping &&
        other.sourceField == sourceField &&
        other.targetField == targetField &&
        other.strategy == strategy &&
        other.transformationScript == transformationScript &&
        mapEquals(other.transformationConfig, transformationConfig);
  }

  @override
  int get hashCode {
    return sourceField.hashCode ^
        targetField.hashCode ^
        strategy.hashCode ^
        transformationScript.hashCode ^
        transformationConfig.hashCode;
  }
}

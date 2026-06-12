import 'package:flutter/foundation.dart';

import 'data_schema.dart';

enum TransformationType { typeConversion, formatting, validation, custom }

class TransformationRule {
  final String id;
  final TransformationType type;
  final DataType sourceType;
  final DataType targetType;
  final String? script;
  final Map<String, dynamic>? configuration;

  TransformationRule({
    required this.id,
    required this.type,
    required this.sourceType,
    required this.targetType,
    this.script,
    this.configuration,
  });

  TransformationRule copyWith({
    String? id,
    TransformationType? type,
    DataType? sourceType,
    DataType? targetType,
    String? script,
    Map<String, dynamic>? configuration,
  }) {
    return TransformationRule(
      id: id ?? this.id,
      type: type ?? this.type,
      sourceType: sourceType ?? this.sourceType,
      targetType: targetType ?? this.targetType,
      script: script ?? this.script,
      configuration: configuration ?? this.configuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'sourceType': sourceType.toString(),
      'targetType': targetType.toString(),
      'script': script,
      'configuration': configuration,
    };
  }

  factory TransformationRule.fromJson(Map<String, dynamic> json) {
    return TransformationRule(
      id: json['id'] as String,
      type: TransformationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      sourceType: DataType.values.firstWhere(
        (e) => e.toString() == json['sourceType'],
      ),
      targetType: DataType.values.firstWhere(
        (e) => e.toString() == json['targetType'],
      ),
      script: json['script'] as String?,
      configuration: json['configuration'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'TransformationRule(id: $id, type: $type, sourceType: $sourceType, targetType: $targetType, script: $script, configuration: $configuration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransformationRule &&
        other.id == id &&
        other.type == type &&
        other.sourceType == sourceType &&
        other.targetType == targetType &&
        other.script == script &&
        mapEquals(other.configuration, configuration);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        sourceType.hashCode ^
        targetType.hashCode ^
        script.hashCode ^
        configuration.hashCode;
  }
}

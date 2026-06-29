import 'package:flutter/foundation.dart';

enum DataType { string, integer, double, boolean, datetime, custom }

enum TransformationType {
  trim,
  lowercase,
  uppercase,
  substringBefore,
  substringAfter,
  replace,
  regex,
  mathematical,
  dateFormat,
}

class SchemaField {
  final String name;
  final DataType type;
  final String? description;
  final bool isNullable;
  final Map<String, dynamic>? metadata;

  SchemaField({
    required this.name,
    required this.type,
    this.description,
    this.isNullable = false,
    this.metadata,
  });

  SchemaField copyWith({
    String? name,
    DataType? type,
    String? description,
    bool? isNullable,
    Map<String, dynamic>? metadata,
  }) {
    return SchemaField(
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      isNullable: isNullable ?? this.isNullable,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.toString(),
      'description': description,
      'isNullable': isNullable,
      'metadata': metadata,
    };
  }

  factory SchemaField.fromJson(Map<String, dynamic> json) {
    return SchemaField(
      name: json['name'] as String,
      type: DataType.values.firstWhere((e) => e.toString() == json['type']),
      description: json['description'] as String?,
      isNullable: json['isNullable'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'SchemaField(name: $name, type: $type, description: $description, isNullable: $isNullable, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SchemaField &&
        other.name == name &&
        other.type == type &&
        other.description == description &&
        other.isNullable == isNullable &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        type.hashCode ^
        description.hashCode ^
        isNullable.hashCode ^
        metadata.hashCode;
  }
}

class TransformationRule {
  final TransformationType type;
  final Map<String, dynamic> parameters;
  final String? description;

  TransformationRule({
    required this.type,
    required this.parameters,
    this.description,
  });

  TransformationRule copyWith({
    TransformationType? type,
    Map<String, dynamic>? parameters,
    String? description,
  }) {
    return TransformationRule(
      type: type ?? this.type,
      parameters: parameters ?? this.parameters,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'parameters': parameters,
      'description': description,
    };
  }

  factory TransformationRule.fromJson(Map<String, dynamic> json) {
    return TransformationRule(
      type: TransformationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      parameters: Map<String, dynamic>.from(json['parameters'] as Map),
      description: json['description'] as String?,
    );
  }

  @override
  String toString() {
    return 'TransformationRule(type: $type, parameters: $parameters, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransformationRule &&
        other.type == type &&
        mapEquals(other.parameters, parameters) &&
        other.description == description;
  }

  @override
  int get hashCode {
    return type.hashCode ^ parameters.hashCode ^ description.hashCode;
  }
}

class SchemaMappingConfiguration {
  final String sourceSchemaName;
  final String targetSchemaName;
  final List<FieldMapping> fieldMappings;
  final List<TransformationRule>? globalTransformations;

  SchemaMappingConfiguration({
    required this.sourceSchemaName,
    required this.targetSchemaName,
    required this.fieldMappings,
    this.globalTransformations,
  });

  SchemaMappingConfiguration copyWith({
    String? sourceSchemaName,
    String? targetSchemaName,
    List<FieldMapping>? fieldMappings,
    List<TransformationRule>? globalTransformations,
  }) {
    return SchemaMappingConfiguration(
      sourceSchemaName: sourceSchemaName ?? this.sourceSchemaName,
      targetSchemaName: targetSchemaName ?? this.targetSchemaName,
      fieldMappings: fieldMappings ?? this.fieldMappings,
      globalTransformations:
          globalTransformations ?? this.globalTransformations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceSchemaName': sourceSchemaName,
      'targetSchemaName': targetSchemaName,
      'fieldMappings': fieldMappings.map((e) => e.toJson()).toList(),
      'globalTransformations':
          globalTransformations?.map((e) => e.toJson()).toList(),
    };
  }

  factory SchemaMappingConfiguration.fromJson(Map<String, dynamic> json) {
    return SchemaMappingConfiguration(
      sourceSchemaName: json['sourceSchemaName'] as String,
      targetSchemaName: json['targetSchemaName'] as String,
      fieldMappings:
          (json['fieldMappings'] as List)
              .map((e) => FieldMapping.fromJson(e as Map<String, dynamic>))
              .toList(),
      globalTransformations:
          (json['globalTransformations'] as List?)
              ?.map(
                (e) => TransformationRule.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  @override
  String toString() {
    return 'SchemaMappingConfiguration(sourceSchemaName: $sourceSchemaName, targetSchemaName: $targetSchemaName, fieldMappings: $fieldMappings, globalTransformations: $globalTransformations)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SchemaMappingConfiguration &&
        other.sourceSchemaName == sourceSchemaName &&
        other.targetSchemaName == targetSchemaName &&
        listEquals(other.fieldMappings, fieldMappings) &&
        listEquals(other.globalTransformations, globalTransformations);
  }

  @override
  int get hashCode {
    return sourceSchemaName.hashCode ^
        targetSchemaName.hashCode ^
        fieldMappings.hashCode ^
        globalTransformations.hashCode;
  }
}

class FieldMapping {
  final SchemaField sourceField;
  final SchemaField targetField;
  final List<TransformationRule>? transformations;
  final double? confidence;

  FieldMapping({
    required this.sourceField,
    required this.targetField,
    this.transformations,
    this.confidence,
  });

  FieldMapping copyWith({
    SchemaField? sourceField,
    SchemaField? targetField,
    List<TransformationRule>? transformations,
    double? confidence,
  }) {
    return FieldMapping(
      sourceField: sourceField ?? this.sourceField,
      targetField: targetField ?? this.targetField,
      transformations: transformations ?? this.transformations,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceField': sourceField.toJson(),
      'targetField': targetField.toJson(),
      'transformations': transformations?.map((e) => e.toJson()).toList(),
      'confidence': confidence,
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
      transformations:
          (json['transformations'] as List?)
              ?.map(
                (e) => TransformationRule.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      confidence: json['confidence'] as double?,
    );
  }

  @override
  String toString() {
    return 'FieldMapping(sourceField: $sourceField, targetField: $targetField, transformations: $transformations, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FieldMapping &&
        other.sourceField == sourceField &&
        other.targetField == targetField &&
        listEquals(other.transformations, transformations) &&
        other.confidence == confidence;
  }

  @override
  int get hashCode {
    return sourceField.hashCode ^
        targetField.hashCode ^
        transformations.hashCode ^
        confidence.hashCode;
  }
}

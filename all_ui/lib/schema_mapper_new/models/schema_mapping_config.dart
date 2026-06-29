import 'package:flutter/foundation.dart';

import 'data_schema.dart';
import 'field_mapping.dart';

class SchemaMappingConfiguration {
  final DataSchema sourceSchema;
  final DataSchema targetSchema;
  final List<FieldMapping> fieldMappings;
  final String? name;
  final String? description;

  SchemaMappingConfiguration({
    required this.sourceSchema,
    required this.targetSchema,
    required this.fieldMappings,
    this.name,
    this.description,
  });

  SchemaMappingConfiguration copyWith({
    DataSchema? sourceSchema,
    DataSchema? targetSchema,
    List<FieldMapping>? fieldMappings,
    String? name,
    String? description,
  }) {
    return SchemaMappingConfiguration(
      sourceSchema: sourceSchema ?? this.sourceSchema,
      targetSchema: targetSchema ?? this.targetSchema,
      fieldMappings: fieldMappings ?? this.fieldMappings,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceSchema': sourceSchema.toJson(),
      'targetSchema': targetSchema.toJson(),
      'fieldMappings': fieldMappings.map((e) => e.toJson()).toList(),
      'name': name,
      'description': description,
    };
  }

  factory SchemaMappingConfiguration.fromJson(Map<String, dynamic> json) {
    return SchemaMappingConfiguration(
      sourceSchema: DataSchema.fromJson(
        json['sourceSchema'] as Map<String, dynamic>,
      ),
      targetSchema: DataSchema.fromJson(
        json['targetSchema'] as Map<String, dynamic>,
      ),
      fieldMappings:
          (json['fieldMappings'] as List)
              .map((e) => FieldMapping.fromJson(e as Map<String, dynamic>))
              .toList(),
      name: json['name'] as String?,
      description: json['description'] as String?,
    );
  }

  @override
  String toString() {
    return 'SchemaMappingConfiguration(sourceSchema: $sourceSchema, targetSchema: $targetSchema, fieldMappings: $fieldMappings, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SchemaMappingConfiguration &&
        other.sourceSchema == sourceSchema &&
        other.targetSchema == targetSchema &&
        listEquals(other.fieldMappings, fieldMappings) &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode {
    return sourceSchema.hashCode ^
        targetSchema.hashCode ^
        fieldMappings.hashCode ^
        name.hashCode ^
        description.hashCode;
  }
}

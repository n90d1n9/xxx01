import 'package:flutter/foundation.dart';

import 'schema_field.dart';

enum DataType { string, integer, double, boolean, datetime, list, map, custom }

class DataSchema {
  final String id;
  final String name;
  final List<SchemaField> fields;
  final String? description;
  final Map<String, dynamic> metadata;

  DataSchema({
    required this.id,
    required this.name,
    required this.fields,
    this.description,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  DataSchema copyWith({
    String? id,
    String? name,
    List<SchemaField>? fields,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return DataSchema(
      id: id ?? this.id,
      name: name ?? this.name,
      fields: fields ?? this.fields,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fields': fields.map((e) => e.toJson()).toList(),
      'description': description,
      'metadata': metadata,
    };
  }

  factory DataSchema.fromJson(Map<String, dynamic> json) {
    return DataSchema(
      id: json['id'] as String,
      name: json['name'] as String,
      fields:
          (json['fields'] as List)
              .map((e) => SchemaField.fromJson(e as Map<String, dynamic>))
              .toList(),
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  String toString() {
    return 'DataSchema(id: $id, name: $name, fields: $fields, description: $description, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataSchema &&
        other.id == id &&
        other.name == name &&
        listEquals(other.fields, fields) &&
        other.description == description &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        fields.hashCode ^
        description.hashCode ^
        metadata.hashCode;
  }
}

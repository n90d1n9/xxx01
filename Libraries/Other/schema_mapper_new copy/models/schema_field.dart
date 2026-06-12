import 'package:flutter/foundation.dart';

import 'data_schema.dart';

class SchemaField {
  final String id;
  final String name;
  final DataType type;
  final String? description;
  final bool? isNullable;
  final dynamic defaultValue;
  final Map<String, dynamic>? metadata;

  SchemaField({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.isNullable,
    this.defaultValue,
    this.metadata,
  });

  SchemaField copyWith({
    String? id,
    String? name,
    DataType? type,
    String? description,
    bool? isNullable,
    dynamic defaultValue,
    Map<String, dynamic>? metadata,
  }) {
    return SchemaField(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      isNullable: isNullable ?? this.isNullable,
      defaultValue: defaultValue ?? this.defaultValue,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'description': description,
      'isNullable': isNullable,
      'defaultValue': defaultValue,
      'metadata': metadata,
    };
  }

  factory SchemaField.fromJson(Map<String, dynamic> json) {
    return SchemaField(
      id: json['id'] as String,
      name: json['name'] as String,
      type: DataType.values.firstWhere((e) => e.toString() == json['type']),
      description: json['description'] as String?,
      isNullable: json['isNullable'] as bool?,
      defaultValue: json['defaultValue'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'SchemaField(id: $id, name: $name, type: $type, description: $description, isNullable: $isNullable, defaultValue: $defaultValue, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SchemaField &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.description == description &&
        other.isNullable == isNullable &&
        other.defaultValue == defaultValue &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        description.hashCode ^
        isNullable.hashCode ^
        defaultValue.hashCode ^
        metadata.hashCode;
  }
}

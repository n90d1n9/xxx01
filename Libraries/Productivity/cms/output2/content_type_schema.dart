import 'field_schema.dart';
import 'content_type_settings.dart';

class ContentTypeSchema {
  final String id;
  final String name;
  final String tableName;
  final String? description;
  final String icon;
  final List<FieldSchema> fields;
  final ContentTypeSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final Map<String, dynamic>? metadata;
  const ContentTypeSchema({
    required this.id,
    required this.name,
    required this.tableName,
    this.description,
    required this.icon,
    required this.fields,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.metadata,
  });
  String toCreateTableSQL() {
    final buffer = StringBuffer();
    buffer.writeln('CREATE TABLE $tableName (');
    buffer.writeln('  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),');
    for (var field in fields) {
      if (!field.isSystemField) {
        buffer.writeln('  ${field.toSQLColumn()},');
      }
    }
    buffer.writeln('  created_at TIMESTAMP DEFAULT NOW(),');
    buffer.writeln('  updated_at TIMESTAMP DEFAULT NOW(),');
    buffer.writeln('  created_by UUID,');
    buffer.writeln('  updated_by UUID,');
    buffer.writeln('  published BOOLEAN DEFAULT FALSE,');
    buffer.writeln('  published_at TIMESTAMP');
    buffer.writeln(');');
    for (var field in fields.where((f) => f.constraints.indexed)) {
      buffer.writeln(
        'CREATE INDEX idx_${tableName}_${field.name} ON $tableName(${field.name});',
      );
    }
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tableName': tableName,
    'description': description,
    'icon': icon,
    'fields': fields.map((f) => f.toJson()).toList(),
    'settings': settings.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'version': version,
    'metadata': metadata,
  };
  factory ContentTypeSchema.fromJson(Map<String, dynamic> json) =>
      ContentTypeSchema(
        id: json['id'],
        name: json['name'],
        tableName: json['tableName'],
        description: json['description'],
        icon: json['icon'],
        fields:
            (json['fields'] as List)
                .map((f) => FieldSchema.fromJson(f))
                .toList(),
        settings: ContentTypeSettings.fromJson(json['settings']),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        version: json['version'] ?? 1,
        metadata: json['metadata'],
      );
  ContentTypeSchema copyWith({
    String? id,
    String? name,
    String? tableName,
    String? description,
    String? icon,
    List<FieldSchema>? fields,
    ContentTypeSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    Map<String, dynamic>? metadata,
  }) {
    return ContentTypeSchema(
      id: id ?? this.id,
      name: name ?? this.name,
      tableName: tableName ?? this.tableName,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      fields: fields ?? this.fields,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
    );
  }
}

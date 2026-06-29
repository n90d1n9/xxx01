import 'dart:convert';
import '../../content/model/content_type_schema.dart';
import '../../content/model/content_type_settings.dart';
import '../model/field_contraint.dart';
import '../model/field_schema.dart';
import '../../models/sql_type.dart';
import '../../models/ui_field_type.dart';

import '../../models/import_source.dart';
import '../../models/imported_schema.dart';
import '../../models/imported_field.dart';
import '../../models/imported_relationship.dart';
import '../model/schema_relationship.dart';
import 'sqlschema_parser.dart';
import '../../code_generator/service/prisma_schema_parser.dart';
import '../../code_generator/service/open_apischema_parser.dart';
import '../../output/graph_qlschema_parser.dart';

import '../../models/relation_type.dart';

class SchemaImportManager {
  static Future<List<ImportedSchema>> importFromSource(
    ImportSource source,
    String content,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    switch (source) {
      case ImportSource.sql:
        return SQLSchemaParser.parse(content);
      case ImportSource.prisma:
        return PrismaSchemaParser.parse(content);
      case ImportSource.openapi:
        return OpenAPISchemaParser.parse(content);
      case ImportSource.graphql:
        return GraphQLSchemaParser.parse(content);
      case ImportSource.json:
        return _parseJSON(content);
    }
  }

  static List<ImportedSchema> _parseJSON(String jsonContent) {
    try {
      final data = jsonDecode(jsonContent);
      if (data is List) {
        return data.map((item) => _jsonToSchema(item)).toList();
      } else if (data is Map) {
        return [_jsonToSchema(data)];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static ImportedSchema _jsonToSchema(dynamic data) {
    final map = data as Map<String, dynamic>;
    return ImportedSchema(
      name: map['name'] ?? 'Unknown',
      tableName: map['tableName'] ?? 'unknown',
      fields:
          (map['fields'] as List?)?.map((f) {
            return ImportedField(
              name: f['name'],
              type: f['type'],
              nullable: f['nullable'] ?? true,
            );
          }).toList() ??
          [],
      relationships: [],
      source: 'JSON',
    );
  }

  static ContentTypeSchema convertToContentType(ImportedSchema imported) {
    final now = DateTime.now();
    return ContentTypeSchema(
      id: 'imported_${now.millisecondsSinceEpoch}',
      name: imported.name,
      tableName: imported.tableName,
      description: 'Imported from ${imported.source}',
      icon: 'article',
      fields: imported.fields.map((f) => _convertField(f)).toList(),
      relationships:
          imported.relationships.map((r) => _convertRelationship(r)).toList(),
      settings: const ContentTypeSettings(),
      createdAt: now,
      updatedAt: now,
    );
  }

  static FieldSchema _convertField(ImportedField imported) {
    final sqlType = _mapToSQLType(imported.type);
    final uiType = _mapToUIType(sqlType);
    return FieldSchema(
      id: 'field_${DateTime.now().millisecondsSinceEpoch}_${imported.name}',
      name: imported.name,
      label: _toLabel(imported.name),
      uiType: uiType,
      sqlType: sqlType,
      constraints: FieldConstraints(
        nullable: imported.nullable,
        unique: imported.unique,
      ),
      position: 0,
    );
  }

  static SchemaRelationship _convertRelationship(
    ImportedRelationship imported,
  ) {
    return SchemaRelationship(
      id: 'rel_${DateTime.now().millisecondsSinceEpoch}',
      name: imported.name,
      type: _mapRelationType(imported.type),
      sourceSchemaId: '',
      targetSchemaId: imported.targetTable,
    );
  }

  static SQLType _mapToSQLType(String type) {
    final upperType = type.toUpperCase();
    if (upperType.contains('VARCHAR') || upperType.contains('TEXT'))
      return SQLType.varchar;
    if (upperType.contains('INT')) return SQLType.integer;
    if (upperType.contains('BIGINT')) return SQLType.bigint;
    if (upperType.contains('DECIMAL') || upperType.contains('NUMERIC'))
      return SQLType.decimal;
    if (upperType.contains('BOOL')) return SQLType.boolean;
    if (upperType.contains('DATE')) return SQLType.date;
    if (upperType.contains('TIMESTAMP')) return SQLType.timestamp;
    if (upperType.contains('TIME')) return SQLType.time;
    if (upperType.contains('JSON')) return SQLType.json;
    if (upperType.contains('UUID')) return SQLType.uuid;
    return SQLType.varchar;
  }

  static UIFieldType _mapToUIType(SQLType sqlType) {
    switch (sqlType) {
      case SQLType.varchar:
      case SQLType.text:
        return UIFieldType.textInput;
      case SQLType.integer:
      case SQLType.bigint:
      case SQLType.decimal:
        return UIFieldType.numberInput;
      case SQLType.boolean:
        return UIFieldType.toggle;
      case SQLType.date:
        return UIFieldType.datePicker;
      case SQLType.timestamp:
        return UIFieldType.dateTimePicker;
      case SQLType.time:
        return UIFieldType.timePicker;
      case SQLType.json:
      case SQLType.jsonb:
        return UIFieldType.json;
      default:
        return UIFieldType.textInput;
    }
  }

  static RelationType _mapRelationType(String type) {
    switch (type.toLowerCase()) {
      case 'onetoone':
        return RelationType.oneToOne;
      case 'onetomany':
        return RelationType.oneToMany;
      case 'manytoone':
        return RelationType.manyToOne;
      case 'manytomany':
        return RelationType.manyToMany;
      default:
        return RelationType.manyToOne;
    }
  }

  static String _toLabel(String name) {
    return name
        .split('_')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

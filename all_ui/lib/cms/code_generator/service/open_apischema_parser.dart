import 'dart:convert';

import '../../models/imported_schema.dart';
import '../../models/imported_field.dart';

class OpenAPISchemaParser {
  static List<ImportedSchema> parse(String openAPIJson) {
    try {
      final data = jsonDecode(openAPIJson) as Map<String, dynamic>;
      final schemas = <ImportedSchema>[];
      final components = data['components'] as Map<String, dynamic>?;
      if (components == null) return schemas;
      final schemasData = components['schemas'] as Map<String, dynamic>?;
      if (schemasData == null) return schemas;
      for (var entry in schemasData.entries) {
        final schemaName = entry.key;
        final schemaData = entry.value as Map<String, dynamic>;
        final properties =
            schemaData['properties'] as Map<String, dynamic>? ?? {};
        final required =
            (schemaData['required'] as List?)?.cast<String>() ?? [];
        final fields = <ImportedField>[];
        for (var prop in properties.entries) {
          final propName = prop.key;
          final propData = prop.value as Map<String, dynamic>;
          fields.add(
            ImportedField(
              name: propName,
              type: _mapOpenAPIType(propData['type'] as String?),
              nullable: !required.contains(propName),
            ),
          );
        }
        schemas.add(
          ImportedSchema(
            name: schemaName,
            tableName: _toSnakeCase(schemaName),
            fields: fields,
            relationships: [],
            source: 'OpenAPI',
          ),
        );
      }
      return schemas;
    } catch (e) {
      return [];
    }
  }

  static String _mapOpenAPIType(String? openAPIType) {
    switch (openAPIType) {
      case 'string':
        return 'VARCHAR';
      case 'integer':
        return 'INTEGER';
      case 'number':
        return 'DECIMAL';
      case 'boolean':
        return 'BOOLEAN';
      case 'array':
        return 'JSON';
      case 'object':
        return 'JSON';
      default:
        return 'VARCHAR';
    }
  }

  static String _toSnakeCase(String str) {
    return str
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst('_', '');
  }
}

import '../models/imported_schema.dart';
import '../models/imported_field.dart';
import '../models/imported_relationship.dart';

class GraphQLSchemaParser {
  static List<ImportedSchema> parse(String graphqlSchema) {
    final schemas = <ImportedSchema>[];
    final typeRegex = RegExp(r'type\s+(\w+)\s*\{([\s\S]*?)\}');
    final matches = typeRegex.allMatches(graphqlSchema);
    for (var match in matches) {
      final typeName = match.group(1)!;
      if (['Query', 'Mutation', 'Subscription'].contains(typeName)) continue;
      final body = match.group(2)!;
      final fields = _parseFields(body);
      final relationships = _parseRelations(body);
      schemas.add(
        ImportedSchema(
          name: typeName,
          tableName: _toSnakeCase(typeName),
          fields: fields,
          relationships: relationships,
          source: 'GraphQL',
        ),
      );
    }
    return schemas;
  }

  static List<ImportedField> _parseFields(String body) {
    final fields = <ImportedField>[];
    final lines = body.split('\n').where((l) => l.trim().isNotEmpty);
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final fieldRegex = RegExp(r'(\w+)\s*:\s*(\[?[\w!]+\]?)');
      final match = fieldRegex.firstMatch(trimmed);
      if (match != null) {
        final fieldName = match.group(1)!;
        var fieldType = match.group(2)!;
        final nullable = !fieldType.contains('!');
        fieldType = fieldType
            .replaceAll('!', '')
            .replaceAll('[', '')
            .replaceAll(']', '');
        fields.add(
          ImportedField(
            name: fieldName,
            type: _mapGraphQLType(fieldType),
            nullable: nullable,
          ),
        );
      }
    }
    return fields;
  }

  static List<ImportedRelationship> _parseRelations(String body) {
    final relationships = <ImportedRelationship>[];
    final lines = body.split('\n');
    for (var line in lines) {
      final trimmed = line.trim();
      final fieldRegex = RegExp(r'(\w+)\s*:\s*(\[?)(\w+)');
      final match = fieldRegex.firstMatch(trimmed);
      if (match != null) {
        final fieldName = match.group(1)!;
        final isArray = match.group(2) == '[';
        final fieldType = match.group(3)!;
        if (fieldType.isNotEmpty &&
            fieldType[0] == fieldType[0].toUpperCase() &&
            !['String', 'Int', 'Float', 'Boolean', 'ID'].contains(fieldType)) {
          relationships.add(
            ImportedRelationship(
              name: fieldName,
              targetTable: _toSnakeCase(fieldType),
              type: isArray ? 'oneToMany' : 'manyToOne',
            ),
          );
        }
      }
    }
    return relationships;
  }

  static String _mapGraphQLType(String graphQLType) {
    switch (graphQLType) {
      case 'String':
        return 'VARCHAR';
      case 'Int':
        return 'INTEGER';
      case 'Float':
        return 'DECIMAL';
      case 'Boolean':
        return 'BOOLEAN';
      case 'ID':
        return 'UUID';
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

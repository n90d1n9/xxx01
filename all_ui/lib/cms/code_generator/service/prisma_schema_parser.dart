import '../../models/imported_schema.dart';
import '../../models/imported_field.dart';
import '../../models/imported_relationship.dart';

class PrismaSchemaParser {
  static List<ImportedSchema> parse(String prismaSchema) {
    final schemas = <ImportedSchema>[];
    final modelRegex = RegExp(r'model\s+(\w+)\s*\{([\s\S]*?)\}');
    final matches = modelRegex.allMatches(prismaSchema);
    for (var match in matches) {
      final modelName = match.group(1)!;
      final body = match.group(2)!;
      final fields = _parseFields(body);
      final relationships = _parseRelations(body);
      schemas.add(
        ImportedSchema(
          name: modelName,
          tableName: _toSnakeCase(modelName),
          fields: fields,
          relationships: relationships,
          source: 'Prisma',
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
      if (trimmed.startsWith('@') || trimmed.startsWith('//')) continue;
      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      final fieldName = parts[0];
      var fieldType = parts[1];
      final nullable = fieldType.endsWith('?');
      final unique = trimmed.contains('@unique');
      fieldType = fieldType.replaceAll('?', '').replaceAll('[]', '');
      fields.add(
        ImportedField(
          name: fieldName,
          type: _mapPrismaType(fieldType),
          nullable: nullable,
          unique: unique,
        ),
      );
    }
    return fields;
  }

  static List<ImportedRelationship> _parseRelations(String body) {
    final relationships = <ImportedRelationship>[];
    final lines = body.split('\n');
    for (var line in lines) {
      final trimmed = line.trim();
      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        final fieldName = parts[0];
        var fieldType = parts[1];
        if (fieldType.isNotEmpty &&
            fieldType[0] == fieldType[0].toUpperCase() &&
            ![
              'String',
              'Int',
              'Boolean',
              'DateTime',
            ].contains(fieldType.replaceAll('?', '').replaceAll('[]', ''))) {
          final isArray = fieldType.contains('[]');
          relationships.add(
            ImportedRelationship(
              name: fieldName,
              targetTable: _toSnakeCase(
                fieldType.replaceAll('?', '').replaceAll('[]', ''),
              ),
              type: isArray ? 'oneToMany' : 'manyToOne',
            ),
          );
        }
      }
    }
    return relationships;
  }

  static String _mapPrismaType(String prismaType) {
    switch (prismaType) {
      case 'String':
        return 'VARCHAR';
      case 'Int':
        return 'INTEGER';
      case 'BigInt':
        return 'BIGINT';
      case 'Float':
        return 'DECIMAL';
      case 'Decimal':
        return 'DECIMAL';
      case 'Boolean':
        return 'BOOLEAN';
      case 'DateTime':
        return 'TIMESTAMP';
      case 'Json':
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

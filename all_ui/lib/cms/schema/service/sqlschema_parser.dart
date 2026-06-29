import '../../models/imported_schema.dart';
import '../../models/imported_field.dart';
import '../../models/imported_relationship.dart';

class SQLSchemaParser {
  static List<ImportedSchema> parse(String sql) {
    final schemas = <ImportedSchema>[];
    final createTableRegex = RegExp(
      r'CREATE\s+TABLE\s+(\w+)\s*\(([\s\S]*?)\);',
      caseSensitive: false,
    );
    final matches = createTableRegex.allMatches(sql);
    for (var match in matches) {
      final tableName = match.group(1)!;
      final columns = match.group(2)!;
      final fields = _parseColumns(columns);
      final relationships = _parseRelationships(columns);
      schemas.add(
        ImportedSchema(
          name: _toDisplayName(tableName),
          tableName: tableName,
          fields: fields,
          relationships: relationships,
          source: 'SQL',
        ),
      );
    }
    return schemas;
  }

  static List<ImportedField> _parseColumns(String columns) {
    final fields = <ImportedField>[];
    final lines = columns.split('\n').where((l) => l.trim().isNotEmpty);
    for (var line in lines) {
      final trimmed = line.trim().replaceAll(',', '');
      if (trimmed.toUpperCase().startsWith('PRIMARY') ||
          trimmed.toUpperCase().startsWith('FOREIGN') ||
          trimmed.toUpperCase().startsWith('CONSTRAINT') ||
          trimmed.toUpperCase().startsWith('UNIQUE') ||
          trimmed.toUpperCase().startsWith('CHECK')) {
        continue;
      }
      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      final fieldName = parts[0];
      final fieldType = parts[1].toUpperCase();
      final nullable = !trimmed.toUpperCase().contains('NOT NULL');
      final unique = trimmed.toUpperCase().contains('UNIQUE');
      fields.add(
        ImportedField(
          name: fieldName,
          type: fieldType,
          nullable: nullable,
          unique: unique,
        ),
      );
    }
    return fields;
  }

  static List<ImportedRelationship> _parseRelationships(String columns) {
    final relationships = <ImportedRelationship>[];
    final lines = columns.split('\n');
    for (var line in lines) {
      if (line.toUpperCase().contains('FOREIGN KEY')) {
        final fkRegex = RegExp(
          r'FOREIGN\s+KEY\s*\((\w+)\)\s*REFERENCES\s+(\w+)',
          caseSensitive: false,
        );
        final match = fkRegex.firstMatch(line);
        if (match != null) {
          relationships.add(
            ImportedRelationship(
              name: match.group(1)!,
              targetTable: match.group(2)!,
              type: 'manyToOne',
            ),
          );
        }
      }
    }
    return relationships;
  }

  static String _toDisplayName(String tableName) {
    return tableName
        .split('_')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

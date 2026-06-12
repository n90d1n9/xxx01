import 'imported_field.dart';
import 'imported_relationship.dart';

class ImportedSchema {
  final String name;
  final String tableName;
  final List<ImportedField> fields;
  final List<ImportedRelationship> relationships;
  final String source;
  const ImportedSchema({
    required this.name,
    required this.tableName,
    required this.fields,
    required this.relationships,
    required this.source,
  });
}

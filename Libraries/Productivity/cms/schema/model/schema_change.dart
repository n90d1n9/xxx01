import 'schema_change_type.dart';

class SchemaChange {
  final SchemaChangeType type;
  final String tableName;
  final String? fieldName;
  final String description;
  const SchemaChange({
    required this.type,
    required this.tableName,
    this.fieldName,
    required this.description,
  });
}

import '../../content/model/content_type_schema.dart';

class SchemaVersion {
  final int version;
  final DateTime timestamp;
  final String description;
  final Map<String, ContentTypeSchema> schemas;
  final List<String> changes;
  const SchemaVersion({
    required this.version,
    required this.timestamp,
    required this.description,
    required this.schemas,
    required this.changes,
  });
}

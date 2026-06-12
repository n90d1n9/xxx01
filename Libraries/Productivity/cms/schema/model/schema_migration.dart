import '../../content/model/content_type_schema.dart';
import '../../migration/model/migration_status.dart';

class SchemaMigration {
  final String id;
  final String name;
  final String description;
  final DateTime timestamp;
  final int version;
  final String upSQL;
  final String downSQL;
  final MigrationStatus status;
  final ContentTypeSchema? beforeSchema;
  final ContentTypeSchema? afterSchema;
  const SchemaMigration({
    required this.id,
    required this.name,
    required this.description,
    required this.timestamp,
    required this.version,
    required this.upSQL,
    required this.downSQL,
    required this.status,
    this.beforeSchema,
    this.afterSchema,
  });
  SchemaMigration copyWith({MigrationStatus? status}) {
    return SchemaMigration(
      id: id,
      name: name,
      description: description,
      timestamp: timestamp,
      version: version,
      upSQL: upSQL,
      downSQL: downSQL,
      status: status ?? this.status,
      beforeSchema: beforeSchema,
      afterSchema: afterSchema,
    );
  }
}

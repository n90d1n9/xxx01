import '../content/model/content_type_schema.dart';
import '../schema/model/field_schema.dart';
import '../schema/model/schema_migration.dart';
import '../migration/model/migration_status.dart';
import '../schema/model/schema_change_type.dart';
import '../schema/model/schema_change.dart';

class MigrationGenerator {
  static SchemaMigration generateMigration({
    required ContentTypeSchema? beforeSchema,
    required ContentTypeSchema afterSchema,
    required int version,
  }) {
    final changes = _detectChanges(beforeSchema, afterSchema);
    final upSQL = _generateUpSQL(beforeSchema, afterSchema, changes);
    final downSQL = _generateDownSQL(beforeSchema, afterSchema, changes);
    return SchemaMigration(
      id: 'migration_${DateTime.now().millisecondsSinceEpoch}',
      name: _generateMigrationName(afterSchema, changes),
      description: _generateDescription(changes),
      timestamp: DateTime.now(),
      version: version,
      upSQL: upSQL,
      downSQL: downSQL,
      status: MigrationStatus.pending,
      beforeSchema: beforeSchema,
      afterSchema: afterSchema,
    );
  }

  static List<SchemaChange> _detectChanges(
    ContentTypeSchema? before,
    ContentTypeSchema after,
  ) {
    final changes = <SchemaChange>[];
    if (before == null) {
      changes.add(
        SchemaChange(
          type: SchemaChangeType.createTable,
          tableName: after.tableName,
          description: 'Create table ${after.tableName}',
        ),
      );
      return changes;
    }
    for (var field in after.fields) {
      final beforeField =
          before.fields.where((f) => f.name == field.name).firstOrNull;
      if (beforeField == null) {
        changes.add(
          SchemaChange(
            type: SchemaChangeType.addColumn,
            tableName: after.tableName,
            fieldName: field.name,
            description: 'Add column ${field.name}',
          ),
        );
      } else if (_isFieldModified(beforeField, field)) {
        changes.add(
          SchemaChange(
            type: SchemaChangeType.modifyColumn,
            tableName: after.tableName,
            fieldName: field.name,
            description: 'Modify column ${field.name}',
          ),
        );
      }
    }
    for (var field in before.fields) {
      final afterField =
          after.fields.where((f) => f.name == field.name).firstOrNull;
      if (afterField == null) {
        changes.add(
          SchemaChange(
            type: SchemaChangeType.dropColumn,
            tableName: after.tableName,
            fieldName: field.name,
            description: 'Drop column ${field.name}',
          ),
        );
      }
    }
    for (var field in after.fields) {
      final beforeField =
          before.fields.where((f) => f.name == field.name).firstOrNull;
      if (beforeField != null &&
          !beforeField.constraints.indexed &&
          field.constraints.indexed) {
        changes.add(
          SchemaChange(
            type: SchemaChangeType.addIndex,
            tableName: after.tableName,
            fieldName: field.name,
            description: 'Add index on ${field.name}',
          ),
        );
      }
    }
    for (var rel in after.relationships) {
      final beforeRel =
          before.relationships.where((r) => r.name == rel.name).firstOrNull;
      if (beforeRel == null) {
        changes.add(
          SchemaChange(
            type: SchemaChangeType.addForeignKey,
            tableName: after.tableName,
            fieldName: rel.name,
            description: 'Add foreign key ${rel.name}',
          ),
        );
      }
    }
    return changes;
  }

  static bool _isFieldModified(FieldSchema before, FieldSchema after) {
    return before.sqlType != after.sqlType ||
        before.constraints.nullable != after.constraints.nullable ||
        before.constraints.unique != after.constraints.unique;
  }

  static String _generateUpSQL(
    ContentTypeSchema? before,
    ContentTypeSchema after,
    List<SchemaChange> changes,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('-- Migration: ${after.name}');
    buffer.writeln('-- Generated: ${DateTime.now()}');
    buffer.writeln();
    if (before == null) {
      buffer.write(after.toCreateTableSQL());
      return buffer.toString();
    }
    for (var change in changes) {
      switch (change.type) {
        case SchemaChangeType.addColumn:
          final field = after.fields.firstWhere(
            (f) => f.name == change.fieldName,
          );
          buffer.writeln(
            'ALTER TABLE ${change.tableName} ADD COLUMN ${field.toSQLColumn()};',
          );
          break;
        case SchemaChangeType.dropColumn:
          buffer.writeln(
            'ALTER TABLE ${change.tableName} DROP COLUMN ${change.fieldName};',
          );
          break;
        case SchemaChangeType.modifyColumn:
          final field = after.fields.firstWhere(
            (f) => f.name == change.fieldName,
          );
          buffer.writeln(
            'ALTER TABLE ${change.tableName} ALTER COLUMN ${field.name} TYPE ${field.sqlType.name};',
          );
          break;
        case SchemaChangeType.addIndex:
          buffer.writeln(
            'CREATE INDEX idx_${change.tableName}_${change.fieldName} ON ${change.tableName}(${change.fieldName});',
          );
          break;
        case SchemaChangeType.addForeignKey:
          final rel = after.relationships.firstWhere(
            (r) => r.name == change.fieldName,
          );
          buffer.writeln(
            'ALTER TABLE ${change.tableName} ADD CONSTRAINT fk_${change.tableName}_${change.fieldName}',
          );
          buffer.writeln(
            '  FOREIGN KEY (${change.fieldName}_id) REFERENCES ${rel.targetSchemaId}(id);',
          );
          break;
        default:
          break;
      }
    }
    return buffer.toString();
  }

  static String _generateDownSQL(
    ContentTypeSchema? before,
    ContentTypeSchema after,
    List<SchemaChange> changes,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('-- Rollback Migration: ${after.name}');
    buffer.writeln();
    if (before == null) {
      buffer.writeln('DROP TABLE IF EXISTS ${after.tableName} CASCADE;');
      return buffer.toString();
    }
    for (var change in changes.reversed) {
      switch (change.type) {
        case SchemaChangeType.addColumn:
          buffer.writeln(
            'ALTER TABLE ${change.tableName} DROP COLUMN ${change.fieldName};',
          );
          break;
        case SchemaChangeType.dropColumn:
          final field = before.fields.firstWhere(
            (f) => f.name == change.fieldName,
          );
          buffer.writeln(
            'ALTER TABLE ${change.tableName} ADD COLUMN ${field.toSQLColumn()};',
          );
          break;
        case SchemaChangeType.addIndex:
          buffer.writeln(
            'DROP INDEX IF EXISTS idx_${change.tableName}_${change.fieldName};',
          );
          break;
        default:
          break;
      }
    }
    return buffer.toString();
  }

  static String _generateMigrationName(
    ContentTypeSchema schema,
    List<SchemaChange> changes,
  ) {
    if (changes.isEmpty) return 'no_changes_${schema.tableName}';
    if (changes.length == 1)
      return '${changes.first.type.name}_${schema.tableName}';
    return 'update_${schema.tableName}_${changes.length}_changes';
  }

  static String _generateDescription(List<SchemaChange> changes) {
    if (changes.isEmpty) return 'No changes detected';
    return changes.map((c) => c.description).join(', ');
  }
}

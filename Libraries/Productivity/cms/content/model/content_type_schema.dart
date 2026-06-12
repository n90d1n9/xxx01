import '../../models/relation_type.dart';
import '../../models/sql_type.dart';
import '../../schema/model/schema_health_report.dart';
import '../../schema/model/schema_issue.dart';
import '../../schema/model/schema_recommendation.dart';
import '../../schema/model/schema_relationship.dart';
import 'content_type_settings.dart';
import '../../schema/model/field_schema.dart';

/// Content Type Schema - Represents a database table
class ContentTypeSchema {
  final String id;
  final String name;
  final String tableName;
  final String? description;
  final String icon;
  final List<FieldSchema> fields;
  final List<SchemaRelationship> relationships;
  final ContentTypeSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final List<String>? tags; // For categorization
  final Map<String, dynamic>? metadata;

  const ContentTypeSchema({
    required this.id,
    required this.name,
    required this.tableName,
    this.description,
    required this.icon,
    required this.fields,
    this.relationships = const [],
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.tags,
    this.metadata,
  });

  String toCreateTableSQL() {
    final buffer = StringBuffer();
    buffer.writeln('CREATE TABLE $tableName (');
    buffer.writeln('  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),');

    for (var field in fields) {
      if (!field.isSystemField) {
        buffer.writeln('  ${field.toSQLColumn()},');
      }
    }

    // Add foreign key relationships
    for (var rel in relationships.where(
      (r) => r.type == RelationType.manyToOne,
    )) {
      final fkField = '${rel.name}_id';
      buffer.writeln('  $fkField UUID${rel.required ? ' NOT NULL' : ''},');
    }

    buffer.writeln('  created_at TIMESTAMP DEFAULT NOW(),');
    buffer.writeln('  updated_at TIMESTAMP DEFAULT NOW(),');
    buffer.writeln('  created_by UUID,');
    buffer.writeln('  updated_by UUID,');
    buffer.writeln('  published BOOLEAN DEFAULT FALSE,');
    buffer.writeln('  published_at TIMESTAMP');
    buffer.writeln(');');

    // Add indexes
    for (var field in fields.where((f) => f.constraints.indexed)) {
      buffer.writeln(
        'CREATE INDEX idx_${tableName}_${field.name} ON $tableName(${field.name});',
      );
    }

    // Add foreign key constraints
    for (var rel in relationships.where(
      (r) => r.type == RelationType.manyToOne,
    )) {
      final fkField = '${rel.name}_id';
      buffer.writeln(
        'ALTER TABLE $tableName ADD CONSTRAINT fk_${tableName}_${rel.name}',
      );
      buffer.writeln(
        '  FOREIGN KEY ($fkField) REFERENCES ${rel.targetSchemaId}(id)',
      );
      buffer.writeln('  ON DELETE ${rel.onDelete} ON UPDATE ${rel.onUpdate};');
    }

    // Add junction tables for many-to-many
    for (var rel in relationships.where(
      (r) => r.type == RelationType.manyToMany,
    )) {
      final junctionTable =
          rel.junctionTable ?? '${tableName}_${rel.targetSchemaId}';
      buffer.writeln();
      buffer.writeln('CREATE TABLE $junctionTable (');
      buffer.writeln('  ${tableName}_id UUID NOT NULL,');
      buffer.writeln('  ${rel.targetSchemaId}_id UUID NOT NULL,');
      buffer.writeln('  created_at TIMESTAMP DEFAULT NOW(),');
      buffer.writeln(
        '  PRIMARY KEY (${tableName}_id, ${rel.targetSchemaId}_id),',
      );
      buffer.writeln(
        '  FOREIGN KEY (${tableName}_id) REFERENCES $tableName(id) ON DELETE CASCADE,',
      );
      buffer.writeln(
        '  FOREIGN KEY (${rel.targetSchemaId}_id) REFERENCES ${rel.targetSchemaId}(id) ON DELETE CASCADE',
      );
      buffer.writeln(');');
    }

    return buffer.toString();
  }

  /// Analyze schema health
  SchemaHealthReport analyzeHealth() {
    final issues = <SchemaIssue>[];
    final recommendations = <SchemaRecommendation>[];

    // Check for missing indexes on foreign keys
    for (var rel in relationships.where(
      (r) => r.type == RelationType.manyToOne,
    )) {
      final fkField = '${rel.name}_id';
      recommendations.add(
        SchemaRecommendation(
          title: 'Add index on $fkField',
          description:
              'Foreign key columns benefit from indexes for join performance',
          benefit: 'Improved query performance by 10-100x',
          autoFixable: true,
        ),
      );
    }

    // Check for text fields without length limits
    for (var field in fields.where((f) => f.sqlType == SQLType.varchar)) {
      if (field.widgetOptions?.maxLength == null ||
          (field.widgetOptions?.maxLength ?? 0) > 500) {
        issues.add(
          SchemaIssue(
            severity: 'warning',
            message:
                'Field "${field.label}" has no length limit or very high limit',
            fieldId: field.id,
            fix: 'Consider adding maxLength validation',
          ),
        );
      }
    }

    // Check for unique constraints without indexes
    for (var field in fields.where(
      (f) => f.constraints.unique && !f.constraints.indexed,
    )) {
      recommendations.add(
        SchemaRecommendation(
          title: 'Add index to unique field "${field.label}"',
          description:
              'Unique constraints are enforced faster with explicit indexes',
          benefit: 'Better constraint checking performance',
          autoFixable: true,
        ),
      );
    }

    // Check for missing required validations
    for (var field in fields.where(
      (f) => !f.constraints.nullable && f.validation == null,
    )) {
      issues.add(
        SchemaIssue(
          severity: 'info',
          message: 'Required field "${field.label}" has no validation rules',
          fieldId: field.id,
          fix: 'Add validation rules for better user experience',
        ),
      );
    }

    // Calculate health score
    final errorCount = issues.where((i) => i.severity == 'error').length;
    final warningCount = issues.where((i) => i.severity == 'warning').length;
    final healthScore = 100 - (errorCount * 20) - (warningCount * 5);

    return SchemaHealthReport(
      issues: issues,
      recommendations: recommendations,
      healthScore: healthScore.clamp(0, 100).toDouble(),
    );
  }

  /// Generate Quarkus Entity (Panache)

  String toQuarkusEntity() {
    final className = _toPascalCase(tableName);
    final buffer = StringBuffer();

    buffer.writeln('package com.example.entity;');
    buffer.writeln();
    buffer.writeln(
      'import io.quarkus.hibernate.orm.panache.PanacheEntityBase;',
    );
    buffer.writeln('import javax.persistence.*;');
    buffer.writeln('import java.time.*;');
    buffer.writeln('import java.util.UUID;');
    if (relationships.isNotEmpty) {
      buffer.writeln('import java.util.List;');
      buffer.writeln('import java.util.Set;');
    }
    buffer.writeln();
    buffer.writeln('@Entity');
    buffer.writeln('@Table(name = "$tableName")');
    buffer.writeln('public class $className extends PanacheEntityBase {');
    buffer.writeln();
    buffer.writeln('    @Id');
    buffer.writeln('    @GeneratedValue');
    buffer.writeln('    public UUID id;');
    buffer.writeln();

    for (var field in fields) {
      if (field.isComputed) {
        buffer.writeln('    @Formula("${field.computeExpression}")');
      }
      if (field.constraints.unique) {
        buffer.writeln(
          '    @Column(unique = true, nullable = ${field.constraints.nullable})',
        );
      } else if (!field.constraints.nullable) {
        buffer.writeln('    @Column(nullable = false)');
      }
      buffer.writeln(
        '    public ${field.toJavaType()} ${_toCamelCase(field.name)};',
      );
      buffer.writeln();
    }

    // Add relationships
    for (var rel in relationships) {
      switch (rel.type) {
        case RelationType.oneToOne:
          buffer.writeln('    @OneToOne');
          buffer.writeln(
            '    public ${_toPascalCase(rel.targetSchemaId)} ${_toCamelCase(rel.name)};',
          );
          break;
        case RelationType.oneToMany:
          buffer.writeln(
            '    @OneToMany(mappedBy = "${_toCamelCase(tableName)}")',
          );
          buffer.writeln(
            '    public List<${_toPascalCase(rel.targetSchemaId)}> ${_toCamelCase(rel.name)};',
          );
          break;
        case RelationType.manyToOne:
          buffer.writeln('    @ManyToOne');
          buffer.writeln('    @JoinColumn(name = "${rel.name}_id")');
          buffer.writeln(
            '    public ${_toPascalCase(rel.targetSchemaId)} ${_toCamelCase(rel.name)};',
          );
          break;
        case RelationType.manyToMany:
          buffer.writeln('    @ManyToMany');
          buffer.writeln(
            '    @JoinTable(name = "${rel.junctionTable ?? '${tableName}_${rel.targetSchemaId}'}")',
          );
          buffer.writeln(
            '    public Set<${_toPascalCase(rel.targetSchemaId)}> ${_toCamelCase(rel.name)};',
          );
          break;
      }
      buffer.writeln();
    }

    buffer.writeln('    @Column(name = "created_at")');
    buffer.writeln('    public LocalDateTime createdAt;');
    buffer.writeln();
    buffer.writeln('    @Column(name = "updated_at")');
    buffer.writeln('    public LocalDateTime updatedAt;');
    buffer.writeln();
    buffer.writeln('    public Boolean published = false;');
    buffer.writeln();
    buffer.writeln('    @Column(name = "published_at")');
    buffer.writeln('    public LocalDateTime publishedAt;');
    buffer.writeln('}');

    return buffer.toString();
  }

  String toQuarkusResource() {
    final className = _toPascalCase(tableName);
    final buffer = StringBuffer();

    buffer.writeln('package com.example.resource;');
    buffer.writeln();
    buffer.writeln('import com.example.entity.$className;');
    buffer.writeln('import javax.transaction.Transactional;');
    buffer.writeln('import javax.ws.rs.*;');
    buffer.writeln('import javax.ws.rs.core.MediaType;');
    buffer.writeln('import javax.ws.rs.core.Response;');
    buffer.writeln('import java.time.LocalDateTime;');
    buffer.writeln('import java.util.List;');
    buffer.writeln('import java.util.UUID;');
    buffer.writeln();
    buffer.writeln('@Path("/$tableName")');
    buffer.writeln('@Produces(MediaType.APPLICATION_JSON)');
    buffer.writeln('@Consumes(MediaType.APPLICATION_JSON)');
    buffer.writeln('public class ${className}Resource {');
    buffer.writeln();
    buffer.writeln('    @GET');
    buffer.writeln('    public List<$className> list(');
    buffer.writeln('        @QueryParam("page") @DefaultValue("0") int page,');
    buffer.writeln(
      '        @QueryParam("size") @DefaultValue("20") int size) {',
    );
    buffer.writeln(
      '        return $className.findAll().page(page, size).list();',
    );
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    @GET');
    buffer.writeln('    @Path("/{id}")');
    buffer.writeln('    public $className get(@PathParam("id") String id) {');
    buffer.writeln(
      '        $className entity = $className.findById(UUID.fromString(id));',
    );
    buffer.writeln(
      '        if (entity == null) throw new NotFoundException();',
    );
    buffer.writeln('        return entity;');
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    @POST');
    buffer.writeln('    @Transactional');
    buffer.writeln('    public Response create($className entity) {');
    buffer.writeln('        entity.createdAt = LocalDateTime.now();');
    buffer.writeln('        entity.updatedAt = LocalDateTime.now();');
    buffer.writeln('        entity.persist();');
    buffer.writeln(
      '        return Response.status(201).entity(entity).build();',
    );
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    @PUT');
    buffer.writeln('    @Path("/{id}")');
    buffer.writeln('    @Transactional');
    buffer.writeln(
      '    public $className update(@PathParam("id") String id, $className updated) {',
    );
    buffer.writeln(
      '        $className entity = $className.findById(UUID.fromString(id));',
    );
    buffer.writeln(
      '        if (entity == null) throw new NotFoundException();',
    );

    for (var field in fields) {
      final camelName = _toCamelCase(field.name);
      buffer.writeln('        entity.$camelName = updated.$camelName;');
    }

    buffer.writeln('        entity.updatedAt = LocalDateTime.now();');
    buffer.writeln('        return entity;');
    buffer.writeln('    }');
    buffer.writeln();
    buffer.writeln('    @DELETE');
    buffer.writeln('    @Path("/{id}")');
    buffer.writeln('    @Transactional');
    buffer.writeln('    public Response delete(@PathParam("id") String id) {');
    buffer.writeln(
      '        boolean deleted = $className.deleteById(UUID.fromString(id));',
    );
    buffer.writeln(
      '        return deleted ? Response.noContent().build() : Response.status(404).build();',
    );
    buffer.writeln('    }');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _toPascalCase(String str) {
    return str
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join('');
  }

  String _toCamelCase(String str) {
    final pascal = _toPascalCase(str);
    return pascal.isEmpty ? '' : pascal[0].toLowerCase() + pascal.substring(1);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tableName': tableName,
    'description': description,
    'icon': icon,
    'fields': fields.map((f) => f.toJson()).toList(),
    'settings': settings.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'version': version,
    'metadata': metadata,
  };

  factory ContentTypeSchema.fromJson(Map<String, dynamic> json) =>
      ContentTypeSchema(
        id: json['id'],
        name: json['name'],
        tableName: json['tableName'],
        description: json['description'],
        icon: json['icon'],
        fields:
            (json['fields'] as List)
                .map((f) => FieldSchema.fromJson(f))
                .toList(),
        settings: ContentTypeSettings.fromJson(json['settings']),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        version: json['version'] ?? 1,
        metadata: json['metadata'],
      );

  ContentTypeSchema copyWith({
    String? id,
    String? name,
    String? tableName,
    String? description,
    String? icon,
    List<FieldSchema>? fields,
    ContentTypeSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    Map<String, dynamic>? metadata,
  }) {
    return ContentTypeSchema(
      id: id ?? this.id,
      name: name ?? this.name,
      tableName: tableName ?? this.tableName,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      fields: fields ?? this.fields,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
    );
  }
}

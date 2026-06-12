import '../../models/relation_type.dart';

class SchemaRelationship {
  final String id;
  final String name;
  final RelationType type;
  final String sourceSchemaId;
  final String targetSchemaId;
  final String? junctionTable;
  final String? onDelete;
  final String? onUpdate;
  final bool required;
  const SchemaRelationship({
    required this.id,
    required this.name,
    required this.type,
    required this.sourceSchemaId,
    required this.targetSchemaId,
    this.junctionTable,
    this.onDelete = 'CASCADE',
    this.onUpdate = 'CASCADE',
    this.required = false,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'sourceSchemaId': sourceSchemaId,
    'targetSchemaId': targetSchemaId,
    'junctionTable': junctionTable,
    'onDelete': onDelete,
    'onUpdate': onUpdate,
    'required': required,
  };
}

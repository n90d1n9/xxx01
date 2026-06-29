import '../../models/relation_type.dart';

class DiagramConnection {
  final String fromSchemaId;
  final String toSchemaId;
  final String relationshipId;
  final RelationType type;
  const DiagramConnection({
    required this.fromSchemaId,
    required this.toSchemaId,
    required this.relationshipId,
    required this.type,
  });
}

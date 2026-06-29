class MahramRelationship {
  final String person1Id;
  final String person2Id;
  final String relationshipType;
  final String description;
  final String ruling;
  final bool isForbidden;
  final String severity; // 'low', 'medium', 'high'

  MahramRelationship({
    required this.person1Id,
    required this.person2Id,
    required this.relationshipType,
    required this.description,
    required this.ruling,
    required this.isForbidden,
    this.severity = 'medium',
  });
}

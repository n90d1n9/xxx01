class ImportedRelationship {
  final String name;
  final String targetTable;
  final String type;
  const ImportedRelationship({
    required this.name,
    required this.targetTable,
    required this.type,
  });
}

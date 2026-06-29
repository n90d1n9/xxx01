class WorkflowMetadata {
  final String id;
  final String name;
  final String description;
  final String version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  WorkflowMetadata({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });
}

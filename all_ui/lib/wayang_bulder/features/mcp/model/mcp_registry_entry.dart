class MCPRegistryEntry {
  final String id;
  final String name;
  final String description;
  final MCPRegistryType type; // SERVER or TOOL
  final List<String> itemIds; // Server or Tool IDs
  final String author;
  final int itemCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPublic;
  final Map<String, dynamic>? metadata;

  MCPRegistryEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.itemIds,
    required this.author,
    required this.createdAt,
    this.updatedAt,
    this.isPublic = true,
    this.metadata,
  }) : itemCount = itemIds.length;
}

enum MCPRegistryType { server, tool }

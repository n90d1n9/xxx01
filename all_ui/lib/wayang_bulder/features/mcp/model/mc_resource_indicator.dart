class MCPResourceIndicator {
  final String uri;
  final String scope;
  final DateTime? expiresAt;
  final List<String> allowedOperations;
  final String? mimeType;
  final int? size;
  final DateTime createdAt;

  MCPResourceIndicator({
    required this.uri,
    required this.scope,
    this.expiresAt,
    this.allowedOperations = const ['read'],
    this.mimeType,
    this.size,
    required this.createdAt,
  });
}
